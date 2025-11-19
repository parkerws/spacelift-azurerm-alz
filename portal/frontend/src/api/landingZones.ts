import apiClient from './client'

export interface LandingZone {
  id: number
  name: string
  display_name: string
  description: string
  environment: string
  landing_zone_type: string
  location: string
  address_space: string
  hub_name: string
  monthly_budget?: number
  current_monthly_cost?: number
  status: string
  deployment_id?: string
  deployment_url?: string
  created_at: string
  updated_at: string
  deployed_at?: string
  created_by_id: number
  approved_by_id?: number
  resource_count?: number
}

export interface CreateLandingZoneRequest {
  name: string
  display_name: string
  description?: string
  environment: string
  landing_zone_type: string
  location: string
  address_space: string
  hub_name: string
  monthly_budget?: number
  tags?: Record<string, string>
  configuration?: Record<string, any>
}

export const landingZonesApi = {
  list: async (params?: {
    skip?: number
    limit?: number
    environment?: string
    status?: string
  }) => {
    const response = await apiClient.get('/landing-zones', { params })
    return response.data
  },

  get: async (id: number) => {
    const response = await apiClient.get(`/landing-zones/${id}`)
    return response.data
  },

  create: async (data: CreateLandingZoneRequest) => {
    const response = await apiClient.post('/landing-zones', data)
    return response.data
  },

  update: async (id: number, data: Partial<CreateLandingZoneRequest>) => {
    const response = await apiClient.patch(`/landing-zones/${id}`, data)
    return response.data
  },

  delete: async (id: number) => {
    const response = await apiClient.delete(`/landing-zones/${id}`)
    return response.data
  },

  submit: async (id: number) => {
    const response = await apiClient.post(`/landing-zones/${id}/submit`)
    return response.data
  },

  getStatus: async (id: number) => {
    const response = await apiClient.get(`/landing-zones/${id}/status`)
    return response.data
  },

  getLogs: async (id: number) => {
    const response = await apiClient.get(`/landing-zones/${id}/logs`)
    return response.data
  },

  retry: async (id: number) => {
    const response = await apiClient.post(`/landing-zones/${id}/retry`)
    return response.data
  },
}
