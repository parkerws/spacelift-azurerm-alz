import React from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import {
  Box,
  Typography,
  Card,
  CardContent,
  Grid,
  Chip,
  Button,
  Divider,
  Link,
} from '@mui/material'
import {
  Launch as LaunchIcon,
  Delete as DeleteIcon,
  Send as SendIcon,
} from '@mui/icons-material'
import { useQuery, useMutation, useQueryClient } from 'react-query'
import { landingZonesApi } from '../api/landingZones'

const LandingZoneDetail: React.FC = () => {
  const { id } = useParams<{ id: string }>()
  const navigate = useNavigate()
  const queryClient = useQueryClient()

  const { data: landingZone, isLoading } = useQuery(
    ['landingZone', id],
    () => landingZonesApi.get(parseInt(id!)),
    { enabled: !!id }
  )

  const submitMutation = useMutation(
    () => landingZonesApi.submit(parseInt(id!)),
    {
      onSuccess: () => {
        queryClient.invalidateQueries(['landingZone', id])
      },
    }
  )

  const deleteMutation = useMutation(
    () => landingZonesApi.delete(parseInt(id!)),
    {
      onSuccess: () => {
        navigate('/landing-zones')
      },
    }
  )

  if (isLoading) {
    return <Typography>Loading...</Typography>
  }

  if (!landingZone) {
    return <Typography>Landing zone not found</Typography>
  }

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'deployed':
        return 'success'
      case 'deploying':
        return 'info'
      case 'failed':
        return 'error'
      case 'approved':
        return 'success'
      case 'submitted':
        return 'warning'
      default:
        return 'default'
    }
  }

  const canSubmit = landingZone.status === 'draft'
  const canDelete = ['draft', 'failed', 'rejected'].includes(landingZone.status)

  return (
    <Box>
      <Box display="flex" justifyContent="space-between" alignItems="center" mb={3}>
        <Box>
          <Typography variant="h4">{landingZone.display_name}</Typography>
          <Typography variant="body2" color="text.secondary">
            {landingZone.name}
          </Typography>
        </Box>
        <Box display="flex" gap={1}>
          {canSubmit && (
            <Button
              variant="contained"
              startIcon={<SendIcon />}
              onClick={() => submitMutation.mutate()}
              disabled={submitMutation.isLoading}
            >
              Submit for Approval
            </Button>
          )}
          {canDelete && (
            <Button
              variant="outlined"
              color="error"
              startIcon={<DeleteIcon />}
              onClick={() => {
                if (confirm('Are you sure you want to delete this landing zone?')) {
                  deleteMutation.mutate()
                }
              }}
              disabled={deleteMutation.isLoading}
            >
              Delete
            </Button>
          )}
        </Box>
      </Box>

      <Grid container spacing={3}>
        <Grid item xs={12} md={8}>
          <Card>
            <CardContent>
              <Typography variant="h6" gutterBottom>
                Configuration
              </Typography>
              <Divider sx={{ my: 2 }} />
              <Grid container spacing={2}>
                <Grid item xs={6}>
                  <Typography variant="caption" color="text.secondary">
                    Status
                  </Typography>
                  <Box mt={0.5}>
                    <Chip
                      label={landingZone.status}
                      color={getStatusColor(landingZone.status) as any}
                      size="small"
                    />
                  </Box>
                </Grid>
                <Grid item xs={6}>
                  <Typography variant="caption" color="text.secondary">
                    Environment
                  </Typography>
                  <Typography variant="body1">{landingZone.environment}</Typography>
                </Grid>
                <Grid item xs={6}>
                  <Typography variant="caption" color="text.secondary">
                    Type
                  </Typography>
                  <Typography variant="body1">
                    {landingZone.landing_zone_type}
                  </Typography>
                </Grid>
                <Grid item xs={6}>
                  <Typography variant="caption" color="text.secondary">
                    Location
                  </Typography>
                  <Typography variant="body1">{landingZone.location}</Typography>
                </Grid>
                <Grid item xs={6}>
                  <Typography variant="caption" color="text.secondary">
                    Address Space
                  </Typography>
                  <Typography variant="body1">{landingZone.address_space}</Typography>
                </Grid>
                <Grid item xs={6}>
                  <Typography variant="caption" color="text.secondary">
                    Hub
                  </Typography>
                  <Typography variant="body1">{landingZone.hub_name}</Typography>
                </Grid>
                {landingZone.description && (
                  <Grid item xs={12}>
                    <Typography variant="caption" color="text.secondary">
                      Description
                    </Typography>
                    <Typography variant="body1">{landingZone.description}</Typography>
                  </Grid>
                )}
              </Grid>
            </CardContent>
          </Card>

          {landingZone.deployment_url && (
            <Card sx={{ mt: 3 }}>
              <CardContent>
                <Typography variant="h6" gutterBottom>
                  Deployment
                </Typography>
                <Divider sx={{ my: 2 }} />
                <Box>
                  <Typography variant="caption" color="text.secondary">
                    Deployment URL
                  </Typography>
                  <Box mt={0.5}>
                    <Link
                      href={landingZone.deployment_url}
                      target="_blank"
                      rel="noopener noreferrer"
                    >
                      View Deployment <LaunchIcon sx={{ fontSize: 14, ml: 0.5 }} />
                    </Link>
                  </Box>
                </Box>
              </CardContent>
            </Card>
          )}
        </Grid>

        <Grid item xs={12} md={4}>
          <Card>
            <CardContent>
              <Typography variant="h6" gutterBottom>
                Details
              </Typography>
              <Divider sx={{ my: 2 }} />
              <Box mb={2}>
                <Typography variant="caption" color="text.secondary">
                  Created
                </Typography>
                <Typography variant="body2">
                  {new Date(landingZone.created_at).toLocaleString()}
                </Typography>
              </Box>
              {landingZone.deployed_at && (
                <Box mb={2}>
                  <Typography variant="caption" color="text.secondary">
                    Deployed
                  </Typography>
                  <Typography variant="body2">
                    {new Date(landingZone.deployed_at).toLocaleString()}
                  </Typography>
                </Box>
              )}
              {landingZone.monthly_budget && (
                <Box>
                  <Typography variant="caption" color="text.secondary">
                    Monthly Budget
                  </Typography>
                  <Typography variant="body2">
                    ${landingZone.monthly_budget}
                  </Typography>
                </Box>
              )}
            </CardContent>
          </Card>

          {landingZone.resource_count !== undefined &&
            landingZone.resource_count > 0 && (
              <Card sx={{ mt: 2 }}>
                <CardContent>
                  <Typography variant="h6" gutterBottom>
                    Resources
                  </Typography>
                  <Divider sx={{ my: 2 }} />
                  <Typography variant="h3" color="primary.main">
                    {landingZone.resource_count}
                  </Typography>
                  <Typography variant="caption" color="text.secondary">
                    Total Resources Deployed
                  </Typography>
                </CardContent>
              </Card>
            )}
        </Grid>
      </Grid>
    </Box>
  )
}

export default LandingZoneDetail
