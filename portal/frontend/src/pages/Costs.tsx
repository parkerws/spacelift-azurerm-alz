import React from 'react'
import {
  Box,
  Typography,
  Grid,
  Card,
  CardContent,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  LinearProgress,
  Chip,
} from '@mui/material'
import {
  TrendingUp as TrendingUpIcon,
  Warning as WarningIcon,
} from '@mui/icons-material'
import { useQuery } from 'react-query'
import apiClient from '../api/client'

const Costs: React.FC = () => {
  const { data: costSummary } = useQuery('costSummary', async () => {
    const response = await apiClient.get('/costs/summary')
    return response.data
  })

  const stats = costSummary || {
    total_landing_zones: 0,
    total_monthly_cost: 0,
    total_budget: 0,
    over_budget_count: 0,
    landing_zones: [],
  }

  const budgetUsagePercentage =
    stats.total_budget > 0
      ? (stats.total_monthly_cost / stats.total_budget) * 100
      : 0

  const StatCard = ({
    title,
    value,
    subtitle,
    color = 'primary',
  }: {
    title: string
    value: string
    subtitle?: string
    color?: string
  }) => (
    <Card>
      <CardContent>
        <Typography color="text.secondary" gutterBottom variant="body2">
          {title}
        </Typography>
        <Typography variant="h4" component="div" color={color}>
          {value}
        </Typography>
        {subtitle && (
          <Typography variant="caption" color="text.secondary">
            {subtitle}
          </Typography>
        )}
      </CardContent>
    </Card>
  )

  return (
    <Box>
      <Typography variant="h4" gutterBottom>
        Cost Management
      </Typography>

      <Grid container spacing={3} mb={4}>
        <Grid item xs={12} sm={6} md={3}>
          <StatCard
            title="Total Monthly Cost"
            value={`$${stats.total_monthly_cost.toFixed(2)}`}
            subtitle={`Across ${stats.total_landing_zones} landing zones`}
          />
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <StatCard
            title="Total Budget"
            value={`$${stats.total_budget.toFixed(2)}`}
            subtitle={`${budgetUsagePercentage.toFixed(1)}% used`}
          />
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <StatCard
            title="Over Budget"
            value={stats.over_budget_count.toString()}
            subtitle="Landing zones exceeding budget"
            color={stats.over_budget_count > 0 ? 'error.main' : 'success.main'}
          />
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <Card>
            <CardContent>
              <Typography color="text.secondary" gutterBottom variant="body2">
                Budget Usage
              </Typography>
              <Box display="flex" alignItems="center" gap={1}>
                <Typography variant="h4" component="div">
                  {budgetUsagePercentage.toFixed(0)}%
                </Typography>
                {budgetUsagePercentage > 80 && (
                  <WarningIcon color="warning" />
                )}
              </Box>
              <LinearProgress
                variant="determinate"
                value={Math.min(budgetUsagePercentage, 100)}
                color={budgetUsagePercentage > 80 ? 'warning' : 'primary'}
                sx={{ mt: 1 }}
              />
            </CardContent>
          </Card>
        </Grid>
      </Grid>

      <Card>
        <CardContent>
          <Typography variant="h6" gutterBottom>
            Landing Zone Costs
          </Typography>
          {stats.landing_zones.length === 0 ? (
            <Box textAlign="center" py={4}>
              <Typography color="text.secondary">
                No cost data available
              </Typography>
            </Box>
          ) : (
            <TableContainer>
              <Table>
                <TableHead>
                  <TableRow>
                    <TableCell>Landing Zone</TableCell>
                    <TableCell align="right">Current Cost</TableCell>
                    <TableCell align="right">Budget</TableCell>
                    <TableCell align="right">Usage</TableCell>
                    <TableCell>Status</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {stats.landing_zones.map((zone: any) => {
                    const usage =
                      zone.budget > 0
                        ? (zone.cost / zone.budget) * 100
                        : 0
                    return (
                      <TableRow key={zone.id} hover>
                        <TableCell>
                          <Typography variant="body2" fontWeight="medium">
                            {zone.name}
                          </Typography>
                        </TableCell>
                        <TableCell align="right">
                          ${zone.cost.toFixed(2)}
                        </TableCell>
                        <TableCell align="right">
                          ${zone.budget.toFixed(2)}
                        </TableCell>
                        <TableCell align="right">
                          <Box display="flex" alignItems="center" justifyContent="flex-end" gap={1}>
                            {usage.toFixed(0)}%
                            {usage > 80 && <TrendingUpIcon color="warning" fontSize="small" />}
                          </Box>
                        </TableCell>
                        <TableCell>
                          {zone.is_over_budget ? (
                            <Chip
                              label="Over Budget"
                              color="error"
                              size="small"
                            />
                          ) : usage > 80 ? (
                            <Chip
                              label="Near Limit"
                              color="warning"
                              size="small"
                            />
                          ) : (
                            <Chip
                              label="On Track"
                              color="success"
                              size="small"
                            />
                          )}
                        </TableCell>
                      </TableRow>
                    )
                  })}
                </TableBody>
              </Table>
            </TableContainer>
          )}
        </CardContent>
      </Card>
    </Box>
  )
}

export default Costs
