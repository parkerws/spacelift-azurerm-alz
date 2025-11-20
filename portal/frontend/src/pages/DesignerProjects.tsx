import React, { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import {
  Box,
  Typography,
  Button,
  Card,
  CardContent,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Chip,
  IconButton,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
} from '@mui/material'
import {
  Add as AddIcon,
  Edit as EditIcon,
  Delete as DeleteIcon,
  ContentCopy as CopyIcon,
} from '@mui/icons-material'
import { useQuery, useMutation, useQueryClient } from 'react-query'
import { designerApi, CreateProjectRequest } from '../api/designer'

const DesignerProjects: React.FC = () => {
  const navigate = useNavigate()
  const queryClient = useQueryClient()
  const [createDialogOpen, setCreateDialogOpen] = useState(false)
  const [newProject, setNewProject] = useState<CreateProjectRequest>({
    name: '',
    description: '',
    environment: 'development',
    deployment_platform: 'spacelift',
  })

  const { data: projects, isLoading } = useQuery('designer-projects', () =>
    designerApi.listProjects()
  )

  const createMutation = useMutation(designerApi.createProject, {
    onSuccess: (data) => {
      queryClient.invalidateQueries('designer-projects')
      setCreateDialogOpen(false)
      navigate(`/designer/${data.id}`)
    },
  })

  const deleteMutation = useMutation(designerApi.deleteProject, {
    onSuccess: () => {
      queryClient.invalidateQueries('designer-projects')
    },
  })

  const handleCreate = () => {
    createMutation.mutate(newProject)
  }

  const handleDelete = (id: number, name: string) => {
    if (confirm(`Delete project "${name}"?`)) {
      deleteMutation.mutate(id)
    }
  }

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'generated':
        return 'success'
      case 'generating':
        return 'info'
      case 'failed':
        return 'error'
      case 'deployed':
        return 'success'
      default:
        return 'default'
    }
  }

  return (
    <Box>
      <Box display="flex" justifyContent="space-between" alignItems="center" mb={3}>
        <Typography variant="h4">Visual IaC Designer</Typography>
        <Button
          variant="contained"
          startIcon={<AddIcon />}
          onClick={() => setCreateDialogOpen(true)}
        >
          New Project
        </Button>
      </Box>

      <Card>
        <CardContent>
          {isLoading ? (
            <Typography>Loading...</Typography>
          ) : projects?.items?.length === 0 ? (
            <Box textAlign="center" py={4}>
              <Typography color="text.secondary" paragraph>
                No projects yet. Create your first visual infrastructure design!
              </Typography>
              <Button
                variant="contained"
                startIcon={<AddIcon />}
                onClick={() => setCreateDialogOpen(true)}
              >
                Create Project
              </Button>
            </Box>
          ) : (
            <TableContainer>
              <Table>
                <TableHead>
                  <TableRow>
                    <TableCell>Name</TableCell>
                    <TableCell>Description</TableCell>
                    <TableCell>Environment</TableCell>
                    <TableCell>Platform</TableCell>
                    <TableCell>Status</TableCell>
                    <TableCell>Components</TableCell>
                    <TableCell>Created</TableCell>
                    <TableCell align="right">Actions</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {projects?.items?.map((project: any) => (
                    <TableRow key={project.id} hover>
                      <TableCell>
                        <Typography variant="body2" fontWeight="medium">
                          {project.name}
                        </Typography>
                      </TableCell>
                      <TableCell>
                        <Typography variant="body2" color="text.secondary">
                          {project.description || '-'}
                        </Typography>
                      </TableCell>
                      <TableCell>{project.environment}</TableCell>
                      <TableCell>{project.deployment_platform}</TableCell>
                      <TableCell>
                        <Chip
                          label={project.status}
                          size="small"
                          color={getStatusColor(project.status) as any}
                        />
                      </TableCell>
                      <TableCell>
                        {project.diagram?.nodes?.length || 0} resources
                      </TableCell>
                      <TableCell>
                        {new Date(project.created_at).toLocaleDateString()}
                      </TableCell>
                      <TableCell align="right">
                        <IconButton
                          size="small"
                          onClick={() => navigate(`/designer/${project.id}`)}
                        >
                          <EditIcon />
                        </IconButton>
                        <IconButton
                          size="small"
                          onClick={() =>
                            navigate(`/designer/${project.id}?mode=duplicate`)
                          }
                        >
                          <CopyIcon />
                        </IconButton>
                        <IconButton
                          size="small"
                          onClick={() => handleDelete(project.id, project.name)}
                        >
                          <DeleteIcon />
                        </IconButton>
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </TableContainer>
          )}
        </CardContent>
      </Card>

      {/* Create Dialog */}
      <Dialog
        open={createDialogOpen}
        onClose={() => setCreateDialogOpen(false)}
        maxWidth="sm"
        fullWidth
      >
        <DialogTitle>Create Visual Design Project</DialogTitle>
        <DialogContent>
          <Box display="flex" flexDirection="column" gap={2} mt={1}>
            <TextField
              label="Project Name"
              value={newProject.name}
              onChange={(e) => setNewProject({ ...newProject, name: e.target.value })}
              required
              fullWidth
              autoFocus
            />
            <TextField
              label="Description"
              value={newProject.description}
              onChange={(e) =>
                setNewProject({ ...newProject, description: e.target.value })
              }
              multiline
              rows={3}
              fullWidth
            />
            <TextField
              label="Environment"
              value={newProject.environment}
              onChange={(e) =>
                setNewProject({ ...newProject, environment: e.target.value })
              }
              select
              SelectProps={{ native: true }}
              fullWidth
            >
              <option value="development">Development</option>
              <option value="staging">Staging</option>
              <option value="production">Production</option>
            </TextField>
            <TextField
              label="Deployment Platform"
              value={newProject.deployment_platform}
              onChange={(e) =>
                setNewProject({ ...newProject, deployment_platform: e.target.value })
              }
              select
              SelectProps={{ native: true }}
              fullWidth
            >
              <option value="spacelift">Spacelift</option>
              <option value="github_actions">GitHub Actions</option>
            </TextField>
          </Box>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setCreateDialogOpen(false)}>Cancel</Button>
          <Button
            variant="contained"
            onClick={handleCreate}
            disabled={!newProject.name || createMutation.isLoading}
          >
            {createMutation.isLoading ? 'Creating...' : 'Create'}
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  )
}

export default DesignerProjects
