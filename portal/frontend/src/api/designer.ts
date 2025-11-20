import apiClient from './client'

export interface DiagramNode {
  id: string
  type: string
  position: { x: number; y: number }
  data: Record<string, any>
  style?: Record<string, any>
}

export interface DiagramEdge {
  id: string
  source: string
  target: string
  type?: string
  data?: Record<string, any>
  style?: Record<string, any>
}

export interface DiagramData {
  nodes: DiagramNode[]
  edges: DiagramEdge[]
  viewport?: { x: number; y: number; zoom: number }
}

export interface Project {
  id: number
  name: string
  description: string
  created_by_id: number
  diagram: DiagramData
  configuration: Record<string, any>
  generated_terraform: Record<string, string>
  generated_pipeline: Record<string, any>
  status: string
  environment: string
  deployment_platform: string
  import_source?: string
  import_filename?: string
  landing_zone_id?: number
  created_at: string
  updated_at?: string
  generated_at?: string
  deployed_at?: string
}

export interface ComponentTemplate {
  id: number
  type: string
  name: string
  category: string
  icon?: string
  terraform_module?: string
  schema: {
    inputs: Array<{
      name: string
      type: string
      required: boolean
      description?: string
    }>
    outputs?: Array<{
      name: string
      description?: string
    }>
  }
  default_config: Record<string, any>
  ui_config: {
    width?: number
    height?: number
    color?: string
  }
}

export interface CreateProjectRequest {
  name: string
  description?: string
  environment?: string
  deployment_platform?: string
  diagram?: DiagramData
  configuration?: Record<string, any>
}

export interface UpdateProjectRequest {
  name?: string
  description?: string
  diagram?: DiagramData
  configuration?: Record<string, any>
  environment?: string
  deployment_platform?: string
}

export interface GenerateTerraformResponse {
  files: Record<string, string>
  validation_errors: string[]
  warnings: string[]
}

export interface ValidationResponse {
  valid: boolean
  errors: Array<{
    node_id: string
    field: string
    message: string
    severity: string
  }>
  warnings: Array<{
    node_id: string
    field: string
    message: string
    severity: string
  }>
}

export const designerApi = {
  // Projects
  listProjects: async (params?: { skip?: number; limit?: number; status?: string }) => {
    const response = await apiClient.get('/designer/projects', { params })
    return response.data
  },

  getProject: async (id: number) => {
    const response = await apiClient.get(`/designer/projects/${id}`)
    return response.data
  },

  createProject: async (data: CreateProjectRequest) => {
    const response = await apiClient.post('/designer/projects', data)
    return response.data
  },

  updateProject: async (id: number, data: UpdateProjectRequest) => {
    const response = await apiClient.patch(`/designer/projects/${id}`, data)
    return response.data
  },

  deleteProject: async (id: number) => {
    const response = await apiClient.delete(`/designer/projects/${id}`)
    return response.data
  },

  // Code Generation
  generateTerraform: async (id: number, validate: boolean = true) => {
    const response = await apiClient.post<GenerateTerraformResponse>(
      `/designer/projects/${id}/generate/terraform`,
      { validate, format: true }
    )
    return response.data
  },

  validateProject: async (id: number) => {
    const response = await apiClient.post<ValidationResponse>(
      `/designer/projects/${id}/validate`
    )
    return response.data
  },

  // Components
  listComponents: async (category?: string) => {
    const response = await apiClient.get('/designer/components', {
      params: category ? { category } : undefined,
    })
    return response.data
  },

  getComponent: async (type: string) => {
    const response = await apiClient.get(`/designer/components/${type}`)
    return response.data
  },
}
