export async function fetchWithAuth(endpoint: string, options: RequestInit = {}) {
  const baseApiUrl = process.env.NEXT_PUBLIC_API_URL + '/api';

  try {
    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
      ...(options.headers as Record<string, string> || {}),
    };

    const response = await fetch(`${baseApiUrl}${endpoint}`, {
      ...options,
      headers,
    });

    if (response.status === 401) {
      console.log('Unauthorized request.');
      return;
    }

    return await response.json();
  } catch (error) {
    console.error('API request error:', error);
    throw error;
  }
}
