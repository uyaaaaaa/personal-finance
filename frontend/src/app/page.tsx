import Image from "next/image";
import { metadata } from "./metadata";

export default function HomePage() {
  return (
    <main className="flex min-h-screen flex-col items-center justify-center p-24">
      <h1 className="text-4xl font-bold mb-6">家計簿アプリへようこそ</h1>
      <p className="text-xl mb-8">あなたの家計をスマートに管理しましょう</p>
      <div className="flex gap-4">
        <a
          href="/login"
          className="rounded-md bg-indigo-600 px-6 py-3 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600"
        >
          Sign in
        </a>
        <a
          href="/register"
          className="rounded-md bg-white px-6 py-3 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50"
        >
          Sign up
        </a>
      </div>
    </main>
  );
}
