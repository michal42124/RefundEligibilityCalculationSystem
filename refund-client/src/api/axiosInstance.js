import axios from 'axios';

// instance משותף לכל קריאות ה-API
const api = axios.create({ baseURL: 'https://localhost:7047/api' });

export default api;