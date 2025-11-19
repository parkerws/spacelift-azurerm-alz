import React from 'react'
import { useNavigate } from 'react-router-dom'
import {
  Box,
  Grid,
  Card,
  CardContent,
  Typography,
  Button,
  Chip,
} from '@mui/material'
import {
  Add as AddIcon,
  Cloud as CloudIcon,
  CheckCircle as CheckIcon,
  Error as ErrorIcon,
  Schedule as ScheduleIcon,
} from '@mui/icons-material'
import { useQuery } from 'react-query'
import { landingZonesApi } from '../api/landingZones'
import { useAuth } from '../contexts/AuthContext'

const Dashboard: React.FC = () => {
  const navigate = useNavigate()
  const { user } = useAuth()

  const { data: landingZones } = useQuery('landingZones', () =>
    landingZonesApi.list({ limit: 100 })
  )

  const zones = landingZones?.items || []

  const stats = {
    total: zones.length,
    deployed: zones.filter((z: any) => z.status === 'deployed').length,
    deploying: zones.filter((z: any) => z.status === 'deploying').length,
    failed: zones.filter((z: any) => z.status === 'failed').length,
    pending: zones.filter((z: any) =>
      ['draft', 'submitted', 'under_review'].includes(z.status)
    ).length,
  }

  const StatCard = ({
    title,
    value,
    icon,
    color,
  }: {
    title: string
    value: number
    icon: React.ReactNode
    color: string
  }) => (
    <Card>
      <CardContent>
        <Box display="flex" justifyContent="space-between" alignItems="center">
          <Box>
            <Typography color="text.secondary" gutterBottom>
              {title}
            </Typography>
            <Typography variant="h3" component="div">
              {value}
            </Typography>
          </Box>
          <Box sx={{ color, fontSize: 48 }}>{icon}</Box>
        </Box>
      </CardContent>
    </Card>
  )

  return (
    <Box>
      <Box display="flex" justifyContent="space-between" alignItems="center" mb={3}>
        <Box>
          <Typography variant="h4" gutterBottom>
            Welcome, {user?.full_name}
          </Typography>
          <Typography variant="body2" color="text.secondary">
            Manage your Azure Landing Zones
          </Typography>
        </Box>
        <Button
          variant="contained"
          startIcon={<AddIcon />}
          onClick={() => navigate('/landing-zones/create')}
        >
          Create Landing Zone
        </Button>
      </Box>

      <Grid container spacing={3} mb={4}>
        <Grid item xs={12} sm={6} md={3}>
          <StatCard
            title="Total Landing Zones"
            value={stats.total}
            icon={<CloudIcon />}
            color="primary.main"
          />
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <StatCard
            title="Deployed"
            value={stats.deployed}
            icon={<CheckIcon />}
            color="success.main"
          />
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <StatCard
            title="In Progress"
            value={stats.deploying}
            icon={<ScheduleIcon />}
            color="info.main"
          />
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <StatCard
            title="Failed"
            value={stats.failed}
            icon={<ErrorIcon />}
            color="error.main"
          />
        </Grid>
      </Grid>

      <Card>
        <CardContent>
          <Typography variant="h6" gutterBottom>
            Recent Landing Zones
          </Typography>
          {zones.length === 0 ? (
            <Box textAlign="center" py={4}>
              <Typography color="text.secondary">
                No landing zones yet. Create your first one to get started.
              </Typography>
              <Button
                variant="contained"
                startIcon={<AddIcon />}
                onClick={() => navigate('/landing-zones/create')}
                sx={{ mt: 2 }}
              >
                Create Landing Zone
              </Button>
            </Box>
          ) : (
            <Box>
              {zones.slice(0, 5).map((zone: any) => (
                <Box
                  key={zone.id}
                  display="flex"
                  justifyContent="space-between"
                  alignItems="center"
                  py={2}
                  borderBottom="1px solid"
                  borderColor="divider"
                >
                  <Box>
                    <Typography variant="body1" fontWeight="medium">
                      {zone.display_name}
                    </Typography>
                    <Typography variant="caption" color="text.secondary">
                      {zone.name} • {zone.environment}
                    </Typography>
                  </Box>
                  <Box display="flex" alignItems="center" gap={2}>
                    <Chip
                      label={zone.status}
                      size="small"
                      color={
                        zone.status === 'deployed'
                          ? 'success'
                          : zone.status === 'failed'
                          ? 'error'
                          : zone.status === 'deploying'
                          ? 'info'
                          : 'default'
                      }
                    />
                    <Button
                      size="small"
                      onClick={() => navigate(`/landing-zones/${zone.id}`)}
                    >
                      View
                    </Button>
                  </Box>
                </Box>
              ))}
              {zones.length > 5 && (
                <Box textAlign="center" mt={2}>
                  <Button onClick={() => navigate('/landing-zones')}>
                    View All
                  </Button>
                </Box>
              )}
            </Box>
          )}
        </CardContent>
      </Card>
    </Box>
  )
}

export default Dashboard
