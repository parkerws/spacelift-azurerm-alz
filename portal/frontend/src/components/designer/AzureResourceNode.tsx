import React from 'react'
import { Handle, Position, NodeProps } from 'reactflow'
import { Box, Typography, Paper, Chip } from '@mui/material'
import {
  Cloud as VNetIcon,
  Router as SubnetIcon,
  Security as NSGIcon,
  Computer as VMIcon,
  Storage as StorageIcon,
} from '@mui/icons-material'

const iconMap: Record<string, React.ReactElement> = {
  'azure-vnet': <VNetIcon />,
  'azure-subnet': <SubnetIcon />,
  'azure-nsg': <NSGIcon />,
  'azure-vm': <VMIcon />,
  'azure-storage': <StorageIcon />,
}

const colorMap: Record<string, string> = {
  'azure-vnet': '#0078d4',
  'azure-subnet': '#50a0e6',
  'azure-nsg': '#107c10',
  'azure-vm': '#8661c5',
  'azure-storage': '#ff8c00',
}

export const AzureResourceNode: React.FC<NodeProps> = ({ data, type, selected }) => {
  const icon = iconMap[type || ''] || <Cloud as VNetIcon />
  const color = colorMap[type || ''] || '#0078d4'
  const name = data.name || 'Unnamed Resource'
  const resourceType = type?.replace('azure-', '').replace('-', ' ').toUpperCase() || 'RESOURCE'

  return (
    <>
      <Handle type="target" position={Position.Top} />

      <Paper
        elevation={selected ? 8 : 2}
        sx={{
          p: 2,
          minWidth: 180,
          maxWidth: 250,
          borderLeft: `4px solid ${color}`,
          borderRadius: 2,
          backgroundColor: selected ? '#f0f8ff' : 'white',
          cursor: 'grab',
          '&:active': {
            cursor: 'grabbing',
          },
        }}
      >
        <Box display="flex" alignItems="center" gap={1} mb={1}>
          <Box sx={{ color, display: 'flex' }}>{icon}</Box>
          <Chip
            label={resourceType}
            size="small"
            sx={{
              backgroundColor: color,
              color: 'white',
              fontSize: '0.65rem',
              height: 20,
            }}
          />
        </Box>

        <Typography variant="body2" fontWeight="medium" noWrap>
          {name}
        </Typography>

        {data.location && (
          <Typography variant="caption" color="text.secondary" display="block">
            {data.location}
          </Typography>
        )}

        {data.address_space && (
          <Typography variant="caption" color="text.secondary" display="block" noWrap>
            {Array.isArray(data.address_space) ? data.address_space[0] : data.address_space}
          </Typography>
        )}

        {data.address_prefixes && (
          <Typography variant="caption" color="text.secondary" display="block" noWrap>
            {Array.isArray(data.address_prefixes) ? data.address_prefixes[0] : data.address_prefixes}
          </Typography>
        )}
      </Paper>

      <Handle type="source" position={Position.Bottom} />
    </>
  )
}
