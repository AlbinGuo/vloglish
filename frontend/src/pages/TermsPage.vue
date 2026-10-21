<script setup lang="ts">
import { useRouter } from 'vue-router'

const router = useRouter()

function back() {
  if (window.history.length > 1) router.back()
  else void router.push('/english')
}
</script>

<template>
  <div class="min-h-screen bg-bg text-ink">
    <div class="mx-auto max-w-2xl px-4 pb-16 pt-4">
      <button
        type="button"
        class="mb-4 inline-flex items-center gap-1 text-[13px] text-ink-faint hover:text-ink"
        @click="back"
      >
        <span aria-hidden="true">‹</span> 返回
      </button>

      <h1 class="text-xl font-bold">用户协议</h1>
      <p class="mt-1 text-[12px] text-ink-faint">生效日期：2026-01-01 · 版本 v1.0</p>

      <p class="mt-4 text-[13px] leading-relaxed text-ink-soft">
        欢迎使用 Vloglish（以下简称「本应用」）。本协议是你与我们之间就使用本应用所订立的约定。你开始使用即视为已阅读并同意本协议。
      </p>

      <section class="mt-6 space-y-2">
        <h2 class="text-[15px] font-semibold">一、服务内容</h2>
        <p class="text-[13px] leading-relaxed text-ink-soft">
          本应用提供英语学习相关的视频/文章精听、生词与 AI 辅助等功能。具体功能以应用实际提供为准，我们可能对服务进行更新或调整。
        </p>
      </section>

      <section class="mt-6 space-y-2">
        <h2 class="text-[15px] font-semibold">二、账号</h2>
        <p class="text-[13px] leading-relaxed text-ink-soft">
          你应妥善保管账号与密码，并对账号下的行为负责。如发现账号被盗用，请及时联系我们。你可以在 App 内「我的」页底部的「设置」区块中注销账号。
        </p>
      </section>

      <section class="mt-6 space-y-2">
        <h2 class="text-[15px] font-semibold">三、会员与付费</h2>
        <ul class="list-disc space-y-1 pl-5 text-[13px] leading-relaxed text-ink-soft">
          <li>会员包含订阅（周/季度/年度）与永久买断等类型，具体价格与权益以购买页展示为准。</li>
          <li>通过 Apple App 内购买支付的订阅为<b>自动续期</b>，将在当前周期结束前 24 小时内自动扣费；你可随时在 App Store 的「订阅」中管理或取消。</li>
          <li>退款、续订与取消遵循 Apple App Store 的相关规则。</li>
          <li>购买后可点击「恢复购买」找回已购权益。</li>
        </ul>
      </section>

      <section class="mt-6 space-y-2">
        <h2 class="text-[15px] font-semibold">四、用户行为规范</h2>
        <p class="text-[13px] leading-relaxed text-ink-soft">
          你不得利用本应用从事违法、侵权、传播有害信息或干扰服务正常运行的行为，不得以技术手段获取未授权的付费内容。
        </p>
      </section>

      <section class="mt-6 space-y-2">
        <h2 class="text-[15px] font-semibold">五、知识产权</h2>
        <p class="text-[13px] leading-relaxed text-ink-soft">
          本应用内的软件、界面、内容及商标等权利归我们或相应权利人所有。未经许可，你不得复制、传播或用于商业用途。
        </p>
      </section>

      <section class="mt-6 space-y-2">
        <h2 class="text-[15px] font-semibold">六、免责声明</h2>
        <p class="text-[13px] leading-relaxed text-ink-soft">
          我们会尽力保障服务稳定与内容准确，但不对因网络、设备、第三方等原因造成的服务中断或数据损失承担超出法律规定范围的责任。
        </p>
      </section>

      <section class="mt-6 space-y-2">
        <h2 class="text-[15px] font-semibold">七、协议变更与终止</h2>
        <p class="text-[13px] leading-relaxed text-ink-soft">
          我们可能更新本协议，重大变更将通过应用内公告告知。若你不同意变更，可停止使用并注销账号。
        </p>
      </section>

      <section class="mt-6 space-y-2">
        <h2 class="text-[15px] font-semibold">八、联系我们</h2>
        <p class="text-[13px] leading-relaxed text-ink-soft">
          如对本协议有疑问，请联系：<b>&lt;请填写你的联系邮箱&gt;</b>。
        </p>
      </section>
    </div>
  </div>
</template>
