import React, { useState, useCallback, useEffect, useRef } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import {
  Box,
  Button,
  IconButton,
  Toolbar,
  Typography,
  Drawer,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Tabs,
  Tab,
  Alert,
  CircularProgress,
} from '@mui/material'
import {
  Save as SaveIcon,
  Code as CodeIcon,
  PlayArrow as GenerateIcon,
  ArrowBack as BackIcon,
  CheckCircle as ValidateIcon,
} from '@mui/icons-material'
import { Node, Edge } from 'reactflow'
import { useQuery, useMutation, useQueryClient } from 'react-query'
import Editor from '@monaco-editor/react'

import { VisualCanvas } from '../components/designer/VisualCanvas'
import { ComponentPalette } from '../components/designer/ComponentPalette'
import { ConfigurationPanel } from '../components/designer/ConfigurationPanel'
import { designerApi, ComponentTemplate } from '../api/designer'

const Designer: React.FC = () => {
  const { id } = useParams<{ id: string }>()
  const navigate = useNavigate()
  const queryClient = useQueryClient()

  const [nodes, setNodes] = useState<Node[]>([])
  const [edges, setEdges] = useState<Edge[]>([])
  const [selectedNode, setSelectedNode] = useState<Node | null>(null)
  const [showCodeDialog, setShowCodeDialog] = useState(false)
  const [codeTab, setCodeTab] = useState(0)
  const [generatedFiles, setGeneratedFiles] = useState<Record<string, string>>({})
  const [validationErrors, setValidationErrors] = useState<string[]>([])

  const canvasRef = useRef<HTMLDivElement>(null)

  // Load project
  const { data: project, isLoading } = useQuery(
    ['project', id],
    () => designerApi.getProject(parseInt(id!)),
    { enabled: !!id }
  )

  // Load components
  const { data: components = [] } = useQuery<ComponentTemplate[]>(
    'components',
    () => designerApi.listComponents()
  )

  // Initialize nodes/edges from project
  useEffect(() => {
    if (project?.diagram) {
      setNodes(project.diagram.nodes || [])
      setEdges(project.diagram.edges || [])
    }
  }, [project])

  // Save project mutation
  const saveMutation = useMutation(
    () =>
      designerApi.updateProject(parseInt(id!), {
        diagram: { nodes, edges },
      }),
    {
      onSuccess: () => {
        queryClient.invalidateQueries(['project', id])
      },
    }
  )

  // Generate Terraform mutation
  const generateMutation = useMutation(
    () => designerApi.generateTerraform(parseInt(id!), true),
    {
      onSuccess: (data) => {
        if (data.validation_errors.length > 0) {
          setValidationErrors(data.validation_errors)
        } else {
          setGeneratedFiles(data.files)
          setShowCodeDialog(true)
          setValidationErrors([])
        }
        queryClient.invalidateQueries(['project', id])
      },
    }
  )

  // Validate mutation
  const validateMutation = useMutation(
    () => designerApi.validateProject(parseInt(id!))
  )

  const handleSave = () => {
    saveMutation.mutate()
  }

  const handleGenerate = () => {
    generateMutation.mutate()
  }

  const handleValidate = async () => {
    const result = await validateMutation.mutateAsync()
    if (result.valid) {
      alert('Configuration is valid!')
    } else {
      setValidationErrors(result.errors.map((e) => e.message))
    }
  }

  const handleDragStart = useCallback(
    (event: React.DragEvent, component: ComponentTemplate) => {
      event.dataTransfer.setData('application/reactflow', component.type)
      event.dataTransfer.setData('componentData', JSON.stringify(component))
      event.dataTransfer.effectAllowed = 'move'
    },
    []
  )

  const handleDragOver = useCallback((event: React.DragEvent) => {
    event.preventDefault()
    event.dataTransfer.dropEffect = 'move'
  }, [])

  const handleDrop = useCallback(
    (event: React.DragEvent) => {
      event.preventDefault()

      const type = event.dataTransfer.getData('application/reactflow')
      const componentDataStr = event.dataTransfer.getData('componentData')

      if (!type || !componentDataStr || !canvasRef.current) return

      const component: ComponentTemplate = JSON.parse(componentDataStr)
      const canvasBounds = canvasRef.current.getBoundingClientRect()

      const position = {
        x: event.clientX - canvasBounds.left - 100,
        y: event.clientY - canvasBounds.top - 50,
      }

      const newNode: Node = {
        id: `${type}-${Date.now()}`,
        type,
        position,
        data: {
          ...component.default_config,
          name: `${component.name} ${nodes.length + 1}`,
        },
      }

      setNodes((nds) => [...nds, newNode])
    },
    [nodes]
  )

  const handleNodeClick = useCallback(
    (event: React.MouseEvent, node: Node) => {
      setSelectedNode(node)
    },
    []
  )

  const handlePaneClick = useCallback(() => {
    setSelectedNode(null)
  }, [])

  const handleUpdateNode = useCallback(
    (nodeId: string, data: Record<string, any>) => {
      setNodes((nds) =>
        nds.map((node) => (node.id === nodeId ? { ...node, data } : node))
      )
      setSelectedNode(null)
    },
    []
  )

  if (isLoading) {
    return (
      <Box display="flex" justifyContent="center" alignItems="center" minHeight="80vh">
        <CircularProgress />
      </Box>
    )
  }

  const fileNames = Object.keys(generatedFiles)

  return (
    <Box sx={{ display: 'flex', flexDirection: 'column', height: 'calc(100vh - 64px)' }}>
      {/* Toolbar */}
      <Toolbar
        sx={{
          borderBottom: 1,
          borderColor: 'divider',
          backgroundColor: 'background.paper',
          gap: 1,
        }}
      >
        <IconButton onClick={() => navigate('/designer/projects')}>
          <BackIcon />
        </IconButton>
        <Typography variant="h6" sx={{ flexGrow: 1 }}>
          {project?.name || 'Visual Designer'}
        </Typography>

        <Button
          startIcon={<ValidateIcon />}
          onClick={handleValidate}
          disabled={validateMutation.isLoading}
        >
          Validate
        </Button>

        <Button
          startIcon={<SaveIcon />}
          onClick={handleSave}
          disabled={saveMutation.isLoading}
          variant="outlined"
        >
          {saveMutation.isLoading ? 'Saving...' : 'Save'}
        </Button>

        <Button
          startIcon={<GenerateIcon />}
          onClick={handleGenerate}
          disabled={generateMutation.isLoading || nodes.length === 0}
          variant="contained"
        >
          {generateMutation.isLoading ? 'Generating...' : 'Generate Terraform'}
        </Button>

        <Button startIcon={<CodeIcon />} onClick={() => setShowCodeDialog(true)}>
          View Code
        </Button>
      </Toolbar>

      {/* Validation Errors */}
      {validationErrors.length > 0 && (
        <Box p={2}>
          <Alert severity="error" onClose={() => setValidationErrors([])}>
            <Typography variant="subtitle2" gutterBottom>
              Validation Errors:
            </Typography>
            <ul style={{ margin: 0, paddingLeft: 20 }}>
              {validationErrors.map((error, i) => (
                <li key={i}>{error}</li>
              ))}
            </ul>
          </Alert>
        </Box>
      )}

      {/* Main Content */}
      <Box display="flex" flexGrow={1} overflow="hidden">
        {/* Component Palette */}
        <Box width={280} sx={{ borderRight: 1, borderColor: 'divider' }}>
          <ComponentPalette components={components} onDragStart={handleDragStart} />
        </Box>

        {/* Canvas */}
        <Box
          ref={canvasRef}
          flexGrow={1}
          onDragOver={handleDragOver}
          onDrop={handleDrop}
        >
          <VisualCanvas
            nodes={nodes}
            edges={edges}
            onNodesChange={setNodes}
            onEdgesChange={setEdges}
            onNodeClick={handleNodeClick}
            onPaneClick={handlePaneClick}
          />
        </Box>

        {/* Configuration Panel */}
        <Drawer
          anchor="right"
          open={!!selectedNode}
          onClose={() => setSelectedNode(null)}
          variant="persistent"
          sx={{
            width: selectedNode ? 350 : 0,
            flexShrink: 0,
            '& .MuiDrawer-paper': {
              width: 350,
              position: 'relative',
            },
          }}
        >
          <ConfigurationPanel
            selectedNode={selectedNode}
            onClose={() => setSelectedNode(null)}
            onUpdate={handleUpdateNode}
          />
        </Drawer>
      </Box>

      {/* Code Dialog */}
      <Dialog
        open={showCodeDialog}
        onClose={() => setShowCodeDialog(false)}
        maxWidth="lg"
        fullWidth
      >
        <DialogTitle>
          Generated Terraform Code
          <Typography variant="caption" display="block" color="text.secondary">
            {fileNames.length} files generated
          </Typography>
        </DialogTitle>
        <DialogContent>
          <Box borderBottom={1} borderColor="divider">
            <Tabs value={codeTab} onChange={(_, v) => setCodeTab(v)} variant="scrollable">
              {fileNames.map((fileName, i) => (
                <Tab key={fileName} label={fileName} />
              ))}
            </Tabs>
          </Box>
          <Box height={500} mt={2}>
            {fileNames.map((fileName, i) => (
              <Box key={fileName} hidden={codeTab !== i} height="100%">
                <Editor
                  height="100%"
                  defaultLanguage={
                    fileName.endsWith('.tf')
                      ? 'hcl'
                      : fileName.endsWith('.md')
                      ? 'markdown'
                      : 'plaintext'
                  }
                  value={generatedFiles[fileName]}
                  theme="vs-light"
                  options={{
                    readOnly: true,
                    minimap: { enabled: false },
                    fontSize: 12,
                  }}
                />
              </Box>
            ))}
          </Box>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setShowCodeDialog(false)}>Close</Button>
          <Button variant="contained">Download</Button>
        </DialogActions>
      </Dialog>
    </Box>
  )
}

export default Designer
