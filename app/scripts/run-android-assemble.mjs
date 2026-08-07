/**
 * 为 Android 打包定位可用的 JDK（≥21，且必须带 jlink），并执行 gradlew assembleDebug。
 * Capacitor 7 / AGP 的 JdkImageTransform 需要 jlink；部分 IDE 精简 JBR 没有该工具。
 */
import { spawnSync } from 'node:child_process'
import fs from 'node:fs'
import path from 'node:path'
import { fileURLToPath } from 'node:url'

const __dirname = path.dirname(fileURLToPath(import.meta.url))
const appRoot = path.resolve(__dirname, '..')
const androidRoot = path.join(appRoot, 'android')
const isWin = process.platform === 'win32'
const gradlew = path.join(androidRoot, isWin ? 'gradlew.bat' : 'gradlew')

const CANDIDATES = [
  process.env.GRADLE_JAVA_HOME,
  // 完整 JDK 21（含 jlink）；优先于 IDE JBR
  'C:\\Program Files\\Eclipse Adoptium\\jdk-21*',
  'C:\\Program Files\\Java\\jdk-21*',
  'C:\\Program Files\\Microsoft\\jdk-21*',
  // Android Studio JBR：新版可能是 JDK 25，Gradle 8.11 不支持，脚本会自动跳过
  'D:\\soft\\install\\Android\\Android Studio\\jbr',
  'D:\\soft\\install\\Android Studio\\jbr',
  'D:\\softs\\install\\Android Studio\\jbr',
  'C:\\Program Files\\Android\\Android Studio\\jbr',
  path.join(process.env.LOCALAPPDATA || '', 'Programs', 'Android Studio', 'jbr'),
  process.env.JAVA_HOME,
  'D:\\soft\\install\\IntelliJ IDEA 2024.3\\jbr',
  'D:\\soft\\install\\WebStorm 2024.3\\jbr',
  'D:\\soft\\install\\GoLand 2024.3\\jbr',
  'D:\\soft\\install\\PyCharm 2024.3\\jbr',
].filter(Boolean)

function javaBin(home) {
  return path.join(home, 'bin', isWin ? 'java.exe' : 'java')
}

function jlinkBin(home) {
  return path.join(home, 'bin', isWin ? 'jlink.exe' : 'jlink')
}

function expandGlobs(p) {
  if (!p.includes('*')) return [p]
  const parent = path.dirname(p)
  const prefix = path.basename(p).replace(/\*$/, '')
  if (!fs.existsSync(parent)) return []
  return fs
    .readdirSync(parent)
    .filter((name) => name.startsWith(prefix))
    .map((name) => path.join(parent, name))
}

function readJavaVersion(home) {
  const bin = javaBin(home)
  if (!fs.existsSync(bin)) return null
  const r = spawnSync(bin, ['-version'], { encoding: 'utf8' })
  const text = `${r.stderr || ''}${r.stdout || ''}`
  const m = text.match(/version "(\d+)/)
  return m ? Number(m[1]) : null
}

function resolveJdk() {
  const homes = CANDIDATES.flatMap(expandGlobs)
  /** @type {{ home: string, ver: number }[]} */
  const usable = []
  for (const home of homes) {
    const ver = readJavaVersion(home)
    if (ver == null || ver < 21) continue
    if (!fs.existsSync(jlinkBin(home))) {
      console.warn(`[run-android-assemble] skip JDK without jlink: ${home}`)
      continue
    }
    // Gradle 8.11 / AGP 8.7 对过高版本 JDK（如 25）会报 class file major version
    if (ver > 23) {
      console.warn(`[run-android-assemble] skip too-new JDK ${ver}: ${home}`)
      continue
    }
    usable.push({ home, ver })
  }
  // 优先 21，其次 22/23
  usable.sort((a, b) => {
    const score = (v) => (v === 21 ? 0 : v)
    return score(a.ver) - score(b.ver)
  })
  return usable[0] ?? null
}

function ensureLocalProperties(sdkDir) {
  const localProps = path.join(androidRoot, 'local.properties')
  const sdkProp = `sdk.dir=${sdkDir.replace(/\\/g, '\\\\')}`
  let content = ''
  if (fs.existsSync(localProps)) {
    content = fs.readFileSync(localProps, 'utf8')
    if (/^\s*sdk\.dir\s*=/m.test(content)) {
      content = content.replace(/^\s*sdk\.dir\s*=.*$/m, sdkProp)
    } else {
      content = `${sdkProp}\n${content}`
    }
  } else {
    content = `${sdkProp}\n`
  }
  fs.writeFileSync(localProps, content)
  console.log(`[run-android-assemble] sdk.dir=${sdkDir}`)
}

function resolveAndroidSdk() {
  const candidates = [
    process.env.ANDROID_HOME,
    process.env.ANDROID_SDK_ROOT,
    path.join(process.env.LOCALAPPDATA || '', 'Android', 'Sdk'),
    'C:\\Android\\Sdk',
    'D:\\Android\\Sdk',
    'D:\\AndroidSDK',
    'D:\\android-sdk',
  ].filter(Boolean)

  for (const dir of candidates) {
    if (fs.existsSync(path.join(dir, 'platform-tools'))) return dir
  }
  return null
}

function main() {
  if (!fs.existsSync(gradlew)) {
    console.error(`[run-android-assemble] missing ${gradlew}`)
    process.exit(1)
  }

  const jdk = resolveJdk()
  if (!jdk) {
    console.error(
      [
        '[run-android-assemble] 未找到可用的 JDK（需 ≥21 且包含 jlink）。',
        '推荐使用 Android Studio 自带 jbr，例如：',
        '  D:\\soft\\install\\Android\\Android Studio\\jbr',
        '也可安装 Temurin/Corretto JDK 21，并设置 GRADLE_JAVA_HOME / JAVA_HOME。',
        '注意：IntelliJ 精简 JBR 往往没有 jlink，会导致 JdkImageTransform 失败。',
      ].join('\n'),
    )
    process.exit(1)
  }

  const sdk = resolveAndroidSdk()
  if (!sdk) {
    console.error(
      [
        '[run-android-assemble] 未找到 Android SDK。',
        '请先安装 Android Studio（会自带 SDK），然后任选其一：',
        '  1) 设置环境变量 ANDROID_HOME=SDK 目录（通常是 %LOCALAPPDATA%\\Android\\Sdk）',
        '  2) 在 app/android/local.properties 写入：sdk.dir=C:\\\\Users\\\\你\\\\AppData\\\\Local\\\\Android\\\\Sdk',
        '安装后用 Android Studio 打开 app/android 工程，按提示装好 Platform SDK 再打包。',
      ].join('\n'),
    )
    process.exit(1)
  }
  ensureLocalProperties(sdk)

  console.log(`[run-android-assemble] using JDK ${jdk.ver}: ${jdk.home}`)

  const env = {
    ...process.env,
    JAVA_HOME: jdk.home,
    ANDROID_HOME: sdk,
    ANDROID_SDK_ROOT: sdk,
  }

  const r = spawnSync(gradlew, ['assembleDebug'], {
    cwd: androidRoot,
    env,
    stdio: 'inherit',
    shell: isWin,
  })
  process.exit(r.status ?? 1)
}

main()
