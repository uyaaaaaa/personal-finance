"use client";

import React, { useEffect } from 'react';
import { useSession, signOut } from 'next-auth/react';
import { useRouter } from 'next/navigation';

export default function DashboardPage() {
  const { data: session, status } = useSession();
  const router = useRouter();

  useEffect(() => {
    if (status === 'unauthenticated') {
      router.push('/login');
    }
  }, [status, router]);

  if (status === 'loading') {
    return (
      <div className="flex min-h-screen items-center justify-center">
        <div className="text-center">
          <div className="mb-4 h-12 w-12 animate-spin rounded-full border-4 border-indigo-600 border-t-transparent mx-auto"></div>
          <p className="text-gray-600">読み込み中...</p>
        </div>
      </div>
    );
  }

  if (!session) {
    return null; // useEffectでリダイレクトするので空を返す
  }

  return (
    <div className="min-h-screen bg-gray-50 py-12">
      <div className="mx-auto max-w-4xl px-4 sm:px-6 lg:px-8">
        <div className="bg-white rounded-lg shadow p-6 sm:p-8">
          <div className="mb-6 text-center sm:text-left">
            <h1 className="text-2xl font-bold text-gray-900">
              {session.user?.name || 'ユーザー'}さん、こんにちは！
            </h1>
            <p className="mt-1 text-gray-500">{session.user?.email}</p>
            <button
              onClick={() => signOut({ callbackUrl: '/' })}
              className="mt-4 inline-flex items-center justify-center rounded-md border border-transparent bg-indigo-600 px-4 py-2 text-sm font-medium text-white shadow-sm hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2"
            >
              ログアウト
            </button>
          </div>
          
          <div className="border-t border-gray-200 pt-6">
            <h2 className="text-lg font-medium text-gray-900">家計簿の概要</h2>
            <div className="mt-4 grid grid-cols-1 gap-4 sm:grid-cols-3">
              <div className="rounded-lg bg-white overflow-hidden border border-gray-200">
                <div className="bg-indigo-50 px-4 py-2">
                  <h3 className="text-sm font-medium text-indigo-900">今月の収入</h3>
                </div>
                <div className="px-4 py-4">
                  <p className="text-2xl font-semibold text-gray-900">¥0</p>
                </div>
              </div>
              <div className="rounded-lg bg-white overflow-hidden border border-gray-200">
                <div className="bg-rose-50 px-4 py-2">
                  <h3 className="text-sm font-medium text-rose-900">今月の支出</h3>
                </div>
                <div className="px-4 py-4">
                  <p className="text-2xl font-semibold text-gray-900">¥0</p>
                </div>
              </div>
              <div className="rounded-lg bg-white overflow-hidden border border-gray-200">
                <div className="bg-emerald-50 px-4 py-2">
                  <h3 className="text-sm font-medium text-emerald-900">今月の残高</h3>
                </div>
                <div className="px-4 py-4">
                  <p className="text-2xl font-semibold text-gray-900">¥0</p>
                </div>
              </div>
            </div>
            
            <div className="mt-8 text-center">
              <p className="text-gray-600">データはまだありません。家計簿の記録を始めましょう！</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
} 