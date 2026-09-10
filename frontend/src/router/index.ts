import {
  createRouter,
  createWebHashHistory,
  createWebHistory,
  type RouteRecordRaw,
} from 'vue-router'
import DefaultLayout from '@/layouts/DefaultLayout.vue'
import { useAuthStore } from '@/stores/auth'
import { useSiteConfigStore } from '@/stores/siteConfig'
import { isMobileAppBuild } from '@/utils/platform'

const isMobile = isMobileAppBuild()

const adminRoutes: RouteRecordRaw[] = [
  {
    path: '/gnadmin/login',
    name: 'AdminLogin',
    component: () => import('@/pages/admin/AdminLoginPage.vue'),
    meta: { adminGuest: true },
  },
  {
    path: '/gnadmin/preview/:videoId',
    name: 'AdminEpisodePreview',
    component: () => import('@/pages/EpisodePage.vue'),
    props: (route) => ({
      videoId: route.params.videoId as string,
      backTo: '/gnadmin/episodes',
      adminPreview: true,
    }),
    meta: { requiresAdmin: true },
  },
  {
    path: '/gnadmin',
    component: () => import('@/layouts/AdminLayout.vue'),
    meta: { requiresAdmin: true },
    children: [
      { path: '', redirect: '/gnadmin/dashboard' },
      {
        path: 'dashboard',
        name: 'AdminDashboard',
        component: () => import('@/pages/admin/AdminDashboardPage.vue'),
      },
      {
        path: 'activation-codes',
        name: 'AdminActivationCodes',
        component: () => import('@/pages/admin/AdminActivationCodesPage.vue'),
      },
      {
        path: 'membership-orders',
        name: 'AdminMembershipOrders',
        component: () => import('@/pages/admin/AdminMembershipOrdersPage.vue'),
      },
      {
        path: 'users',
        name: 'AdminUsers',
        component: () => import('@/pages/admin/AdminUsersPage.vue'),
      },
      {
        path: 'geo',
        name: 'AdminGeo',
        component: () => import('@/pages/admin/AdminGeoPage.vue'),
      },
      {
        path: 'notifications',
        name: 'AdminNotifications',
        component: () => import('@/pages/admin/AdminNotificationsPage.vue'),
      },
      {
        path: 'feedback',
        name: 'AdminFeedback',
        component: () => import('@/pages/admin/AdminFeedbackPage.vue'),
      },
      {
        path: 'wish-wall',
        name: 'AdminWishWall',
        component: () => import('@/pages/admin/AdminWishWallPage.vue'),
      },
      {
        path: 'app',
        name: 'AdminApp',
        component: () => import('@/pages/admin/AdminAppPage.vue'),
      },
      {
        path: 'learning',
        name: 'AdminLearning',
        component: () => import('@/pages/admin/AdminLearningPage.vue'),
      },
      {
        path: 'ai-usage',
        name: 'AdminAiUsage',
        component: () => import('@/pages/admin/AdminAiUsagePage.vue'),
      },
      {
        path: 'episodes',
        name: 'AdminEpisodes',
        component: () => import('@/pages/admin/AdminEpisodesPage.vue'),
      },
      {
        path: 'episodes/new',
        name: 'AdminEpisodeNew',
        component: () => import('@/pages/admin/AdminEpisodeEditPage.vue'),
      },
      {
        path: 'episodes/:id',
        name: 'AdminEpisodeEdit',
        component: () => import('@/pages/admin/AdminEpisodeEditPage.vue'),
      },
      {
        path: 'series',
        name: 'AdminSeries',
        component: () => import('@/pages/admin/AdminSeriesPage.vue'),
      },
      {
        path: 'reading',
        name: 'AdminReading',
        component: () => import('@/pages/admin/AdminReadingListPage.vue'),
      },
      {
        path: 'reading/new',
        name: 'AdminReadingNew',
        component: () => import('@/pages/admin/AdminReadingEditPage.vue'),
      },
      {
        path: 'reading/:id',
        name: 'AdminReadingEdit',
        component: () => import('@/pages/admin/AdminReadingEditPage.vue'),
      },
      {
        path: 'import',
        name: 'AdminImport',
        component: () => import('@/pages/admin/AdminImportPage.vue'),
      },
      {
        path: 'demo-codes',
        name: 'AdminDemoCodes',
        component: () => import('@/pages/admin/AdminDemoCodesPage.vue'),
      },
      {
        path: 'authors',
        name: 'AdminAuthors',
        component: () => import('@/pages/admin/AdminAuthorsPage.vue'),
      },
      {
        path: 'tags',
        name: 'AdminTags',
        component: () => import('@/pages/admin/AdminTagsPage.vue'),
      },
    ],
  },
]

