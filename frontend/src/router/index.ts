import { createRouter, createWebHistory } from 'vue-router'
import { isDemoVerified } from '@/api/client'
import DefaultLayout from '@/layouts/DefaultLayout.vue'

const router = createRouter({
  history: createWebHistory(),
  routes: [
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
          path: 'english/episode/:videoId',
          name: 'EpisodePage',
          component: () => import('@/pages/EpisodePage.vue'),
          props: (route) => ({ videoId: route.params.videoId as string, backTo: '/english' }),
          meta: { immersive: true },
        },
        {
          path: 'english/demo/:videoId',
          name: 'DemoEpisode',
          component: () => import('@/pages/EpisodePage.vue'),
          props: (route) => ({ videoId: route.params.videoId as string, backTo: '/demo' }),
          meta: { requiresDemo: true, immersive: true },
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

router.beforeEach((to) => {
  if (to.meta.requiresDemo && !isDemoVerified() && to.path !== '/demo') {
    return '/demo'
  }
})

export default router
