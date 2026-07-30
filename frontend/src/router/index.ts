import { createRouter, createWebHistory } from 'vue-router'
import DefaultLayout from '@/layouts/DefaultLayout.vue'
import AdminLayout from '@/layouts/AdminLayout.vue'
import { useAdminAuthStore } from '@/stores/adminAuth'
import { useAuthStore } from '@/stores/auth'

const router = createRouter({
  history: createWebHistory(),
  routes: [
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
      component: AdminLayout,
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
          path: 'learning',
          name: 'AdminLearning',
          component: () => import('@/pages/admin/AdminLearningPage.vue'),
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
      meta: { authPage: true },
    },
    {
      path: '/pricing/result',
      name: 'PricingResult',
      component: () => import('@/pages/PricingResultPage.vue'),
      meta: { authPage: true },
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
        },
        {
          path: 'english/series',
          name: 'SeriesList',
          component: () => import('@/pages/SeriesListPage.vue'),
        },
        {
          path: 'english/series/:slug',
          name: 'SeriesDetail',
          component: () => import('@/pages/SeriesDetailPage.vue'),
        },
        {
          path: 'english/authors/:authorId',
          name: 'AuthorDetail',
          component: () => import('@/pages/AuthorDetailPage.vue'),
        },
        {
          path: 'english/reading',
          name: 'NewsReadingList',
          component: () => import('@/pages/NewsReadingListPage.vue'),
        },
        {
          path: 'english/reading/:articleId',
          name: 'NewsReading',
          component: () => import('@/pages/NewsReadingPage.vue'),
          meta: { immersive: true },
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
        {
          path: 'english/submit',
          name: 'SubmitEpisode',
          component: () => import('@/pages/SubmitEpisodePage.vue'),
          meta: { requiresAuth: true, requiresMember: true },
        },
        {
          path: 'english/my-submissions',
          name: 'MySubmissions',
          component: () => import('@/pages/MySubmissionsPage.vue'),
          meta: { requiresAuth: true, requiresMember: true },
        },
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
      ],
    },
    {
      path: '/demo',
      name: 'DemoPage',
      component: () => import('@/pages/DemoPage.vue'),
    },
  ],
})

router.beforeEach(async (to) => {
  if (to.path.startsWith('/gnadmin')) {
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
  if (!auth.ready) {
    await auth.hydrate()
  }

  if (to.meta.requiresAuth && !auth.isLoggedIn) {
    return { path: '/login', query: { next: to.fullPath } }
  }

  if (to.meta.requiresMember && auth.isLoggedIn && !auth.isMember) {
    return '/english'
  }
})

export default router
