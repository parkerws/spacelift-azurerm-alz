import React, { useState, useEffect } from 'react'
import {
  Box,
  Typography,
  TextField,
  Paper,
  Divider,
  Button,
  IconButton,
  Tabs,
  Tab,
  Chip,
} from '@mui/material'
import { Close as CloseIcon } from '@mui/icons-material'
import { Node } from 'reactflow'
import Editor from '@monaco-editor/react'
import yaml from 'js-yaml'

interface ConfigurationPanelProps {
  selectedNode: Node | null
  onClose: () => void
  onUpdate: (nodeId: string, data: Record<string, any>) => void
}

interface TabPanelProps {
  children?: React.ReactNode
  index: number
  value: number
}

const TabPanel: React.FC<TabPanelProps> = ({ children, value, index }) => {
  return (
    <div role="tabpanel" hidden={value !== index}>
      {value === index && <Box sx={{ p: 2 }}>{children}</Box>}
    </div>
  )
}

export const ConfigurationPanel: React.FC<ConfigurationPanelProps> = ({
  selectedNode,
  onClose,
  onUpdate,
}) => {
  const [tabValue, setTabValue] = useState(0)
  const [formData, setFormData] = useState<Record<string, any>>({})
  const [yamlConfig, setYamlConfig] = useState('')
  const [yamlError, setYamlError] = useState('')

  useEffect(() => {
    if (selectedNode) {
      setFormData(selectedNode.data || {})

      // Convert data to YAML
      try {
        const yamlStr = yaml.dump(selectedNode.data || {}, { indent: 2 })
        setYamlConfig(yamlStr)
        setYamlError('')
      } catch (error) {
        setYamlError('Error converting to YAML')
      }
    }
  }, [selectedNode])

  const handleFieldChange = (field: string, value: any) => {
    const newData = { ...formData, [field]: value }
    setFormData(newData)
  }

  const handleYamlChange = (value: string | undefined) => {
    if (value === undefined) return

    setYamlConfig(value)

    try {
      const parsed = yaml.load(value) as Record<string, any>
      setFormData(parsed)
      setYamlError('')
    } catch (error: any) {
      setYamlError(error.message)
    }
  }

  const handleSave = () => {
    if (selectedNode) {
      onUpdate(selectedNode.id, formData)
    }
  }

  if (!selectedNode) {
    return (
      <Paper sx={{ height: '100%', p: 2, textAlign: 'center' }}>
        <Typography variant="body2" color="text.secondary">
          Select a component to configure
        </Typography>
      </Paper>
    )
  }

  const resourceType = selectedNode.type?.replace('azure-', '').replace('-', ' ') || 'Resource'

  return (
    <Paper sx={{ height: '100%', display: 'flex', flexDirection: 'column' }}>
      {/* Header */}
      <Box
        display="flex"
        justifyContent="space-between"
        alignItems="center"
        p={2}
        borderBottom={1}
        borderColor="divider"
      >
        <Box>
          <Typography variant="h6" textTransform="capitalize">
            {resourceType}
          </Typography>
          <Chip label={selectedNode.id} size="small" sx={{ mt: 0.5 }} />
        </Box>
        <IconButton size="small" onClick={onClose}>
          <CloseIcon />
        </IconButton>
      </Box>

      {/* Tabs */}
      <Box borderBottom={1} borderColor="divider">
        <Tabs value={tabValue} onChange={(_, v) => setTabValue(v)}>
          <Tab label="Properties" />
          <Tab label="YAML" />
        </Tabs>
      </Box>

      {/* Content */}
      <Box flexGrow={1} overflow="auto">
        <TabPanel value={tabValue} index={0}>
          <Box display="flex" flexDirection="column" gap={2}>
            <TextField
              label="Name"
              value={formData.name || ''}
              onChange={(e) => handleFieldChange('name', e.target.value)}
              size="small"
              fullWidth
              required
            />

            {selectedNode.type === 'azure-vnet' && (
              <>
                <TextField
                  label="Address Space"
                  value={
                    Array.isArray(formData.address_space)
                      ? formData.address_space.join(', ')
                      : formData.address_space || ''
                  }
                  onChange={(e) =>
                    handleFieldChange(
                      'address_space',
                      e.target.value.split(',').map((s) => s.trim())
                    )
                  }
                  size="small"
                  fullWidth
                  helperText="Comma-separated CIDR blocks, e.g., 10.0.0.0/16"
                />
                <TextField
                  label="Location"
                  value={formData.location || ''}
                  onChange={(e) => handleFieldChange('location', e.target.value)}
                  size="small"
                  fullWidth
                  select
                  SelectProps={{ native: true }}
                >
                  <option value="">Select...</option>
                  <option value="eastus">East US</option>
                  <option value="eastus2">East US 2</option>
                  <option value="westus">West US</option>
                  <option value="westus2">West US 2</option>
                  <option value="centralus">Central US</option>
                  <option value="northeurope">North Europe</option>
                  <option value="westeurope">West Europe</option>
                </TextField>
              </>
            )}

            {selectedNode.type === 'azure-subnet' && (
              <TextField
                label="Address Prefixes"
                value={
                  Array.isArray(formData.address_prefixes)
                    ? formData.address_prefixes.join(', ')
                    : formData.address_prefixes || ''
                }
                onChange={(e) =>
                  handleFieldChange(
                    'address_prefixes',
                    e.target.value.split(',').map((s) => s.trim())
                  )
                }
                size="small"
                fullWidth
                helperText="Comma-separated CIDR blocks, e.g., 10.0.1.0/24"
              />
            )}

            {selectedNode.type === 'azure-vm' && (
              <>
                <TextField
                  label="VM Size"
                  value={formData.size || ''}
                  onChange={(e) => handleFieldChange('size', e.target.value)}
                  size="small"
                  fullWidth
                  select
                  SelectProps={{ native: true }}
                >
                  <option value="">Select...</option>
                  <option value="Standard_B2s">Standard_B2s</option>
                  <option value="Standard_B2ms">Standard_B2ms</option>
                  <option value="Standard_D2s_v3">Standard_D2s_v3</option>
                  <option value="Standard_D4s_v3">Standard_D4s_v3</option>
                </TextField>
                <TextField
                  label="Admin Username"
                  value={formData.admin_username || ''}
                  onChange={(e) => handleFieldChange('admin_username', e.target.value)}
                  size="small"
                  fullWidth
                />
              </>
            )}

            {selectedNode.type === 'azure-storage' && (
              <>
                <TextField
                  label="Account Tier"
                  value={formData.account_tier || ''}
                  onChange={(e) => handleFieldChange('account_tier', e.target.value)}
                  size="small"
                  fullWidth
                  select
                  SelectProps={{ native: true }}
                >
                  <option value="">Select...</option>
                  <option value="Standard">Standard</option>
                  <option value="Premium">Premium</option>
                </TextField>
                <TextField
                  label="Replication Type"
                  value={formData.account_replication_type || ''}
                  onChange={(e) => handleFieldChange('account_replication_type', e.target.value)}
                  size="small"
                  fullWidth
                  select
                  SelectProps={{ native: true }}
                >
                  <option value="">Select...</option>
                  <option value="LRS">LRS (Locally Redundant)</option>
                  <option value="GRS">GRS (Geo Redundant)</option>
                  <option value="ZRS">ZRS (Zone Redundant)</option>
                </TextField>
              </>
            )}
          </Box>
        </TabPanel>

        <TabPanel value={tabValue} index={1}>
          <Box height={400}>
            <Editor
              height="100%"
              defaultLanguage="yaml"
              value={yamlConfig}
              onChange={handleYamlChange}
              theme="vs-light"
              options={{
                minimap: { enabled: false },
                fontSize: 12,
                lineNumbers: 'on',
                scrollBeyondLastLine: false,
              }}
            />
            {yamlError && (
              <Typography variant="caption" color="error" display="block" mt={1}>
                {yamlError}
              </Typography>
            )}
          </Box>
        </TabPanel>
      </Box>

      {/* Footer */}
      <Divider />
      <Box p={2} display="flex" justifyContent="flex-end" gap={1}>
        <Button onClick={onClose}>Cancel</Button>
        <Button variant="contained" onClick={handleSave} disabled={!!yamlError}>
          Save
        </Button>
      </Box>
    </Paper>
  )
}
