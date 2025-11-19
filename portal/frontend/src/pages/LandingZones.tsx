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
  TextField,
  MenuItem,
} from '@mui/material'
import { Add as AddIcon, Visibility as ViewIcon } from '@mui/icons-material'
import { useQuery } from 'react-query'
import { landingZonesApi } from '../api/landingZones'

const LandingZones: React.FC = () => {
  const navigate = useNavigate()
  const [environmentFilter, setEnvironmentFilter] = useState('')
  const [statusFilter, setStatusFilter] = useState('')

  const { data: landingZones, isLoading } = useQuery('landingZones', () =>
    landingZonesApi.list({ limit: 100 })
  )

  const zones = landingZones?.items || []

  const filteredZones = zones.filter((zone: any) => {
    if (environmentFilter && zone.environment !== environmentFilter) return false
    if (statusFilter && zone.status !== statusFilter) return false
    return true
  })

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
      case 'draft':
        return 'default'
      default:
        return 'default'
    }
  }

  return (
    <Box>
      <Box display="flex" justifyContent="space-between" alignItems="center" mb={3}>
        <Typography variant="h4">Landing Zones</Typography>
        <Button
          variant="contained"
          startIcon={<AddIcon />}
          onClick={() => navigate('/landing-zones/create')}
        >
          Create Landing Zone
        </Button>
      </Box>

      <Card>
        <CardContent>
          <Box display="flex" gap={2} mb={3}>
            <TextField
              select
              label="Environment"
              value={environmentFilter}
              onChange={(e) => setEnvironmentFilter(e.target.value)}
              sx={{ minWidth: 200 }}
              size="small"
            >
              <MenuItem value="">All</MenuItem>
              <MenuItem value="production">Production</MenuItem>
              <MenuItem value="staging">Staging</MenuItem>
              <MenuItem value="development">Development</MenuItem>
              <MenuItem value="sandbox">Sandbox</MenuItem>
            </TextField>
            <TextField
              select
              label="Status"
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value)}
              sx={{ minWidth: 200 }}
              size="small"
            >
              <MenuItem value="">All</MenuItem>
              <MenuItem value="draft">Draft</MenuItem>
              <MenuItem value="submitted">Submitted</MenuItem>
              <MenuItem value="approved">Approved</MenuItem>
              <MenuItem value="deploying">Deploying</MenuItem>
              <MenuItem value="deployed">Deployed</MenuItem>
              <MenuItem value="failed">Failed</MenuItem>
            </TextField>
          </Box>

          {isLoading ? (
            <Box textAlign="center" py={4}>
              <Typography>Loading...</Typography>
            </Box>
          ) : filteredZones.length === 0 ? (
            <Box textAlign="center" py={4}>
              <Typography color="text.secondary">
                No landing zones found
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
                    <TableCell>Status</TableCell>
                    <TableCell>Created</TableCell>
                    <TableCell align="right">Actions</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {filteredZones.map((zone: any) => (
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
                      <TableCell>{zone.environment}</TableCell>
                      <TableCell>{zone.location}</TableCell>
                      <TableCell>
                        <Chip
                          label={zone.status}
                          size="small"
                          color={getStatusColor(zone.status) as any}
                        />
                      </TableCell>
                      <TableCell>
                        {new Date(zone.created_at).toLocaleDateString()}
                      </TableCell>
                      <TableCell align="right">
                        <IconButton
                          size="small"
                          onClick={() => navigate(`/landing-zones/${zone.id}`)}
                        >
                          <ViewIcon />
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
    </Box>
  )
}

export default LandingZones
