<script setup lang="ts">
import { useRouter } from 'vue-router'
import AppIcon from '@/components/AppIcon.vue'

const router = useRouter()

function back() {
  if (window.history.length > 1) router.back()
  else void router.push('/english')
}
</script>

<template>
  <div class="flex min-h-dvh flex-col bg-canvas text-ink">
    <header
      class="sticky top-0 z-20 flex items-center gap-3 border-b border-line-soft bg-canvas px-4 pb-3 pt-[calc(0.75rem+env(safe-area-inset-top,0px))]"
    >
      <button
        type="button"
        class="inline-flex h-9 w-9 items-center justify-center rounded-full bg-sunken text-ink-soft transition active:scale-95"
        aria-label="返回"
        @click="back"
      >
        <AppIcon name="chevron-left" class="h-5 w-5" />
      </button>
      <h1 class="flex-1 text-[16px] font-semibold tracking-tight">隐私政策</h1>
    </header>

    <div class="mx-auto w-full max-w-2xl px-4 pb-16 pt-5">
      <p class="text-[12px] text-ink-faint">生效日期：2026-01-01 · 版本 v1.0</p>

      <p class="mt-4 text-[13px] leading-relaxed text-ink-soft">
        Vloglish（以下简称「本应用」「我们」）重视你的个人信息与隐私保护。本政策说明我们如何收集、使用、存储和保护你的信息，以及你享有的权利。请在使用本应用前仔细阅读。
      </p>

      <section class="mt-6 space-y-2">
        <h2 class="text-[15px] font-semibold">一、我们收集的信息</h2>
        <ul class="list-disc space-y-1 pl-5 text-[13px] leading-relaxed text-ink-soft">
          <li><b>账号信息</b>：邮箱、加密后的密码；微信绑定标识（仅在你主动绑定并用于接收通知/客服时）。</li>
          <li><b>学习与使用数据</b>：生词本、学习进度、播放记录、收藏、练习与提交内容等。</li>
          <li><b>设备与日志</b>：设备型号、系统版本、应用版本、崩溃与运行日志、网络状态。</li>
          <li><b>支付信息</b>：通过 Apple App 内购买或微信支付完成。支付凭据由平台处理，我们<b>不存储你的银行卡/支付账号</b>。</li>
        </ul>
      </section>

      <section class="mt-6 space-y-2">
        <h2 class="text-[15px] font-semibold">二、我们如何使用信息</h2>
        <ul class="list-disc space-y-1 pl-5 text-[13px] leading-relaxed text-ink-soft">
          <li>提供并维护核心功能（学习、复习、播放、AI 辅助等）；</li>
          <li>识别会员权益、处理付费与续订；</li>
          <li>保障账号与服务安全、排查故障、改进体验；</li>
          <li>在取得你同意的前提下发送与服务相关的通知。</li>
        </ul>
      </section>

      <section class="mt-6 space-y-2">
        <h2 class="text-[15px] font-semibold">三、第三方服务</h2>
        <p class="text-[13px] leading-relaxed text-ink-soft">
          为提供服务，我们可能使用 Apple（App 内购买）、微信（绑定/客服）、以及云端存储与 AI 处理等第三方服务。我们仅向其提供实现功能所必需的信息，并要求其遵守相应的数据保护义务。
        </p>
      </section>

      <section class="mt-6 space-y-2">
        <h2 class="text-[15px] font-semibold">四、数据存储与保留</h2>
        <p class="text-[13px] leading-relaxed text-ink-soft">
          你的信息存储于我们的服务器，并在实现本政策所述目的所需的期限内保留。依法须留存的交易/财务记录会在法律要求的期限内保留并去标识化，其余个人数据在账号注销后删除。
        </p>
      </section>

      <section class="mt-6 space-y-2">
        <h2 class="text-[15px] font-semibold">五、你的权利与账号注销</h2>
        <p class="text-[13px] leading-relaxed text-ink-soft">
          你有权访问、更正你的个人信息，或注销账号。你可以在 App 内「我的」页底部的「设置」区块中找到「注销账号」入口完成注销；注销后账号将被删除或匿名化、个人数据将被清除（依法须留存的交易记录除外），且无法恢复。
        </p>
      </section>

      <section class="mt-6 space-y-2">
        <h2 class="text-[15px] font-semibold">六、未成年人保护</h2>
        <p class="text-[13px] leading-relaxed text-ink-soft">
          本应用面向一般用户。若你为未成年人，应在监护人指导下使用并提交信息。我们不会在明知的情况下收集儿童的个人信息。
        </p>
      </section>

      <section class="mt-6 space-y-2">
        <h2 class="text-[15px] font-semibold">七、信息安全</h2>
        <p class="text-[13px] leading-relaxed text-ink-soft">
          我们采用加密传输、访问控制等措施保护你的信息，但互联网环境并非绝对安全，请妥善保管账号密码。
        </p>
      </section>

      <section class="mt-6 space-y-2">
        <h2 class="text-[15px] font-semibold">八、政策更新</h2>
        <p class="text-[13px] leading-relaxed text-ink-soft">
          我们可能不时更新本政策。重大变更将通过应用内通知或页面公告告知。
        </p>
      </section>

      <section class="mt-6 space-y-2">
        <h2 class="text-[15px] font-semibold">九、联系我们</h2>
        <p class="text-[13px] leading-relaxed text-ink-soft">
          如对本政策有任何疑问，请联系：<b>838093891@qq.com</b>。
        </p>
      </section>
    </div>
  </div>
</template>