/** App MVP 暂不含投稿 */
const memberSubmitRoutes: RouteRecordRaw[] = [
  {
    path: 'english/submit',
    name: 'SubmitEpisode',
    component: () => import('@/pages/SubmitEpisodePage.vue'),
    meta: { requiresAuth: true, requiresMember: true },
  },
  {
    path: 'english/submit-article',
    name: 'SubmitArticle',
    component: () => import('@/pages/SubmitArticlePage.vue'),
    meta: { requiresAuth: true, requiresMember: true },
  },
  {
    path: 'english/my-submissions',
    name: 'MySubmissions',
    component: () => import('@/pages/MySubmissionsPage.vue'),
    meta: { requiresAuth: true, requiresMember: true },
  },
]

const userRoutes: RouteRecordRaw[] = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/pages/LoginPage.vue'),
    meta: { authPage: true },
  },
  {
    path: '/signup',
    name: 'Signup',
    component: () => import('@/pages/SignupPage.vue'),
    meta: { authPage: true },
  },
  {
    path: '/pricing',
    name: 'Pricing',
    component: () => import('@/pages/PricingPage.vue'),
    meta: { authPage: true, requiresAuth: true },
  },
  {
    path: '/pricing/result',
    name: 'PricingResult',
    component: () => import('@/pages/PricingResultPage.vue'),
    meta: { authPage: true, requiresAuth: true },
  },
  {
    path: '/price',
    redirect: '/pricing',
  },
  {
    path: '/forgot-password',
    name: 'ForgotPassword',
    component: () => import('@/pages/ForgotPasswordPage.vue'),
    meta: { authPage: true },
  },
  {
    path: '/reset-password',
    name: 'ResetPassword',
    component: () => import('@/pages/ResetPasswordPage.vue'),
    meta: { authPage: true },
  },
  {
    path: '/',
    component: DefaultLayout,
    children: [
      { path: '', redirect: '/english' },
      {
        path: 'english',
        name: 'HomePage',
        component: () => import('@/pages/HomePage.vue'),
        meta: { requiresAuth: true },
      },
      {
        path: 'english/series',
        name: 'SeriesList',
        component: () => import('@/pages/SeriesListPage.vue'),
        meta: { requiresAuth: true },
      },
      {
        path: 'english/series/:slug',
        name: 'SeriesDetail',
        component: () => import('@/pages/SeriesDetailPage.vue'),
        meta: { requiresAuth: true },
      },
      {
        path: 'english/authors/:authorId',
        name: 'AuthorDetail',
        component: () => import('@/pages/AuthorDetailPage.vue'),
        meta: { requiresAuth: true },
      },
      {
        path: 'english/reading',
        name: 'NewsReadingList',
        component: () => import('@/pages/NewsReadingListPage.vue'),
        meta: { requiresAuth: true },
      },
      {
        path: 'english/study',
        name: 'StudyGuide',
        component: () => import('@/pages/StudyGuidePage.vue'),
        meta: { requiresAuth: true },
      },
      {
        path: 'english/reading/:articleId/typing',
        name: 'ArticleTyping',
        component: () => import('@/pages/ArticleTypingPage.vue'),
        meta: { immersive: true, requiresAuth: true },
      },
      {
        path: 'english/reading/:articleId',
        name: 'NewsReading',
        component: () => import('@/pages/NewsReadingPage.vue'),
        meta: { immersive: true, requiresAuth: true },
      },
      {
        path: 'english/episode/:videoId',
        name: 'EpisodePage',
        component: () => import('@/pages/EpisodePage.vue'),
        props: (route) => ({ videoId: route.params.videoId as string, backTo: '/english' }),
        meta: { immersive: true, requiresAuth: true },
      },
      {
        path: 'english/demo/:videoId',
        name: 'DemoEpisode',
        component: () => import('@/pages/EpisodePage.vue'),
        props: (route) => ({ videoId: route.params.videoId as string, backTo: '/english' }),
        meta: { immersive: true },
      },
      {
        path: 'activate',
        redirect: '/english',
      },
      ...(isMobile ? [] : memberSubmitRoutes),
      {
        path: 'english/notifications',
        name: 'Notifications',
        component: () => import('@/pages/NotificationsPage.vue'),
        meta: { requiresAuth: true },
      },
      {
        path: 'english/learning',
        name: 'Learning',
        component: () => import('@/pages/LearningPage.vue'),
        meta: { requiresAuth: true },
      },
      {
        path: 'english/vocabulary',
        name: 'Vocabulary',
        component: () => import('@/pages/VocabularyPage.vue'),
        meta: { requiresAuth: true },
      },
      {
        path: 'english/clips',
        name: 'Clips',
        component: () => import('@/pages/ClipsPage.vue'),
        meta: { requiresAuth: true },
      },
      {
        path: 'english/word-practice',
        name: 'WordPractice',
        component: () => import('@/pages/WordPracticePage.vue'),
        meta: { requiresAuth: true },
      },
      {
        path: 'english/wish-wall',
        name: 'WishWall',
        component: () => import('@/pages/WishWallPage.vue'),
        meta: { requiresAuth: true },
      },
    ],
  },
  {
    path: '/demo',
    name: 'DemoPage',
    component: () => import('@/pages/DemoPage.vue'),
  },
  {
    path: '/download',
    name: 'AppDownload',
    component: () => import('@/pages/AppDownloadPage.vue'),
  },
]

