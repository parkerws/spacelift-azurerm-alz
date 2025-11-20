import React from 'react'
import {
  Box,
  Typography,
  List,
  ListItem,
  ListItemButton,
  ListItemIcon,
  ListItemText,
  Paper,
  Divider,
  Accordion,
  AccordionSummary,
  AccordionDetails,
} from '@mui/material'
import {
  ExpandMore as ExpandMoreIcon,
  Cloud as VNetIcon,
  Router as SubnetIcon,
  Security as NSGIcon,
  Computer as VMIcon,
  Storage as StorageIcon,
} from '@mui/icons-material'
import { ComponentTemplate } from '@/api/designer'

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

interface ComponentPaletteProps {
  components: ComponentTemplate[]
  onDragStart: (event: React.DragEvent, component: ComponentTemplate) => void
}

export const ComponentPalette: React.FC<ComponentPaletteProps> = ({
  components,
  onDragStart,
}) => {
  // Group components by category
  const groupedComponents = components.reduce((acc, component) => {
    const category = component.category || 'other'
    if (!acc[category]) {
      acc[category] = []
    }
    acc[category].push(component)
    return acc
  }, {} as Record<string, ComponentTemplate[]>)

  const categoryNames: Record<string, string> = {
    networking: 'Networking',
    compute: 'Compute',
    storage: 'Storage',
    database: 'Database',
    security: 'Security',
    monitoring: 'Monitoring',
    other: 'Other',
  }

  return (
    <Paper
      sx={{
        height: '100%',
        overflow: 'auto',
        borderRight: 1,
        borderColor: 'divider',
      }}
    >
      <Box p={2}>
        <Typography variant="h6" gutterBottom>
          Components
        </Typography>
        <Typography variant="caption" color="text.secondary">
          Drag and drop to canvas
        </Typography>
      </Box>

      <Divider />

      {Object.entries(groupedComponents).map(([category, items]) => (
        <Accordion key={category} defaultExpanded={category === 'networking'}>
          <AccordionSummary expandIcon={<ExpandMoreIcon />}>
            <Typography variant="subtitle2">
              {categoryNames[category] || category}
              <Typography component="span" variant="caption" color="text.secondary" ml={1}>
                ({items.length})
              </Typography>
            </Typography>
          </AccordionSummary>
          <AccordionDetails sx={{ p: 0 }}>
            <List dense>
              {items.map((component) => (
                <ListItem key={component.type} disablePadding>
                  <ListItemButton
                    draggable
                    onDragStart={(e) => onDragStart(e, component)}
                    sx={{
                      cursor: 'grab',
                      '&:active': {
                        cursor: 'grabbing',
                      },
                      '&:hover': {
                        backgroundColor: 'action.hover',
                      },
                    }}
                  >
                    <ListItemIcon
                      sx={{
                        color: colorMap[component.type] || '#666',
                        minWidth: 40,
                      }}
                    >
                      {iconMap[component.type] || <VNetIcon />}
                    </ListItemIcon>
                    <ListItemText
                      primary={component.name}
                      primaryTypographyProps={{
                        variant: 'body2',
                        fontWeight: 'medium',
                      }}
                      secondary={component.type}
                      secondaryTypographyProps={{
                        variant: 'caption',
                      }}
                    />
                  </ListItemButton>
                </ListItem>
              ))}
            </List>
          </AccordionDetails>
        </Accordion>
      ))}

      {components.length === 0 && (
        <Box p={2} textAlign="center">
          <Typography variant="body2" color="text.secondary">
            No components available
          </Typography>
        </Box>
      )}
    </Paper>
  )
}
