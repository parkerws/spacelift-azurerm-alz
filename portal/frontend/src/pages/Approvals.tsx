import React from 'react'
import { useNavigate } from 'react-router-dom'
import {
  Box,
  Typography,
  Card,
  CardContent,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Button,
  Chip,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
} from '@mui/material'
import { useQuery, useMutation, useQueryClient } from 'react-query'
import apiClient from '../api/client'

const Approvals: React.FC = () => {
  const navigate = useNavigate()
  const queryClient = useQueryClient()
  const [selectedZone, setSelectedZone] = React.useState<any>(null)
  const [action, setAction] = React.useState<'approve' | 'reject' | 'changes' | null>(
    null
  )
  const [comment, setComment] = React.useState('')

  const { data: pendingApprovals } = useQuery('pendingApprovals', async () => {
    const response = await apiClient.get('/approvals/pending')
    return response.data
  })

  const approveMutation = useMutation(
    async ({ id, comment }: { id: number; comment?: string }) => {
      const response = await apiClient.post(`/approvals/${id}/approve`, { comment })
      return response.data
    },
    {
      onSuccess: () => {
        queryClient.invalidateQueries('pendingApprovals')
        handleCloseDialog()
      },
    }
  )

  const rejectMutation = useMutation(
    async ({ id, comment }: { id: number; comment?: string }) => {
      const response = await apiClient.post(`/approvals/${id}/reject`, { comment })
      return response.data
    },
    {
      onSuccess: () => {
        queryClient.invalidateQueries('pendingApprovals')
        handleCloseDialog()
      },
    }
  )

  const requestChangesMutation = useMutation(
    async ({ id, comment }: { id: number; comment: string }) => {
      const response = await apiClient.post(`/approvals/${id}/request-changes`, {
        comment,
      })
      return response.data
    },
    {
      onSuccess: () => {
        queryClient.invalidateQueries('pendingApprovals')
        handleCloseDialog()
      },
    }
  )

  const handleOpenDialog = (
    zone: any,
    actionType: 'approve' | 'reject' | 'changes'
  ) => {
    setSelectedZone(zone)
    setAction(actionType)
    setComment('')
  }

  const handleCloseDialog = () => {
    setSelectedZone(null)
    setAction(null)
    setComment('')
  }

  const handleSubmit = () => {
    if (!selectedZone) return

    const payload = { id: selectedZone.id, comment }

    switch (action) {
      case 'approve':
        approveMutation.mutate(payload)
        break
      case 'reject':
        rejectMutation.mutate(payload)
        break
      case 'changes':
        if (comment.trim()) {
          requestChangesMutation.mutate({ ...payload, comment: comment.trim() })
        }
        break
    }
  }

  const zones = pendingApprovals?.items || []

  return (
    <Box>
      <Typography variant="h4" gutterBottom>
        Pending Approvals
      </Typography>

      <Card>
        <CardContent>
          {zones.length === 0 ? (
            <Box textAlign="center" py={4}>
              <Typography color="text.secondary">
                No pending approvals at this time
              </Typography>
            </Box>
          ) : (
            <TableContainer>
              <Table>
                <TableHead>
                  <TableRow>
                    <TableCell>Name</TableCell>
                    <TableCell>Type</TableCell>
                    <TableCell>Environment</TableCell>
                    <TableCell>Location</TableCell>
                    <TableCell>Submitted</TableCell>
                    <TableCell align="right">Actions</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {zones.map((zone: any) => (
                    <TableRow key={zone.id} hover>
                      <TableCell>
                        <Typography variant="body2" fontWeight="medium">
                          {zone.display_name}
                        </Typography>
                        <Typography variant="caption" color="text.secondary">
                          {zone.name}
                        </Typography>
                      </TableCell>
                      <TableCell>{zone.landing_zone_type}</TableCell>
                      <TableCell>
                        <Chip label={zone.environment} size="small" />
                      </TableCell>
                      <TableCell>{zone.location}</TableCell>
                      <TableCell>
                        {new Date(zone.created_at).toLocaleDateString()}
                      </TableCell>
                      <TableCell align="right">
                        <Box display="flex" gap={1} justifyContent="flex-end">
                          <Button
                            size="small"
                            onClick={() => navigate(`/landing-zones/${zone.id}`)}
                          >
                            View
                          </Button>
                          <Button
                            size="small"
                            variant="outlined"
                            onClick={() => handleOpenDialog(zone, 'changes')}
                          >
                            Request Changes
                          </Button>
                          <Button
                            size="small"
                            variant="outlined"
                            color="error"
                            onClick={() => handleOpenDialog(zone, 'reject')}
                          >
                            Reject
                          </Button>
                          <Button
                            size="small"
                            variant="contained"
                            color="success"
                            onClick={() => handleOpenDialog(zone, 'approve')}
                          >
                            Approve
                          </Button>
                        </Box>
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </TableContainer>
          )}
        </CardContent>
      </Card>

      <Dialog open={!!action} onClose={handleCloseDialog} maxWidth="sm" fullWidth>
        <DialogTitle>
          {action === 'approve' && 'Approve Landing Zone'}
          {action === 'reject' && 'Reject Landing Zone'}
          {action === 'changes' && 'Request Changes'}
        </DialogTitle>
        <DialogContent>
          <Box mt={2}>
            <Typography variant="body2" gutterBottom>
              {selectedZone?.display_name}
            </Typography>
            <TextField
              fullWidth
              multiline
              rows={4}
              label="Comment"
              value={comment}
              onChange={(e) => setComment(e.target.value)}
              placeholder={
                action === 'changes'
                  ? 'Explain what changes are needed (required)'
                  : 'Optional comment'
              }
              required={action === 'changes'}
            />
          </Box>
        </DialogContent>
        <DialogActions>
          <Button onClick={handleCloseDialog}>Cancel</Button>
          <Button
            onClick={handleSubmit}
            variant="contained"
            color={
              action === 'approve'
                ? 'success'
                : action === 'reject'
                ? 'error'
                : 'primary'
            }
            disabled={
              (action === 'changes' && !comment.trim()) ||
              approveMutation.isLoading ||
              rejectMutation.isLoading ||
              requestChangesMutation.isLoading
            }
          >
            Confirm
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  )
}

export default Approvals
