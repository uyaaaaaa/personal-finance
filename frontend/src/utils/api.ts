// バックエンドAPIとの通信を行うためのユーティリティ関数

// APIリクエストの基本設定
const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL;

// 認証済みリクエストを実行する関数
export async function fetchWithAuth(endpoint: string, options: RequestInit = {}) {
  try {
    // セッションストレージからJWTトークンを取得
    // クライアントサイドのみで実行されるコード
    const session = typeof window !== 'undefined' ?
      JSON.parse(sessionStorage.getItem('next-auth.session-token') || '{}') : {};

    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
      ...(options.headers as Record<string, string> || {}),
    };

    // アクセストークンがあればAuthorizationヘッダーに追加
    if (session.accessToken) {
      headers['Authorization'] = `Bearer ${session.accessToken}`;
    }

    const response = await fetch(`${API_BASE_URL}${endpoint}`, {
      ...options,
      headers,
    });

    if (!response.ok) {
      throw new Error(`API request failed with status ${response.status}`);
    }

    return await response.json();
  } catch (error) {
    console.error('API request error:', error);
    throw error;
  }
}

// ユーザープロフィール情報を取得する関数の例
export async function getUserProfile() {
  return fetchWithAuth('/user/profile');
}

// その他APIエンドポイント関数...
