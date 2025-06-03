"use client";

export default function LoginPage() {

  return (
    <div className="flex flex-col items-center justify-center min-h-screen bg-gray-900">
      <h2 className="mb-6 text-center text-2xl font-bold text-white">
        Sign in
      </h2>
      <button
        onClick={handleGoogleLogin}
        className="flex items-center gap-2 px-6 py-3 bg-white text-gray-800 rounded shadow hover:bg-gray-100 transition"
      >
        Googleでログイン
      </button>
    </div>
  );
}
