import React, { useCallback, useMemo } from 'react'
import ReactFlow, {
  Node,
  Edge,
  Controls,
  Background,
  MiniMap,
  useNodesState,
  useEdgesState,
  addEdge,
  Connection,
  ConnectionMode,
  Panel,
} from 'reactflow'
import 'reactflow/dist/style.css'
import { Box, Paper, Typography } from '@mui/material'
import { AzureResourceNode } from './AzureResourceNode'

interface VisualCanvasProps {
  nodes: Node[]
  edges: Edge[]
  onNodesChange: (nodes: Node[]) => void
  onEdgesChange: (edges: Edge[]) => void
  onNodeClick?: (event: React.MouseEvent, node: Node) => void
  onPaneClick?: (event: React.MouseEvent) => void
  readOnly?: boolean
}

const nodeTypes = {
  'azure-vnet': AzureResourceNode,
  'azure-subnet': AzureResourceNode,
  'azure-nsg': AzureResourceNode,
  'azure-vm': AzureResourceNode,
  'azure-storage': AzureResourceNode,
}

export const VisualCanvas: React.FC<VisualCanvasProps> = ({
  nodes: initialNodes,
  edges: initialEdges,
  onNodesChange: handleNodesChange,
  onEdgesChange: handleEdgesChange,
  onNodeClick,
  onPaneClick,
  readOnly = false,
}) => {
  const [nodes, setNodes, onNodesChangeInternal] = useNodesState(initialNodes)
  const [edges, setEdges, onEdgesChangeInternal] = useEdgesState(initialEdges)

  // Sync with parent
  React.useEffect(() => {
    setNodes(initialNodes)
  }, [initialNodes, setNodes])

  React.useEffect(() => {
    setEdges(initialEdges)
  }, [initialEdges, setEdges])

  const onConnect = useCallback(
    (params: Connection) => {
      if (readOnly) return

      const newEdge = {
        ...params,
        id: `e${params.source}-${params.target}`,
        type: 'smoothstep',
        animated: true,
      }

      setEdges((eds) => addEdge(newEdge, eds))

      // Notify parent
      handleEdgesChange([...edges, newEdge as Edge])
    },
    [readOnly, setEdges, edges, handleEdgesChange]
  )

  const handleNodesChangeWrapper = useCallback(
    (changes: any) => {
      onNodesChangeInternal(changes)

      // Notify parent with updated nodes
      setTimeout(() => {
        setNodes((nds) => {
          handleNodesChange(nds)
          return nds
        })
      }, 0)
    },
    [onNodesChangeInternal, handleNodesChange, setNodes]
  )

  const handleEdgesChangeWrapper = useCallback(
    (changes: any) => {
      onEdgesChangeInternal(changes)

      // Notify parent with updated edges
      setTimeout(() => {
        setEdges((eds) => {
          handleEdgesChange(eds)
          return eds
        })
      }, 0)
    },
    [onEdgesChangeInternal, handleEdgesChange, setEdges]
  )

  const proOptions = useMemo(
    () => ({
      hideAttribution: true,
    }),
    []
  )

  return (
    <Box sx={{ width: '100%', height: '100%', position: 'relative' }}>
      <ReactFlow
        nodes={nodes}
        edges={edges}
        onNodesChange={handleNodesChangeWrapper}
        onEdgesChange={handleEdgesChangeWrapper}
        onConnect={onConnect}
        onNodeClick={onNodeClick}
        onPaneClick={onPaneClick}
        nodeTypes={nodeTypes}
        connectionMode={ConnectionMode.Loose}
        fitView
        proOptions={proOptions}
        deleteKeyCode={readOnly ? null : 'Delete'}
        multiSelectionKeyCode="Shift"
      >
        <Background />
        <Controls />
        <MiniMap
          nodeColor={(node) => {
            const colorMap: Record<string, string> = {
              'azure-vnet': '#0078d4',
              'azure-subnet': '#50a0e6',
              'azure-nsg': '#107c10',
              'azure-vm': '#8661c5',
              'azure-storage': '#ff8c00',
            }
            return colorMap[node.type || ''] || '#gray'
          }}
          maskColor="rgba(0, 0, 0, 0.1)"
        />

        {nodes.length === 0 && (
          <Panel position="top-center">
            <Paper sx={{ p: 2, mt: 2 }}>
              <Typography variant="body2" color="text.secondary">
                Drag components from the palette to start designing your infrastructure
              </Typography>
            </Paper>
          </Panel>
        )}
      </ReactFlow>
    </Box>
  )
}
