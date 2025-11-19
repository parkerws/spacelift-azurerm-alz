import React from 'react'
import { useNavigate } from 'react-router-dom'
import {
  Box,
  Typography,
  Grid,
  Card,
  CardContent,
  CardActions,
  Button,
  Chip,
  List,
  ListItem,
  ListItemIcon,
  ListItemText,
} from '@mui/material'
import { Check as CheckIcon } from '@mui/icons-material'
import { useQuery } from 'react-query'
import apiClient from '../api/client'

const Templates: React.FC = () => {
  const navigate = useNavigate()

  const { data: templates, isLoading } = useQuery('templates', async () => {
    const response = await apiClient.get('/templates')
    return response.data
  })

  if (isLoading) {
    return <Typography>Loading templates...</Typography>
  }

  return (
    <Box>
      <Typography variant="h4" gutterBottom>
        Landing Zone Templates
      </Typography>
      <Typography variant="body2" color="text.secondary" paragraph>
        Choose a pre-configured template to quickly create your landing zone
      </Typography>

      <Grid container spacing={3}>
        {templates?.map((template: any) => (
          <Grid item xs={12} md={6} lg={4} key={template.id}>
            <Card
              sx={{
                height: '100%',
                display: 'flex',
                flexDirection: 'column',
              }}
            >
              <CardContent sx={{ flexGrow: 1 }}>
                <Box display="flex" justifyContent="space-between" alignItems="start" mb={2}>
                  <Typography variant="h6" component="h2">
                    {template.name}
                  </Typography>
                  <Chip
                    label={template.landing_zone_type}
                    size="small"
                    color="primary"
                  />
                </Box>

                <Typography variant="body2" color="text.secondary" paragraph>
                  {template.description}
                </Typography>

                <Box mb={2}>
                  <Typography variant="caption" color="text.secondary">
                    Features:
                  </Typography>
                  <List dense>
                    {template.features.slice(0, 4).map((feature: string, index: number) => (
                      <ListItem key={index} sx={{ py: 0.5 }}>
                        <ListItemIcon sx={{ minWidth: 32 }}>
                          <CheckIcon fontSize="small" color="success" />
                        </ListItemIcon>
                        <ListItemText
                          primary={feature}
                          primaryTypographyProps={{ variant: 'body2' }}
                        />
                      </ListItem>
                    ))}
                  </List>
                </Box>

                <Box
                  display="flex"
                  justifyContent="space-between"
                  sx={{ pt: 2, borderTop: 1, borderColor: 'divider' }}
                >
                  <Box>
                    <Typography variant="caption" color="text.secondary">
                      Est. Monthly Cost
                    </Typography>
                    <Typography variant="body1" fontWeight="medium">
                      ${template.estimated_monthly_cost}
                    </Typography>
                  </Box>
                  <Box>
                    <Typography variant="caption" color="text.secondary">
                      Deployment Time
                    </Typography>
                    <Typography variant="body1" fontWeight="medium">
                      ~{template.deployment_time_minutes} min
                    </Typography>
                  </Box>
                </Box>
              </CardContent>

              <CardActions sx={{ p: 2, pt: 0 }}>
                <Button
                  fullWidth
                  variant="outlined"
                  onClick={() => navigate('/landing-zones/create')}
                >
                  Use Template
                </Button>
              </CardActions>
            </Card>
          </Grid>
        ))}
      </Grid>
    </Box>
  )
}

export default Templates
