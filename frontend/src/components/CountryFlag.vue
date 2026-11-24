<script setup lang="ts">
defineProps<{ code: string }>()
</script>

<template>
  <span class="inline-block overflow-hidden align-middle">
    <svg v-if="code === 'de'" viewBox="0 0 3 2" class="block h-full w-full">
      <rect width="3" height="0.6667" y="0" fill="#000000" />
      <rect width="3" height="0.6667" y="0.6667" fill="#dd0000" />
      <rect width="3" height="0.6666" y="1.3334" fill="#ffce00" />
    </svg>
    <svg v-else-if="code === 'fr'" viewBox="0 0 3 2" class="block h-full w-full">
      <rect width="1" height="2" x="0" fill="#0055a4" />
      <rect width="1" height="2" x="1" fill="#ffffff" />
      <rect width="1" height="2" x="2" fill="#ef4135" />
    </svg>
    <svg v-else-if="code === 'es'" viewBox="0 0 3 2" class="block h-full w-full">
      <rect width="3" height="2" fill="#c60b1e" />
      <rect width="3" height="1" y="0.5" fill="#ffc400" />
    </svg>
    <svg v-else-if="code === 'pt'" viewBox="0 0 3 2" class="block h-full w-full">
      <rect width="3" height="2" fill="#da291c" />
      <rect width="1.2" height="2" x="0" fill="#046a38" />
      <circle cx="1.2" cy="1" r="0.36" fill="#ffe000" />
    </svg>
    <svg v-else-if="code === 'ja'" viewBox="0 0 3 2" class="block h-full w-full">
      <rect width="3" height="2" fill="#ffffff" />
      <circle cx="1.5" cy="1" r="0.6" fill="#bc002d" />
    </svg>
    <svg v-else-if="code === 'ko'" viewBox="0 0 3 2" class="block h-full w-full">
      <rect width="3" height="2" fill="#ffffff" />
      <circle cx="1.5" cy="1" r="0.5" fill="#cd2e3a" />
      <path d="M1 1a0.5 0.5 0 0 0 1 0z" fill="#0047a0" />
    </svg>
    <svg v-else-if="code === 'zh'" viewBox="0 0 30 20" class="block h-full w-full">
      <rect width="30" height="20" fill="#de2910" />
      <g fill="#ffde00">
        <polygon points="5,3 5.9,6.1 9.2,6.1 6.5,8.1 7.4,11.2 5,9.2 2.6,11.2 3.5,8.1 0.8,6.1 4.1,6.1" />
        <polygon points="10,2 10.4,3.3 11.8,3.3 10.7,4.1 11.1,5.4 10,4.6 8.9,5.4 9.3,4.1 8.2,3.3 9.6,3.3" />
        <polygon points="12,4.5 12.4,5.8 13.8,5.8 12.7,6.6 13.1,7.9 12,7.1 10.9,7.9 11.3,6.6 10.2,5.8 11.6,5.8" />
        <polygon points="12,8 12.4,9.3 13.8,9.3 12.7,10.1 13.1,11.4 12,10.6 10.9,11.4 11.3,10.1 10.2,9.3 11.6,9.3" />
        <polygon points="10,10.5 10.4,11.8 11.8,11.8 10.7,12.6 11.1,13.9 10,13.1 8.9,13.9 9.3,12.6 8.2,11.8 9.6,11.8" />
      </g>
    </svg>
    <svg v-else viewBox="0 0 60 30" class="block h-full w-full" preserveAspectRatio="none">
      <rect width="60" height="30" fill="#012169" />
      <path d="M0 0 60 30M60 0 0 30" stroke="#ffffff" stroke-width="6" />
      <path d="M0 0 60 30M60 0 0 30" stroke="#c8102e" stroke-width="2.5" />
      <path d="M30 0V30M0 15H60" stroke="#ffffff" stroke-width="10" />
      <path d="M30 0V30M0 15H60" stroke="#c8102e" stroke-width="6" />
    </svg>
  </span>
</template>
