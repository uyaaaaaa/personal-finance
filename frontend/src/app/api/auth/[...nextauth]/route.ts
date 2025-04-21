import NextAuth from "next-auth";
import GoogleProvider from "next-auth/providers/google";

const handler = NextAuth({
  providers: [
    GoogleProvider({
      clientId: process.env.GOOGLE_CLIENT_ID as string,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET as string,
    }),
  ],
  callbacks: {
    async jwt({ token, account }) {
      // アクセストークンをJWTに保存
      if (account) {
        token.accessToken = account.access_token;
      }
      return token;
    },
    async session({ session, token }) {
      // セッションにアクセストークンを追加
      session.accessToken = token.accessToken;
      return session;
    },
  },
  pages: {
    signIn: '/login',
  },
});

export { handler as GET, handler as POST }; 