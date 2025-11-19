import { Routes, Route, Navigate } from 'react-router-dom'
import { Box } from '@mui/material'
import Layout from './components/Layout'
import Login from './pages/Login'
import Dashboard from './pages/Dashboard'
import LandingZones from './pages/LandingZones'
import CreateLandingZone from './pages/CreateLandingZone'
import LandingZoneDetail from './pages/LandingZoneDetail'
import Approvals from './pages/Approvals'
import Templates from './pages/Templates'
import Costs from './pages/Costs'
import { useAuth } from './contexts/AuthContext'

function App() {
  const { user, loading } = useAuth()

  if (loading) {
    return (
      <Box
        display="flex"
        justifyContent="center"
        alignItems="center"
        minHeight="100vh"
      >
        Loading...
      </Box>
    )
  }

  if (!user) {
    return (
      <Routes>
        <Route path="/login" element={<Login />} />
        <Route path="*" element={<Navigate to="/login" />} />
      </Routes>
    )
  }

  return (
    <Layout>
      <Routes>
        <Route path="/" element={<Dashboard />} />
        <Route path="/landing-zones" element={<LandingZones />} />
        <Route path="/landing-zones/create" element={<CreateLandingZone />} />
        <Route path="/landing-zones/:id" element={<LandingZoneDetail />} />
        <Route path="/approvals" element={<Approvals />} />
        <Route path="/templates" element={<Templates />} />
        <Route path="/costs" element={<Costs />} />
        <Route path="*" element={<Navigate to="/" />} />
      </Routes>
    </Layout>
  )
}

export default App