const routes: RouteRecordRaw[] = isMobile ? userRoutes : [...adminRoutes, ...userRoutes]

const router = createRouter({
  // App 本地加载用 Hash；Web 仍用 History
  history: isMobile ? createWebHashHistory() : createWebHistory(),
  routes,
})

router.beforeEach(async (to) => {
  if (to.path.startsWith('/gnadmin')) {
    const { useAdminAuthStore } = await import('@/stores/adminAuth')
    const adminAuth = useAdminAuthStore()
    if (!adminAuth.ready) {
      if (to.meta.adminGuest) {
        adminAuth.resetForGuest()
      } else {
        await adminAuth.hydrate()
      }
    }

    if (to.meta.requiresAdmin && !adminAuth.isLoggedIn) {
      return { path: '/gnadmin/login', query: { next: to.fullPath } }
    }
    if (to.meta.adminGuest && adminAuth.isLoggedIn) {
      return '/gnadmin/dashboard'
    }
    return
  }

  const auth = useAuthStore()
  const siteConfig = useSiteConfigStore()
  if (!auth.ready) {
    await auth.hydrate()
  }
  if (!siteConfig.ready) {
    await siteConfig.hydrate()
  }

  if (to.meta.requiresAuth && !auth.isLoggedIn) {
    return { path: '/login', query: { next: to.fullPath } }
  }

  // 关会员内容限制时，登录用户即可使用上传/语料库，不强制跳转开通页
  if (
    to.meta.requiresMember &&
    auth.isLoggedIn &&
    !auth.isMember &&
    siteConfig.isContentGated
  ) {
    return { path: '/pricing', query: { next: to.fullPath } }
  }
})

export default router
