import React, { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import {
  Box,
  Typography,
  Card,
  CardContent,
  TextField,
  Button,
  Grid,
  MenuItem,
  Alert,
  Stepper,
  Step,
  StepLabel,
} from '@mui/material'
import { useMutation, useQueryClient } from 'react-query'
import { landingZonesApi, CreateLandingZoneRequest } from '../api/landingZones'

const steps = ['Basic Information', 'Network Configuration', 'Budget & Tags', 'Review']

const CreateLandingZone: React.FC = () => {
  const navigate = useNavigate()
  const queryClient = useQueryClient()
  const [activeStep, setActiveStep] = useState(0)
  const [error, setError] = useState('')

  const [formData, setFormData] = useState<CreateLandingZoneRequest>({
    name: '',
    display_name: '',
    description: '',
    environment: 'development',
    landing_zone_type: 'corp',
    location: 'eastus',
    address_space: '',
    hub_name: 'hub-prod',
    monthly_budget: undefined,
    tags: {},
    configuration: {},
  })

  const createMutation = useMutation(landingZonesApi.create, {
    onSuccess: (data) => {
      queryClient.invalidateQueries('landingZones')
      navigate(`/landing-zones/${data.id}`)
    },
    onError: (err: any) => {
      setError(err.response?.data?.detail || 'Failed to create landing zone')
    },
  })

  const handleChange = (field: keyof CreateLandingZoneRequest, value: any) => {
    setFormData((prev) => ({ ...prev, [field]: value }))
  }

  const handleNext = () => {
    setActiveStep((prev) => prev + 1)
  }

  const handleBack = () => {
    setActiveStep((prev) => prev - 1)
  }

  const handleSubmit = () => {
    createMutation.mutate(formData)
  }

  const renderStepContent = (step: number) => {
    switch (step) {
      case 0:
        return (
          <Grid container spacing={2}>
            <Grid item xs={12}>
              <TextField
                fullWidth
                label="Name"
                value={formData.name}
                onChange={(e) => handleChange('name', e.target.value)}
                helperText="Lowercase letters, numbers, and hyphens only"
                required
              />
            </Grid>
            <Grid item xs={12}>
              <TextField
                fullWidth
                label="Display Name"
                value={formData.display_name}
                onChange={(e) => handleChange('display_name', e.target.value)}
                required
              />
            </Grid>
            <Grid item xs={12}>
              <TextField
                fullWidth
                multiline
                rows={3}
                label="Description"
                value={formData.description}
                onChange={(e) => handleChange('description', e.target.value)}
              />
            </Grid>
            <Grid item xs={12} sm={6}>
              <TextField
                fullWidth
                select
                label="Landing Zone Type"
                value={formData.landing_zone_type}
                onChange={(e) => handleChange('landing_zone_type', e.target.value)}
                required
              >
                <MenuItem value="corp">Corporate</MenuItem>
                <MenuItem value="online">Online</MenuItem>
                <MenuItem value="sap">SAP</MenuItem>
                <MenuItem value="custom">Custom</MenuItem>
              </TextField>
            </Grid>
            <Grid item xs={12} sm={6}>
              <TextField
                fullWidth
                select
                label="Environment"
                value={formData.environment}
                onChange={(e) => handleChange('environment', e.target.value)}
                required
              >
                <MenuItem value="production">Production</MenuItem>
                <MenuItem value="staging">Staging</MenuItem>
                <MenuItem value="development">Development</MenuItem>
                <MenuItem value="sandbox">Sandbox</MenuItem>
              </TextField>
            </Grid>
          </Grid>
        )

      case 1:
        return (
          <Grid container spacing={2}>
            <Grid item xs={12} sm={6}>
              <TextField
                fullWidth
                select
                label="Azure Region"
                value={formData.location}
                onChange={(e) => handleChange('location', e.target.value)}
                required
              >
                <MenuItem value="eastus">East US</MenuItem>
                <MenuItem value="eastus2">East US 2</MenuItem>
                <MenuItem value="westus">West US</MenuItem>
                <MenuItem value="westus2">West US 2</MenuItem>
                <MenuItem value="centralus">Central US</MenuItem>
                <MenuItem value="northeurope">North Europe</MenuItem>
                <MenuItem value="westeurope">West Europe</MenuItem>
              </TextField>
            </Grid>
            <Grid item xs={12} sm={6}>
              <TextField
                fullWidth
                label="Address Space (CIDR)"
                value={formData.address_space}
                onChange={(e) => handleChange('address_space', e.target.value)}
                placeholder="10.1.0.0/16"
                helperText="e.g., 10.1.0.0/16"
                required
              />
            </Grid>
            <Grid item xs={12}>
              <TextField
                fullWidth
                select
                label="Hub Landing Zone"
                value={formData.hub_name}
                onChange={(e) => handleChange('hub_name', e.target.value)}
                helperText="Select the hub to connect to"
                required
              >
                <MenuItem value="hub-prod">hub-prod (Production Hub)</MenuItem>
                <MenuItem value="hub-nonprod">hub-nonprod (Non-Production Hub)</MenuItem>
              </TextField>
            </Grid>
          </Grid>
        )

      case 2:
        return (
          <Grid container spacing={2}>
            <Grid item xs={12}>
              <TextField
                fullWidth
                type="number"
                label="Monthly Budget (USD)"
                value={formData.monthly_budget || ''}
                onChange={(e) =>
                  handleChange('monthly_budget', parseFloat(e.target.value) || undefined)
                }
                helperText="Optional budget limit for cost alerts"
              />
            </Grid>
            <Grid item xs={12}>
              <Typography variant="subtitle2" gutterBottom>
                Tags (Optional)
              </Typography>
              <TextField
                fullWidth
                label="Cost Center"
                placeholder="e.g., CC-12345"
                onChange={(e) =>
                  handleChange('tags', { ...formData.tags, CostCenter: e.target.value })
                }
              />
            </Grid>
            <Grid item xs={12}>
              <TextField
                fullWidth
                label="Owner"
                placeholder="e.g., john.doe@example.com"
                onChange={(e) =>
                  handleChange('tags', { ...formData.tags, Owner: e.target.value })
                }
              />
            </Grid>
          </Grid>
        )

      case 3:
        return (
          <Box>
            <Typography variant="h6" gutterBottom>
              Review Your Landing Zone Configuration
            </Typography>
            <Grid container spacing={2}>
              <Grid item xs={12} sm={6}>
                <Typography variant="caption" color="text.secondary">
                  Name
                </Typography>
                <Typography variant="body1">{formData.name}</Typography>
              </Grid>
              <Grid item xs={12} sm={6}>
                <Typography variant="caption" color="text.secondary">
                  Display Name
                </Typography>
                <Typography variant="body1">{formData.display_name}</Typography>
              </Grid>
              <Grid item xs={12} sm={6}>
                <Typography variant="caption" color="text.secondary">
                  Type
                </Typography>
                <Typography variant="body1">{formData.landing_zone_type}</Typography>
              </Grid>
              <Grid item xs={12} sm={6}>
                <Typography variant="caption" color="text.secondary">
                  Environment
                </Typography>
                <Typography variant="body1">{formData.environment}</Typography>
              </Grid>
              <Grid item xs={12} sm={6}>
                <Typography variant="caption" color="text.secondary">
                  Location
                </Typography>
                <Typography variant="body1">{formData.location}</Typography>
              </Grid>
              <Grid item xs={12} sm={6}>
                <Typography variant="caption" color="text.secondary">
                  Address Space
                </Typography>
                <Typography variant="body1">{formData.address_space}</Typography>
              </Grid>
              <Grid item xs={12} sm={6}>
                <Typography variant="caption" color="text.secondary">
                  Hub
                </Typography>
                <Typography variant="body1">{formData.hub_name}</Typography>
              </Grid>
              {formData.monthly_budget && (
                <Grid item xs={12} sm={6}>
                  <Typography variant="caption" color="text.secondary">
                    Monthly Budget
                  </Typography>
                  <Typography variant="body1">${formData.monthly_budget}</Typography>
                </Grid>
              )}
            </Grid>
          </Box>
        )

      default:
        return null
    }
  }

  return (
    <Box>
      <Typography variant="h4" gutterBottom>
        Create Landing Zone
      </Typography>

      <Card>
        <CardContent>
          <Stepper activeStep={activeStep} sx={{ mb: 4 }}>
            {steps.map((label) => (
              <Step key={label}>
                <StepLabel>{label}</StepLabel>
              </Step>
            ))}
          </Stepper>

          {error && (
            <Alert severity="error" sx={{ mb: 2 }}>
              {error}
            </Alert>
          )}

          <Box mb={3}>{renderStepContent(activeStep)}</Box>

          <Box display="flex" justifyContent="space-between">
            <Button disabled={activeStep === 0} onClick={handleBack}>
              Back
            </Button>
            <Box>
              <Button onClick={() => navigate('/landing-zones')} sx={{ mr: 1 }}>
                Cancel
              </Button>
              {activeStep === steps.length - 1 ? (
                <Button
                  variant="contained"
                  onClick={handleSubmit}
                  disabled={createMutation.isLoading}
                >
                  {createMutation.isLoading ? 'Creating...' : 'Create'}
                </Button>
              ) : (
                <Button variant="contained" onClick={handleNext}>
                  Next
                </Button>
              )}
            </Box>
          </Box>
        </CardContent>
      </Card>
    </Box>
  )
}

export default CreateLandingZone
