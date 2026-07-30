-- vlogish episode import SQL
-- generated: 2026-07-13T17:01:20.847042Z
-- episodes: 9 (index 214..222)
-- Run on production PostgreSQL inside transaction.
-- Prerequisite: episode_series table + episodes.series_id/series_index columns exist.

BEGIN;

INSERT INTO authors (name, gender, nationality, accent)
SELECT 'Learn English with Jessica', 'm', '', '美国'
WHERE NOT EXISTS (
  SELECT 1 FROM authors x
  WHERE x.name = 'Learn English with Jessica' AND x.accent = '美国'
);
INSERT INTO authors (name, gender, nationality, accent)
SELECT 'da.vinci sarga', 'm', '🇺🇸', '美国'
WHERE NOT EXISTS (
  SELECT 1 FROM authors x
  WHERE x.name = 'da.vinci sarga' AND x.accent = '美国'
);
INSERT INTO authors (name, gender, nationality, accent)
SELECT '润人巧记', 'm', '🇺🇸', '美国'
WHERE NOT EXISTS (
  SELECT 1 FROM authors x
  WHERE x.name = '润人巧记' AND x.accent = '美国'
);

INSERT INTO episode_series (
  slug, title, summary, cover, status, sort_order, created_at, published_at
) VALUES (
  '走遍美国视频版-1-78全集', '走遍美国视频版（1-78全集）',
  '走遍美国视频版（1-78全集）', 'https://picx.zhimg.com/v2-63b872b596141d1d3a0ad23cbbc3c0ae_720w.jpg?source=172ae18b',
  'published', 0,
  '2026-07-13 15:31:58'::timestamp, '2026-07-13 15:32:13'::timestamp
)
ON CONFLICT (slug) DO UPDATE SET
  title = EXCLUDED.title,
  summary = EXCLUDED.summary,
  cover = EXCLUDED.cover,
  status = EXCLUDED.status,
  sort_order = EXCLUDED.sort_order,
  published_at = EXCLUDED.published_at;
INSERT INTO episode_series (
  slug, title, summary, cover, status, sort_order, created_at, published_at
) VALUES (
  '华尔街英语-李深闯美', '华尔街英语-李深闯美（1-100全集）',
  '跟着中国小伙子到美国纽约学英语，看美剧磨耳朵跟读！', 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSltXEpH7hEEDs35YOE9CRgZGa9wL0prOE1BaabUjMNmA&s=10',
  'published', 1,
  '2026-07-13 16:12:29'::timestamp, '2026-07-13 16:12:29'::timestamp
)
ON CONFLICT (slug) DO UPDATE SET
  title = EXCLUDED.title,
  summary = EXCLUDED.summary,
  cover = EXCLUDED.cover,
  status = EXCLUDED.status,
  sort_order = EXCLUDED.sort_order,
  published_at = EXCLUDED.published_at;


-- episode 214: 5FAegfs5fTHS8Ac
UPDATE user_word_lookups SET subtitle_id = NULL WHERE subtitle_id IN (SELECT s.id FROM subtitles s JOIN episodes e ON s.episode_id = e.id WHERE e.video_id = '5FAegfs5fTHS8Ac');
UPDATE user_vocabulary_items SET source_subtitle_id = NULL WHERE source_subtitle_id IN (SELECT s.id FROM subtitles s JOIN episodes e ON s.episode_id = e.id WHERE e.video_id = '5FAegfs5fTHS8Ac');
DELETE FROM user_subtitle_progress WHERE subtitle_id IN (SELECT s.id FROM subtitles s JOIN episodes e ON s.episode_id = e.id WHERE e.video_id = '5FAegfs5fTHS8Ac');
DELETE FROM user_subtitle_progress WHERE episode_id = (SELECT id FROM episodes WHERE video_id = '5FAegfs5fTHS8Ac');
DELETE FROM subtitles WHERE episode_id = (SELECT id FROM episodes WHERE video_id = '5FAegfs5fTHS8Ac');
DELETE FROM episode_tags WHERE episode_id = (SELECT id FROM episodes WHERE video_id = '5FAegfs5fTHS8Ac');
INSERT INTO episodes (
  index, video_id, short_title, summary, remark, stars, voca_size,
  subtitle_count, clip_length, cover, video_url, audio_url, thumbnail_url,
  original_video_url, author_id, series_id, series_index,
  submitted_by_user_id, rejection_reason,
  created_at, is_demo, status, published_at
) VALUES (
  214, '5FAegfs5fTHS8Ac', '日常短语轻松学英语，初学者口语练习',
  '你想在说英语时感到更自在吗？你想理解母语者而不需要反复回放视频吗？你来对地方了！
欢迎回到Learn English with Jessica！今天，Rob将带你通过一个简单、循序渐进的课程，帮助你的英语变得更流畅、更自然。非常适合你的日常练习！
在今天的故事中，Mark在收到一封工作面试的拒绝邮件后感到难过。但在朋友Betty的帮助下，他学会了如何“往好的方面看”。
💡 Rob的成功秘诀：
重复是流利的关键！反复观看这个视频，并确保大声说出单词和答案。坚持练习，你会一次比一次更好。我保证！
👍 如果你喜欢这节课并想要更多简单的英语练习，请点赞这个视频并订阅频道！
✅ 在此加入Learn English with Jessica ☞
https://www.youtube.com/channel/UCXtMjo8xJqjEhS4A9KUY8GA/join
✅ 在此获取提高英语的提示 ☞
https://www.youtube.com/playlist?list=PLtBFFyhEIC7luNeJJNWuMG6TMri9Byttm
✅ 每日英语口语和听力练习 ☞
https://www.youtube.com/playlist?list=PLtBFFyhEIC7nWgv1UdTKhMYMst8QVx75z
✅ 在此练习英语口语技能 ☞
https://www.youtube.com/playlist?list=PLtBFFyhEIC7k87XSwvFsMlKFE-dnsrca-
✅ 在此练习英语听力技能 ☞
https://www.youtube.com/playlist?list=PLtBFFyhEIC7mFO3wS07Mv8ZyLLPaO7NdC
✅ 学习英语并提高语法、词汇和阅读技能 ➡️
https://www.youtube.com/playlist?list=PLtBFFyhEIC7lFhONPSYAryiaG4BpoyhbD
✅ 在此通过英语故事学习英语 ☞
https://www.youtube.com/watch?v=i9K0SxFSyx0&list=PLtBFFyhEIC7l3EmZvx2NTllHtWlVGERZ6
▶ 请订阅以获取新视频。➡️ https://www.youtube.com/
☞ 感谢观看！☞ 如果你喜欢这个视频，请分享和点赞，非常感谢 ♥', '',
  2, 12, 374,
  952.84, 'http://oss.sxakgs.com/en/0M7LiYdfjlU/cover.webp',
  'http://oss.sxakgs.com/en/0M7LiYdfjlU/video.mp4', 'http://oss.sxakgs.com/en/0M7LiYdfjlU/audio.mp3',
  'http://oss.sxakgs.com/en/0M7LiYdfjlU/cover.webp', 'https://www.youtube.com/watch?v=0M7LiYdfjlU',
  (SELECT id FROM authors WHERE name = 'Learn English with Jessica' AND accent = '美国' LIMIT 1),
  NULL, NULL,
  NULL, NULL,
  '2026-07-12 16:36:09'::timestamp,
  FALSE, 'published',
  '2026-07-12 16:36:09'::timestamp
)
ON CONFLICT (video_id) DO UPDATE SET
  index = EXCLUDED.index,
  short_title = EXCLUDED.short_title,
  summary = EXCLUDED.summary,
  remark = EXCLUDED.remark,
  stars = EXCLUDED.stars,
  voca_size = EXCLUDED.voca_size,
  subtitle_count = EXCLUDED.subtitle_count,
  clip_length = EXCLUDED.clip_length,
  cover = EXCLUDED.cover,
  video_url = EXCLUDED.video_url,
  audio_url = EXCLUDED.audio_url,
  thumbnail_url = EXCLUDED.thumbnail_url,
  original_video_url = EXCLUDED.original_video_url,
  author_id = EXCLUDED.author_id,
  series_id = EXCLUDED.series_id,
  series_index = EXCLUDED.series_index,
  submitted_by_user_id = EXCLUDED.submitted_by_user_id,
  rejection_reason = EXCLUDED.rejection_reason,
  is_demo = EXCLUDED.is_demo,
  status = EXCLUDED.status,
  published_at = EXCLUDED.published_at;

INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 0, 3.35, 3.36, 'Hello everyone, I''m Rob.', '大家好，我是罗布。', '/həˈloʊ ˈɛvriˌwʌn aɪm rɑb/', '<span>Hello</span><span>everyone</span><span>,</span><span>I</span><span>''m</span><span>Rob</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 1, 3.36, 6.75, 'Hello everyone, I''m Rob. Before we start, let me ask you Before we start, let me ask you Before we start, let me ask you something.', '大家好，我是罗布。在我们开始之前，让我问你们一个问题。', '/həˈloʊ ˈɛvriˌwʌn aɪm rɑb bɪˈfɔr wi stɑrt lɛt mi æsk ju ˈsʌmθɪŋ/', '<span>Hello</span><span>everyone</span><span>,</span><span>I</span><span>''m</span><span>Rob</span><span>.</span><span>Before</span><span>we</span><span>start</span><span>,</span><span>let</span><span>me</span><span tid="50001" class="highlight highlight-a">ask</span><span>you</span><span>Before</span><span>we</span><span>start</span><span>,</span><span>let</span><span>me</span><span tid="50002" class="highlight highlight-a">ask</span><span>you</span><span>Before</span><span>we</span><span>start</span><span>,</span><span>let</span><span>me</span><span tid="50003" class="highlight highlight-a">ask</span><span>you</span><span>something</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 2, 6.75, 6.76, 'something.', '一个问题。', '/ˈsʌmθɪŋ/', '<span>something</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 3, 6.76, 10.87, 'something. Do you want to feel more comfortable Do you want to feel more comfortable Do you want to feel more comfortable when you speak English?', '一个问题。你想在说英语时感觉更自在吗？', '/ˈsʌmθɪŋ du ju wɑnt tu fil mɔr kəmˈfɔrtəbəl wɛn ju spik ˈɪŋɡlɪʃ/', '<span>something</span><span>.</span><span>Do</span><span>you</span><span>want</span><span>to</span><span tid="50004" class="highlight highlight-a">feel</span><span>more</span><span tid="50005" class="highlight highlight-a">comfortable</span><span>Do</span><span>you</span><span>want</span><span>to</span><span tid="50006" class="highlight highlight-a">feel</span><span>more</span><span tid="50007" class="highlight highlight-a">comfortable</span><span>Do</span><span>you</span><span>want</span><span>to</span><span tid="50008" class="highlight highlight-a">feel</span><span>more</span><span tid="50009" class="highlight highlight-a">comfortable</span><span>when</span><span>you</span><span>speak</span><span>English</span><span>?</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 4, 10.87, 10.88, 'when you speak English?', '当你说英语时？', '/wɛn ju spik ˈɪŋɡlɪʃ/', '<span>when</span><span>you</span><span>speak</span><span>English</span><span>?</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 5, 10.88, 14.27, 'when you speak English? Do you want to understand native Do you want to understand native Do you want to understand native speakers without replaying the video', '当你说英语时？你想不用重播视频就能理解母语者吗？', '/wɛn ju spik ˈɪŋɡlɪʃ du ju wɑnt tu ˌʌndərˈstænd ˈneɪtɪv ˈspikərz wɪˈðaʊt riˈpleɪɪŋ ðə ˈvɪdioʊ/', '<span>when</span><span>you</span><span>speak</span><span>English</span><span>?</span><span>Do</span><span>you</span><span>want</span><span>to</span><span tid="50010" class="highlight highlight-a">understand</span><span tid="50011" class="highlight highlight-a">native</span><span>Do</span><span>you</span><span>want</span><span>to</span><span tid="50012" class="highlight highlight-a">understand</span><span tid="50013" class="highlight highlight-a">native</span><span>Do</span><span>you</span><span>want</span><span>to</span><span tid="50014" class="highlight highlight-a">understand</span><span tid="50015" class="highlight highlight-a">native</span><span tid="50016" class="highlight highlight-a">speakers</span><span>without</span><span tid="50017" class="highlight highlight-a">replaying</span><span>the</span><span>video</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 6, 14.27, 16.39, 'speakers without replaying the video speakers without replaying the video again and again?', '不用一遍又一遍地重播视频？', '/ˈspikərz wɪˈðaʊt riˈpleɪɪŋ ðə ˈvɪdioʊ əˈɡɛn ænd əˈɡɛn/', '<span tid="50018" class="highlight highlight-a">speakers</span><span>without</span><span tid="50019" class="highlight highlight-a">replaying</span><span>the</span><span>video</span><span tid="50020" class="highlight highlight-a">speakers</span><span>without</span><span tid="50021" class="highlight highlight-a">replaying</span><span>the</span><span>video</span><span>again</span><span>and</span><span>again</span><span>?</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 7, 16.39, 16.4, 'again and again?', '一遍又一遍？', '/əˈɡɛn ænd əˈɡɛn/', '<span>again</span><span>and</span><span>again</span><span>?</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 8, 16.4, 19.79, 'again and again? If that sounds like you, you''re in the If that sounds like you, you''re in the If that sounds like you, you''re in the right place.', '一次又一次？如果这听起来像你，那你来对地方了。', '/əˈɡɛn ənd əˈɡɛn? ɪf ðæt saʊndz laɪk ju, jʊr ɪn ðə raɪt pleɪs./', '<span>again</span><span>and</span><span>again?</span><span>If</span><span>that</span><span>sounds</span><span>like</span><span>you,</span><span>you''re</span><span>in</span><span>the</span><span>If</span><span>that</span><span>sounds</span><span>like</span><span>you,</span><span>you''re</span><span>in</span><span>the</span><span>If</span><span>that</span><span>sounds</span><span>like</span><span>you,</span><span>you''re</span><span>in</span><span>the</span><span>right</span><span>place.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 9, 19.79, 19.8, 'right place.', '对的地方。', '/raɪt pleɪs./', '<span tid="50022" class="highlight highlight-a">right</span><span>place</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 10, 19.8, 24.43, 'right place. This lesson is designed to help you grow This lesson is designed to help you grow This lesson is designed to help you grow step-by-step.', '对的地方。这节课旨在帮助你逐步成长。', '/raɪt pleɪs. ðɪs ˈlɛsən ɪz dɪˈzaɪnd tu hɛlp ju groʊ stɛp baɪ stɛp./', '<span>right</span><span>place.</span><span>This</span><span>lesson</span><span>is</span><span>designed</span><span>to</span><span>help</span><span>you</span><span>grow</span><span>This</span><span>lesson</span><span>is</span><span>designed</span><span>to</span><span>help</span><span>you</span><span>grow</span><span>This</span><span>lesson</span><span>is</span><span>designed</span><span>to</span><span>help</span><span>you</span><span>grow</span><span>step-by-step.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 11, 24.43, 24.44, 'step-by-step.', '逐步地。', '/stɛp baɪ stɛp./', '<span pid="501" class="highlight highlight-i">step-by-step</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 12, 24.44, 29.63, 'step-by-step. It''s simple to follow, easy to repeat, It''s simple to follow, easy to repeat, It''s simple to follow, easy to repeat, and perfect for daily practice.', '逐步地。它简单易学，容易重复，非常适合日常练习。', '/stɛp baɪ stɛp. ɪts ˈsɪmpəl tu ˈfɑloʊ, ˈizi tu rɪˈpit, ænd ˈpɜːrfəkt fɔr ˈdeɪli ˈpræktɪs./', '<span>step-by-step.</span><span>It''s</span><span>simple</span><span>to</span><span>follow,</span><span>easy</span><span>to</span><span>repeat,</span><span>It''s</span><span>simple</span><span>to</span><span>follow,</span><span>easy</span><span>to</span><span>repeat,</span><span>It''s</span><span>simple</span><span>to</span><span>follow,</span><span>easy</span><span>to</span><span>repeat,</span><span>and</span><span>perfect</span><span>for</span><span>daily</span><span>practice.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 13, 29.63, 29.64, 'and perfect for daily practice.', '并且非常适合日常练习。', '/ænd ˈpɜːrfəkt fɔr ˈdeɪli ˈpræktɪs./', '<span>and</span><span tid="50023" class="highlight highlight-a">perfect</span><span>for</span><span>daily</span><span>practice</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 14, 29.64, 31.76, 'and perfect for daily practice. In today''s session, Rob will guide you In today''s session, Rob will guide you', '并且非常适合日常练习。在今天的课程中，Rob将指导你', '/ænd ˈpɜːrfəkt fɔr ˈdeɪli ˈpræktɪs. ɪn təˈdeɪz ˈsɛʃən, rɑb wɪl gaɪd ju/', '<span>and</span><span>perfect</span><span>for</span><span>daily</span><span>practice.</span><span>In</span><span>today''s</span><span>session,</span><span>Rob</span><span>will</span><span>guide</span><span>you</span><span>In</span><span>today''s</span><span>session,</span><span>Rob</span><span>will</span><span>guide</span><span>you</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 15, 31.76, 34.39, 'In today''s session, Rob will guide you through four parts.', '在今天的课程中，Rob将指导你完成四个部分。', '/ɪn təˈdeɪz ˈsɛʃən, rɑb wɪl gaɪd ju θru fɔr pɑrts./', '<span>In</span><span>today''s</span><span>session</span><span>,</span><span>Rob</span><span>will</span><span tid="50024" class="highlight highlight-a">guide</span><span>you</span><span>through</span><span>four</span><span>parts</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 16, 34.39, 34.4, 'through four parts.', '通过四个部分。', '/θruː fɔːr pɑːrts/', '<span>through</span><span>four</span><span>parts.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 17, 34.4, 37.11, 'through four parts. Part one, listening practice.', '通过四个部分。第一部分，听力练习。', '/θruː fɔːr pɑːrts. pɑːrt wʌn, ˈlɪsənɪŋ ˈpræktɪs/', '<span>through</span><span>four</span><span>parts.</span><span>Part</span><span>one,</span><span>listening</span><span>practice.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 18, 37.11, 37.12, 'Part one, listening practice.', '第一部分，听力练习。', '/pɑːrt wʌn, ˈlɪsənɪŋ ˈpræktɪs/', '<span>Part</span><span>one,</span><span>listening</span><span>practice.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 19, 37.12, 39.99, 'Part one, listening practice. Part two, learn vocabulary.', '第一部分，听力练习。第二部分，学习词汇。', '/pɑːrt wʌn, ˈlɪsənɪŋ ˈpræktɪs. pɑːrt tuː, lɜːrn vəˈkæbjəleri/', '<span>Part</span><span>one,</span><span>listening</span><span>practice.</span><span>Part</span><span>two,</span><span>learn</span><span tid="50025" class="highlight highlight-a">vocabulary.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 20, 39.99, 40.0, 'Part two, learn vocabulary.', '第二部分，学习词汇。', '/pɑːrt tuː, lɜːrn vəˈkæbjəleri/', '<span>Part</span><span>two,</span><span>learn</span><span tid="50026" class="highlight highlight-a">vocabulary.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 21, 40.0, 43.03, 'Part two, learn vocabulary. Part three, listen and answer.', '第二部分，学习词汇。第三部分，听并回答。', '/pɑːrt tuː, lɜːrn vəˈkæbjəleri. pɑːrt θriː, lɪsən ænd ˈænsər/', '<span>Part</span><span>two,</span><span>learn</span><span tid="50027" class="highlight highlight-a">vocabulary.</span><span>Part</span><span>three,</span><span>listen</span><span>and</span><span>answer.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 22, 43.03, 43.04, 'Part three, listen and answer.', '第三部分，听并回答。', '/pɑːrt θriː, lɪsən ænd ˈænsər/', '<span>Part</span><span>three,</span><span>listen</span><span>and</span><span>answer.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 23, 43.04, 46.43, 'Part three, listen and answer. Part four, shadowing practice.', '第三部分，听并回答。第四部分，影子练习。', '/pɑːrt θriː, lɪsən ænd ˈænsər. pɑːrt fɔːr, ˈʃædoʊɪŋ ˈpræktɪs/', '<span>Part</span><span>three,</span><span>listen</span><span>and</span><span>answer.</span><span>Part</span><span>four,</span><span tid="50028" class="highlight highlight-a">shadowing</span><span>practice.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 24, 46.43, 46.44, 'Part four, shadowing practice.', '第四部分，影子练习。', '/pɑːrt fɔːr ˈʃædoʊɪŋ ˈpræktɪs/', '<span>Part</span><span>four</span><span>,</span><span tid="50029" class="highlight highlight-a">shadowing</span><span>practice</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 25, 46.44, 49.83, 'Part four, shadowing practice. Each part will help you train a Each part will help you train a Each part will help you train a different skill so your English becomes', '第四部分，影子练习。每个部分都会帮助你训练不同的技能，这样你的英语就会变得更流畅、更自然。', '/pɑːrt fɔːr ˈʃædoʊɪŋ ˈpræktɪs. iːtʃ pɑːrt wɪl hɛlp juː treɪn ə ˈdɪfərənt skɪl soʊ jɔːr ˈɪŋɡlɪʃ bɪˈkʌmz ˈsmuːðər ænd mɔːr ˈnætʃərəl/', '<span>Part</span><span>four</span><span>,</span><span tid="50030" class="highlight highlight-a">shadowing</span><span>practice</span><span>.</span><span>Each</span><span>part</span><span>will</span><span>help</span><span>you</span><span tid="50031" class="highlight highlight-a">train</span><span>a</span><span>Each</span><span>part</span><span>will</span><span>help</span><span>you</span><span tid="50032" class="highlight highlight-a">train</span><span>a</span><span>Each</span><span>part</span><span>will</span><span>help</span><span>you</span><span tid="50033" class="highlight highlight-a">train</span><span>a</span><span tid="50034" class="highlight highlight-a">different</span><span>skill</span><span>so</span><span>your</span><span>English</span><span>becomes</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 26, 49.83, 52.35, 'different skill so your English becomes different skill so your English becomes smoother and more natural.', '不同的技能，这样你的英语就会变得更流畅、更自然。', '/ˈdɪfərənt skɪl soʊ jɔːr ˈɪŋɡlɪʃ bɪˈkʌmz ˈsmuːðər ænd mɔːr ˈnætʃərəl/', '<span tid="50035" class="highlight highlight-a">different</span><span>skill</span><span>so</span><span>your</span><span>English</span><span>becomes</span><span tid="50036" class="highlight highlight-a">different</span><span>skill</span><span>so</span><span>your</span><span>English</span><span>becomes</span><span tid="50037" class="highlight highlight-a">smoother</span><span>and</span><span>more</span><span tid="50038" class="highlight highlight-a">natural</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 27, 52.35, 52.36, 'smoother and more natural.', '更流畅、更自然。', '/ˈsmuːðər ænd mɔːr ˈnætʃərəl/', '<span tid="50039" class="highlight highlight-a">smoother</span><span>and</span><span>more</span><span tid="50040" class="highlight highlight-a">natural</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 28, 52.36, 54.96, 'smoother and more natural. Take a breath, listen well, and let Rob Take a breath, listen well, and let Rob', '更流畅、更自然。深吸一口气，仔细听，让罗布引导你用英语思考和说话。', '/ˈsmuːðər ænd mɔːr ˈnætʃərəl. teɪk ə brɛθ, ˈlɪsən wɛl, ænd lɛt rɑːb gaɪd juː tuː θɪŋk ænd spiːk ɪn ˈɪŋɡlɪʃ/', '<span tid="50041" class="highlight highlight-a">smoother</span><span>and</span><span>more</span><span tid="50042" class="highlight highlight-a">natural</span><span>.</span><span>Take</span><span>a</span><span tid="50043" class="highlight highlight-a">breath</span><span>,</span><span>listen</span><span>well</span><span>,</span><span>and</span><span>let</span><span>Rob</span><span>Take</span><span>a</span><span tid="50044" class="highlight highlight-a">breath</span><span>,</span><span>listen</span><span>well</span><span>,</span><span>and</span><span>let</span><span>Rob</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 29, 54.96, 58.59, 'Take a breath, listen well, and let Rob guide you to think and speak in English.', '深吸一口气，仔细听，让罗布引导你用英语思考和说话。', '/teɪk ə brɛθ, ˈlɪsən wɛl, ænd lɛt rɑːb gaɪd juː tuː θɪŋk ænd spiːk ɪn ˈɪŋɡlɪʃ/', '<span>Take</span><span>a</span><span tid="50045" class="highlight highlight-a">breath</span><span>,</span><span>listen</span><span>well</span><span>,</span><span>and</span><span>let</span><span>Rob</span><span tid="50046" class="highlight highlight-a">guide</span><span>you</span><span>to</span><span>think</span><span>and</span><span>speak</span><span>in</span><span>English</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 30, 58.59, 58.6, 'guide you to think and speak in English.', '引导你用英语思考和说话。', '/gaɪd juː tuː θɪŋk ænd spiːk ɪn ˈɪŋɡlɪʃ/', '<span tid="50047" class="highlight highlight-a">guide</span><span>you</span><span>to</span><span>think</span><span>and</span><span>speak</span><span>in</span><span>English</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 31, 58.6, 61.91, 'guide you to think and speak in English. Part one, Part one, Part one, listening.', '引导你用英语思考和说话。第一部分，第一部分，第一部分，听力。', '/gaɪd juː tuː θɪŋk ænd spiːk ɪn ˈɪŋɡlɪʃ. pɑːrt wʌn, pɑːrt wʌn, pɑːrt wʌn, ˈlɪsənɪŋ/', '<span tid="50048" class="highlight highlight-a">guide</span><span>you</span><span>to</span><span>think</span><span>and</span><span>speak</span><span>in</span><span>English</span><span>.</span><span>Part</span><span>one</span><span>,</span><span>Part</span><span>one</span><span>,</span><span>Part</span><span>one</span><span>,</span><span tid="50049" class="highlight highlight-a">listening</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 32, 61.91, 61.92, 'listening.', '听。', '/ˈlɪs.ən.ɪŋ/', '<span>listening.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 33, 61.92, 66.79, 'listening. In this part, you will listen to a short In this part, you will listen to a short In this part, you will listen to a short conversation. Just relax and try to', '听。在这一部分，你将听到一段简短的对话。放松，试着理解大意。', '/ˈlɪs.ən.ɪŋ ɪn ðɪs pɑːrt ju wɪl ˈlɪs.ən tu ə ʃɔːrt kɑːnvərˈseɪʃən dʒʌst rɪˈlæks ænd traɪ tu ˌʌndərˈstænd ðə meɪn aɪˈdiːə/', '<span>listening.</span><span>In</span><span>this</span><span>part,</span><span>you</span><span>will</span><span>listen</span><span>to</span><span>a</span><span>short</span><span>In</span><span>this</span><span>part,</span><span>you</span><span>will</span><span>listen</span><span>to</span><span>a</span><span>short</span><span>In</span><span>this</span><span>part,</span><span>you</span><span>will</span><span>listen</span><span>to</span><span>a</span><span>short</span><span>conversation.</span><span>Just</span><span>relax</span><span>and</span><span>try</span><span>to</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 34, 66.79, 69.51, 'conversation. Just relax and try to conversation. Just relax and try to understand the main idea.', '对话。放松，试着理解大意。', '/ˈkɑːnvərˈseɪʃən dʒʌst rɪˈlæks ænd traɪ tu ˌʌndərˈstænd ðə meɪn aɪˈdiːə/', '<span>conversation.</span><span>Just</span><span>relax</span><span>and</span><span>try</span><span>to</span><span>conversation.</span><span>Just</span><span>relax</span><span>and</span><span>try</span><span>to</span><span>understand</span><span>the</span><span>main</span><span>idea.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 35, 69.51, 69.52, 'understand the main idea.', '理解大意。', '/ˌʌndərˈstænd ðə meɪn aɪˈdiːə/', '<span tid="50050" class="highlight highlight-a">understand</span><span>the</span><span>main</span><span>idea.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 36, 69.52, 73.03, 'understand the main idea. Don''t worry if you don''t catch every Don''t worry if you don''t catch every Don''t worry if you don''t catch every word. That''s normal.', '理解大意。如果你没有听懂每个单词，不用担心。这很正常。', '/ˌʌndərˈstænd ðə meɪn aɪˈdiːə doʊnt ˈwɜːri ɪf ju doʊnt kætʃ ˈɛvəri wɜːrd ðæts ˈnɔːrməl/', '<span tid="50051" class="highlight highlight-a">understand</span><span>the</span><span>main</span><span>idea.</span><span>Don''t</span><span>worry</span><span>if</span><span>you</span><span>don''t</span><span tid="50052" class="highlight highlight-a">catch</span><span>every</span><span>Don''t</span><span>worry</span><span>if</span><span>you</span><span>don''t</span><span tid="50053" class="highlight highlight-a">catch</span><span>every</span><span>Don''t</span><span>worry</span><span>if</span><span>you</span><span>don''t</span><span tid="50054" class="highlight highlight-a">catch</span><span>every</span><span>word.</span><span>That''s</span><span>normal.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 37, 73.03, 73.04, 'word. That''s normal.', '单词。这很正常。', '/wɜːrd ðæts ˈnɔːrməl/', '<span>word.</span><span>That''s</span><span>normal.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 38, 73.04, 76.19, 'word. That''s normal. Before we begin, here is the key Before we begin, here is the key Before we begin, here is the key vocabulary you will hear in the', '单词。这很正常。在我们开始之前，这是你将在对话中听到的关键词汇。', '/wɜːrd ðæts ˈnɔːrməl bɪˈfɔːr wi bɪˈɡɪn hɪr ɪz ðə kiː voʊˈkæbjəˌlɛri ju wɪl hɪr ɪn ðə/', '<span>word.</span><span>That''s</span><span>normal.</span><span>Before</span><span>we</span><span>begin,</span><span>here</span><span>is</span><span>the</span><span>key</span><span>Before</span><span>we</span><span>begin,</span><span>here</span><span>is</span><span>the</span><span>key</span><span>Before</span><span>we</span><span>begin,</span><span>here</span><span>is</span><span>the</span><span>key</span><span tid="50055" class="highlight highlight-a">vocabulary</span><span>you</span><span>will</span><span>hear</span><span>in</span><span>the</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 39, 76.19, 78.83, 'vocabulary you will hear in the vocabulary you will hear in the conversation.', '你将在对话中听到的词汇。', '/voʊˈkæbjəˌlɛri ju wɪl hɪr ɪn ðə ˈkɑːnvərˈseɪʃən/', '<span>vocabulary</span><span>you</span><span>will</span><span>hear</span><span>in</span><span>the</span><span>vocabulary</span><span>you</span><span>will</span><span>hear</span><span>in</span><span>the</span><span>conversation.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 40, 78.83, 78.84, 'conversation.', '对话。', '/ˌkɑːnvərˈseɪʃən/', '<span>conversation.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 41, 78.84, 80.59, 'conversation. Look on the bright side.', '对话。往好的方面看。', '/ˌkɑːnvərˈseɪʃən. lʊk ɑːn ðə braɪt saɪd/', '<span>conversation.</span><span pid="502" class="highlight highlight-i">Look on the bright side.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 42, 80.59, 80.6, 'Look on the bright side.', '往好的方面看。', '/lʊk ɑːn ðə braɪt saɪd/', '<span pid="503" class="highlight highlight-i">Look on the bright side.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 43, 80.6, 88.03, 'Look on the bright side. Are you ready? Let''s listen.', '往好的方面看。准备好了吗？我们来听。', '/lʊk ɑːn ðə braɪt saɪd. ɑːr juː ˈrɛdi? lɛts ˈlɪsən/', '<span pid="504" class="highlight highlight-i">Look on the bright side.</span><span>Are</span><span>you</span><span>ready?</span><span>Let''s</span><span>listen.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 44, 89.03, 91.55, 'Betty, Betty, I feel awful today.', '贝蒂，贝蒂，我今天感觉很糟糕。', '/ˈbɛti, ˈbɛti, aɪ fil ˈɔːfəl təˈdeɪ/', '<span>Betty,</span><span>Betty,</span><span>I</span><span>feel</span><span tid="50056" class="highlight highlight-a">awful</span><span>today.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 45, 91.55, 91.56, 'I feel awful today.', '我今天感觉很糟糕。', '/aɪ fil ˈɔːfəl təˈdeɪ/', '<span>I</span><span>feel</span><span tid="50057" class="highlight highlight-a">awful</span><span>today.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 46, 91.56, 93.91, 'I feel awful today. What happened, Mark?', '我今天感觉很糟糕。怎么了，马克？', '/aɪ fil ˈɔːfəl təˈdeɪ. wʌt ˈhæpənd, mɑːrk/', '<span>I</span><span>feel</span><span tid="50058" class="highlight highlight-a">awful</span><span>today.</span><span>What</span><span>happened,</span><span>Mark?</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 47, 93.91, 93.92, 'What happened, Mark?', '怎么了，马克？', '/wʌt ˈhæpənd, mɑːrk/', '<span>What</span><span>happened,</span><span>Mark?</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 48, 93.92, 96.0, 'What happened, Mark? Do you remember the job I told you about Do you remember the job I told you about', '怎么了，马克？你还记得我跟你说的那份工作吗？', '/wʌt ˈhæpənd mɑːrk | duː juː rɪˈmɛmbər ðə dʒɑːb aɪ toʊld juː əˈbaʊt/', '<span>What</span><span tid="50059" class="highlight highlight-a">happened</span><span>,</span><span>Mark</span><span>?</span><span>Do</span><span>you</span><span tid="50060" class="highlight highlight-a">remember</span><span>the</span><span>job</span><span>I</span><span>told</span><span>you</span><span>about</span><span>Do</span><span>you</span><span tid="50061" class="highlight highlight-a">remember</span><span>the</span><span>job</span><span>I</span><span>told</span><span>you</span><span>about</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 49, 96.0, 97.83, 'Do you remember the job I told you about before?', '你还记得我之前跟你说的那份工作吗？', '/duː juː rɪˈmɛmbər ðə dʒɑːb aɪ toʊld juː əˈbaʊt bɪˈfɔːr/', '<span>Do</span><span>you</span><span tid="50062" class="highlight highlight-a">remember</span><span>the</span><span>job</span><span>I</span><span>told</span><span>you</span><span>about</span><span>before</span><span>?</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 50, 97.83, 97.84, 'before?', '之前？', '/bɪˈfɔːr/', '<span>before</span><span>?</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 51, 97.84, 101.55, 'before? I got a rejection email from the I got a rejection email from the I got a rejection email from the company.', '之前？我收到了那家公司的拒信。', '/bɪˈfɔːr | aɪ ɡɑːt ə rɪˈdʒɛkʃən iːmeɪl frəm ðə ˈkʌmpəni/', '<span>before</span><span>?</span><span>I</span><span>got</span><span>a</span><span tid="50063" class="highlight highlight-a">rejection</span><span>email</span><span>from</span><span>the</span><span>I</span><span>got</span><span>a</span><span tid="50064" class="highlight highlight-a">rejection</span><span>email</span><span>from</span><span>the</span><span>I</span><span>got</span><span>a</span><span tid="50065" class="highlight highlight-a">rejection</span><span>email</span><span>from</span><span>the</span><span>company</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 52, 101.55, 101.56, 'company.', '公司。', '/ˈkʌmpəni/', '<span>company.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 53, 101.56, 105.19, 'company. Oh, no. I''m sorry to hear that.', '公司。哦，不。听到这个我很难过。', '/ˈkʌmpəni | oʊ noʊ | aɪm ˈsɔːri tuː hɪr ðæt/', '<span>company.</span><span>Oh,</span><span>no.</span><span>I''m</span><span tid="50066" class="highlight highlight-a">sorry</span><span>to</span><span>hear</span><span>that.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 54, 105.19, 105.2, 'Oh, no. I''m sorry to hear that.', '哦，不。听到这个我很难过。', '/oʊ noʊ | aɪm ˈsɔːri tuː hɪr ðæt/', '<span>Oh,</span><span>no.</span><span>I''m</span><span tid="50067" class="highlight highlight-a">sorry</span><span>to</span><span>hear</span><span>that.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 55, 105.2, 108.59, 'Oh, no. I''m sorry to hear that. I prepared so hard for the interview.', '哦，不。听到这个我很难过。我为面试准备得非常努力。', '/oʊ noʊ | aɪm ˈsɔːri tuː hɪr ðæt | aɪ prɪˈpɛrd soʊ hɑːrd fɔːr ði ˈɪntərvjuː/', '<span>Oh,</span><span>no.</span><span>I''m</span><span tid="50068" class="highlight highlight-a">sorry</span><span>to</span><span>hear</span><span>that.</span><span>I</span><span tid="50069" class="highlight highlight-a">prepared</span><span>so</span><span>hard</span><span>for</span><span>the</span><span tid="50070" class="highlight highlight-a">interview.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 56, 108.59, 108.6, 'I prepared so hard for the interview.', '我为这次面试准备得非常努力。', '/aɪ prɪˈpɛrd soʊ hɑːrd fɔːr ði ˈɪntərˌvjuː/', '<span>I</span><span tid="50071" class="highlight highlight-a">prepared</span><span>so</span><span>hard</span><span>for</span><span>the</span><span tid="50072" class="highlight highlight-a">interview.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 57, 108.6, 111.08, 'I prepared so hard for the interview. I studied all week and practiced answers I studied all week and practiced answers', '我为这次面试准备得非常努力。我整个星期都在学习，练习答案。', '/aɪ prɪˈpɛrd soʊ hɑːrd fɔːr ði ˈɪntərˌvjuː aɪ ˈstʌdid ɔːl wiːk ænd ˈpræktɪst ˈænsərz aɪ ˈstʌdid ɔːl wiːk ænd ˈpræktɪst ˈænsərz/', '<span>I</span><span tid="50073" class="highlight highlight-a">prepared</span><span>so</span><span>hard</span><span>for</span><span>the</span><span tid="50074" class="highlight highlight-a">interview.</span><span>I</span><span tid="50075" class="highlight highlight-a">studied</span><span>all</span><span>week</span><span>and</span><span tid="50076" class="highlight highlight-a">practiced</span><span>answers</span><span>I</span><span tid="50077" class="highlight highlight-a">studied</span><span>all</span><span>week</span><span>and</span><span tid="50078" class="highlight highlight-a">practiced</span><span>answers</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 58, 111.08, 112.95, 'I studied all week and practiced answers every night.', '我整个星期都在学习，每晚练习答案。', '/aɪ ˈstʌdid ɔːl wiːk ænd ˈpræktɪst ˈænsərz ˈɛvri naɪt/', '<span>I</span><span tid="50079" class="highlight highlight-a">studied</span><span>all</span><span>week</span><span>and</span><span tid="50080" class="highlight highlight-a">practiced</span><span>answers</span><span>every</span><span>night.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 59, 112.95, 112.96, 'every night.', '每晚。', '/ˈɛvri naɪt/', '<span>every</span><span>night.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 60, 112.96, 117.11, 'every night. Wow, you really tried your best.', '每晚。哇，你真的尽力了。', '/ˈɛvri naɪt waʊ juː ˈrɪli traɪd jɔːr bɛst/', '<span>every</span><span>night.</span><span>Wow,</span><span>you</span><span>really</span><span tid="50081" class="highlight highlight-a">tried</span><span>your</span><span tid="50082" class="highlight highlight-i">best.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 61, 117.11, 117.12, 'Wow, you really tried your best.', '哇，你真的尽力了。', '/waʊ juː ˈrɪli traɪd jɔːr bɛst/', '<span>Wow,</span><span>you</span><span>really</span><span tid="50083" class="highlight highlight-a">tried</span><span>your</span><span tid="50084" class="highlight highlight-i">best.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 62, 117.12, 119.56, 'Wow, you really tried your best. Yes, I did everything I could to get Yes, I did everything I could to get', '哇，你真的尽力了。是的，我做了我能做的一切来得到。', '/waʊ juː ˈrɪli traɪd jɔːr bɛst jɛs aɪ dɪd ˈɛvriθɪŋ aɪ kʊd tuː gɛt jɛs aɪ dɪd ˈɛvriθɪŋ aɪ kʊd tuː gɛt/', '<span>Wow,</span><span>you</span><span>really</span><span tid="50085" class="highlight highlight-a">tried</span><span>your</span><span tid="50086" class="highlight highlight-i">best.</span><span>Yes,</span><span>I</span><span>did</span><span tid="50087" class="highlight highlight-a">everything</span><span>I</span><span>could</span><span>to</span><span>get</span><span>Yes,</span><span>I</span><span>did</span><span tid="50088" class="highlight highlight-a">everything</span><span>I</span><span>could</span><span>to</span><span>get</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 63, 119.56, 121.47, 'Yes, I did everything I could to get that job.', '是的，我做了我能做的一切来得到那份工作。', '/jɛs aɪ dɪd ˈɛvriθɪŋ aɪ kʊd tuː gɛt ðæt dʒoʊb/', '<span>Yes,</span><span>I</span><span>did</span><span tid="50089" class="highlight highlight-a">everything</span><span>I</span><span>could</span><span>to</span><span>get</span><span>that</span><span tid="50090" class="highlight highlight-a">job.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 64, 121.47, 121.48, 'that job.', '那份工作。', '/ðæt dʒɑb/', '<span>that</span><span>job.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 65, 121.48, 125.87, 'that job. Oh, I understand why you feel so sad.', '那份工作。哦，我理解你为什么感到这么难过。', '/ðæt dʒɑb. oʊ, aɪ ˌʌndərˈstænd waɪ juː fiːl soʊ sæd/', '<span>that</span><span>job.</span><span>Oh,</span><span>I</span><span tid="50091" class="highlight highlight-a">understand</span><span>why</span><span>you</span><span>feel</span><span>so</span><span>sad.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 66, 125.87, 125.88, 'Oh, I understand why you feel so sad.', '哦，我理解你为什么感到这么难过。', '/oʊ, aɪ ˌʌndərˈstænd waɪ juː fiːl soʊ sæd/', '<span>Oh,</span><span>I</span><span tid="50092" class="highlight highlight-a">understand</span><span>why</span><span>you</span><span>feel</span><span>so</span><span>sad.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 67, 125.88, 130.91, 'Oh, I understand why you feel so sad. But tell me, But tell me, But tell me, is that job really good for you?', '哦，我理解你为什么感到这么难过。但告诉我，但告诉我，但告诉我，那份工作真的适合你吗？', '/oʊ, aɪ ˌʌndərˈstænd waɪ juː fiːl soʊ sæd. bʌt tɛl mi, bʌt tɛl mi, bʌt tɛl mi, ɪz ðæt dʒɑb ˈrɪli ɡʊd fɔr juː/', '<span>Oh,</span><span>I</span><span tid="50093" class="highlight highlight-a">understand</span><span>why</span><span>you</span><span>feel</span><span>so</span><span>sad.</span><span>But</span><span>tell</span><span>me,</span><span>But</span><span>tell</span><span>me,</span><span>But</span><span>tell</span><span>me,</span><span>is</span><span>that</span><span>job</span><span>really</span><span>good</span><span>for</span><span>you?</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 68, 130.91, 130.92, 'is that job really good for you?', '那份工作真的适合你吗？', '/ɪz ðæt dʒɑb ˈrɪli ɡʊd fɔr juː/', '<span>is</span><span>that</span><span>job</span><span>really</span><span>good</span><span>for</span><span>you?</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 69, 130.92, 133.64, 'is that job really good for you? Yes, I think so. My friend works there Yes, I think so. My friend works there', '那份工作真的适合你吗？是的，我想是的。我的朋友在那里工作，是的，我想是的。我的朋友在那里工作', '/ɪz ðæt dʒɑb ˈrɪli ɡʊd fɔr juː? jɛs, aɪ θɪŋk soʊ. maɪ frɛnd wɜːrks ðɛr jɛs, aɪ θɪŋk soʊ. maɪ frɛnd wɜːrks ðɛr/', '<span>is</span><span>that</span><span>job</span><span>really</span><span>good</span><span>for</span><span>you?</span><span>Yes,</span><span>I</span><span>think</span><span>so.</span><span>My</span><span>friend</span><span>works</span><span>there</span><span>Yes,</span><span>I</span><span>think</span><span>so.</span><span>My</span><span>friend</span><span>works</span><span>there</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 70, 133.64, 137.15, 'Yes, I think so. My friend works there and he told me the company is very good.', '是的，我想是的。我的朋友在那里工作，他告诉我这家公司非常好。', '/jɛs, aɪ θɪŋk soʊ. maɪ frɛnd wɜːrks ðɛr ænd hiː toʊld mi ðə ˈkʌmpəni ɪz ˈvɛri ɡʊd/', '<span>Yes,</span><span>I</span><span>think</span><span>so.</span><span>My</span><span>friend</span><span>works</span><span>there</span><span>and</span><span>he</span><span>told</span><span>me</span><span>the</span><span tid="50094" class="highlight highlight-a">company</span><span>is</span><span>very</span><span>good.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 71, 137.15, 137.16, 'and he told me the company is very good.', '他告诉我这家公司非常好。', '/ænd hiː toʊld mi ðə ˈkʌmpəni ɪz ˈvɛri ɡʊd/', '<span>and</span><span>he</span><span>told</span><span>me</span><span>the</span><span tid="50095" class="highlight highlight-a">company</span><span>is</span><span>very</span><span>good.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 72, 137.16, 139.0, 'and he told me the company is very good. Is the salary really as high as you Is the salary really as high as you', '他告诉我这家公司很好。薪水真的像你一样高吗？', '/ænd hiː toʊld miː ðə ˈkʌmpəni ɪz ˈvɛri ɡʊd. ɪz ðə ˈsæləri ˈrɪli æz haɪ æz juː ɪz ðə ˈsæləri ˈrɪli æz haɪ æz juː/', '<span>and</span><span>he</span><span tid="50096" class="highlight highlight-a">told</span><span>me</span><span>the</span><span tid="50097" class="highlight highlight-a">company</span><span>is</span><span>very</span><span>good.</span><span>Is</span><span>the</span><span tid="50098" class="highlight highlight-a">salary</span><span>really</span><span>as</span><span tid="50099" class="highlight highlight-a">high</span><span>as</span><span>you</span><span>Is</span><span>the</span><span tid="50100" class="highlight highlight-a">salary</span><span>really</span><span>as</span><span tid="50101" class="highlight highlight-a">high</span><span>as</span><span>you</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 73, 139.0, 140.67, 'Is the salary really as high as you wanted?', '薪水真的像你期望的那么高吗？', '/ɪz ðə ˈsæləri ˈrɪli æz haɪ æz juː ˈwɑntɪd/', '<span>Is</span><span>the</span><span tid="50102" class="highlight highlight-a">salary</span><span>really</span><span>as</span><span tid="50103" class="highlight highlight-a">high</span><span>as</span><span>you</span><span>wanted?</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 74, 140.67, 140.68, 'wanted?', '期望的？', '/ˈwɑntɪd/', '<span>wanted?</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 75, 140.68, 144.27, 'wanted? Not really. It''s lower than I wanted.', '期望的？不太高。比我期望的低。', '/ˈwɑntɪd? nɑt ˈrɪli. ɪts ˈloʊər ðæn aɪ ˈwɑntɪd/', '<span>wanted?</span><span>Not</span><span>really.</span><span>It''s</span><span tid="50104" class="highlight highlight-a">lower</span><span>than</span><span>I</span><span>wanted.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 76, 144.27, 144.28, 'Not really. It''s lower than I wanted.', '不太高。比我期望的低。', '/nɑt ˈrɪli. ɪts ˈloʊər ðæn aɪ ˈwɑntɪd/', '<span>Not</span><span>really.</span><span>It''s</span><span tid="50105" class="highlight highlight-a">lower</span><span>than</span><span>I</span><span>wanted.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 77, 144.28, 148.51, 'Not really. It''s lower than I wanted. Oh, is the office far from your house?', '不太高。比我期望的低。哦，办公室离你家远吗？', '/nɑt ˈrɪli. ɪts ˈloʊər ðæn aɪ ˈwɑntɪd. oʊ, ɪz ði ˈɔfɪs fɑr frəm jɔr haʊs/', '<span>Not</span><span>really.</span><span>It''s</span><span tid="50106" class="highlight highlight-a">lower</span><span>than</span><span>I</span><span>wanted.</span><span>Oh,</span><span>is</span><span>the</span><span tid="50107" class="highlight highlight-a">office</span><span>far</span><span>from</span><span>your</span><span>house?</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 78, 148.51, 148.52, 'Oh, is the office far from your house?', '哦，办公室离你家远吗？', '/oʊ, ɪz ði ˈɔfɪs fɑr frəm jɔr haʊs/', '<span>Oh,</span><span>is</span><span>the</span><span tid="50108" class="highlight highlight-a">office</span><span>far</span><span>from</span><span>your</span><span>house?</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 79, 148.52, 150.84, 'Oh, is the office far from your house? Yeah, it takes me almost an hour to get Yeah, it takes me almost an hour to get', '哦，办公室离你家远吗？是的，我几乎要花一个小时才能到。', '/oʊ, ɪz ði ˈɔfɪs fɑr frəm jɔr haʊs? jɛs, ɪt teɪks mi ˈɔlmoʊst æn ˈaʊər tuː ɡɛt jɛs, ɪt teɪks mi ˈɔlmoʊst æn ˈaʊər tuː ɡɛt/', '<span>Oh,</span><span>is</span><span>the</span><span tid="50109" class="highlight highlight-a">office</span><span>far</span><span>from</span><span>your</span><span>house?</span><span>Yeah,</span><span>it</span><span tid="50110" class="highlight highlight-a">takes</span><span>me</span><span>almost</span><span>an</span><span>hour</span><span>to</span><span>get</span><span>Yeah,</span><span>it</span><span tid="50111" class="highlight highlight-a">takes</span><span>me</span><span>almost</span><span>an</span><span>hour</span><span>to</span><span>get</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 80, 150.84, 152.55, 'Yeah, it takes me almost an hour to get there.', '是的，我几乎要花一个小时才能到那里。', '/jɛs ɪt teɪks mi ˈɔːlmoʊst ən ˈaʊər tə ɡɛt ðɛr/', '<span>Yeah</span><span>,</span><span>it</span><span tid="50112" class="highlight highlight-a">takes</span><span>me</span><span>almost</span><span>an</span><span>hour</span><span>to</span><span>get</span><span>there</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 81, 152.55, 152.56, 'there.', '那里。', '/ðɛr/', '<span>there</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 82, 152.56, 155.87, 'there. Mark, Mark, Mark, look on the bright side.', '那里。马克，马克，马克，往好的方面看。', '/ðɛr mɑːrk mɑːrk mɑːrk lʊk ɑn ðə braɪt saɪd/', '<span>there</span><span>.</span><span>Mark</span><span>,</span><span>Mark</span><span>,</span><span>Mark</span><span>,</span><span pid="505" class="highlight highlight-i">look on the bright side</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 83, 155.87, 155.88, 'look on the bright side.', '往好的方面看。', '/lʊk ɑn ðə braɪt saɪd/', '<span pid="506" class="highlight highlight-i">look on the bright side</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 84, 155.88, 160.27, 'look on the bright side. Maybe you only missed something that Maybe you only missed something that Maybe you only missed something that wasn''t right for you.', '往好的方面看。也许你只是错过了一些不适合你的东西。', '/lʊk ɑn ðə braɪt saɪd ˈmeɪbi ju ˈoʊnli mɪst ˈsʌmθɪŋ ðæt ˈmeɪbi ju ˈoʊnli mɪst ˈsʌmθɪŋ ðæt ˈmeɪbi ju ˈoʊnli mɪst ˈsʌmθɪŋ ðæt ˈwʌzənt raɪt fər ju/', '<span pid="507" class="highlight highlight-i">look on the bright side</span><span>.</span><span>Maybe</span><span>you</span><span>only</span><span tid="50113" class="highlight highlight-a">missed</span><span>something</span><span>that</span><span>Maybe</span><span>you</span><span>only</span><span tid="50114" class="highlight highlight-a">missed</span><span>something</span><span>that</span><span>Maybe</span><span>you</span><span>only</span><span tid="50115" class="highlight highlight-a">missed</span><span>something</span><span>that</span><span>wasn''t</span><span>right</span><span>for</span><span>you</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 85, 160.27, 160.28, 'wasn''t right for you.', '不适合你的东西。', '/ˈwʌzənt raɪt fər ju/', '<span>wasn''t</span><span>right</span><span>for</span><span>you</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 86, 160.28, 162.949, 'wasn''t right for you. I never thought about it that way.', '不适合你的东西。我从未那样想过。', '/ˈwʌzənt raɪt fər ju aɪ ˈnɛvər θɔːt əˈbaʊt ɪt ðæt weɪ/', '<span>wasn''t</span><span>right</span><span>for</span><span>you</span><span>.</span><span>I</span><span>never</span><span tid="50116" class="highlight highlight-a">thought</span><span>about</span><span>it</span><span>that</span><span>way</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 87, 162.949, 162.959, 'I never thought about it that way.', '我从未那样想过。', '/aɪ ˈnɛvər θɔːt əˈbaʊt ɪt ðæt weɪ/', '<span>I</span><span>never</span><span tid="50117" class="highlight highlight-a">thought</span><span>about</span><span>it</span><span>that</span><span>way</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 88, 162.959, 165.44, 'I never thought about it that way. Now you can find a better company with Now you can find a better company with', '我从未那样想过。现在你可以找到一家更好的公司，有', '/aɪ ˈnɛvər θɔːt əˈbaʊt ɪt ðæt weɪ. naʊ juː kæn faɪnd ə ˈbɛtər ˈkʌmpəni wɪð naʊ juː kæn faɪnd ə ˈbɛtər ˈkʌmpəni wɪð/', '<span>I</span><span>never</span><span pid="508" class="highlight highlight-d">thought about</span><span>it</span><span>that</span><span>way.</span><span>Now</span><span>you</span><span>can</span><span tid="50118" class="highlight highlight-a">find</span><span>a</span><span>better</span><span>company</span><span>with</span><span>Now</span><span>you</span><span>can</span><span tid="50119" class="highlight highlight-a">find</span><span>a</span><span>better</span><span>company</span><span>with</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 89, 165.44, 169.15, 'Now you can find a better company with better pay and closer to home.', '现在你可以找到一家更好的公司，有更好的薪酬，离家更近。', '/naʊ juː kæn faɪnd ə ˈbɛtər ˈkʌmpəni wɪð ˈbɛtər peɪ ænd ˈkloʊsər tuː hoʊm/', '<span>Now</span><span>you</span><span>can</span><span tid="50120" class="highlight highlight-a">find</span><span>a</span><span>better</span><span>company</span><span>with</span><span>better</span><span>pay</span><span>and</span><span pid="509" class="highlight highlight-c">closer to</span><span>home.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 90, 169.15, 169.16, 'better pay and closer to home.', '更好的薪酬，离家更近。', '/ˈbɛtər peɪ ænd ˈkloʊsər tuː hoʊm/', '<span>better</span><span>pay</span><span>and</span><span pid="510" class="highlight highlight-c">closer to</span><span>home.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 91, 169.16, 171.87, 'better pay and closer to home. That makes me feel better.', '更好的薪酬，离家更近。这让我感觉好多了。', '/ˈbɛtər peɪ ænd ˈkloʊsər tuː hoʊm. ðæt meɪks miː fiːl ˈbɛtər/', '<span>better</span><span>pay</span><span>and</span><span pid="511" class="highlight highlight-c">closer to</span><span>home.</span><span>That</span><span>makes</span><span>me</span><span>feel</span><span>better.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 92, 171.87, 171.88, 'That makes me feel better.', '这让我感觉好多了。', '/ðæt meɪks miː fiːl ˈbɛtər/', '<span>That</span><span>makes</span><span>me</span><span>feel</span><span tid="50121" class="highlight highlight-a">better.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 93, 171.88, 172.949, 'That makes me feel better. Good.', '这让我感觉好多了。好。', '/ðæt meɪks miː fiːl ˈbɛtər. ɡʊd/', '<span>That</span><span>makes</span><span>me</span><span>feel</span><span tid="50122" class="highlight highlight-a">better.</span><span>Good.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 94, 172.949, 172.959, 'Good.', '好。', '/ɡʊd/', '<span>Good.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 95, 172.959, 175.83, 'Good. I like seeing you smile.', '好。我喜欢看到你微笑。', '/ɡʊd. aɪ laɪk ˈsiːɪŋ juː smaɪl/', '<span>Good.</span><span>I</span><span>like</span><span tid="50123" class="highlight highlight-a">seeing</span><span>you</span><span tid="50124" class="highlight highlight-a">smile.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 96, 175.83, 175.84, 'I like seeing you smile.', '我喜欢看到你微笑。', '/aɪ laɪk ˈsiːɪŋ juː smaɪl/', '<span>I</span><span tid="50125" class="highlight highlight-a">like</span><span tid="50126" class="highlight highlight-a">seeing</span><span>you</span><span>smile.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 97, 175.84, 177.76, 'I like seeing you smile. Thanks, Betty. Let''s go eat something Thanks, Betty. Let''s go eat something', '我喜欢看到你微笑。谢谢，贝蒂。我们去吃点东西吧。谢谢，贝蒂。我们去吃点东西吧。', '/aɪ laɪk ˈsiːɪŋ juː smaɪl. θæŋks, ˈbɛti. lets goʊ iːt ˈsʌmθɪŋ. θæŋks, ˈbɛti. lets goʊ iːt ˈsʌmθɪŋ/', '<span>I</span><span tid="50127" class="highlight highlight-a">like</span><span tid="50128" class="highlight highlight-a">seeing</span><span>you</span><span>smile.</span><span>Thanks,</span><span>Betty.</span><span>Let''s</span><span pid="512" class="highlight highlight-d">go eat</span><span>something</span><span>Thanks,</span><span>Betty.</span><span>Let''s</span><span pid="513" class="highlight highlight-d">go eat</span><span>something</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 98, 177.76, 179.59, 'Thanks, Betty. Let''s go eat something together.', '谢谢，贝蒂。我们一起去吃点东西吧。', '/θæŋks, ˈbɛti. lets goʊ iːt ˈsʌmθɪŋ təˈɡɛðər/', '<span>Thanks,</span><span>Betty.</span><span>Let''s</span><span pid="514" class="highlight highlight-d">go eat</span><span>something</span><span>together.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 99, 179.59, 179.6, 'together.', '一起。', '/təˈɡɛðər/', '<span>together.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 100, 179.6, 183.35, 'together. Sounds great. I''m hungry, too.', '一起。听起来不错。我也饿了。', '/təˈɡɛðər. saʊndz ɡreɪt. aɪm ˈhʌŋɡri, tuː/', '<span>together.</span><span tid="50129" class="highlight highlight-a">Sounds</span><span>great.</span><span>I''m</span><span tid="50130" class="highlight highlight-a">hungry,</span><span>too.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 101, 183.35, 183.36, 'Sounds great. I''m hungry, too.', '听起来不错。我也饿了。', '/saʊndz ɡreɪt. aɪm ˈhʌŋɡri, tuː/', '<span tid="50131" class="highlight highlight-a">Sounds</span><span>great.</span><span>I''m</span><span tid="50132" class="highlight highlight-a">hungry,</span><span>too.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 102, 183.36, 185.56, 'Sounds great. I''m hungry, too. My treat today. You really cheered me My treat today. You really cheered me', '听起来不错。我也饿了。今天我请客。你真的让我开心了。今天我请客。你真的让我开心了。', '/saʊndz ɡreɪt. aɪm ˈhʌŋɡri, tuː. maɪ triːt təˈdeɪ. juː ˈrɪli tʃɪrd miː. maɪ triːt təˈdeɪ. juː ˈrɪli tʃɪrd miː/', '<span tid="50133" class="highlight highlight-a">Sounds</span><span>great.</span><span>I''m</span><span tid="50134" class="highlight highlight-a">hungry,</span><span>too.</span><span>My</span><span tid="50135" class="highlight highlight-a">treat</span><span>today.</span><span>You</span><span>really</span><span tid="50136" class="highlight highlight-a">cheered</span><span>me</span><span>My</span><span tid="50137" class="highlight highlight-a">treat</span><span>today.</span><span>You</span><span>really</span><span tid="50138" class="highlight highlight-a">cheered</span><span>me</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 103, 185.56, 187.229, 'My treat today. You really cheered me up.', '今天我请客。你真的让我开心了。', '/maɪ triːt təˈdeɪ. juː ˈrɪli tʃɪrd miː ʌp/', '<span>My</span><span tid="50139" class="highlight highlight-a">treat</span><span>today.</span><span>You</span><span>really</span><span tid="50140" class="highlight highlight-a">cheered</span><span>me</span><span tid="50141" class="highlight highlight-d">up.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 104, 187.229, 187.239, 'up.', '起来。', '/ʌp/', '<span>up.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 105, 187.239, 196.55, 'up. Awesome.', '起来。太棒了。', '/ʌp. əˈsʌm/', '<span>up.</span><span tid="50142" class="highlight highlight-a">Awesome.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 106, 198.59, 201.19, 'In this part, we will learn some useful In this part, we will learn some useful words from the conversation.', '在这一部分，我们将从对话中学到一些有用的单词。', '/ɪn ðɪs pɑːrt, wi wɪl lɜːrn sʌm ˈjusfəl wɜːrdz frəm ðə ˌkɑːnvərˈseɪʃən/', '<span>In</span><span>this</span><span>part,</span><span>we</span><span>will</span><span>learn</span><span>some</span><span tid="50143" class="highlight highlight-a">useful</span><span>In</span><span>this</span><span>part,</span><span>we</span><span>will</span><span>learn</span><span>some</span><span tid="50144" class="highlight highlight-a">useful</span><span>words</span><span>from</span><span>the</span><span>conversation.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 107, 201.19, 201.2, 'words from the conversation.', '从对话中学到的单词。', '/wɜːrdz frəm ðə ˌkɑːnvərˈseɪʃən/', '<span>words</span><span>from</span><span>the</span><span>conversation.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 108, 201.2, 202.92, 'words from the conversation. These words will help you understand These words will help you understand', '这些单词将帮助你更好地理解英语，并更自信地说英语。', '/ðiːz wɜːrdz wɪl hɛlp ju ˌʌndərˈstænd ˈɪŋɡlɪʃ ˈbɛtər ænd spiːk ˈɪŋɡlɪʃ mɔːr ˈkɑːnfɪdəntli/', '<span>words</span><span>from</span><span>the</span><span>conversation.</span><span>These</span><span>words</span><span>will</span><span>help</span><span>you</span><span>understand</span><span>These</span><span>words</span><span>will</span><span>help</span><span>you</span><span>understand</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 109, 202.92, 204.84, 'These words will help you understand English better and speak English more English better and speak English more', '这些单词将帮助你更好地理解英语，并更自信地说英语。', '/ðiːz wɜːrdz wɪl hɛlp ju ˌʌndərˈstænd ˈɪŋɡlɪʃ ˈbɛtər ænd spiːk ˈɪŋɡlɪʃ mɔːr ˈkɑːnfɪdəntli/', '<span>These</span><span>words</span><span>will</span><span>help</span><span>you</span><span>understand</span><span>English</span><span>better</span><span>and</span><span>speak</span><span>English</span><span>more</span><span>English</span><span>better</span><span>and</span><span>speak</span><span>English</span><span>more</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 110, 204.84, 206.59, 'English better and speak English more confidently.', '更好地理解英语，并更自信地说英语。', '/ˈɪŋɡlɪʃ ˈbɛtər ænd spiːk ˈɪŋɡlɪʃ mɔːr ˈkɑːnfɪdəntli/', '<span>English</span><span>better</span><span>and</span><span>speak</span><span>English</span><span>more</span><span tid="50145" class="highlight highlight-a">confidently.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 111, 206.59, 206.6, 'confidently.', '自信地。', '/ˈkɑːnfɪdəntli/', '<span tid="50146" class="highlight highlight-a">confidently.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 112, 206.6, 211.39, 'confidently. Listen carefully, repeat after me, and Listen carefully, repeat after me, and Listen carefully, repeat after me, and try to remember them.', '自信地。仔细听，跟我重复，仔细听，跟我重复，仔细听，跟我重复，并试着记住它们。', '/ˈkɑːnfɪdəntli. ˈlɪsən ˈkɛrfli, rɪˈpit æftər mi, ænd ˈlɪsən ˈkɛrfli, rɪˈpit æftər mi, ænd ˈlɪsən ˈkɛrfli, rɪˈpit æftər mi, ænd traɪ tuː rɪˈmɛmbər ðɛm./', '<span tid="50147" class="highlight highlight-a">confidently.</span><span>Listen</span><span tid="50148" class="highlight highlight-a">carefully,</span><span tid="50149" class="highlight highlight-a">repeat</span><span>after</span><span>me,</span><span>and</span><span>Listen</span><span tid="50150" class="highlight highlight-a">carefully,</span><span tid="50151" class="highlight highlight-a">repeat</span><span>after</span><span>me,</span><span>and</span><span>Listen</span><span tid="50152" class="highlight highlight-a">carefully,</span><span tid="50153" class="highlight highlight-a">repeat</span><span>after</span><span>me,</span><span>and</span><span tid="50154" class="highlight highlight-a">try</span><span>to</span><span tid="50155" class="highlight highlight-a">remember</span><span>them.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 113, 211.39, 211.4, 'try to remember them.', '试着记住它们。', '/traɪ tuː rɪˈmɛmbər ðɛm./', '<span tid="50156" class="highlight highlight-a">try</span><span>to</span><span tid="50157" class="highlight highlight-a">remember</span><span>them.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 114, 211.4, 214.509, 'try to remember them. Now, let''s learn the vocabulary.', '试着记住它们。现在，让我们学习词汇。', '/traɪ tuː rɪˈmɛmbər ðɛm. naʊ, lɛts lɜːrn ðə ˈvoʊkəbjʊlɛri./', '<span tid="50158" class="highlight highlight-a">try</span><span>to</span><span tid="50159" class="highlight highlight-a">remember</span><span>them.</span><span>Now,</span><span>let''s</span><span tid="50160" class="highlight highlight-a">learn</span><span>the</span><span tid="50161" class="highlight highlight-a">vocabulary.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 115, 214.509, 214.519, 'Now, let''s learn the vocabulary.', '现在，让我们学习词汇。', '/naʊ, lɛts lɜːrn ðə ˈvoʊkəbjʊlɛri./', '<span>Now,</span><span>let''s</span><span tid="50162" class="highlight highlight-a">learn</span><span>the</span><span tid="50163" class="highlight highlight-a">vocabulary.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 116, 214.519, 217.83, 'Now, let''s learn the vocabulary. One, look on the bright side.', '现在，让我们学习词汇。一，往好的方面看。', '/naʊ, lɛts lɜːrn ðə ˈvoʊkəbjʊlɛri. wʌn, lʊk ɑːn ðə braɪt saɪd./', '<span>Now,</span><span>let''s</span><span>learn</span><span>the</span><span>vocabulary.</span><span>One,</span><span>look</span><span>on</span><span>the</span><span>bright</span><span>side.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 117, 217.83, 217.84, 'One, look on the bright side.', '一，往好的方面看。', '/wʌn, lʊk ɑːn ðə braɪt saɪd./', '<span>One,</span><span>look</span><span>on</span><span>the</span><span>bright</span><span>side.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 118, 217.84, 222.19, 'One, look on the bright side. Try to see the good part of a bad Try to see the good part of a bad Try to see the good part of a bad situation.', '一，往好的方面看。试着看到坏情况中的好部分，试着看到坏情况中的好部分，试着看到坏情况中的好部分。', '/wʌn, lʊk ɑːn ðə braɪt saɪd. traɪ tuː siː ðə gʊd pɑːrt ʌv ə bæd ˈsɪtʃuːeɪʃən, traɪ tuː siː ðə gʊd pɑːrt ʌv ə bæd ˈsɪtʃuːeɪʃən, traɪ tuː siː ðə gʊd pɑːrt ʌv ə bæd ˈsɪtʃuːeɪʃən./', '<span>One,</span><span>look</span><span>on</span><span>the</span><span>bright</span><span>side.</span><span>Try</span><span>to</span><span>see</span><span>the</span><span>good</span><span>part</span><span>of</span><span>a</span><span>bad</span><span>Try</span><span>to</span><span>see</span><span>the</span><span>good</span><span>part</span><span>of</span><span>a</span><span>bad</span><span>Try</span><span>to</span><span>see</span><span>the</span><span>good</span><span>part</span><span>of</span><span>a</span><span>bad</span><span>situation.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 119, 222.19, 222.2, 'situation.', '情况。', '/ˈsɪtʃuːeɪʃən./', '<span tid="50164" class="highlight highlight-a">situation</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 120, 222.2, 224.11, 'situation. Examples.', '情况。例子。', '/ˌsɪtʃuˈeɪʃən ˈɛɡzæmpəlz/', '<span>situation.</span><span>Examples.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 121, 224.11, 224.12, 'Examples.', '例子。', '/ˈɛɡzæmpəlz/', '<span>Examples.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 122, 224.12, 231.11, 'Examples. I lost my job, but I looked on the I lost my job, but I looked on the I lost my job, but I looked on the bright side. Now, I have time to rest.', '例子。我丢了工作，但我往好处想。现在我有了休息的时间。', '/ˈɛɡzæmpəlz aɪ lɔːst maɪ dʒɑːb bʌt aɪ lʊkt ɑːn ðə braɪt saɪd naʊ aɪ hæv taɪm tuː rɛst/', '<span>Examples.</span><span>I</span><span tid="50165" class="highlight highlight-a">lost</span><span>my</span><span>job</span><span>,</span><span>but</span><span>I</span><span pid="515" class="highlight highlight-d">looked on</span><span>the</span><span>I</span><span tid="50166" class="highlight highlight-a">lost</span><span>my</span><span>job</span><span>,</span><span>but</span><span>I</span><span pid="516" class="highlight highlight-d">looked on</span><span>the</span><span>I</span><span tid="50167" class="highlight highlight-a">lost</span><span>my</span><span>job</span><span>,</span><span>but</span><span>I</span><span pid="517" class="highlight highlight-d">looked on</span><span>the</span><span tid="50168" class="highlight highlight-a">bright</span><span>side.</span><span>Now</span><span>,</span><span>I</span><span>have</span><span>time</span><span>to</span><span>rest.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 123, 231.11, 231.12, 'bright side. Now, I have time to rest.', '往好处想。现在我有了休息的时间。', '/braɪt saɪd naʊ aɪ hæv taɪm tuː rɛst/', '<span tid="50169" class="highlight highlight-a">bright</span><span>side.</span><span>Now</span><span>,</span><span>I</span><span>have</span><span>time</span><span>to</span><span>rest.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 124, 231.12, 233.52, 'bright side. Now, I have time to rest. The weather is rainy, but let''s look on The weather is rainy, but let''s look on', '往好处想。现在我有了休息的时间。天气下雨，但让我们往好处想。', '/braɪt saɪd naʊ aɪ hæv taɪm tuː rɛst ðə ˈwɛðər ɪz ˈreɪni bʌt lɛts lʊk ɑːn ðə braɪt saɪd/', '<span tid="50170" class="highlight highlight-a">bright</span><span>side.</span><span>Now</span><span>,</span><span>I</span><span>have</span><span>time</span><span>to</span><span>rest.</span><span>The</span><span>weather</span><span>is</span><span tid="50171" class="highlight highlight-a">rainy</span><span>,</span><span>but</span><span>let''s</span><span pid="518" class="highlight highlight-d">look on</span><span>The</span><span>weather</span><span>is</span><span tid="50172" class="highlight highlight-a">rainy</span><span>,</span><span>but</span><span>let''s</span><span pid="519" class="highlight highlight-d">look on</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 125, 233.52, 235.96, 'The weather is rainy, but let''s look on the bright side. We can stay home and the bright side. We can stay home and', '天气下雨，但让我们往好处想。我们可以待在家里，', '/ðə ˈwɛðər ɪz ˈreɪni bʌt lɛts lʊk ɑːn ðə braɪt saɪd wi kæn steɪ hoʊm ænd/', '<span>The</span><span>weather</span><span>is</span><span tid="50173" class="highlight highlight-a">rainy</span><span>,</span><span>but</span><span>let''s</span><span pid="520" class="highlight highlight-d">look on</span><span>the</span><span tid="50174" class="highlight highlight-a">bright</span><span>side.</span><span>We</span><span>can</span><span>stay</span><span>home</span><span>and</span><span>the</span><span tid="50175" class="highlight highlight-a">bright</span><span>side.</span><span>We</span><span>can</span><span>stay</span><span>home</span><span>and</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 126, 235.96, 238.35, 'the bright side. We can stay home and watch movies.', '往好处想。我们可以待在家里看电影。', '/ðə braɪt saɪd wi kæn steɪ hoʊm ænd wɑːtʃ ˈmuːviz/', '<span>the</span><span tid="50176" class="highlight highlight-a">bright</span><span>side.</span><span>We</span><span>can</span><span>stay</span><span>home</span><span>and</span><span>watch</span><span>movies.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 127, 238.35, 238.36, 'watch movies.', '看电影。', '/wɑːtʃ ˈmuːviz/', '<span>watch</span><span>movies.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 128, 238.36, 239.35, 'watch movies. Two.', '看电影。两个。', '/wɑːtʃ ˈmuːviz tuː/', '<span>watch</span><span>movies.</span><span>Two.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 129, 239.35, 239.36, 'Two.', '两个。', '/tuː/', '<span>Two.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 130, 239.36, 241.87, 'Two. With better pay.', '两个。有更好的报酬。', '/tuː wɪð ˈbɛtər peɪ/', '<span>Two.</span><span>With</span><span tid="50177" class="highlight highlight-a">better</span><span>pay.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 131, 241.87, 241.88, 'With better pay.', '有更好的报酬。', '/wɪð ˈbɛtər peɪ/', '<span>With</span><span tid="50178" class="highlight highlight-a">better</span><span>pay.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 132, 241.88, 245.07, 'With better pay. More money or a higher salary.', '有更好的报酬。更多的钱或更高的薪水。', '/wɪð ˈbɛtər peɪ mɔːr ˈmʌni ɔːr ə ˈhaɪər ˈsæləri/', '<span>With</span><span tid="50179" class="highlight highlight-a">better</span><span>pay.</span><span>More</span><span>money</span><span>or</span><span>a</span><span tid="50180" class="highlight highlight-a">higher</span><span>salary.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 133, 245.07, 245.08, 'More money or a higher salary.', '更多的钱或更高的薪水。', '/mɔːr ˈmʌni ɔːr ə ˈhaɪər ˈsæləri/', '<span>More</span><span>money</span><span>or</span><span>a</span><span tid="50181" class="highlight highlight-a">higher</span><span>salary.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 134, 245.08, 247.43, 'More money or a higher salary. Examples.', '更多的钱或更高的薪水。例子。', '/mɔːr ˈmʌni ɔːr ə ˈhaɪər ˈsæləri ɪɡˈzæmpəlz/', '<span>More</span><span>money</span><span>or</span><span>a</span><span tid="50182" class="highlight highlight-a">higher</span><span>salary.</span><span>Examples.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 135, 247.43, 247.44, 'Examples.', '例子。', '/ɪɡˈzæmpəlz/', '<span>Examples.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 136, 247.44, 250.87, 'Examples. She wants a job with better pay.', '例子。她想要一份薪水更高的工作。', '/ˈɛɡzæmpəlz. ʃi wɑːnts ə dʒɑb wɪð ˈbɛtər peɪ./', '<span>Examples.</span><span>She</span><span>wants</span><span>a</span><span>job</span><span>with</span><span>better</span><span>pay.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 137, 250.87, 250.88, 'She wants a job with better pay.', '她想要一份薪水更高的工作。', '/ʃi wɑːnts ə dʒɑb wɪð ˈbɛtər peɪ./', '<span>She</span><span tid="50183" class="highlight highlight-a">wants</span><span>a</span><span>job</span><span>with</span><span tid="50184" class="highlight highlight-a">better</span><span>pay.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 138, 250.88, 253.48, 'She wants a job with better pay. This company offers better pay than my This company offers better pay than my', '她想要一份薪水更高的工作。这家公司提供的薪水比我上一份工作高。', '/ʃi wɑːnts ə dʒɑb wɪð ˈbɛtər peɪ. ðɪs ˈkʌmpəni ˈɔfərz ˈbɛtər peɪ ðæn maɪ læst dʒɑb./', '<span>She</span><span>wants</span><span>a</span><span>job</span><span>with</span><span>better</span><span>pay.</span><span>This</span><span>company</span><span>offers</span><span>better</span><span>pay</span><span>than</span><span>my</span><span>This</span><span>company</span><span>offers</span><span>better</span><span>pay</span><span>than</span><span>my</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 139, 253.48, 255.91, 'This company offers better pay than my last job.', '这家公司提供的薪水比我上一份工作高。', '/ðɪs ˈkʌmpəni ˈɔfərz ˈbɛtər peɪ ðæn maɪ læst dʒɑb./', '<span>This</span><span>company</span><span tid="50185" class="highlight highlight-a">offers</span><span tid="50186" class="highlight highlight-a">better</span><span>pay</span><span>than</span><span>my</span><span>last</span><span>job.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 140, 255.91, 255.92, 'last job.', '上一份工作。', '/læst dʒɑb./', '<span>last</span><span>job.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 141, 255.92, 259.11, 'last job. Three. My treat.', '上一份工作。三。我请客。', '/læst dʒɑb. θriː. maɪ triːt./', '<span>last</span><span>job.</span><span>Three.</span><span>My</span><span tid="50187" class="highlight highlight-i">treat.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 142, 259.11, 259.12, 'Three. My treat.', '三。我请客。', '/θriː. maɪ triːt./', '<span>Three.</span><span>My</span><span tid="50188" class="highlight highlight-i">treat.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 143, 259.12, 264.63, 'Three. My treat. I will pay for it. Usually food, drinks, I will pay for it. Usually food, drinks, I will pay for it. Usually food, drinks, or tickets.', '三。我请客。我来付钱。通常是食物、饮料或门票。', '/θriː. maɪ triːt. aɪ wɪl peɪ fɔr ɪt. ˈjuʒuəli fud, drɪŋks, ɔr ˈtɪkɪts./', '<span>Three.</span><span>My</span><span>treat.</span><span>I</span><span>will</span><span>pay</span><span>for</span><span>it.</span><span>Usually</span><span>food,</span><span>drinks,</span><span>I</span><span>will</span><span>pay</span><span>for</span><span>it.</span><span>Usually</span><span>food,</span><span>drinks,</span><span>I</span><span>will</span><span>pay</span><span>for</span><span>it.</span><span>Usually</span><span>food,</span><span>drinks,</span><span>or</span><span>tickets.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 144, 264.63, 264.64, 'or tickets.', '或者票。', '/ɔːr ˈtɪkɪts/', '<span>or</span><span>tickets.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 145, 264.64, 266.67, 'or tickets. Examples.', '或者票。例子。', '/ɔːr ˈtɪkɪts. ˈɛɡzəmpəlz/', '<span>or</span><span>tickets.</span><span>Examples.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 146, 266.67, 266.68, 'Examples.', '例子。', '/ˈɛɡzəmpəlz/', '<span>Examples.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 147, 266.68, 270.63, 'Examples. Don''t worry about the bill. My treat.', '例子。别担心账单。我请客。', '/ˈɛɡzəmpəlz. doʊnt ˈwɜːri əˈbaʊt ðə bɪl. maɪ triːt/', '<span>Examples.</span><span>Don''t</span><span pid="521" class="highlight highlight-d">worry about</span><span>the</span><span>bill.</span><span>My</span><span tid="50189" class="highlight highlight-a">treat.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 148, 270.63, 270.64, 'Don''t worry about the bill. My treat.', '别担心账单。我请客。', '/doʊnt ˈwɜːri əˈbaʊt ðə bɪl. maɪ triːt/', '<span>Don''t</span><span pid="522" class="highlight highlight-d">worry about</span><span>the</span><span>bill.</span><span>My</span><span tid="50190" class="highlight highlight-a">treat.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 149, 270.64, 273.72, 'Don''t worry about the bill. My treat. You helped me today, so lunch is my You helped me today, so lunch is my', '别担心账单。我请客。你今天帮了我，所以午餐我请。你今天帮了我，所以午餐我请。', '/doʊnt ˈwɜːri əˈbaʊt ðə bɪl. maɪ triːt. juː hɛlpt miː təˈdeɪ, soʊ lʌntʃ ɪz maɪ juː hɛlpt miː təˈdeɪ, soʊ lʌntʃ ɪz maɪ/', '<span>Don''t</span><span pid="523" class="highlight highlight-d">worry about</span><span>the</span><span>bill.</span><span>My</span><span tid="50191" class="highlight highlight-a">treat.</span><span>You</span><span>helped</span><span>me</span><span>today,</span><span>so</span><span>lunch</span><span>is</span><span>my</span><span>You</span><span>helped</span><span>me</span><span>today,</span><span>so</span><span>lunch</span><span>is</span><span>my</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 150, 273.72, 275.27, 'You helped me today, so lunch is my treat.', '你今天帮了我，所以午餐我请。', '/juː hɛlpt miː təˈdeɪ, soʊ lʌntʃ ɪz maɪ triːt/', '<span>You</span><span>helped</span><span>me</span><span>today,</span><span>so</span><span>lunch</span><span>is</span><span>my</span><span tid="50192" class="highlight highlight-a">treat.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 151, 275.27, 275.28, 'treat.', '请客。', '/triːt/', '<span tid="50193" class="highlight highlight-a">treat.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 152, 275.28, 280.909, 'treat. Great job, guys. Remember, repetition is Great job, guys. Remember, repetition is Great job, guys. Remember, repetition is the key to success in English.', '对待。干得好，伙计们。记住，重复是英语成功的关键。', '/triːt. ɡreɪt dʒɑb, ɡaɪz. rɪˈmɛmbər, ˌrɛpəˈtɪʃən ɪz ðə kiː tuː səkˈsɛs ɪn ˈɪŋɡlɪʃ./', '<span>treat.</span><span>Great</span><span>job,</span><span>guys.</span><span>Remember,</span><span>repetition</span><span>is</span><span>Great</span><span>job,</span><span>guys.</span><span>Remember,</span><span>repetition</span><span>is</span><span>Great</span><span>job,</span><span>guys.</span><span>Remember,</span><span>repetition</span><span>is</span><span>the</span><span>key</span><span>to</span><span>success</span><span>in</span><span>English.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 153, 280.909, 280.919, 'the key to success in English.', '英语成功的关键。', '/ðə kiː tuː səkˈsɛs ɪn ˈɪŋɡlɪʃ./', '<span>the</span><span tid="50194" class="highlight highlight-a">key</span><span>to</span><span tid="50195" class="highlight highlight-a">success</span><span>in</span><span>English.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 154, 280.919, 282.64, 'the key to success in English. The more you repeat the words, the The more you repeat the words, the', '英语成功的关键。你重复单词的次数越多，', '/ðə kiː tuː səkˈsɛs ɪn ˈɪŋɡlɪʃ. ðə mɔːr juː rɪˈpit ðə wɜːrdz, ðə/', '<span>the</span><span>key</span><span>to</span><span>success</span><span>in</span><span>English.</span><span>The</span><span>more</span><span>you</span><span>repeat</span><span>the</span><span>words,</span><span>the</span><span>The</span><span>more</span><span>you</span><span>repeat</span><span>the</span><span>words,</span><span>the</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 155, 282.64, 284.87, 'The more you repeat the words, the easier they will become.', '你重复单词的次数越多，它们就会变得越容易。', '/ðə mɔːr juː rɪˈpit ðə wɜːrdz, ðə ˈiːziər ðeɪ wɪl bɪˈkʌm./', '<span>The</span><span>more</span><span>you</span><span tid="50196" class="highlight highlight-a">repeat</span><span>the</span><span>words</span><span>,</span><span>the</span><span tid="50197" class="highlight highlight-a">easier</span><span>they</span><span>will</span><span>become.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 156, 284.87, 284.88, 'easier they will become.', '它们就会变得越容易。', '/ˈiːziər ðeɪ wɪl bɪˈkʌm./', '<span tid="50198" class="highlight highlight-a">easier</span><span>they</span><span>will</span><span>become.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 157, 284.88, 287.28, 'easier they will become. Watch this video again and again, then Watch this video again and again, then', '它们就会变得越容易。反复观看这个视频，然后', '/ˈiːziər ðeɪ wɪl bɪˈkʌm. wɑːtʃ ðɪs ˈvɪdiəʊ əˈɡɛn ænd əˈɡɛn, ðɛn/', '<span>easier</span><span>they</span><span>will</span><span>become.</span><span>Watch</span><span>this</span><span>video</span><span>again</span><span>and</span><span>again,</span><span>then</span><span>Watch</span><span>this</span><span>video</span><span>again</span><span>and</span><span>again,</span><span>then</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 158, 287.28, 289.32, 'Watch this video again and again, then say the words out loud. You will get say the words out loud. You will get', '反复观看这个视频，然后大声说出单词。你会', '/wɑːtʃ ðɪs ˈvɪdiəʊ əˈɡɛn ænd əˈɡɛn, ðɛn seɪ ðə wɜːrdz aʊt laʊd. juː wɪl ɡɛt/', '<span>Watch</span><span>this</span><span>video</span><span>again</span><span>and</span><span>again,</span><span>then</span><span>say</span><span>the</span><span>words</span><span>out</span><span>loud.</span><span>You</span><span>will</span><span>get</span><span>say</span><span>the</span><span>words</span><span>out</span><span>loud.</span><span>You</span><span>will</span><span>get</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 159, 289.32, 292.83, 'say the words out loud. You will get better and better each time.', '大声说出单词。你会每次变得更好。', '/seɪ ðə wɜːrdz aʊt laʊd. juː wɪl ɡɛt ˈbɛtər ænd ˈbɛtər iːtʃ taɪm./', '<span tid="50199" class="highlight highlight-a">say</span><span>the</span><span>words</span><span>out</span><span tid="50200" class="highlight highlight-c">loud.</span><span>You</span><span>will</span><span>get</span><span>better</span><span>and</span><span>better</span><span>each</span><span>time.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 160, 292.83, 292.84, 'better and better each time.', '每次越来越好。', '/ˈbɛtər ænd ˈbɛtər iːtʃ taɪm/', '<span tid="50201" class="highlight highlight-a">better</span><span>and</span><span tid="50202" class="highlight highlight-a">better</span><span>each</span><span>time.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 161, 292.84, 294.31, 'better and better each time. Part three.', '每次越来越好。第三部分。', '/ˈbɛtər ænd ˈbɛtər iːtʃ taɪm. pɑːrt θriː/', '<span tid="50203" class="highlight highlight-a">better</span><span>and</span><span tid="50204" class="highlight highlight-a">better</span><span>each</span><span>time.</span><span>Part</span><span>three.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 162, 294.31, 294.32, 'Part three.', '第三部分。', '/pɑːrt θriː/', '<span>Part</span><span>three.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 163, 294.32, 297.39, 'Part three. Listen and answer.', '第三部分。听并回答。', '/pɑːrt θriː. lɪsən ænd ˈænsər/', '<span>Part</span><span>three.</span><span tid="50205" class="highlight highlight-a">Listen</span><span>and</span><span tid="50206" class="highlight highlight-a">answer.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 164, 297.39, 297.4, 'Listen and answer.', '听并回答。', '/ˈlɪsən ænd ˈænsər/', '<span tid="50207" class="highlight highlight-a">Listen</span><span>and</span><span tid="50208" class="highlight highlight-a">answer.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 165, 297.4, 302.11, 'Listen and answer. In this part, I will ask you questions In this part, I will ask you questions In this part, I will ask you questions about the conversation. Listen carefully', '听并回答。在这一部分，我会问你关于对话的问题。仔细听。', '/ˈlɪsən ænd ˈænsər. ɪn ðɪs pɑːrt, aɪ wɪl æsk juː ˈkwɛstʃənz əˈbaʊt ðə ˌkɑːnvərˈseɪʃən. ˈlɪsən ˈkɛrəfli/', '<span tid="50209" class="highlight highlight-a">Listen</span><span>and</span><span tid="50210" class="highlight highlight-a">answer.</span><span>In</span><span>this</span><span>part,</span><span>I</span><span>will</span><span tid="50211" class="highlight highlight-a">ask</span><span>you</span><span tid="50212" class="highlight highlight-a">questions</span><span>In</span><span>this</span><span>part,</span><span>I</span><span>will</span><span tid="50213" class="highlight highlight-a">ask</span><span>you</span><span tid="50214" class="highlight highlight-a">questions</span><span>In</span><span>this</span><span>part,</span><span>I</span><span>will</span><span tid="50215" class="highlight highlight-a">ask</span><span>you</span><span tid="50216" class="highlight highlight-a">questions</span><span>about</span><span>the</span><span tid="50217" class="highlight highlight-a">conversation.</span><span tid="50218" class="highlight highlight-a">Listen</span><span tid="50219" class="highlight highlight-a">carefully</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 166, 302.11, 304.35, 'about the conversation. Listen carefully about the conversation. Listen carefully and try to answer out loud before you', '关于对话。仔细听，并在你听到正确答案之前大声尝试回答。', '/əˈbaʊt ðə ˌkɑːnvərˈseɪʃən. ˈlɪsən ˈkɛrəfli ænd traɪ tuː ˈænsər aʊt laʊd bɪˈfɔːr juː/', '<span>about</span><span>the</span><span tid="50220" class="highlight highlight-a">conversation.</span><span tid="50221" class="highlight highlight-a">Listen</span><span tid="50222" class="highlight highlight-a">carefully</span><span>about</span><span>the</span><span tid="50223" class="highlight highlight-a">conversation.</span><span tid="50224" class="highlight highlight-a">Listen</span><span tid="50225" class="highlight highlight-a">carefully</span><span>and</span><span tid="50226" class="highlight highlight-a">try</span><span>to</span><span tid="50227" class="highlight highlight-a">answer</span><span>out</span><span tid="50228" class="highlight highlight-a">loud</span><span>before</span><span>you</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 167, 304.35, 306.55, 'and try to answer out loud before you and try to answer out loud before you hear the correct answer.', '并在你听到正确答案之前大声尝试回答。', '/ænd traɪ tuː ˈænsər aʊt laʊd bɪˈfɔːr juː hɪr ðə ˈkɔːrəkt ˈænsər/', '<span>and</span><span tid="50229" class="highlight highlight-a">try</span><span>to</span><span tid="50230" class="highlight highlight-a">answer</span><span>out</span><span tid="50231" class="highlight highlight-a">loud</span><span>before</span><span>you</span><span>and</span><span tid="50232" class="highlight highlight-a">try</span><span>to</span><span tid="50233" class="highlight highlight-a">answer</span><span>out</span><span tid="50234" class="highlight highlight-a">loud</span><span>before</span><span>you</span><span tid="50235" class="highlight highlight-a">hear</span><span>the</span><span tid="50236" class="highlight highlight-a">correct</span><span tid="50237" class="highlight highlight-a">answer.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 168, 306.55, 306.56, 'hear the correct answer.', '听到正确答案。', '/hɪr ðə kəˈrɛkt ˈænsər/', '<span tid="50238" class="highlight highlight-a">hear</span><span>the</span><span tid="50239" class="highlight highlight-a">correct</span><span>answer.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 169, 306.56, 310.47, 'hear the correct answer. Don''t worry if your answer is not Don''t worry if your answer is not Don''t worry if your answer is not perfect. Speaking practice helps you', '听到正确答案。如果你的答案不完美，别担心。口语练习能帮助你更快地流利表达。', '/hɪr ðə kəˈrɛkt ˈænsər. doʊnt ˈwɜːri ɪf jɔːr ˈænsər ɪz nɑːt pərˈfɛkt. ˈspiːkɪŋ ˈpræktɪs hɛlps juː bɪˈkʌm ˈfluːənt moʊr ˈkwɪkli/', '<span tid="50240" class="highlight highlight-a">hear</span><span>the</span><span tid="50241" class="highlight highlight-a">correct</span><span>answer.</span><span>Don''t</span><span tid="50242" class="highlight highlight-a">worry</span><span>if</span><span>your</span><span tid="50243" class="highlight highlight-a">answer</span><span>is</span><span>not</span><span>Don''t</span><span tid="50244" class="highlight highlight-a">worry</span><span>if</span><span>your</span><span tid="50245" class="highlight highlight-a">answer</span><span>is</span><span>not</span><span>Don''t</span><span tid="50246" class="highlight highlight-a">worry</span><span>if</span><span>your</span><span tid="50247" class="highlight highlight-a">answer</span><span>is</span><span>not</span><span tid="50248" class="highlight highlight-a">perfect.</span><span tid="50249" class="highlight highlight-a">Speaking</span><span tid="50250" class="highlight highlight-a">practice</span><span>helps</span><span>you</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 170, 310.47, 313.15, 'perfect. Speaking practice helps you perfect. Speaking practice helps you become fluent more quickly.', '完美。口语练习能帮助你更快地流利表达。', '/pərˈfɛkt. ˈspiːkɪŋ ˈpræktɪs hɛlps juː bɪˈkʌm ˈfluːənt moʊr ˈkwɪkli/', '<span tid="50251" class="highlight highlight-a">perfect.</span><span tid="50252" class="highlight highlight-a">Speaking</span><span tid="50253" class="highlight highlight-a">practice</span><span>helps</span><span>you</span><span tid="50254" class="highlight highlight-a">perfect.</span><span tid="50255" class="highlight highlight-a">Speaking</span><span tid="50256" class="highlight highlight-a">practice</span><span>helps</span><span>you</span><span tid="50257" class="highlight highlight-a">become</span><span tid="50258" class="highlight highlight-a">fluent</span><span>more</span><span tid="50259" class="highlight highlight-a">quickly.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 171, 313.15, 313.16, 'become fluent more quickly.', '更快地流利表达。', '/bɪˈkʌm ˈfluːənt moʊr ˈkwɪkli/', '<span tid="50260" class="highlight highlight-a">become</span><span tid="50261" class="highlight highlight-a">fluent</span><span>more</span><span tid="50262" class="highlight highlight-a">quickly.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 172, 313.16, 315.51, 'become fluent more quickly. What happened, Mark?', '更快地流利表达。发生什么事了，马克？', '/bɪˈkʌm ˈfluːənt moʊr ˈkwɪkli. wʌt ˈhæpənd, mɑːrk/', '<span tid="50263" class="highlight highlight-a">become</span><span tid="50264" class="highlight highlight-a">fluent</span><span>more</span><span tid="50265" class="highlight highlight-a">quickly.</span><span>What</span><span tid="50266" class="highlight highlight-a">happened,</span><span>Mark?</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 173, 315.51, 315.52, 'What happened, Mark?', '发生什么事了，马克？', '/wʌt ˈhæpənd, mɑːrk/', '<span>What</span><span tid="50267" class="highlight highlight-a">happened,</span><span>Mark?</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 174, 315.52, 317.56, 'What happened, Mark? Do you remember the job I told you about Do you remember the job I told you about', '发生什么事了，马克？你还记得我之前告诉你的那份工作吗？', '/wʌt ˈhæpənd, mɑːrk? duː juː rɪˈmɛmbər ðə dʒɑːb aɪ toʊld juː əˈbaʊt/', '<span>What</span><span tid="50268" class="highlight highlight-a">happened,</span><span>Mark?</span><span>Do</span><span>you</span><span tid="50269" class="highlight highlight-a">remember</span><span>the</span><span tid="50270" class="highlight highlight-a">job</span><span>I</span><span>told</span><span>you</span><span>about</span><span>Do</span><span>you</span><span tid="50271" class="highlight highlight-a">remember</span><span>the</span><span tid="50272" class="highlight highlight-a">job</span><span>I</span><span>told</span><span>you</span><span>about</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 175, 317.56, 319.47, 'Do you remember the job I told you about before?', '你还记得我之前告诉你的那份工作吗？', '/duː juː rɪˈmɛmbər ðə dʒɑːb aɪ toʊld juː əˈbaʊt bɪˈfɔːr/', '<span>Do</span><span>you</span><span tid="50273" class="highlight highlight-a">remember</span><span>the</span><span tid="50274" class="highlight highlight-a">job</span><span>I</span><span>told</span><span>you</span><span>about</span><span tid="50275" class="highlight highlight-a">before?</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 176, 319.47, 319.48, 'before?', '之前？', '/bɪˈfɔːr/', '<span>before?</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 177, 319.48, 322.67, 'before? I got a rejection email from the I got a rejection email from the I got a rejection email from the company.', '之前？我收到了一封来自公司的拒绝邮件。', '/bɪˈfɔːr aɪ ˈɡɑːt ə rɪˈdʒɛkʃən ˈiːmeɪl frəm ðə aɪ ˈɡɑːt ə rɪˈdʒɛkʃən ˈiːmeɪl frəm ðə aɪ ˈɡɑːt ə rɪˈdʒɛkʃən ˈiːmeɪl frəm ðə ˈkʌmpəni/', '<span>before?</span><span>I</span><span>got</span><span>a</span><span tid="50276" class="highlight highlight-a">rejection</span><span>email</span><span>from</span><span>the</span><span>I</span><span>got</span><span>a</span><span tid="50277" class="highlight highlight-a">rejection</span><span>email</span><span>from</span><span>the</span><span>I</span><span>got</span><span>a</span><span tid="50278" class="highlight highlight-a">rejection</span><span>email</span><span>from</span><span>the</span><span>company.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 178, 322.67, 322.68, 'company.', '公司。', '/ˈkʌmpəni/', '<span>company.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 179, 322.68, 328.35, 'company. What did Mark get?', '公司。马克收到了什么？', '/ˈkʌmpəni wʌt dɪd mɑːrk ˈɡɛt/', '<span>company.</span><span>What</span><span>did</span><span>Mark</span><span>get?</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 180, 331.75, 331.76, 'An email from the company.', '一封来自公司的邮件。', '/ən ˈiːmeɪl frəm ðə ˈkʌmpəni/', '<span>An</span><span>email</span><span>from</span><span>the</span><span>company.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 181, 331.76, 336.15, 'An email from the company. He got an email from the company.', '一封来自公司的邮件。他收到了一封来自公司的邮件。', '/ən ˈiːmeɪl frəm ðə ˈkʌmpəni hi ˈɡɑːt ən ˈiːmeɪl frəm ðə ˈkʌmpəni/', '<span>An</span><span>email</span><span>from</span><span>the</span><span>company.</span><span>He</span><span>got</span><span>an</span><span>email</span><span>from</span><span>the</span><span>company.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 182, 344.99, 345.0, 'No, they didn''t.', '不，他们没有。', '/noʊ ðeɪ ˈdɪdənt/', '<span>No,</span><span>they</span><span>didn''t.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 183, 345.0, 348.95, 'No, they didn''t. They rejected him.', '不，他们没有。他们拒绝了他。', '/noʊ ðeɪ ˈdɪdənt ðeɪ rɪˈdʒɛktɪd hɪm/', '<span>No,</span><span>they</span><span>didn''t.</span><span>They</span><span tid="50279" class="highlight highlight-a">rejected</span><span>him.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 184, 351.27, 355.71, 'Did Mark tell Betty before about the Did Mark tell Betty before about the job?', '马克之前告诉过贝蒂关于那份工作的事吗？', '/dɪd mɑːrk tɛl ˈbɛti bɪˈfɔːr əˈbaʊt ðə dʒɑb/', '<span>Did</span><span>Mark</span><span>tell</span><span>Betty</span><span>before</span><span>about</span><span>the</span><span>Did</span><span>Mark</span><span>tell</span><span>Betty</span><span>before</span><span>about</span><span>the</span><span>job?</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 185, 358.99, 359.0, 'Yes, he did.', '是的，他告诉了。', '/jɛs hi dɪd/', '<span>Yes,</span><span>he</span><span>did.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 186, 359.0, 363.07, 'Yes, he did. He told Betty before about the job.', '是的，他告诉了。他之前告诉过贝蒂关于那份工作的事。', '/jɛs hi dɪd hi tɛl ˈbɛti bɪˈfɔːr əˈbaʊt ðə dʒɑb/', '<span>Yes,</span><span>he</span><span>did.</span><span>He</span><span tid="50280" class="highlight highlight-a">told</span><span>Betty</span><span>before</span><span>about</span><span>the</span><span>job.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 187, 363.07, 363.08, 'He told Betty before about the job.', '他之前告诉过贝蒂关于那份工作的事。', '/hi tɛl ˈbɛti bɪˈfɔːr əˈbaʊt ðə dʒɑb/', '<span>He</span><span tid="50281" class="highlight highlight-a">told</span><span>Betty</span><span>before</span><span>about</span><span>the</span><span>job.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 188, 363.08, 366.51, 'He told Betty before about the job. I prepared so hard for the interview.', '他之前告诉过贝蒂关于那份工作的事。我为面试准备得非常努力。', '/hi tɛl ˈbɛti bɪˈfɔːr əˈbaʊt ðə dʒɑb aɪ prɪˈpɛrd soʊ hɑːrd fɔːr ði ˈɪntərvjuː/', '<span>He</span><span tid="50282" class="highlight highlight-a">told</span><span>Betty</span><span>before</span><span>about</span><span>the</span><span>job.</span><span>I</span><span tid="50283" class="highlight highlight-a">prepared</span><span>so</span><span>hard</span><span>for</span><span>the</span><span>interview.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 189, 366.51, 366.52, 'I prepared so hard for the interview.', '我为面试准备得非常努力。', '/aɪ prɪˈpɛrd soʊ hɑːrd fɔːr ði ˈɪntərvjuː/', '<span>I</span><span tid="50284" class="highlight highlight-a">prepared</span><span>so</span><span>hard</span><span>for</span><span>the</span><span>interview.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 190, 366.52, 369.0, 'I prepared so hard for the interview. I studied all week and practiced answers I studied all week and practiced answers', '我为面试准备得非常努力。我整个星期都在学习，并且练习了答案。', '/aɪ prɪˈpɛrd soʊ hɑːrd fɔːr ði ˈɪntərvjuː aɪ ˈstʌdid ɔːl wiːk ænd ˈpræktɪst ˈænsərz aɪ ˈstʌdid ɔːl wiːk ænd ˈpræktɪst ˈænsərz/', '<span>I</span><span tid="50285" class="highlight highlight-a">prepared</span><span>so</span><span>hard</span><span>for</span><span>the</span><span>interview.</span><span>I</span><span tid="50286" class="highlight highlight-a">studied</span><span>all</span><span>week</span><span>and</span><span tid="50287" class="highlight highlight-a">practiced</span><span>answers</span><span>I</span><span tid="50288" class="highlight highlight-a">studied</span><span>all</span><span>week</span><span>and</span><span tid="50289" class="highlight highlight-a">practiced</span><span>answers</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 191, 369.0, 370.79, 'I studied all week and practiced answers every night.', '我整个星期都在学习，并且每晚练习答案。', '/aɪ ˈstʌdid ɔːl wiːk ænd ˈpræktɪst ˈænsərz ˈɛvri naɪt/', '<span>I</span><span tid="50290" class="highlight highlight-a">studied</span><span>all</span><span>week</span><span>and</span><span tid="50291" class="highlight highlight-a">practiced</span><span>answers</span><span>every</span><span>night.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 192, 370.79, 370.8, 'every night.', '每晚。', '/ˈɛv.ri naɪt/', '<span>every</span><span>night.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 193, 370.8, 376.83, 'every night. Did Mark prepare for the interview?', '每晚。马克为面试做准备了吗？', '/ˈɛv.ri naɪt. dɪd mɑːrk prɪˈpɛr fɔːr ði ˈɪn.tər.vjuː/', '<span>every</span><span>night.</span><span>Did</span><span>Mark</span><span tid="50292" class="highlight highlight-a">prepare</span><span>for</span><span>the</span><span tid="50293" class="highlight highlight-a">interview?</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 194, 379.83, 379.84, 'Yes, he did.', '是的，他做了。', '/jɛs, hi dɪd/', '<span>Yes,</span><span>he</span><span>did.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 195, 379.84, 383.909, 'Yes, he did. He prepared for the interview.', '是的，他做了。他为面试做了准备。', '/jɛs, hi dɪd. hi prɪˈpɛrd fɔːr ði ˈɪn.tər.vjuː/', '<span>Yes,</span><span>he</span><span>did.</span><span>He</span><span tid="50294" class="highlight highlight-a">prepared</span><span>for</span><span>the</span><span tid="50295" class="highlight highlight-a">interview.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 196, 391.909, 391.919, 'All week.', '整个星期。', '/ɔːl wiːk/', '<span>All</span><span>week.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 197, 391.919, 395.47, 'All week. He studied all week.', '整个星期。他整个星期都在学习。', '/ɔːl wiːk. hi ˈstʌd.id ɔːl wiːk/', '<span>All</span><span>week.</span><span>He</span><span tid="50296" class="highlight highlight-a">studied</span><span>all</span><span>week.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 198, 395.47, 395.48, 'He studied all week.', '他整个星期都在学习。', '/hi ˈstʌd.id ɔːl wiːk/', '<span>He</span><span tid="50297" class="highlight highlight-a">studied</span><span>all</span><span>week.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 199, 395.48, 401.63, 'He studied all week. Did Mark work hard for the interview?', '他整个星期都在学习。马克为面试努力准备了吗？', '/hi ˈstʌd.id ɔːl wiːk. dɪd mɑːrk wɜːrk hɑːrd fɔːr ði ˈɪn.tər.vjuː/', '<span>He</span><span tid="50298" class="highlight highlight-a">studied</span><span>all</span><span>week.</span><span>Did</span><span>Mark</span><span tid="50299" class="highlight highlight-a">work</span><span>hard</span><span>for</span><span>the</span><span tid="50300" class="highlight highlight-a">interview?</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 200, 404.03, 404.04, 'Yes, he did.', '是的，他做到了。', '/jɛs hi dɪd/', '<span>Yes</span><span>,</span><span>he</span><span>did</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 201, 404.04, 407.79, 'Yes, he did. He worked hard for the interview.', '是的，他做到了。他为面试付出了很多努力。', '/jɛs hi dɪd hi wɜːrkt hɑːrd fɔːr ði ˈɪntərˌvjuː/', '<span>Yes</span><span>,</span><span>he</span><span>did</span><span>.</span><span>He</span><span pid="524" class="highlight highlight-c">worked hard for</span><span>the</span><span tid="50301" class="highlight highlight-a">interview</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 202, 407.79, 407.8, 'He worked hard for the interview.', '他为面试付出了很多努力。', '/hi wɜːrkt hɑːrd fɔːr ði ˈɪntərˌvjuː/', '<span>He</span><span pid="525" class="highlight highlight-c">worked hard for</span><span>the</span><span tid="50302" class="highlight highlight-a">interview</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 203, 407.8, 411.95, 'He worked hard for the interview. Wow, you really tried your best.', '他为面试付出了很多努力。哇，你真的尽力了。', '/hi wɜːrkt hɑːrd fɔːr ði ˈɪntərˌvjuː waʊ ju ˈrɪli traɪd jɔːr bɛst/', '<span>He</span><span pid="526" class="highlight highlight-c">worked hard for</span><span>the</span><span tid="50303" class="highlight highlight-a">interview</span><span>.</span><span>Wow</span><span>,</span><span>you</span><span>really</span><span pid="527" class="highlight highlight-i">tried your best</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 204, 411.95, 411.96, 'Wow, you really tried your best.', '哇，你真的尽力了。', '/waʊ ju ˈrɪli traɪd jɔːr bɛst/', '<span>Wow</span><span>,</span><span>you</span><span>really</span><span pid="528" class="highlight highlight-i">tried your best</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 205, 411.96, 414.44, 'Wow, you really tried your best. Yes, I did everything I could to get Yes, I did everything I could to get', '哇，你真的尽力了。是的，我尽了一切努力去得到是的，我尽了一切努力去得到', '/waʊ ju ˈrɪli traɪd jɔːr bɛst jɛs aɪ dɪd ˈɛvriθɪŋ aɪ kʊd tuː ɡɛt jɛs aɪ dɪd ˈɛvriθɪŋ aɪ kʊd tuː ɡɛt/', '<span>Wow</span><span>,</span><span>you</span><span>really</span><span pid="529" class="highlight highlight-i">tried your best</span><span>.</span><span>Yes</span><span>,</span><span>I</span><span pid="530" class="highlight highlight-l">did everything I could to get</span><span>Yes</span><span>,</span><span>I</span><span pid="531" class="highlight highlight-l">did everything I could to get</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 206, 414.44, 416.27, 'Yes, I did everything I could to get that job.', '是的，我尽了一切努力去得到那份工作。', '/jɛs aɪ dɪd ˈɛvriθɪŋ aɪ kʊd tuː ɡɛt ðæt dʒɑːb/', '<span>Yes</span><span>,</span><span>I</span><span pid="532" class="highlight highlight-l">did everything I could to get</span><span>that</span><span tid="50304" class="highlight highlight-a">job</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 207, 416.27, 416.28, 'that job.', '那份工作。', '/ðæt dʒɑːb/', '<span>that</span><span tid="50305" class="highlight highlight-a">job</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 208, 416.28, 420.67, 'that job. Oh, I understand why you feel so sad.', '那份工作。哦，我理解你为什么这么难过。', '/ðæt dʒɑb. oʊ, aɪ ˌʌndərˈstænd waɪ juː fiːl soʊ sæd./', '<span>that</span><span tid="50306" class="highlight highlight-a">job</span><span>.</span><span>Oh</span><span>,</span><span>I</span><span tid="50307" class="highlight highlight-a">understand</span><span>why</span><span>you</span><span>feel</span><span>so</span><span tid="50308" class="highlight highlight-a">sad</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 209, 420.67, 420.68, 'Oh, I understand why you feel so sad.', '哦，我理解你为什么这么难过。', '/oʊ, aɪ ˌʌndərˈstænd waɪ juː fiːl soʊ sæd./', '<span>Oh</span><span>,</span><span>I</span><span tid="50309" class="highlight highlight-a">understand</span><span>why</span><span>you</span><span>feel</span><span>so</span><span tid="50310" class="highlight highlight-a">sad</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 210, 420.68, 425.71, 'Oh, I understand why you feel so sad. But tell me, But tell me, But tell me, is that job really good for you?', '哦，我理解你为什么这么难过。但告诉我，但告诉我，但告诉我，那份工作真的适合你吗？', '/oʊ, aɪ ˌʌndərˈstænd waɪ juː fiːl soʊ sæd. bʌt tɛl mi, bʌt tɛl mi, bʌt tɛl mi, ɪz ðæt dʒɑb ˈrɪli ɡʊd fɔr juː?/', '<span>Oh</span><span>,</span><span>I</span><span tid="50311" class="highlight highlight-a">understand</span><span>why</span><span>you</span><span>feel</span><span>so</span><span tid="50312" class="highlight highlight-a">sad</span><span>.</span><span>But</span><span>tell</span><span>me</span><span>,</span><span>But</span><span>tell</span><span>me</span><span>,</span><span>But</span><span>tell</span><span>me</span><span>,</span><span>is</span><span>that</span><span tid="50313" class="highlight highlight-a">job</span><span>really</span><span>good</span><span>for</span><span>you</span><span>?</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 211, 425.71, 425.72, 'is that job really good for you?', '那份工作真的适合你吗？', '/ɪz ðæt dʒɑb ˈrɪli ɡʊd fɔr juː?/', '<span>is</span><span>that</span><span tid="50314" class="highlight highlight-a">job</span><span>really</span><span>good</span><span>for</span><span>you</span><span>?</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 212, 425.72, 428.52, 'is that job really good for you? Yes, I think so. My friend works there Yes, I think so. My friend works there', '那份工作真的适合你吗？是的，我想是的。我的朋友在那里工作，是的，我想是的。我的朋友在那里工作', '/ɪz ðæt dʒɑb ˈrɪli ɡʊd fɔr juː? jɛs, aɪ θɪŋk soʊ. maɪ frɛnd wɜːrks ðɛr jɛs, aɪ θɪŋk soʊ. maɪ frɛnd wɜːrks ðɛr/', '<span>is</span><span>that</span><span tid="50315" class="highlight highlight-a">job</span><span>really</span><span>good</span><span>for</span><span>you</span><span>?</span><span>Yes</span><span>,</span><span>I</span><span>think</span><span>so</span><span>.</span><span>My</span><span>friend</span><span>works</span><span>there</span><span>Yes</span><span>,</span><span>I</span><span>think</span><span>so</span><span>.</span><span>My</span><span>friend</span><span>works</span><span>there</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 213, 428.52, 431.75, 'Yes, I think so. My friend works there and he told me the company is very good.', '是的，我想是的。我的朋友在那里工作，他告诉我这家公司非常好。', '/jɛs, aɪ θɪŋk soʊ. maɪ frɛnd wɜːrks ðɛr ænd hiː toʊld mi ðə ˈkʌmpəni ɪz ˈvɛri ɡʊd./', '<span>Yes</span><span>,</span><span>I</span><span>think</span><span>so</span><span>.</span><span>My</span><span>friend</span><span>works</span><span>there</span><span>and</span><span>he</span><span>told</span><span>me</span><span>the</span><span tid="50316" class="highlight highlight-a">company</span><span>is</span><span>very</span><span>good</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 214, 431.75, 431.76, 'and he told me the company is very good.', '他告诉我这家公司非常好。', '/ænd hiː toʊld mi ðə ˈkʌmpəni ɪz ˈvɛri ɡʊd./', '<span>and</span><span>he</span><span>told</span><span>me</span><span>the</span><span tid="50317" class="highlight highlight-a">company</span><span>is</span><span>very</span><span>good</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 215, 431.76, 437.23, 'and he told me the company is very good. Did Mark try his best?', '他告诉我这家公司非常好。马克尽力了吗？', '/ænd hiː toʊld mi ðə ˈkʌmpəni ɪz ˈvɛri ɡʊd. dɪd mɑːrk traɪ hɪz bɛst?/', '<span>and</span><span>he</span><span>told</span><span>me</span><span>the</span><span tid="50318" class="highlight highlight-a">company</span><span>is</span><span>very</span><span>good</span><span>.</span><span>Did</span><span>Mark</span><span>try</span><span>his</span><span tid="50319" class="highlight highlight-i">best</span><span>?</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 216, 439.79, 439.8, 'Yes, he did.', '是的，他做了。', '/jɛs hi dɪd/', '<span>Yes</span><span>,</span><span>he</span><span>did</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 217, 439.8, 443.59, 'Yes, he did. He tried his best.', '是的，他做了。他尽力了。', '/jɛs hi dɪd hi traɪd hɪz bɛst/', '<span>Yes,</span><span>he</span><span>did.</span><span>He</span><span>tried</span><span>his</span><span>best.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 218, 452.55, 452.56, 'Mark''s friend.', '马克的朋友。', '/mɑːrks frɛnd/', '<span>Mark</span><span>''s</span><span>friend</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 219, 452.56, 457.83, 'Mark''s friend. Mark''s friend told him the company was Mark''s friend told him the company was Mark''s friend told him the company was good.', '马克的朋友。马克的朋友告诉他公司很好。', '/mɑːrks frɛnd mɑːrks frɛnd toʊld hɪm ðə ˈkʌmpəni wʌz mɑːrks frɛnd toʊld hɪm ðə ˈkʌmpəni wʌz mɑːrks frɛnd toʊld hɪm ðə ˈkʌmpəni wʌz ɡʊd/', '<span>Mark</span><span>''s</span><span>friend</span><span>.</span><span>Mark</span><span>''s</span><span>friend</span><span tid="50320" class="highlight highlight-a">told</span><span>him</span><span>the</span><span>company</span><span>was</span><span>Mark</span><span>''s</span><span>friend</span><span tid="50321" class="highlight highlight-a">told</span><span>him</span><span>the</span><span>company</span><span>was</span><span>Mark</span><span>''s</span><span>friend</span><span tid="50322" class="highlight highlight-a">told</span><span>him</span><span>the</span><span>company</span><span>was</span><span>good</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 220, 467.31, 467.32, 'Yes, he did.', '是的，他做了。', '/jɛs hi dɪd/', '<span>Yes</span><span>,</span><span>he</span><span>did</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 221, 467.32, 471.55, 'Yes, he did. He thought the job was good for him.', '是的，他做了。他认为这份工作对他有好处。', '/jɛs hi dɪd hi θɔːt ðə dʒɑːb wʌz ɡʊd fɔːr hɪm/', '<span>Yes</span><span>,</span><span>he</span><span>did</span><span>.</span><span>He</span><span tid="50323" class="highlight highlight-a">thought</span><span>the</span><span>job</span><span>was</span><span>good</span><span>for</span><span>him</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 222, 471.55, 471.56, 'He thought the job was good for him.', '他认为这份工作对他有好处。', '/hi θɔːt ðə dʒɑːb wʌz ɡʊd fɔːr hɪm/', '<span>He</span><span tid="50324" class="highlight highlight-a">thought</span><span>the</span><span>job</span><span>was</span><span>good</span><span>for</span><span>him</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 223, 471.56, 473.4, 'He thought the job was good for him. Is the salary really as high as you Is the salary really as high as you', '他认为这份工作对他有好处。薪水真的像你说的那么高吗？', '/hi θɔːt ðə dʒɑːb wʌz ɡʊd fɔːr hɪm ɪz ðə ˈsæləri ˈriːli æz haɪ æz juː ɪz ðə ˈsæləri ˈriːli æz haɪ æz juː/', '<span>He</span><span tid="50325" class="highlight highlight-a">thought</span><span>the</span><span>job</span><span>was</span><span>good</span><span>for</span><span>him</span><span>.</span><span>Is</span><span>the</span><span tid="50326" class="highlight highlight-a">salary</span><span>really</span><span>as</span><span>high</span><span>as</span><span>you</span><span>Is</span><span>the</span><span tid="50327" class="highlight highlight-a">salary</span><span>really</span><span>as</span><span>high</span><span>as</span><span>you</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 224, 473.4, 475.03, 'Is the salary really as high as you wanted?', '薪水真的有你想要的那么高吗？', '/ɪz ðə ˈsæləri ˈrɪli æz haɪ æz ju ˈwɑntɪd/', '<span>Is</span><span>the</span><span tid="50328" class="highlight highlight-a">salary</span><span>really</span><span>as</span><span tid="50329" class="highlight highlight-a">high</span><span>as</span><span>you</span><span>wanted</span><span>?</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 225, 475.03, 475.04, 'wanted?', '想要的？', '/ˈwɑntɪd/', '<span>wanted</span><span>?</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 226, 475.04, 478.67, 'wanted? Not really. It''s lower than I wanted.', '想要的？不完全是。它比我想要的低。', '/ˈwɑntɪd? nɑt ˈrɪli. ɪts ˈloʊər ðæn aɪ ˈwɑntɪd/', '<span>wanted</span><span>?</span><span>Not</span><span>really</span><span>.</span><span>It</span><span>''s</span><span tid="50330" class="highlight highlight-a">lower</span><span>than</span><span>I</span><span>wanted</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 227, 478.67, 478.68, 'Not really. It''s lower than I wanted.', '不完全是。它比我想要的低。', '/nɑt ˈrɪli. ɪts ˈloʊər ðæn aɪ ˈwɑntɪd/', '<span>Not</span><span>really</span><span>.</span><span>It</span><span>''s</span><span tid="50331" class="highlight highlight-a">lower</span><span>than</span><span>I</span><span>wanted</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 228, 478.68, 479.63, 'Not really. It''s lower than I wanted. Oh.', '不完全是。它比我想要的低。哦。', '/nɑt ˈrɪli. ɪts ˈloʊər ðæn aɪ ˈwɑntɪd. oʊ/', '<span>Not</span><span>really</span><span>.</span><span>It</span><span>''s</span><span tid="50332" class="highlight highlight-a">lower</span><span>than</span><span>I</span><span>wanted</span><span>.</span><span>Oh</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 229, 479.63, 479.64, 'Oh.', '哦。', '/oʊ/', '<span>Oh</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 230, 479.64, 482.91, 'Oh. Is the office far from your house?', '哦。办公室离你家远吗？', '/oʊ. ɪz ðə ˈɔfɪs fɑr frəm jɔr haʊs/', '<span>Oh</span><span>.</span><span>Is</span><span>the</span><span tid="50333" class="highlight highlight-a">office</span><span>far</span><span>from</span><span>your</span><span>house</span><span>?</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 231, 482.91, 482.92, 'Is the office far from your house?', '办公室离你家远吗？', '/ɪz ðə ˈɔfɪs fɑr frəm jɔr haʊs/', '<span>Is</span><span>the</span><span tid="50334" class="highlight highlight-a">office</span><span>far</span><span>from</span><span>your</span><span>house</span><span>?</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 232, 482.92, 485.24, 'Is the office far from your house? Yeah, it takes me almost an hour to get Yeah, it takes me almost an hour to get', '办公室离你家远吗？', '/ɪz ðə ˈɔːfɪs fɑːr frəm jɔːr haʊs/', '<span>Is</span><span>the</span><span>office</span><span>far</span><span>from</span><span>your</span><span>house?</span><span>Yeah,</span><span>it</span><span>takes</span><span>me</span><span>almost</span><span>an</span><span>hour</span><span>to</span><span>get</span><span>Yeah,</span><span>it</span><span>takes</span><span>me</span><span>almost</span><span>an</span><span>hour</span><span>to</span><span>get</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 233, 485.24, 486.43, 'Yeah, it takes me almost an hour to get there.', '是的，我几乎要花一个小时才能到那里。', '/jeə, ɪt teɪks mi ˈɔːlmoʊst ən ˈaʊər tə ɡet ðer/', '<span>Yeah,</span><span>it</span><span tid="50335" class="highlight highlight-a">takes</span><span>me</span><span>almost</span><span>an</span><span>hour</span><span>to</span><span>get</span><span>there.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 234, 486.43, 486.44, 'there.', '那里。', '/ðer/', '<span>there.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 235, 486.44, 492.71, 'there. Is the office near Mark''s home?', '那里。办公室离马克家近吗？', '/ðer. ɪz ðə ˈɔːfɪs nɪr mɑːrks hoʊm/', '<span>there.</span><span>Is</span><span>the</span><span tid="50336" class="highlight highlight-a">office</span><span>near</span><span>Mark''s</span><span>home?</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 236, 495.83, 495.84, 'No, it isn''t.', '不，不是。', '/noʊ, ɪt ˈɪzənt/', '<span>No</span><span>,</span><span>it</span><span>isn''t</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 237, 495.84, 500.23, 'No, it isn''t. The office is not near Mark''s home.', '不，不是。办公室离马克家不远。', '/noʊ, ɪt ˈɪzənt. ðə ˈɔːfɪs ɪz nɑːt nɪr mɑːrks hoʊm/', '<span>No</span><span>,</span><span>it</span><span>isn''t</span><span>.</span><span>The</span><span tid="50337" class="highlight highlight-a">office</span><span>is</span><span>not</span><span>near</span><span>Mark''s</span><span>home</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 238, 500.23, 500.24, 'The office is not near Mark''s home.', '办公室离马克家不远。', '/ðə ˈɔːfɪs ɪz nɑːt nɪr mɑːrks hoʊm/', '<span>The</span><span tid="50338" class="highlight highlight-a">office</span><span>is</span><span>not</span><span>near</span><span>Mark''s</span><span>home</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 239, 500.24, 503.55, 'The office is not near Mark''s home. Mark, Mark, Mark, look on the bright side.', '办公室离马克家不远。马克，马克，马克，往好处想。', '/ðə ˈɔːfɪs ɪz nɑːt nɪr mɑːrks hoʊm. mɑːrk, mɑːrk, mɑːrk, lʊk ɑːn ðə braɪt saɪd/', '<span>The</span><span>office</span><span>is</span><span>not</span><span>near</span><span>Mark''s</span><span>home.</span><span>Mark,</span><span>Mark,</span><span>Mark,</span><span>look</span><span>on</span><span>the</span><span>bright</span><span>side.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 240, 503.55, 503.56, 'look on the bright side.', '往好的方面看。', '/lʊk ɑːn ðə braɪt saɪd/', '<span pid="533" class="highlight highlight-d">look on</span><span>the</span><span tid="50339" class="highlight highlight-a">bright</span><span>side.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 241, 503.56, 507.95, 'look on the bright side. Maybe you only miss something that Maybe you only miss something that Maybe you only miss something that wasn''t right for you.', '往好的方面看。也许你只是错过了一些不适合你的东西。', '/lʊk ɑːn ðə braɪt saɪd. ˈmeɪbi ju ˈoʊnli mɪs ˈsʌmθɪŋ ðæt ˈwɑːzənt raɪt fɔːr ju/', '<span pid="534" class="highlight highlight-d">look on</span><span>the</span><span tid="50340" class="highlight highlight-a">bright</span><span>side.</span><span>Maybe</span><span>you</span><span>only</span><span tid="50341" class="highlight highlight-a">miss</span><span>something</span><span>that</span><span>Maybe</span><span>you</span><span>only</span><span tid="50342" class="highlight highlight-a">miss</span><span>something</span><span>that</span><span>Maybe</span><span>you</span><span>only</span><span tid="50343" class="highlight highlight-a">miss</span><span>something</span><span>that</span><span>wasn''t</span><span tid="50344" class="highlight highlight-a">right</span><span>for</span><span>you.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 242, 507.95, 507.96, 'wasn''t right for you.', '不适合你。', '/ˈwɑːzənt raɪt fɔːr ju/', '<span>wasn''t</span><span tid="50345" class="highlight highlight-a">right</span><span>for</span><span>you.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 243, 507.96, 510.59, 'wasn''t right for you. I never thought about it that way.', '不适合你。我从未那样想过。', '/ˈwɑːzənt raɪt fɔːr ju. aɪ ˈnɛvər θɔːt əˈbaʊt ɪt ðæt weɪ/', '<span>wasn''t</span><span tid="50346" class="highlight highlight-a">right</span><span>for</span><span>you.</span><span>I</span><span>never</span><span tid="50347" class="highlight highlight-a">thought</span><span>about</span><span>it</span><span>that</span><span>way.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 244, 510.59, 510.6, 'I never thought about it that way.', '我从未那样想过。', '/aɪ ˈnɛvər θɔːt əˈbaʊt ɪt ðæt weɪ/', '<span>I</span><span>never</span><span tid="50348" class="highlight highlight-a">thought</span><span>about</span><span>it</span><span>that</span><span>way.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 245, 510.6, 513.08, 'I never thought about it that way. Now you can find a better company with Now you can find a better company with', '我从未那样想过。现在你可以找到一家更好的公司，', '/aɪ ˈnɛvər θɔːt əˈbaʊt ɪt ðæt weɪ. naʊ ju kæn faɪnd ə ˈbɛtər ˈkʌmpəni wɪð/', '<span>I</span><span>never</span><span tid="50349" class="highlight highlight-a">thought</span><span>about</span><span>it</span><span>that</span><span>way.</span><span>Now</span><span>you</span><span>can</span><span tid="50350" class="highlight highlight-a">find</span><span>a</span><span tid="50351" class="highlight highlight-a">better</span><span>company</span><span>with</span><span>Now</span><span>you</span><span>can</span><span tid="50352" class="highlight highlight-a">find</span><span>a</span><span tid="50353" class="highlight highlight-a">better</span><span>company</span><span>with</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 246, 513.08, 516.83, 'Now you can find a better company with better pay and closer to home.', '现在你可以找到一家更好的公司，薪资更高，离家更近。', '/naʊ ju kæn faɪnd ə ˈbɛtər ˈkʌmpəni wɪð ˈbɛtər peɪ ænd ˈkloʊsər tuː hoʊm/', '<span>Now</span><span>you</span><span>can</span><span tid="50354" class="highlight highlight-a">find</span><span>a</span><span tid="50355" class="highlight highlight-a">better</span><span>company</span><span>with</span><span tid="50356" class="highlight highlight-a">better</span><span>pay</span><span>and</span><span tid="50357" class="highlight highlight-a">closer</span><span>to</span><span>home.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 247, 516.83, 516.84, 'better pay and closer to home.', '薪资更高，离家更近。', '/ˈbɛtər peɪ ænd ˈkloʊsər tuː hoʊm/', '<span tid="50358" class="highlight highlight-a">better</span><span>pay</span><span>and</span><span tid="50359" class="highlight highlight-a">closer</span><span>to</span><span>home.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 248, 516.84, 519.31, 'better pay and closer to home. That makes me feel better.', '更好的薪水，而且离家更近。这让我感觉好多了。', '/ˈbɛtər peɪ ænd ˈkloʊsər tə hoʊm. ðæt meɪks miː fiːl ˈbɛtər./', '<span tid="50360" class="highlight highlight-a">better</span><span tid="50361" class="highlight highlight-a">pay</span><span>and</span><span tid="50362" class="highlight highlight-a">closer</span><span>to</span><span>home.</span><span>That</span><span>makes</span><span>me</span><span>feel</span><span>better.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 249, 519.31, 519.32, 'That makes me feel better.', '这让我感觉好多了。', '/ðæt meɪks miː fiːl ˈbɛtər./', '<span>That</span><span>makes</span><span>me</span><span>feel</span><span>better.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 250, 519.32, 525.71, 'That makes me feel better. Did Mark look on the bright side before?', '这让我感觉好多了。马克以前看到过积极的一面吗？', '/ðæt meɪks miː fiːl ˈbɛtər. dɪd mɑːrk lʊk ɑːn ðə braɪt saɪd bɪˈfɔːr?/', '<span>That</span><span>makes</span><span>me</span><span>feel</span><span>better.</span><span>Did</span><span>Mark</span><span pid="535" class="highlight highlight-i">look on the bright side</span><span>before?</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 251, 528.35, 528.36, 'No, he didn''t.', '不，他没有。', '/noʊ, hiː ˈdɪdənt./', '<span>No,</span><span>he</span><span>didn''t.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 252, 528.36, 533.11, 'No, he didn''t. Mark didn''t look on the bright side Mark didn''t look on the bright side Mark didn''t look on the bright side before.', '不，他没有。马克以前没有看到积极的一面。', '/noʊ, hiː ˈdɪdənt. mɑːrk ˈdɪdənt lʊk ɑːn ðə braɪt saɪd bɪˈfɔːr./', '<span>No,</span><span>he</span><span>didn''t.</span><span>Mark</span><span>didn''t</span><span pid="536" class="highlight highlight-i">look on the bright side</span><span>Mark</span><span>didn''t</span><span pid="537" class="highlight highlight-i">look on the bright side</span><span>Mark</span><span>didn''t</span><span pid="538" class="highlight highlight-i">look on the bright side</span><span>before.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 253, 541.99, 542.0, 'Yes, he can.', '是的，他可以。', '/jɛs, hiː kæn./', '<span>Yes,</span><span>he</span><span>can.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 254, 542.0, 545.55, 'Yes, he can. He can find a better job now.', '是的，他可以。他现在可以找到一份更好的工作。', '/jɛs, hiː kæn. hiː kæn faɪnd ə ˈbɛtər dʒɑːb naʊ./', '<span>Yes,</span><span>he</span><span>can.</span><span>He</span><span>can</span><span tid="50363" class="highlight highlight-a">find</span><span>a</span><span tid="50364" class="highlight highlight-a">better</span><span>job</span><span>now.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 255, 545.55, 545.56, 'He can find a better job now.', '他现在可以找到一份更好的工作。', '/hiː kæn faɪnd ə ˈbɛtər dʒɑːb naʊ./', '<span>He</span><span>can</span><span tid="50365" class="highlight highlight-a">find</span><span>a</span><span tid="50366" class="highlight highlight-a">better</span><span>job</span><span>now.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 256, 545.56, 547.56, 'He can find a better job now. Thanks, Betty. Let''s go eat something Thanks, Betty. Let''s go eat something', '他现在能找到更好的工作了。谢谢，贝蒂。我们去吃点东西吧。谢谢，贝蒂。我们去吃点东西吧。', '/hiː kæn faɪnd ə ˈbɛtər dʒɑb naʊ. θæŋks, ˈbɛti. lets goʊ iːt ˈsʌmθɪŋ θæŋks, ˈbɛti. lets goʊ iːt ˈsʌmθɪŋ/', '<span>He</span><span>can</span><span tid="50367" class="highlight highlight-a">find</span><span>a</span><span tid="50368" class="highlight highlight-a">better</span><span>job</span><span>now</span><span>.</span><span>Thanks</span><span>,</span><span>Betty</span><span>.</span><span>Let''s</span><span>go</span><span>eat</span><span>something</span><span>Thanks</span><span>,</span><span>Betty</span><span>.</span><span>Let''s</span><span>go</span><span>eat</span><span>something</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 257, 547.56, 549.35, 'Thanks, Betty. Let''s go eat something together.', '谢谢，贝蒂。我们一起去吃点东西吧。', '/θæŋks, ˈbɛti. lets goʊ iːt ˈsʌmθɪŋ təˈgɛðər/', '<span>Thanks</span><span>,</span><span>Betty</span><span>.</span><span>Let''s</span><span>go</span><span>eat</span><span>something</span><span>together</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 258, 549.35, 549.36, 'together.', '一起。', '/təˈgɛðər/', '<span>together</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 259, 549.36, 553.11, 'together. Sounds great. I''m hungry, too.', '一起。听起来不错。我也饿了。', '/təˈgɛðər. saʊnds greɪt. aɪm ˈhʌŋgri, tuː/', '<span>together</span><span>.</span><span>Sounds</span><span>great</span><span>.</span><span>I''m</span><span tid="50369" class="highlight highlight-a">hungry</span><span>,</span><span>too</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 260, 553.11, 553.12, 'Sounds great. I''m hungry, too.', '听起来不错。我也饿了。', '/saʊnds greɪt. aɪm ˈhʌŋgri, tuː/', '<span>Sounds</span><span>great</span><span>.</span><span>I''m</span><span tid="50370" class="highlight highlight-a">hungry</span><span>,</span><span>too</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 261, 553.12, 555.32, 'Sounds great. I''m hungry, too. My treat today. You really cheered me My treat today. You really cheered me', '听起来不错。我也饿了。今天我请客。你真的让我开心了。今天我请客。你真的让我开心了。', '/saʊnds greɪt. aɪm ˈhʌŋgri, tuː. maɪ triːt təˈdeɪ. juː ˈrɪli tʃɪrd miː maɪ triːt təˈdeɪ. juː ˈrɪli tʃɪrd miː/', '<span>Sounds</span><span>great</span><span>.</span><span>I''m</span><span tid="50371" class="highlight highlight-a">hungry</span><span>,</span><span>too</span><span>.</span><span>My</span><span tid="50372" class="highlight highlight-a">treat</span><span>today</span><span>.</span><span>You</span><span>really</span><span>cheered</span><span>me</span><span>My</span><span tid="50373" class="highlight highlight-a">treat</span><span>today</span><span>.</span><span>You</span><span>really</span><span>cheered</span><span>me</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 262, 555.32, 556.87, 'My treat today. You really cheered me up.', '今天我请客。你真的让我开心了。', '/maɪ triːt təˈdeɪ. juː ˈrɪli tʃɪrd miː ʌp/', '<span>My</span><span>treat</span><span>today.</span><span>You</span><span>really</span><span>cheered</span><span>me</span><span>up.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 263, 556.87, 556.88, 'up.', '开心了。', '/ʌp/', '<span tid="50374" class="highlight highlight-d">up</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 264, 556.88, 562.59, 'up. Is Betty hungry now?', '贝蒂现在饿了吗？', '/ʌp ɪz ˈbɛti ˈhʌŋgri naʊ/', '<span>up.</span><span>Is</span><span>Betty</span><span tid="50375" class="highlight highlight-a">hungry</span><span>now</span><span>?</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 265, 564.71, 564.72, 'Yes, she is.', '是的，她饿了。', '/jɛs ʃi ɪz/', '<span>Yes</span><span>,</span><span>she</span><span>is.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 266, 564.72, 568.03, 'Yes, she is. She is hungry now.', '是的，她饿了。她现在饿了。', '/jɛs ʃi ɪz ʃi ɪz ˈhʌŋgri naʊ/', '<span>Yes</span><span>,</span><span>she</span><span>is.</span><span>She</span><span>is</span><span tid="50376" class="highlight highlight-a">hungry</span><span>now</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 267, 576.829, 576.839, 'Yes, he will.', '是的，他会。', '/jɛs hi wɪl/', '<span>Yes</span><span>,</span><span>he</span><span>will.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 268, 576.839, 581.47, 'Yes, he will. He will pay for the food today.', '是的，他会。他今天会付饭钱。', '/jɛs hi wɪl hi wɪl peɪ fɔr ðə fud təˈdeɪ/', '<span>Yes</span><span>,</span><span>he</span><span>will.</span><span>He</span><span>will</span><span pid="539" class="highlight highlight-d">pay for</span><span>the</span><span>food</span><span>today</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 269, 584.63, 588.63, 'Well done. You did a great job. Now, Well done. You did a great job. Now, let''s move on to our shadowing practice.', '做得好。你做得很好。现在，让我们进入影子练习。', '/wɛl dʌn ju dɪd ə greɪt dʒɑb naʊ wɛl dʌn ju dɪd ə greɪt dʒɑb naʊ lɛts muv ɑn tu ˈaʊər ˈʃædoʊɪŋ ˈpræktɪs/', '<span>Well</span><span>done.</span><span>You</span><span>did</span><span>a</span><span tid="50377" class="highlight highlight-a">great</span><span>job.</span><span>Now</span><span>,</span><span>Well</span><span>done.</span><span>You</span><span>did</span><span>a</span><span tid="50378" class="highlight highlight-a">great</span><span>job.</span><span>Now</span><span>,</span><span>let''s</span><span pid="540" class="highlight highlight-d">move on to</span><span>our</span><span tid="50379" class="highlight highlight-a">shadowing</span><span>practice.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 270, 588.63, 588.64, 'let''s move on to our shadowing practice.', '让我们进入影子练习。', '/lɛts muv ɑn tu ˈaʊər ˈʃædoʊɪŋ ˈpræktɪs/', '<span>let''s</span><span pid="541" class="highlight highlight-d">move on to</span><span>our</span><span tid="50380" class="highlight highlight-a">shadowing</span><span>practice.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 271, 588.64, 592.51, 'let''s move on to our shadowing practice. Part four, shadowing practice.', '让我们进入影子练习。第四部分，影子练习。', '/lɛts muv ɑn tu ˈaʊər ˈʃædoʊɪŋ ˈpræktɪs pɑrt fɔr ˈʃædoʊɪŋ ˈpræktɪs/', '<span>let''s</span><span pid="542" class="highlight highlight-d">move on to</span><span>our</span><span tid="50381" class="highlight highlight-a">shadowing</span><span>practice.</span><span>Part</span><span>four</span><span>,</span><span tid="50382" class="highlight highlight-a">shadowing</span><span>practice.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 272, 592.51, 592.52, 'Part four, shadowing practice.', '第四部分，影子练习。', '/pɑːrt fɔːr ˈʃædoʊɪŋ ˈpræktɪs/', '<span>Part</span><span>four</span><span>,</span><span tid="50383" class="highlight highlight-a">shadowing</span><span tid="50384" class="highlight highlight-a">practice</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 273, 592.52, 594.84, 'Part four, shadowing practice. In this part, repeat each line after In this part, repeat each line after', '第四部分，影子练习。在这一部分，重复每一行之后在这一部分，重复每一行之后', '/pɑːrt fɔːr ˈʃædoʊɪŋ ˈpræktɪs ɪn ðɪs pɑːrt rɪˈpiːt iːtʃ laɪn ˈæftər ɪn ðɪs pɑːrt rɪˈpiːt iːtʃ laɪn ˈæftər/', '<span>Part</span><span>four</span><span>,</span><span tid="50385" class="highlight highlight-a">shadowing</span><span tid="50386" class="highlight highlight-a">practice</span><span>.</span><span>In</span><span>this</span><span>part</span><span>,</span><span tid="50387" class="highlight highlight-a">repeat</span><span>each</span><span>line</span><span>after</span><span>In</span><span>this</span><span>part</span><span>,</span><span tid="50388" class="highlight highlight-a">repeat</span><span>each</span><span>line</span><span>after</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 274, 594.84, 597.12, 'In this part, repeat each line after speakers. Try to follow their rhythm and speakers. Try to follow their rhythm and', '在这一部分，重复每一行之后说话者。试着跟随他们的节奏和说话者。试着跟随他们的节奏和', '/ɪn ðɪs pɑːrt rɪˈpiːt iːtʃ laɪn ˈæftər ˈspiːkərz traɪ tuː ˈfɑːloʊ ðɛr ˈrɪðəm ænd ˈspiːkərz traɪ tuː ˈfɑːloʊ ðɛr ˈrɪðəm ænd/', '<span>In</span><span>this</span><span>part</span><span>,</span><span tid="50389" class="highlight highlight-a">repeat</span><span>each</span><span>line</span><span>after</span><span tid="50390" class="highlight highlight-a">speakers</span><span>.</span><span>Try</span><span>to</span><span tid="50391" class="highlight highlight-d">follow</span><span>their</span><span tid="50392" class="highlight highlight-a">rhythm</span><span>and</span><span tid="50393" class="highlight highlight-a">speakers</span><span>.</span><span>Try</span><span>to</span><span tid="50394" class="highlight highlight-d">follow</span><span>their</span><span tid="50395" class="highlight highlight-a">rhythm</span><span>and</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 275, 597.12, 599.11, 'speakers. Try to follow their rhythm and pronunciation.', '说话者。试着跟随他们的节奏和发音。', '/ˈspiːkərz traɪ tuː ˈfɑːloʊ ðɛr ˈrɪðəm ænd prəˌnʌnsiˈeɪʃən/', '<span tid="50396" class="highlight highlight-a">speakers</span><span>.</span><span>Try</span><span>to</span><span tid="50397" class="highlight highlight-d">follow</span><span>their</span><span tid="50398" class="highlight highlight-a">rhythm</span><span>and</span><span tid="50399" class="highlight highlight-a">pronunciation</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 276, 599.11, 599.12, 'pronunciation.', '发音。', '/prəˌnʌnsiˈeɪʃən/', '<span tid="50400" class="highlight highlight-a">pronunciation</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 277, 599.12, 607.55, 'pronunciation. This will help you speak more naturally This will help you speak more naturally This will help you speak more naturally and with more confidence.', '发音。这将帮助你更自然地说话这将帮助你更自然地说话这将帮助你更自然地说话并且更有信心。', '/prəˌnʌnsiˈeɪʃən ðɪs wɪl hɛlp juː spiːk mɔːr ˈnætʃərəli ðɪs wɪl hɛlp juː spiːk mɔːr ˈnætʃərəli ðɪs wɪl hɛlp juː spiːk mɔːr ˈnætʃərəli ænd wɪð mɔːr ˈkɑːnfɪdəns/', '<span tid="50401" class="highlight highlight-a">pronunciation</span><span>.</span><span>This</span><span>will</span><span>help</span><span>you</span><span>speak</span><span>more</span><span tid="50402" class="highlight highlight-a">naturally</span><span>This</span><span>will</span><span>help</span><span>you</span><span>speak</span><span>more</span><span tid="50403" class="highlight highlight-a">naturally</span><span>This</span><span>will</span><span>help</span><span>you</span><span>speak</span><span>more</span><span tid="50404" class="highlight highlight-a">naturally</span><span>and</span><span>with</span><span>more</span><span tid="50405" class="highlight highlight-a">confidence</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 278, 608.55, 611.07, 'Betty, Betty, I feel awful today.', '贝蒂，贝蒂，我今天感觉很糟糕。', '/ˈbɛti ˈbɛti aɪ fiːl ˈɔːfəl təˈdeɪ/', '<span>Betty</span><span>,</span><span>Betty</span><span>,</span><span>I</span><span>feel</span><span tid="50406" class="highlight highlight-a">awful</span><span>today</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 279, 611.07, 611.08, 'I feel awful today.', '我今天感觉很糟糕。', '/aɪ fiːl ˈɔːfəl təˈdeɪ/', '<span>I</span><span>feel</span><span tid="50407" class="highlight highlight-a">awful</span><span>today</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 280, 611.08, 615.75, 'I feel awful today. What happened, Mark?', '我今天感觉很糟糕。马克，发生什么事了？', '/aɪ fiːl ˈɔːfəl təˈdeɪ. wʌt ˈhæpənd, mɑːrk/', '<span>I</span><span>feel</span><span tid="50408" class="highlight highlight-a">awful</span><span>today</span><span>.</span><span>What</span><span tid="50409" class="highlight highlight-a">happened</span><span>,</span><span>Mark</span><span>?</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 281, 617.79, 619.71, 'Do you remember the job I told you about Do you remember the job I told you about before?', '你还记得我之前告诉你的那份工作吗？', '/duː juː rɪˈmɛmbər ðə dʒɑːb aɪ toʊld juː əˈbaʊt bɪˈfɔːr/', '<span>Do</span><span>you</span><span>remember</span><span>the</span><span>job</span><span>I</span><span>told</span><span>you</span><span>about</span><span>Do</span><span>you</span><span>remember</span><span>the</span><span>job</span><span>I</span><span>told</span><span>you</span><span>about</span><span>before</span><span>?</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 282, 619.71, 619.72, 'before?', '之前？', '/bɪˈfɔːr/', '<span>before</span><span>?</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 283, 619.72, 623.39, 'before? I got a rejection email from the I got a rejection email from the I got a rejection email from the company.', '之前？我收到了那家公司的拒信。', '/bɪˈfɔːr? aɪ gɑːt ə rɪˈdʒɛkʃən iːˈmeɪl frəm ðə ˈkʌmpəni/', '<span>before</span><span>?</span><span>I</span><span>got</span><span>a</span><span tid="50410" class="highlight highlight-a">rejection</span><span>email</span><span>from</span><span>the</span><span>I</span><span>got</span><span>a</span><span tid="50411" class="highlight highlight-a">rejection</span><span>email</span><span>from</span><span>the</span><span>I</span><span>got</span><span>a</span><span tid="50412" class="highlight highlight-a">rejection</span><span>email</span><span>from</span><span>the</span><span>company</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 284, 623.39, 623.4, 'company.', '公司。', '/ˈkʌmpəni/', '<span>company</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 285, 623.4, 630.39, 'company. Oh no, I''m sorry to hear that.', '公司。哦不，听到这个我很难过。', '/ˈkʌmpəni. oʊ noʊ, aɪm ˈsɔri tuː hɪr ðæt/', '<span>company</span><span>.</span><span>Oh</span><span>no</span><span>,</span><span>I</span><span>''m</span><span>sorry</span><span>to</span><span>hear</span><span>that</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 286, 633.83, 633.84, 'I prepared so hard for the interview.', '我为面试准备得非常努力。', '/aɪ prɪˈpɛrd soʊ hɑːrd fɔːr ði ˈɪntərvjuː/', '<span>I</span><span tid="50413" class="highlight highlight-a">prepared</span><span>so</span><span>hard</span><span>for</span><span>the</span><span>interview</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 287, 633.84, 636.32, 'I prepared so hard for the interview. I studied all week and practiced answers I studied all week and practiced answers', '我为面试准备得非常努力。我学习了一整周并练习了答案。', '/aɪ prɪˈpɛrd soʊ hɑːrd fɔːr ði ˈɪntərvjuː. aɪ ˈstʌdid ɔːl wiːk ænd ˈpræktɪst ˈænsərz/', '<span>I</span><span tid="50414" class="highlight highlight-a">prepared</span><span>so</span><span>hard</span><span>for</span><span>the</span><span>interview</span><span>.</span><span>I</span><span>studied</span><span>all</span><span>week</span><span>and</span><span tid="50415" class="highlight highlight-a">practiced</span><span>answers</span><span>I</span><span>studied</span><span>all</span><span>week</span><span>and</span><span tid="50416" class="highlight highlight-a">practiced</span><span>answers</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 288, 636.32, 638.19, 'I studied all week and practiced answers every night.', '我整个星期都在学习，每晚练习回答。', '/aɪ ˈstʌdi ɔːl wiːk ænd ˈpræktɪst ˈænsərz ˈɛvri naɪt/', '<span>I</span><span tid="50417" class="highlight highlight-a">studied</span><span>all</span><span>week</span><span>and</span><span tid="50418" class="highlight highlight-a">practiced</span><span>answers</span><span>every</span><span>night.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 289, 638.19, 638.2, 'every night.', '每晚。', '/ˈɛvri naɪt/', '<span>every</span><span>night.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 290, 638.2, 645.75, 'every night. Wow, you really tried your best.', '每晚。哇，你真的尽力了。', '/ˈɛvri naɪt waʊ ju ˈrɪli traɪd jɔr bɛst/', '<span>every</span><span>night.</span><span>Wow,</span><span>you</span><span>really</span><span tid="50419" class="highlight highlight-a">tried</span><span>your</span><span tid="50420" class="highlight highlight-i">best.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 291, 648.15, 650.07, 'Yes, I did everything I could to get Yes, I did everything I could to get that job.', '是的，我尽了一切努力去得到那份工作。', '/jɛs aɪ dɪd ˈɛvriθɪŋ aɪ kʊd tu gɛt ðæt dʒɑb/', '<span>Yes,</span><span>I</span><span>did</span><span>everything</span><span>I</span><span>could</span><span>to</span><span tid="50421" class="highlight highlight-a">get</span><span>Yes,</span><span>I</span><span>did</span><span>everything</span><span>I</span><span>could</span><span>to</span><span tid="50422" class="highlight highlight-a">get</span><span>that</span><span>job.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 292, 650.07, 650.08, 'that job.', '那份工作。', '/ðæt dʒɑb/', '<span>that</span><span>job.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 293, 650.08, 654.47, 'that job. Oh, I understand why you feel so sad.', '那份工作。哦，我理解你为什么这么难过。', '/ðæt dʒɑb oʊ aɪ ˌʌndərˈstænd waɪ ju fil soʊ sæd/', '<span>that</span><span>job.</span><span>Oh,</span><span>I</span><span tid="50423" class="highlight highlight-a">understand</span><span>why</span><span>you</span><span>feel</span><span>so</span><span>sad.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 294, 654.47, 654.48, 'Oh, I understand why you feel so sad.', '哦，我理解你为什么这么难过。', '/oʊ aɪ ˌʌndərˈstænd waɪ ju fil soʊ sæd/', '<span>Oh,</span><span>I</span><span tid="50424" class="highlight highlight-a">understand</span><span>why</span><span>you</span><span>feel</span><span>so</span><span>sad.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 295, 654.48, 667.31, 'Oh, I understand why you feel so sad. But tell me, But tell me, But tell me, is that job really good for you?', '哦，我理解你为什么这么难过。但告诉我，那份工作真的适合你吗？', '/oʊ aɪ ˌʌndərˈstænd waɪ ju fil soʊ sæd bʌt tɛl mi ɪz ðæt dʒɑb ˈrɪli gʊd fɔr ju/', '<span>Oh,</span><span>I</span><span tid="50425" class="highlight highlight-a">understand</span><span>why</span><span>you</span><span>feel</span><span>so</span><span>sad.</span><span>But</span><span>tell</span><span>me,</span><span>But</span><span>tell</span><span>me,</span><span>But</span><span>tell</span><span>me,</span><span>is</span><span>that</span><span>job</span><span>really</span><span>good</span><span>for</span><span>you?</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 296, 670.03, 673.55, 'Yes, I think so. My friend works there Yes, I think so. My friend works there and he told me the company is very good.', '是的，我想是的。我朋友在那里工作，他告诉我这家公司很好。', '/jɛs aɪ θɪŋk soʊ maɪ frɛnd wɜːrks ðɛr ænd hi toʊld mi ðə ˈkʌmpəni ɪz ˈvɛri gʊd/', '<span>Yes,</span><span>I</span><span>think</span><span>so.</span><span>My</span><span>friend</span><span>works</span><span>there</span><span>Yes,</span><span>I</span><span>think</span><span>so.</span><span>My</span><span>friend</span><span>works</span><span>there</span><span>and</span><span>he</span><span>told</span><span>me</span><span>the</span><span>company</span><span>is</span><span>very</span><span>good.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 297, 673.55, 673.56, 'and he told me the company is very good.', '他告诉我这家公司很好。', '/ænd hi toʊld mi ðə ˈkʌmpəni ɪz ˈvɛri gʊd/', '<span>and</span><span>he</span><span>told</span><span>me</span><span>the</span><span tid="50426" class="highlight highlight-a">company</span><span>is</span><span>very</span><span>good</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 298, 673.56, 675.4, 'and he told me the company is very good. Is the salary really as high as you Is the salary really as high as you', '他告诉我这家公司很好。薪水真的像你一样高吗？', '/ænd hi toʊld mi ðə ˈkʌmpəni ɪz ˈvɛri gʊd ɪz ðə ˈsæləri ˈrɪli æz haɪ æz ju/', '<span>and</span><span>he</span><span>told</span><span>me</span><span>the</span><span>company</span><span>is</span><span>very</span><span>good.</span><span>Is</span><span>the</span><span>salary</span><span>really</span><span>as</span><span>high</span><span>as</span><span>you</span><span>Is</span><span>the</span><span>salary</span><span>really</span><span>as</span><span>high</span><span>as</span><span>you</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 299, 675.4, 681.35, 'Is the salary really as high as you wanted?', '薪水真的有你想要的那样高吗？', '/ɪz ðə ˈsæləri ˈrɪli æz haɪ æz ju ˈwɔntɪd/', '<span>Is</span><span>the</span><span tid="50427" class="highlight highlight-a">salary</span><span>really</span><span>as</span><span>high</span><span>as</span><span>you</span><span>wanted</span><span>?</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 300, 684.95, 684.96, 'Not really. It''s lower than I wanted.', '不完全是。比我想要的低。', '/nɑt ˈrɪli ɪts ˈloʊər ðæn aɪ ˈwɔntɪd/', '<span>Not</span><span>really</span><span>.</span><span>It</span><span>''s</span><span tid="50428" class="highlight highlight-a">lower</span><span>than</span><span>I</span><span>wanted</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 301, 684.96, 693.51, 'Not really. It''s lower than I wanted. Oh, is the office far from your house?', '不完全是。比我想要的低。哦，办公室离你家远吗？', '/nɑt ˈrɪli ɪts ˈloʊər ðæn aɪ ˈwɔntɪd oʊ ɪz ði ˈɔfɪs fɑr frəm jɔr haʊs/', '<span>Not</span><span>really</span><span>.</span><span>It</span><span>''s</span><span tid="50429" class="highlight highlight-a">lower</span><span>than</span><span>I</span><span>wanted</span><span>.</span><span>Oh</span><span>,</span><span>is</span><span>the</span><span tid="50430" class="highlight highlight-a">office</span><span>far</span><span>from</span><span>your</span><span>house</span><span>?</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 302, 695.83, 697.55, 'Yeah, it takes me almost an hour to get Yeah, it takes me almost an hour to get there.', '是的，我几乎要花一个小时才能到那里。', '/jɛs ɪt teɪks mi ˈɔlmoʊst ən ˈaʊər tu gɛt ðɛr/', '<span>Yeah,</span><span>it</span><span>takes</span><span>me</span><span>almost</span><span>an</span><span>hour</span><span>to</span><span>get</span><span>Yeah,</span><span>it</span><span>takes</span><span>me</span><span>almost</span><span>an</span><span>hour</span><span>to</span><span>get</span><span>there.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 303, 697.55, 697.56, 'there.', '那里。', '/ðɛr/', '<span>there</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 304, 697.56, 700.87, 'there. Mark, Mark, Mark, look on the bright side.', '那里。马克，马克，马克，往好的方面看。', '/ðɛr mɑːrk mɑːrk mɑːrk lʊk ɑːn ðə braɪt saɪd/', '<span>there.</span><span>Mark</span><span>,</span><span>Mark</span><span>,</span><span>Mark</span><span>,</span><span pid="543" class="highlight highlight-i">look on the bright side.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 305, 700.87, 700.88, 'look on the bright side.', '往好的方面看。', '/lʊk ɑːn ðə braɪt saɪd/', '<span pid="544" class="highlight highlight-i">look on the bright side.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 306, 700.88, 711.67, 'look on the bright side. Maybe you only missed something that Maybe you only missed something that Maybe you only missed something that wasn''t right for you.', '往好的方面看。也许你只是错过了一些不适合你的东西。', '/lʊk ɑːn ðə braɪt saɪd ˈmeɪbi ju ˈoʊnli mɪst ˈsʌmθɪŋ ðæt ˈwɑːznt raɪt fər ju/', '<span pid="545" class="highlight highlight-i">look on the bright side.</span><span>Maybe</span><span>you</span><span>only</span><span tid="50431" class="highlight highlight-a">missed</span><span>something</span><span>that</span><span>Maybe</span><span>you</span><span>only</span><span tid="50432" class="highlight highlight-a">missed</span><span>something</span><span>that</span><span>Maybe</span><span>you</span><span>only</span><span tid="50433" class="highlight highlight-a">missed</span><span>something</span><span>that</span><span>wasn''t</span><span tid="50434" class="highlight highlight-a">right</span><span>for</span><span>you.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 307, 714.35, 714.36, 'I never thought about it that way.', '我从未那样想过。', '/aɪ ˈnɛvər θɔːt əˈbaʊt ɪt ðæt weɪ/', '<span>I</span><span>never</span><span tid="50435" class="highlight highlight-a">thought</span><span>about</span><span>it</span><span>that</span><span tid="50436" class="highlight highlight-c">way.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 308, 714.36, 716.88, 'I never thought about it that way. Now you can find a better company with Now you can find a better company with', '我从未那样想过。现在你可以找到一家更好的公司，', '/aɪ ˈnɛvər θɔːt əˈbaʊt ɪt ðæt weɪ naʊ ju kæn faɪnd ə ˈbɛtər ˈkʌmpəni wɪð/', '<span>I</span><span>never</span><span tid="50437" class="highlight highlight-a">thought</span><span>about</span><span>it</span><span>that</span><span tid="50438" class="highlight highlight-c">way.</span><span>Now</span><span>you</span><span>can</span><span tid="50439" class="highlight highlight-a">find</span><span>a</span><span>better</span><span tid="50440" class="highlight highlight-a">company</span><span>with</span><span>Now</span><span>you</span><span>can</span><span tid="50441" class="highlight highlight-a">find</span><span>a</span><span>better</span><span tid="50442" class="highlight highlight-a">company</span><span>with</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 309, 716.88, 726.99, 'Now you can find a better company with better pay and closer to home.', '现在你可以找到一家更好的公司，薪水更高，离家更近。', '/naʊ ju kæn faɪnd ə ˈbɛtər ˈkʌmpəni wɪð ˈbɛtər peɪ ænd ˈkloʊsər tə hoʊm/', '<span>Now</span><span>you</span><span>can</span><span tid="50443" class="highlight highlight-a">find</span><span>a</span><span>better</span><span tid="50444" class="highlight highlight-a">company</span><span>with</span><span>better</span><span tid="50445" class="highlight highlight-a">pay</span><span>and</span><span tid="50446" class="highlight highlight-a">closer</span><span>to</span><span>home.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 310, 729.71, 729.72, 'That makes me feel better.', '这让我感觉好多了。', '/ðæt meɪks mi ˈfil ˈbɛtər/', '<span>That</span><span tid="50447" class="highlight highlight-d">makes</span><span>me</span><span>feel</span><span>better.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 311, 729.72, 730.79, 'That makes me feel better. Good.', '这让我感觉好多了。很好。', '/ðæt meɪks mi ˈfil ˈbɛtər ɡʊd/', '<span>That</span><span tid="50448" class="highlight highlight-d">makes</span><span>me</span><span>feel</span><span>better.</span><span>Good.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 312, 730.79, 730.8, 'Good.', '很好。', '/ɡʊd/', '<span>Good.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 313, 730.8, 736.91, 'Good. I like seeing you smile.', '很好。我喜欢看到你微笑。', '/ɡʊd. aɪ laɪk ˈsiːɪŋ juː smaɪl/', '<span>Good.</span><span>I</span><span tid="50449" class="highlight highlight-a">like</span><span>seeing</span><span>you</span><span>smile.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 314, 738.87, 740.67, 'Thanks, Betty. Let''s go eat something Thanks, Betty. Let''s go eat something together.', '谢谢，贝蒂。我们一起去吃点东西吧。', '/θæŋks, ˈbɛti. lets ɡoʊ iːt ˈsʌmθɪŋ təˈɡɛðər/', '<span>Thanks,</span><span>Betty.</span><span>Let''s</span><span>go</span><span>eat</span><span>something</span><span>Thanks,</span><span>Betty.</span><span>Let''s</span><span>go</span><span>eat</span><span>something</span><span>together.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 315, 740.67, 740.68, 'together.', '一起。', '/təˈɡɛðər/', '<span>together.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 316, 740.68, 747.55, 'together. Sounds great. I''m hungry, too.', '一起。听起来不错。我也饿了。', '/təˈɡɛðər. saʊndz ɡreɪt. aɪm ˈhʌŋɡri, tuː/', '<span>together.</span><span>Sounds</span><span>great.</span><span>I''m</span><span tid="50450" class="highlight highlight-a">hungry,</span><span>too.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 317, 749.83, 751.43, 'My treat today. You really cheered me My treat today. You really cheered me up.', '今天我请客。你真的让我开心起来了。', '/maɪ triːt təˈdeɪ. juː ˈrɪəli tʃɪrd miː ʌp/', '<span>My</span><span tid="50451" class="highlight highlight-a">treat</span><span>today.</span><span>You</span><span>really</span><span>cheered</span><span>me</span><span>My</span><span tid="50452" class="highlight highlight-a">treat</span><span>today.</span><span>You</span><span>really</span><span>cheered</span><span>me</span><span tid="50453" class="highlight highlight-d">up.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 318, 751.43, 751.44, 'up.', '起来。', '/ʌp/', '<span tid="50454" class="highlight highlight-d">up.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 319, 751.44, 760.35, 'up. Awesome.', '起来。太棒了。', '/ʌp. ˈɔːsəm/', '<span tid="50455" class="highlight highlight-d">up.</span><span tid="50456" class="highlight highlight-a">Awesome.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 320, 768.43, 773.23, 'Betty, Betty, I feel awful today.', '贝蒂，贝蒂，我今天感觉很糟糕。', '/ˈbɛti ˈbɛti aɪ fil ˈɔːfəl təˈdeɪ/', '<span>Betty</span><span>,</span><span>Betty</span><span>,</span><span>I</span><span tid="50457" class="highlight highlight-a">feel</span><span tid="50458" class="highlight highlight-a">awful</span><span>today</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 321, 775.59, 775.6, 'What happened, Mark?', '怎么了，马克？', '/wʌt ˈhæpənd mɑːrk/', '<span>What</span><span tid="50459" class="highlight highlight-a">happened</span><span>,</span><span>Mark</span><span>?</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 322, 775.6, 777.72, 'What happened, Mark? Do you remember the job I told you about Do you remember the job I told you about', '怎么了，马克？你还记得我告诉你的那份工作吗？', '/wʌt ˈhæpənd mɑːrk duː juː rɪˈmɛmbər ðə dʒɑːb aɪ toʊld juː əˈbaʊt/', '<span>What</span><span tid="50460" class="highlight highlight-a">happened</span><span>,</span><span>Mark</span><span>?</span><span>Do</span><span>you</span><span tid="50461" class="highlight highlight-a">remember</span><span>the</span><span>job</span><span>I</span><span tid="50462" class="highlight highlight-a">told</span><span>you</span><span>about</span><span>Do</span><span>you</span><span tid="50463" class="highlight highlight-a">remember</span><span>the</span><span>job</span><span>I</span><span tid="50464" class="highlight highlight-a">told</span><span>you</span><span>about</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 323, 777.72, 779.55, 'Do you remember the job I told you about before?', '你还记得我之前告诉你的那份工作吗？', '/duː juː rɪˈmɛmbər ðə dʒɑːb aɪ toʊld juː əˈbaʊt bɪˈfɔːr/', '<span>Do</span><span>you</span><span tid="50465" class="highlight highlight-a">remember</span><span>the</span><span>job</span><span>I</span><span tid="50466" class="highlight highlight-a">told</span><span>you</span><span>about</span><span>before</span><span>?</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 324, 779.55, 779.56, 'before?', '之前？', '/bɪˈfɔːr/', '<span>before</span><span>?</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 325, 779.56, 792.99, 'before? I got a rejection email from the I got a rejection email from the I got a rejection email from the company.', '之前？我收到了那家公司的拒绝邮件。', '/bɪˈfɔːr aɪ ɡɑːt ə rɪˈdʒɛkʃən iːmeɪl frəm ðə ˈkʌmpəni/', '<span>before</span><span>?</span><span>I</span><span tid="50467" class="highlight highlight-a">got</span><span>a</span><span tid="50468" class="highlight highlight-a">rejection</span><span>email</span><span>from</span><span>the</span><span>I</span><span tid="50469" class="highlight highlight-a">got</span><span>a</span><span tid="50470" class="highlight highlight-a">rejection</span><span>email</span><span>from</span><span>the</span><span>I</span><span tid="50471" class="highlight highlight-a">got</span><span>a</span><span tid="50472" class="highlight highlight-a">rejection</span><span>email</span><span>from</span><span>the</span><span>company</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 326, 796.63, 796.64, 'Oh, no. I''m sorry to hear that.', '哦，不。听到这个我很难过。', '/oʊ noʊ aɪm ˈsɔri tuː hɪr ðæt/', '<span>Oh</span><span>,</span><span>no</span><span>.</span><span>I''m</span><span tid="50473" class="highlight highlight-a">sorry</span><span>to</span><span tid="50474" class="highlight highlight-a">hear</span><span>that</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 327, 796.64, 800.07, 'Oh, no. I''m sorry to hear that. I prepared so hard for the interview.', '哦，不。听到这个我很难过。我为面试准备得非常努力。', '/oʊ noʊ aɪm ˈsɔri tuː hɪr ðæt aɪ prɪˈpɛrd soʊ hɑːrd fɔːr ði ˈɪntərvjuː/', '<span>Oh</span><span>,</span><span>no</span><span>.</span><span>I''m</span><span tid="50475" class="highlight highlight-a">sorry</span><span>to</span><span tid="50476" class="highlight highlight-a">hear</span><span>that</span><span>.</span><span>I</span><span tid="50477" class="highlight highlight-a">prepared</span><span>so</span><span>hard</span><span>for</span><span>the</span><span tid="50478" class="highlight highlight-a">interview</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 328, 800.07, 800.08, 'I prepared so hard for the interview.', '我为面试做了非常充分的准备。', '/aɪ prɪˈpɛrd soʊ hɑːrd fɔːr ði ˈɪntərvjuː/', '<span>I</span><span tid="50479" class="highlight highlight-a">prepared</span><span>so</span><span>hard</span><span>for</span><span>the</span><span tid="50480" class="highlight highlight-a">interview.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 329, 800.08, 802.56, 'I prepared so hard for the interview. I studied all week and practiced answers I studied all week and practiced answers', '我为面试做了非常充分的准备。我整个星期都在学习并练习答案。', '/aɪ prɪˈpɛrd soʊ hɑːrd fɔːr ði ˈɪntərvjuː aɪ ˈstʌdid ɔːl wiːk ænd ˈpræktɪst ˈænsərz aɪ ˈstʌdid ɔːl wiːk ænd ˈpræktɪst ˈænsərz/', '<span>I</span><span tid="50481" class="highlight highlight-a">prepared</span><span>so</span><span>hard</span><span>for</span><span>the</span><span tid="50482" class="highlight highlight-a">interview.</span><span>I</span><span tid="50483" class="highlight highlight-a">studied</span><span>all</span><span>week</span><span>and</span><span tid="50484" class="highlight highlight-a">practiced</span><span>answers</span><span>I</span><span tid="50485" class="highlight highlight-a">studied</span><span>all</span><span>week</span><span>and</span><span tid="50486" class="highlight highlight-a">practiced</span><span>answers</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 330, 802.56, 811.11, 'I studied all week and practiced answers every night.', '我整个星期都在学习，每晚练习答案。', '/aɪ ˈstʌdid ɔːl wiːk ænd ˈpræktɪst ˈænsərz ˈɛvri naɪt/', '<span>I</span><span tid="50487" class="highlight highlight-a">studied</span><span>all</span><span>week</span><span>and</span><span tid="50488" class="highlight highlight-a">practiced</span><span>answers</span><span>every</span><span>night.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 331, 815.27, 815.28, '&gt;&gt; Wow, you really tried your best.', '哇，你真的尽力了。', '/wɑː juː ˈrɪli traɪd jɔːr bɛst/', '<span>&gt;&gt;</span><span>Wow,</span><span>you</span><span>really</span><span tid="50489" class="highlight highlight-a">tried</span><span>your</span><span tid="50490" class="highlight highlight-i">best.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 332, 815.28, 817.72, '&gt;&gt; Wow, you really tried your best. Yes, I did everything I could to get Yes, I did everything I could to get', '哇，你真的尽力了。是的，我尽了一切努力去得到。', '/wɑː juː ˈrɪli traɪd jɔːr bɛst jɛs aɪ dɪd ˈɛvriθɪŋ aɪ kʊd tuː gɛt jɛs aɪ dɪd ˈɛvriθɪŋ aɪ kʊd tuː gɛt/', '<span>&gt;&gt;</span><span>Wow,</span><span>you</span><span>really</span><span tid="50491" class="highlight highlight-a">tried</span><span>your</span><span tid="50492" class="highlight highlight-i">best.</span><span>Yes,</span><span>I</span><span>did</span><span tid="50493" class="highlight highlight-a">everything</span><span>I</span><span>could</span><span>to</span><span>get</span><span>Yes,</span><span>I</span><span>did</span><span tid="50494" class="highlight highlight-a">everything</span><span>I</span><span>could</span><span>to</span><span>get</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 333, 817.72, 823.31, 'Yes, I did everything I could to get that job.', '是的，我尽了一切努力去得到那份工作。', '/jɛs aɪ dɪd ˈɛvriθɪŋ aɪ kʊd tuː gɛt ðæt dʒoʊb/', '<span>Yes,</span><span>I</span><span>did</span><span tid="50495" class="highlight highlight-a">everything</span><span>I</span><span>could</span><span>to</span><span>get</span><span>that</span><span tid="50496" class="highlight highlight-a">job.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 334, 827.71, 827.72, 'Oh, I understand why you feel so sad.', '哦，我理解你为什么这么难过。', '/oʊ aɪ ˌʌndərˈstænd waɪ juː fiːl soʊ sæd/', '<span>Oh,</span><span>I</span><span tid="50497" class="highlight highlight-a">understand</span><span>why</span><span>you</span><span>feel</span><span>so</span><span tid="50498" class="highlight highlight-a">sad.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 335, 827.72, 832.75, 'Oh, I understand why you feel so sad. But tell me, But tell me, But tell me, is that job really good for you?', '哦，我理解你为什么这么难过。但告诉我，那份工作真的适合你吗？', '/oʊ aɪ ˌʌndərˈstænd waɪ juː fiːl soʊ sæd bʌt tɛl miː bʌt tɛl miː bʌt tɛl miː ɪz ðæt dʒoʊb ˈrɪli gʊd fɔːr juː/', '<span>Oh,</span><span>I</span><span tid="50499" class="highlight highlight-a">understand</span><span>why</span><span>you</span><span>feel</span><span>so</span><span tid="50500" class="highlight highlight-a">sad.</span><span>But</span><span>tell</span><span>me,</span><span>But</span><span>tell</span><span>me,</span><span>But</span><span>tell</span><span>me,</span><span>is</span><span>that</span><span tid="50501" class="highlight highlight-a">job</span><span>really</span><span>good</span><span>for</span><span>you?</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 336, 832.75, 832.76, 'is that job really good for you?', '那份工作真的对你好吗？', '/ɪz ðæt dʒɑb ˈrɪli ɡʊd fɔr ju/', '<span>is</span><span>that</span><span tid="50502" class="highlight highlight-a">job</span><span>really</span><span>good</span><span>for</span><span>you?</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 337, 832.76, 835.52, 'is that job really good for you? Yes, I think so. My friend works there Yes, I think so. My friend works there', '那份工作真的对你好吗？是的，我觉得是。我的朋友在那里工作。是的，我觉得是。我的朋友在那里工作。', '/ɪz ðæt dʒɑb ˈrɪli ɡʊd fɔr ju jɛs aɪ θɪŋk soʊ maɪ frɛnd wɜːrks ðɛr jɛs aɪ θɪŋk soʊ maɪ frɛnd wɜːrks ðɛr/', '<span>is</span><span>that</span><span tid="50503" class="highlight highlight-a">job</span><span>really</span><span>good</span><span>for</span><span>you?</span><span>Yes,</span><span>I</span><span>think</span><span>so.</span><span>My</span><span tid="50504" class="highlight highlight-a">friend</span><span>works</span><span>there</span><span>Yes,</span><span>I</span><span>think</span><span>so.</span><span>My</span><span tid="50505" class="highlight highlight-a">friend</span><span>works</span><span>there</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 338, 835.52, 846.31, 'Yes, I think so. My friend works there and he told me the company is very good.', '是的，我觉得是。我的朋友在那里工作，他告诉我这家公司非常好。', '/jɛs aɪ θɪŋk soʊ maɪ frɛnd wɜːrks ðɛr ænd hi toʊld mi ðə ˈkʌmpəni ɪz ˈvɛri ɡʊd/', '<span>Yes,</span><span>I</span><span>think</span><span>so.</span><span>My</span><span tid="50506" class="highlight highlight-a">friend</span><span>works</span><span>there</span><span>and</span><span>he</span><span>told</span><span>me</span><span>the</span><span tid="50507" class="highlight highlight-a">company</span><span>is</span><span>very</span><span>good.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 339, 848.19, 849.87, 'Is the salary really as high as you Is the salary really as high as you wanted?', '薪水真的有你想要的那样高吗？薪水真的有你想要的那样高吗？', '/ɪz ðə ˈsæləri ˈrɪli æz haɪ æz ju wɑntɪd ɪz ðə ˈsæləri ˈrɪli æz haɪ æz ju wɑntɪd/', '<span>Is</span><span>the</span><span tid="50508" class="highlight highlight-a">salary</span><span>really</span><span>as</span><span>high</span><span>as</span><span>you</span><span>Is</span><span>the</span><span tid="50509" class="highlight highlight-a">salary</span><span>really</span><span>as</span><span>high</span><span>as</span><span>you</span><span>wanted?</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 340, 849.87, 849.88, 'wanted?', '想要？', '/wɑntɪd/', '<span>wanted?</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 341, 849.88, 856.83, 'wanted? Not really. It''s lower than I wanted.', '想要？不完全是。它比我想要的低。', '/wɑntɪd nɑt ˈrɪli ɪts ˈloʊər ðæn aɪ wɑntɪd/', '<span>wanted?</span><span>Not</span><span>really.</span><span>It''s</span><span>lower</span><span>than</span><span>I</span><span>wanted.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 342, 861.11, 861.12, 'Oh, is the office far from your house?', '哦，办公室离你家远吗？', '/oʊ ɪz ði ˈɔfɪs fɑr frʌm jɔr haʊs/', '<span>Oh,</span><span>is</span><span>the</span><span tid="50510" class="highlight highlight-a">office</span><span>far</span><span>from</span><span>your</span><span>house?</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 343, 861.12, 863.44, 'Oh, is the office far from your house? Yeah, it takes me almost an hour to get Yeah, it takes me almost an hour to get', '哦，办公室离你家远吗？是的，我几乎要花一个小时才能到。是的，我几乎要花一个小时才能到。', '/oʊ ɪz ði ˈɔfɪs fɑr frʌm jɔr haʊs jɛs ɪt teɪks mi ˈɔlmoʊst ən ˈaʊər tu ɡɛt jɛs ɪt teɪks mi ˈɔlmoʊst ən ˈaʊər tu ɡɛt/', '<span>Oh,</span><span>is</span><span>the</span><span tid="50511" class="highlight highlight-a">office</span><span>far</span><span>from</span><span>your</span><span>house?</span><span>Yeah,</span><span>it</span><span>takes</span><span>me</span><span>almost</span><span>an</span><span tid="50512" class="highlight highlight-a">hour</span><span>to</span><span>get</span><span>Yeah,</span><span>it</span><span>takes</span><span>me</span><span>almost</span><span>an</span><span tid="50513" class="highlight highlight-a">hour</span><span>to</span><span>get</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 344, 863.44, 869.43, 'Yeah, it takes me almost an hour to get there.', '是的，我几乎要花一个小时才能到那里。', '/jɛə ɪt teɪks mi ˈɔːlmoʊst ən ˈaʊər tə ɡɛt ðɛr/', '<span>Yeah</span><span>,</span><span>it</span><span tid="50514" class="highlight highlight-a">takes</span><span>me</span><span>almost</span><span>an</span><span>hour</span><span>to</span><span>get</span><span>there</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 345, 870.63, 872.75, 'Mark, Mark, look on the bright side.', '马克，马克，往好的方面看。', '/mɑːrk mɑːrk lʊk ɑːn ðə braɪt saɪd/', '<span>Mark</span><span>,</span><span>Mark</span><span>,</span><span pid="546" class="highlight highlight-i">look on the bright side</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 346, 872.75, 872.76, 'look on the bright side.', '往好的方面看。', '/lʊk ɑːn ðə braɪt saɪd/', '<span pid="547" class="highlight highlight-i">look on the bright side</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 347, 872.76, 877.15, 'look on the bright side. Maybe you only missed something that Maybe you only missed something that Maybe you only missed something that wasn''t right for you.', '往好的方面看。也许你只是错过了一些不适合你的东西。', '/lʊk ɑːn ðə braɪt saɪd ˈmeɪbi ju ˈoʊnli mɪst ˈsʌmθɪŋ ðæt ˈwɑːzənt raɪt fər ju/', '<span pid="548" class="highlight highlight-i">look on the bright side</span><span>.</span><span>Maybe</span><span>you</span><span>only</span><span tid="50515" class="highlight highlight-a">missed</span><span>something</span><span>that</span><span>Maybe</span><span>you</span><span>only</span><span tid="50516" class="highlight highlight-a">missed</span><span>something</span><span>that</span><span>Maybe</span><span>you</span><span>only</span><span tid="50517" class="highlight highlight-a">missed</span><span>something</span><span>that</span><span>wasn''t</span><span>right</span><span>for</span><span>you</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 348, 877.15, 877.16, 'wasn''t right for you.', '不适合你的。', '/ˈwɑːzənt raɪt fər ju/', '<span>wasn''t</span><span>right</span><span>for</span><span>you</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 349, 877.16, 883.23, 'wasn''t right for you. I never thought about it that way.', '不适合你的。我从来没有那样想过。', '/ˈwɑːzənt raɪt fər ju aɪ ˈnɛvər θɔːt əˈbaʊt ɪt ðæt weɪ/', '<span>wasn''t</span><span>right</span><span>for</span><span>you</span><span>.</span><span>I</span><span>never</span><span tid="50518" class="highlight highlight-a">thought</span><span>about</span><span>it</span><span>that</span><span>way</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 350, 885.71, 889.43, 'Now you can find a better company with Now you can find a better company with better pay and closer to home.', '现在你可以找到一家更好的公司，薪水更高，离家更近。', '/naʊ ju kən faɪnd ə ˈbɛtər ˈkʌmpəni wɪð ˈbɛtər peɪ ænd ˈkloʊsər tə hoʊm/', '<span>Now</span><span>you</span><span>can</span><span tid="50519" class="highlight highlight-a">find</span><span>a</span><span>better</span><span>company</span><span>with</span><span>Now</span><span>you</span><span>can</span><span tid="50520" class="highlight highlight-a">find</span><span>a</span><span>better</span><span>company</span><span>with</span><span>better</span><span>pay</span><span>and</span><span>closer</span><span>to</span><span>home</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 351, 889.43, 889.44, 'better pay and closer to home.', '薪水更高，离家更近。', '/ˈbɛtər peɪ ænd ˈkloʊsər tə hoʊm/', '<span>better</span><span>pay</span><span>and</span><span>closer</span><span>to</span><span>home</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 352, 889.44, 895.23, 'better pay and closer to home. That makes me feel better.', '更好的薪水，而且离家更近。这让我感觉好多了。', '/ˈbɛtər peɪ ænd ˈkloʊsər tə hoʊm. ðæt meɪks miː fiːl ˈbɛtər/', '<span tid="50521" class="highlight highlight-a">better</span><span tid="50522" class="highlight highlight-a">pay</span><span>and</span><span tid="50523" class="highlight highlight-a">closer</span><span>to</span><span>home.</span><span>That</span><span>makes</span><span>me</span><span>feel</span><span>better.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 353, 896.31, 896.32, 'Good.', '很好。', '/ɡʊd/', '<span>Good.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 354, 896.32, 899.15, 'Good. I like seeing you smile.', '很好。我喜欢看到你微笑。', '/ɡʊd. aɪ laɪk ˈsiːɪŋ juː ˈsmaɪl/', '<span>Good.</span><span>I</span><span>like</span><span tid="50524" class="highlight highlight-a">seeing</span><span>you</span><span>smile.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 355, 899.15, 899.16, 'I like seeing you smile.', '我喜欢看到你微笑。', '/aɪ laɪk ˈsiːɪŋ juː ˈsmaɪl/', '<span>I</span><span>like</span><span tid="50525" class="highlight highlight-a">seeing</span><span>you</span><span>smile.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 356, 899.16, 901.16, 'I like seeing you smile. Thanks, Betty. Let''s go eat something Thanks, Betty. Let''s go eat something', '我喜欢看到你微笑。谢谢，贝蒂。我们去吃点东西吧。谢谢，贝蒂。我们去吃点东西吧。', '/aɪ laɪk ˈsiːɪŋ juː ˈsmaɪl. θæŋks, ˈbɛti. lets ɡoʊ iːt ˈsʌmθɪŋ θæŋks, ˈbɛti. lets ɡoʊ iːt ˈsʌmθɪŋ/', '<span>I</span><span>like</span><span tid="50526" class="highlight highlight-a">seeing</span><span>you</span><span>smile.</span><span>Thanks,</span><span>Betty.</span><span>Let''s</span><span>go</span><span>eat</span><span>something</span><span>Thanks,</span><span>Betty.</span><span>Let''s</span><span>go</span><span>eat</span><span>something</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 357, 901.16, 907.87, 'Thanks, Betty. Let''s go eat something together.', '谢谢，贝蒂。我们一起去吃点东西吧。', '/θæŋks, ˈbɛti. lets ɡoʊ iːt ˈsʌmθɪŋ təˈɡɛðər/', '<span>Thanks,</span><span>Betty.</span><span>Let''s</span><span>go</span><span>eat</span><span>something</span><span>together.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 358, 911.59, 911.6, 'Sounds great. I''m hungry, too.', '听起来不错。我也饿了。', '/saʊndz ɡreɪt. aɪm ˈhʌŋɡri, tuː/', '<span>Sounds</span><span>great.</span><span>I''m</span><span tid="50527" class="highlight highlight-a">hungry,</span><span>too.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 359, 911.6, 913.8, 'Sounds great. I''m hungry, too. My treat today. You really cheered me My treat today. You really cheered me', '听起来不错。我也饿了。今天我请客。你真的让我开心了。今天我请客。你真的让我开心了。', '/saʊndz ɡreɪt. aɪm ˈhʌŋɡri, tuː. maɪ triːt təˈdeɪ. juː ˈrɪli tʃɪrd miː maɪ triːt təˈdeɪ. juː ˈrɪli tʃɪrd miː/', '<span>Sounds</span><span>great.</span><span>I''m</span><span tid="50528" class="highlight highlight-a">hungry,</span><span>too.</span><span>My</span><span tid="50529" class="highlight highlight-a">treat</span><span>today.</span><span>You</span><span>really</span><span tid="50530" class="highlight highlight-d">cheered</span><span>me</span><span>My</span><span tid="50531" class="highlight highlight-a">treat</span><span>today.</span><span>You</span><span>really</span><span tid="50532" class="highlight highlight-d">cheered</span><span>me</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 360, 913.8, 919.19, 'My treat today. You really cheered me up.', '今天我请客。你确实让我开心起来了。', '/maɪ triːt təˈdeɪ. juː ˈrɪli tʃɪrd miː ʌp/', '<span>My</span><span tid="50533" class="highlight highlight-a">treat</span><span>today</span><span>.</span><span>You</span><span>really</span><span tid="50534" class="highlight highlight-d">cheered</span><span>me</span><span>up</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 361, 927.99, 930.51, '&gt;&gt; Amazing work today. You finished all &gt;&gt; Amazing work today. You finished all four parts of this lesson.', '今天表现很棒。你完成了这节课的所有四个部分。', '/əˈmeɪzɪŋ wɜːrk təˈdeɪ. juː ˈfɪnɪʃt ɔːl fɔːr pɑːrts ʌv ðɪs ˈlesən/', '<span>&gt;&gt;</span><span tid="50535" class="highlight highlight-a">Amazing</span><span>work</span><span>today</span><span>.</span><span>You</span><span tid="50536" class="highlight highlight-a">finished</span><span>all</span><span>&gt;&gt;</span><span tid="50537" class="highlight highlight-a">Amazing</span><span>work</span><span>today</span><span>.</span><span>You</span><span tid="50538" class="highlight highlight-a">finished</span><span>all</span><span>four</span><span>parts</span><span>of</span><span>this</span><span>lesson</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 362, 930.51, 930.52, 'four parts of this lesson.', '这节课的四个部分。', '/fɔːr pɑːrts ʌv ðɪs ˈlesən/', '<span>four</span><span>parts</span><span>of</span><span>this</span><span>lesson</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 363, 930.52, 932.68, 'four parts of this lesson. Keep watching this video again every day Keep watching this video again every day', '这节课的四个部分。继续每天观看这个视频。', '/fɔːr pɑːrts ʌv ðɪs ˈlesən. kiːp ˈwɑːtʃɪŋ ðɪs ˈviːdiːoʊ əˈɡen ˈɛvri deɪ/', '<span>four</span><span>parts</span><span>of</span><span>this</span><span>lesson</span><span>.</span><span>Keep</span><span tid="50539" class="highlight highlight-a">watching</span><span>this</span><span>video</span><span>again</span><span>every</span><span>day</span><span>Keep</span><span tid="50540" class="highlight highlight-a">watching</span><span>this</span><span>video</span><span>again</span><span>every</span><span>day</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 364, 932.68, 934.31, 'Keep watching this video again every day this week.', '这周每天继续观看这个视频。', '/kiːp ˈwɑːtʃɪŋ ðɪs ˈviːdiːoʊ əˈɡen ˈɛvri deɪ ðɪs wiːk/', '<span>Keep</span><span tid="50541" class="highlight highlight-a">watching</span><span>this</span><span>video</span><span>again</span><span>every</span><span>day</span><span>this</span><span>week</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 365, 934.31, 934.32, 'this week.', '这周。', '/ðɪs wiːk/', '<span>this</span><span>week</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 366, 934.32, 939.75, 'this week. When you repeat often, your English When you repeat often, your English When you repeat often, your English becomes more fluent. I promise.', '当你经常重复时，你的英语会变得更流利。我保证。', '/wɛn juː rɪˈpiːt ˈɔːfən, jʊr ˈɪŋɡlɪʃ bɪˈkʌmz moʊr ˈfluːənt. aɪ ˈprɑːmɪs/', '<span>this</span><span>week</span><span>.</span><span>When</span><span>you</span><span tid="50542" class="highlight highlight-a">repeat</span><span>often</span><span>,</span><span>your</span><span>English</span><span>When</span><span>you</span><span tid="50543" class="highlight highlight-a">repeat</span><span>often</span><span>,</span><span>your</span><span>English</span><span>When</span><span>you</span><span tid="50544" class="highlight highlight-a">repeat</span><span>often</span><span>,</span><span>your</span><span>English</span><span tid="50545" class="highlight highlight-a">becomes</span><span>more</span><span tid="50546" class="highlight highlight-a">fluent</span><span>.</span><span>I</span><span>promise</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 367, 939.75, 939.76, 'becomes more fluent. I promise.', '变得更流利。我保证。', '/bɪˈkʌmz moʊr ˈfluːənt. aɪ ˈprɑːmɪs/', '<span tid="50547" class="highlight highlight-a">becomes</span><span>more</span><span tid="50548" class="highlight highlight-a">fluent</span><span>.</span><span>I</span><span>promise</span><span>.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 368, 939.76, 942.95, 'becomes more fluent. I promise. If you want more simple English If you want more simple English If you want more simple English practice, remember to like and', '变得更流利。我保证。如果你想要更简单的英语练习，记得点赞和', '/bɪˈkʌmz mɔːr ˈfluːənt. aɪ ˈprɑːmɪs. ɪf juː wɑːnt mɔːr ˈsɪmpəl ˈɪŋɡlɪʃ ˈpræktɪs, rɪˈmɛmbər tuː laɪk ænd/', '<span tid="50549" class="highlight highlight-a">becomes</span><span>more</span><span tid="50550" class="highlight highlight-a">fluent.</span><span>I</span><span tid="50551" class="highlight highlight-a">promise.</span><span>If</span><span>you</span><span>want</span><span>more</span><span tid="50552" class="highlight highlight-a">simple</span><span>English</span><span>If</span><span>you</span><span>want</span><span>more</span><span tid="50553" class="highlight highlight-a">simple</span><span>English</span><span>If</span><span>you</span><span>want</span><span>more</span><span tid="50554" class="highlight highlight-a">simple</span><span>English</span><span tid="50555" class="highlight highlight-a">practice,</span><span>remember</span><span>to</span><span>like</span><span>and</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 369, 942.95, 944.71, 'practice, remember to like and practice, remember to like and subscribe.', '练习，记得点赞和订阅。', '/ˈpræktɪs, rɪˈmɛmbər tuː laɪk ænd səbˈskraɪb./', '<span tid="50556" class="highlight highlight-a">practice,</span><span>remember</span><span>to</span><span>like</span><span>and</span><span tid="50557" class="highlight highlight-a">practice,</span><span>remember</span><span>to</span><span>like</span><span>and</span><span tid="50558" class="highlight highlight-a">subscribe.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 370, 944.71, 944.72, 'subscribe.', '订阅。', '/səbˈskraɪb./', '<span tid="50559" class="highlight highlight-a">subscribe.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 371, 944.72, 949.27, 'subscribe. Keep training your English, keep showing Keep training your English, keep showing Keep training your English, keep showing up, and I''ll be in the next lesson.', '订阅。继续训练你的英语，继续出现，下一节课见。', '/səbˈskraɪb. kiːp ˈtreɪnɪŋ jɔːr ˈɪŋɡlɪʃ, kiːp ˈʃoʊɪŋ ʌp, ænd aɪl biː ɪn ðə nɛkst ˈlɛsən./', '<span tid="50560" class="highlight highlight-a">subscribe.</span><span>Keep</span><span tid="50561" class="highlight highlight-a">training</span><span>your</span><span>English,</span><span>keep</span><span tid="50562" class="highlight highlight-d">showing</span><span>Keep</span><span tid="50563" class="highlight highlight-a">training</span><span>your</span><span>English,</span><span>keep</span><span tid="50564" class="highlight highlight-d">showing</span><span>Keep</span><span tid="50565" class="highlight highlight-a">training</span><span>your</span><span>English,</span><span>keep</span><span tid="50566" class="highlight highlight-d">showing</span><span>up,</span><span>and</span><span>I''ll</span><span>be</span><span>in</span><span>the</span><span>next</span><span tid="50567" class="highlight highlight-a">lesson.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 372, 949.27, 949.28, 'up, and I''ll be in the next lesson.', '出现，下一节课见。', '/ʌp, ænd aɪl biː ɪn ðə nɛkst ˈlɛsən./', '<span>up,</span><span>and</span><span>I''ll</span><span>be</span><span>in</span><span>the</span><span>next</span><span tid="50568" class="highlight highlight-a">lesson.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 373, 949.28, 952.84, 'up, and I''ll be in the next lesson. Goodbye. See you soon.', '出现，下一节课见。再见。回头见。', '/ʌp, ænd aɪl biː ɪn ðə nɛkst ˈlɛsən. ɡʊdˈbaɪ. siː juː suːn./', '<span>up,</span><span>and</span><span>I''ll</span><span>be</span><span>in</span><span>the</span><span>next</span><span tid="50569" class="highlight highlight-a">lesson.</span><span>Goodbye.</span><span>See</span><span>you</span><span tid="50570" class="highlight highlight-i">soon.</span>'
FROM episodes e WHERE e.video_id = '5FAegfs5fTHS8Ac';

-- episode 215: NrkfL2tex-OvHfg
UPDATE user_word_lookups SET subtitle_id = NULL WHERE subtitle_id IN (SELECT s.id FROM subtitles s JOIN episodes e ON s.episode_id = e.id WHERE e.video_id = 'NrkfL2tex-OvHfg');
UPDATE user_vocabulary_items SET source_subtitle_id = NULL WHERE source_subtitle_id IN (SELECT s.id FROM subtitles s JOIN episodes e ON s.episode_id = e.id WHERE e.video_id = 'NrkfL2tex-OvHfg');
DELETE FROM user_subtitle_progress WHERE subtitle_id IN (SELECT s.id FROM subtitles s JOIN episodes e ON s.episode_id = e.id WHERE e.video_id = 'NrkfL2tex-OvHfg');
DELETE FROM user_subtitle_progress WHERE episode_id = (SELECT id FROM episodes WHERE video_id = 'NrkfL2tex-OvHfg');
DELETE FROM subtitles WHERE episode_id = (SELECT id FROM episodes WHERE video_id = 'NrkfL2tex-OvHfg');
DELETE FROM episode_tags WHERE episode_id = (SELECT id FROM episodes WHERE video_id = 'NrkfL2tex-OvHfg');
INSERT INTO episodes (
  index, video_id, short_title, summary, remark, stars, voca_size,
  subtitle_count, clip_length, cover, video_url, audio_url, thumbnail_url,
  original_video_url, author_id, series_id, series_index,
  submitted_by_user_id, rejection_reason,
  created_at, is_demo, status, published_at
) VALUES (
  215, 'NrkfL2tex-OvHfg', '走遍美国完整版 - 第1集',
  '', '',
  2, 35, 135,
  503.68, 'http://oss.sxakgs.com/en/0UExkPj5QY/cover.webp',
  'http://oss.sxakgs.com/en/0UExkPj5QY/video.mp4', 'http://oss.sxakgs.com/en/0UExkPj5QY/audio.mp3',
  'http://oss.sxakgs.com/en/0UExkPj5QY/cover.webp', 'https://www.youtube.com/watch?v=-0UExkPj5QY',
  (SELECT id FROM authors WHERE name = 'da.vinci sarga' AND accent = '美国' LIMIT 1),
  (SELECT id FROM episode_series WHERE slug = '走遍美国视频版-1-78全集' LIMIT 1), 1,
  NULL, NULL,
  '2026-07-13 15:46:58'::timestamp,
  FALSE, 'published',
  '2026-07-13 15:46:58'::timestamp
)
ON CONFLICT (video_id) DO UPDATE SET
  index = EXCLUDED.index,
  short_title = EXCLUDED.short_title,
  summary = EXCLUDED.summary,
  remark = EXCLUDED.remark,
  stars = EXCLUDED.stars,
  voca_size = EXCLUDED.voca_size,
  subtitle_count = EXCLUDED.subtitle_count,
  clip_length = EXCLUDED.clip_length,
  cover = EXCLUDED.cover,
  video_url = EXCLUDED.video_url,
  audio_url = EXCLUDED.audio_url,
  thumbnail_url = EXCLUDED.thumbnail_url,
  original_video_url = EXCLUDED.original_video_url,
  author_id = EXCLUDED.author_id,
  series_id = EXCLUDED.series_id,
  series_index = EXCLUDED.series_index,
  submitted_by_user_id = EXCLUDED.submitted_by_user_id,
  rejection_reason = EXCLUDED.rejection_reason,
  is_demo = EXCLUDED.is_demo,
  status = EXCLUDED.status,
  published_at = EXCLUDED.published_at;

INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 0, 77.72, 81.72, 'richard stewart is a photographer.', '理查德·斯图尔特是一名摄影师。', '/ˈrɪtʃərd ˈstuːərt ɪz ə fəˈtɑːɡrəfər/', '<span>richard</span> <span>stewart</span> <span>is</span> <span>a</span> <span>photographer.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 1, 81.72, 87.16, 'in act one, he takes pictures of new york city on the staten island ferry.', '在第一幕中，他在斯塔滕岛渡轮上拍摄了纽约市的风景。', '/ɪn ækt wʌn, hi teɪks ˈpɪktʃərz əv nu ˈjɔːrk ˈsɪti ɑn ðə ˈsteɪtən ˈaɪlənd ˈfɛri/', '<span>in</span> <span>act</span> <span>one,</span> <span>he</span> <span>takes</span> <span>pictures</span> <span>of</span> <span>new</span> <span>york</span> <span>city</span> <span>on</span> <span>the</span> <span>staten</span> <span>island</span> <span>ferry.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 2, 87.16, 90.8, 'richard meets alexandra pappas.', '理查德与亚历山德拉·帕帕斯会面了。', '/ˈrɪtʃərd miːts ˌælɪɡˈzændrə ˈpæpəs/', '<span>richard</span> <span>meets</span> <span>alexandra</span> <span>pappas.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 3, 90.8, 92.28, 'are you from new york?', '你来自纽约吗？', '/ɑr ju frəm nu ˈjɔːrk/', '<span>are</span> <span>you</span> <span>from</span> <span>new</span> <span>york?</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 4, 92.28, 93.96, 'no, i''m from greece.', '不，我来自希腊。', '/noʊ, aɪm frəm ɡriːs/', '<span>no,</span> <span>i''m</span> <span>from</span> <span>greece.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 5, 93.96, 96.24, 'i''m an exchange student.', '我是一名交换生。', '/aɪm ən ɪksˈtʃeɪndʒ ˈstuːdənt/', '<span>i''m</span> <span>an</span> <span>exchange</span> <span>student.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 6, 96.24, 102.72, 'he shows alexandra some pictures for family album usa.', '他给亚历山德拉看了一些用于制作美国家庭相册的照片。', '/hi ʃoʊz ˌælɪɡˈzændrə səm ˈpɪktʃərz fər ˈfæməli ˈælbəm juːˈeɪ/', '<span>he</span> <span>shows</span> <span>alexandra</span> <span>some</span> <span>pictures</span> <span>for</span> <span>family</span> <span>album</span> <span>usa.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 7, 102.72, 106.28, 'family album usa.', '美国家庭相册。', '/ˈfæməli ˈælbəm juːˈeɪ/', '<span>family</span> <span>album</span> <span>usa.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 8, 106.28, 108.32, 'it''s an album of pictures of the united states.', '这是一本记录美国各地风景的照片集。', '/ɪts ən ˈælbəm əv ˈpɪktʃərz əv ðə juˈnaɪtɪd steɪts/', '<span>it''s</span> <span>an</span> <span>album</span> <span>of</span> <span>pictures</span> <span>of</span> <span>the</span> <span>united</span> <span>states.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 9, 108.32, 110.92, 'later, richard leaves quickly.', '后来，理查德很快就离开了。', '/ˈleɪtər ˈrɪtʃərd livz ˈkwɪkli/', '<span>later,</span> <span>richard</span> <span>leaves</span> <span>quickly.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 10, 110.92, 111.72, 'bye-bye, alexandra.', '再见了，亚历山德拉。', '/ˈbaɪbaɪ ˌælɪɡˈzændrə/', '<span>bye-bye,</span> <span>alexandra.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 11, 111.72, 112.28, 'thanks.', '谢谢。', '/θæŋks/', '<span>thanks.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 12, 112.28, 113.72, 'bye-bye.', '再见了。', '/ˈbaɪbaɪ/', '<span>bye-bye.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 13, 113.72, 115.76, 'and he forgets something.', '而他忘了某件事。', '/ənd hi fərˈɡɛts ˈsʌmθɪŋ/', '<span>and</span> <span>he</span> <span>forgets</span> <span>something.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 14, 115.76, 119.24, 'what does richard forget?', '理查德忘记了什么？', '/wʌt dʌz ˈrɪtʃərd fərˈɡɛt/', '<span>what</span> <span>does</span> <span>richard</span> <span>forget?</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 15, 156.76, 158.72, 'excuse me.', '打扰一下。', '/ɪkˈskjuz mi/', '<span>excuse</span> <span>me.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 16, 158.72, 159.88, 'my name is richard stewart.', '我叫理查德·斯图尔特。', '/maɪ neɪm ɪz ˈrɪtʃərd ˈstuːərt/', '<span>my</span> <span>name</span> <span>is</span> <span>richard</span> <span>stewart.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 17, 159.88, 161.24, 'i''m a photographer.', '我是一名摄影师。', '/aɪm ə fəˈtɑːɡrəfər/', '<span>i''m</span> <span>a</span> <span>photographer.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 18, 161.24, 163.04, 'may i take a picture of you and your little boy?', '我可以给您和您的小儿子拍张照片吗？', '/meɪ aɪ teɪk ə ˈpɪktʃər əv juː ænd jɔːr ˈlɪtəl bɔɪ/', '<span>may</span> <span>i</span> <span>take</span> <span>a</span> <span>picture</span> <span>of</span> <span>you</span> <span>and</span> <span>your</span> <span>little</span> <span>boy?</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 19, 163.04, 163.92, 'what''s it for?', '这是用来做什么的？', '/wʌts ɪt fɔːr/', '<span>what''s</span> <span>it</span> <span>for?</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 20, 163.92, 164.92, 'it''s for a book.', '这是为一本书准备的。', '/ɪts fɔːr ə bʊk/', '<span>it''s</span> <span>for</span> <span>a</span> <span>book.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 21, 164.92, 166.72, 'you''re writing a book?', '你在写书吗？', '/jʊr ˈraɪtɪŋ ə bʊk/', '<span>you''re</span> <span>writing</span> <span>a</span> <span>book?</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 22, 166.72, 168.04, 'it''s a book of pictures.', '这是一本图画书。', '/ɪts ə bʊk əv ˈpɪktʃərz/', '<span>it''s</span> <span>a</span> <span>book</span> <span>of</span> <span>pictures.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 23, 168.04, 169.88, 'i call it family album usa.', '我把它叫做“美国家庭相册”。', '/aɪ kɔːl ɪt ˈfæməli ˈælbəm juː ˈeɪ/', '<span>i</span> <span>call</span> <span>it</span> <span>family</span> <span>album</span> <span>usa.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 24, 169.88, 171.96, 'oh, that''s a nice idea.', '哦，那真是个好主意。', '/oʊ, ðæts ə naɪs aɪˈdiːə/', '<span>oh,</span> <span>that''s</span> <span>a</span> <span>nice</span> <span>idea.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 25, 171.96, 173.8, 'well, it''s fine if you take our picture.', '嗯，如果你想拍我们的照片的话，那也没关系。', '/wɛl, ɪts faɪn ɪf juː teɪk aʊər ˈpɪktʃər/', '<span>well,</span> <span>it''s</span> <span>fine</span> <span>if</span> <span>you</span> <span>take</span> <span>our</span> <span>picture.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 26, 173.8, 175.36, 'i''m martha van.', '我是玛莎·范。', '/aɪm ˈmɑːrθə væn/', '<span>i''m</span> <span>martha</span> <span>van.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 27, 175.36, 175.8, 'thank you.', '谢谢。', '/θæŋk juː/', '<span>thank</span> <span>you.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 28, 175.8, 178.44, 'i appreciate your help.', '感谢你的帮助。', '/aɪ əˈpriːʃieɪt jʊr hɛlp/', '<span>i</span> <span>appreciate</span> <span>your</span> <span>help.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 29, 178.44, 179.56, 'i''m richard.', '我是理查德。', '/aɪm ˈrɪtʃərd/', '<span>i''m</span> <span>richard.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 30, 179.56, 180.48, 'what''s your name?', '你叫什么名字？', '/wʌts jʊr neɪm/', '<span>what''s</span> <span>your</span> <span>name?</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 31, 180.48, 181.44, 'gerald.', '杰拉尔德。', '/ˈdʒɛrəld/', '<span>gerald.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 32, 181.44, 182.64, 'how old are you, gerald?', '杰拉尔德，你多大了？', '/haʊ oʊld ɑːr juː, ˈdʒɛrəld?/', '<span>how</span> <span>old</span> <span>are</span> <span>you,</span> <span>gerald?</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 33, 182.64, 183.6, 'five.', '五。', '/faɪv./', '<span>five.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 34, 183.6, 184.68, 'and where do you live?', '你住在哪里呢？', '/ænd wɛr duː juː lɪv?/', '<span>and</span> <span>where</span> <span>do</span> <span>you</span> <span>live?</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 35, 184.68, 186.16, 'we live in california.', '我们住在加利福尼亚州。', '/wiː lɪv ɪn ˌkælɪˈfɔːrnjə./', '<span>we</span> <span>live</span> <span>in</span> <span>california.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 36, 186.16, 189.84, 'well, welcome to new york.', '嗯，欢迎来到纽约。', '/wɛl, ˈwɛlkəm tuː nuː jɔːrk./', '<span>well,</span> <span>welcome</span> <span>to</span> <span>new</span> <span>york.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 37, 189.84, 193.32, 'okay, just a second.', '好吧，稍等一下。', '/oʊˈkeɪ, dʒʌst ə ˈsɛkənd./', '<span>okay,</span> <span>just</span> <span>a</span> <span>second.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 38, 193.32, 194.96, 'i''m almost ready here.', '我这边差不多准备好了。', '/aɪm ˈɔːlmoʊst ˈrɛdi hɪr./', '<span>i''m</span> <span>almost</span> <span>ready</span> <span>here.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 39, 194.96, 196.44, 'can i help you?', '需要我帮忙吗？', '/kæn aɪ hɛlp juː?/', '<span>can</span> <span>i</span> <span>help</span> <span>you?</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 40, 196.44, 199.52, 'oh, please.', '哦，求你了。', '/oʊ pliːz/', '<span>oh,</span> <span>please.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 41, 204.28, 207.8, 'now, hold gerald''s hand, please.', '现在，请握住杰拉尔德的手吧。', '/naʊ hoʊld ˈdʒɛrəldz hænd pliːz/', '<span>now,</span> <span>hold</span> <span>gerald''s</span> <span>hand,</span> <span>please.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 42, 209.04, 210.88, 'great.', '太好了。', '/ɡreɪt/', '<span>great.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 43, 210.88, 214.16, 'now, point to the buildings.', '现在，请把手指指向那些建筑物。', '/naʊ pɔɪnt tə ðə ˈbɪldɪŋz/', '<span>now,</span> <span>point</span> <span>to</span> <span>the</span> <span>buildings.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 44, 215.4, 218.36, 'terrific.', '太棒了。', '/təˈrɪfɪk/', '<span>terrific.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 45, 219.0, 223.0, 'now, give mommy a kiss, gerald.', '现在，给妈妈一个吻吧，杰拉尔德。', '/naʊ ɡɪv ˈmɑːmi ə kɪs ˈdʒɛrəld/', '<span>now,</span> <span>give</span> <span>mommy</span> <span>a</span> <span>kiss,</span> <span>gerald.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 46, 223.52, 226.28, 'nice.', '不错。', '/naɪs/', '<span>nice.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 47, 226.32, 228.56, 'thanks, gerald.', '谢谢，杰拉尔德。', '/θæŋks ˈdʒɛrəld/', '<span>thanks,</span> <span>gerald.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 48, 228.56, 229.48, 'and thank you, mrs.', '谢谢您，夫人。', '/ænd θæŋk juː ˈmɪsɪz/', '<span>and</span> <span>thank</span> <span>you,</span> <span>mrs.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 49, 229.48, 229.8, 'van.', '货车。', '/væn/', '<span>van.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 50, 229.8, 231.12, 'oh, my pleasure.', '哦，不客气。/很高兴能帮忙。', '/oʊ maɪ ˈplɛʒər/', '<span>oh,</span> <span>my</span> <span>pleasure.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 51, 231.12, 232.8, 'we''ll be looking for your book.', '我们会去找你的书。', '/wiːl biː ˈlʊkɪŋ fɔːr jʊr bʊk/', '<span>we''ll</span> <span>be</span> <span>looking</span> <span>for</span> <span>your</span> <span>book.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 52, 232.8, 233.04, 'thank you.', '谢谢。', '/θæŋk juː/', '<span>thank</span> <span>you.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 53, 233.04, 234.2, 'goodbye.', '再见。', '/ɡʊdˈbaɪ/', '<span>goodbye.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 54, 234.2, 236.84, 'bye, gerald.', '再见，杰拉尔德。', '/baɪ ˈdʒɛrəld/', '<span>bye,</span> <span>gerald.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 55, 238.8, 240.72, 'thanks again.', '再次感谢。', '/θæŋks əˈɡɛn/', '<span>thanks</span> <span>again.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 56, 240.72, 242.64, 'uh, you''re welcome.', '呃，不用客气。', '/ə juːr ˈwɛlkəm/', '<span>uh,</span> <span>you''re</span> <span>welcome.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 57, 242.64, 244.52, 'here, let me take your picture.', '来，让我来给你拍照吧。', '/hɪr lɛt mi teɪk jʊr ˈpɪktʃər/', '<span>here,</span> <span>let</span> <span>me</span> <span>take</span> <span>your</span> <span>picture.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 58, 244.52, 245.12, 'wonderful.', '太棒了。', '/ˈwʌndərfəl/', '<span>wonderful.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 59, 245.12, 247.8, 'please.', '请吧。', '/pliz/', '<span>please.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 60, 252.68, 254.08, 'are you from new york?', '你来自纽约吗？', '/ɑr ju frəm nu ˈjɔrk/', '<span>are</span> <span>you</span> <span>from</span> <span>new</span> <span>york?</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 61, 254.08, 255.76, 'no, i''m from greece.', '不，我来自希腊。', '/noʊ aɪm frəm ɡris/', '<span>no,</span> <span>i''m</span> <span>from</span> <span>greece.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 62, 255.76, 258.16, 'i''m an exchange student.', '我是一名交换生。', '/aɪm ən ɪksˈtʃeɪndʒ ˈstudənt/', '<span>i''m</span> <span>an</span> <span>exchange</span> <span>student.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 63, 258.16, 259.839, 'when did you come here?', '你什么时候来到这里的？', '/wɛn dɪd ju kʌm hɪr/', '<span>when</span> <span>did</span> <span>you</span> <span>come</span> <span>here?</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 64, 259.839, 261.48, 'three months ago.', '三个月前。', '/θriː mʌnθs əˈɡoʊ/', '<span>three</span> <span>months</span> <span>ago.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 65, 261.48, 263.8, 'your english is very good.', '你的英语非常好。', '/jɔːr ˈɪŋɡlɪʃ ɪz ˈvɛri ɡʊd/', '<span>your</span> <span>english</span> <span>is</span> <span>very</span> <span>good.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 66, 263.8, 264.68, 'thanks.', '谢谢。', '/θæŋks/', '<span>thanks.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 67, 264.68, 268.4, 'i studied english in school.', '我在学校里学过英语。', '/aɪ ˈstʌdid ˈɪŋɡlɪʃ ɪn skuːl/', '<span>i</span> <span>studied</span> <span>english</span> <span>in</span> <span>school.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 68, 271.16, 272.6, 'would you like some coffee?', '你想来点咖啡吗？', '/wʊd juː laɪk sʌm ˈkɔːfi/', '<span>would</span> <span>you</span> <span>like</span> <span>some</span> <span>coffee?</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 69, 272.6, 274.72, 'no, thank you.', '不用了，谢谢。', '/noʊ, θæŋk juː/', '<span>no,</span> <span>thank</span> <span>you.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 70, 274.72, 276.76, 'tell me about your book.', '请告诉我关于你的书的一些情况吧。', '/tɛl miː əˈbaʊt jɔːr bʊk/', '<span>tell</span> <span>me</span> <span>about</span> <span>your</span> <span>book.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 71, 276.76, 278.88, 'oh, it''s not finished yet.', '哦，还没完成呢。', '/oʊ, ɪts nɑːt ˈfɪnɪʃt jɛt/', '<span>oh,</span> <span>it''s</span> <span>not</span> <span>finished</span> <span>yet.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 72, 278.88, 280.32, 'but i have some of the pictures.', '但我有一些照片。', '/bʌt aɪ hæv sʌm əv ðə ˈpɪktʃərz/', '<span>but</span> <span>i</span> <span>have</span> <span>some</span> <span>of</span> <span>the</span> <span>pictures.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 73, 280.32, 281.32, 'would you like to see them?', '你想看看它们吗？', '/wʊd ju laɪk tu si ðɛm/', '<span>would</span> <span>you</span> <span>like</span> <span>to</span> <span>see</span> <span>them?</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 74, 281.32, 283.12, 'yes, i''d like that.', '是的，我想要那个。', '/jɛs aɪd laɪk ðæt/', '<span>yes,</span> <span>i''d</span> <span>like</span> <span>that.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 75, 283.12, 285.68, 'here they are.', '他们来了。', '/hɪr ðeɪ ɑr/', '<span>here</span> <span>they</span> <span>are.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 76, 287.08, 290.64, 'family album usa.', '美国家庭相册。', '/ˈfæməli ˈælbəm ju ɛs eɪ/', '<span>family</span> <span>album</span> <span>usa.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 77, 290.64, 296.12, 'it''s an album of pictures of the united states, the cities, the special places, and the people.', '这是一本展示美国各地风景的照片集。 那些城市，那些特别的地方。 还有那些人们。', '/ɪts ən ˈælbəm əv ˈpɪktʃərz əv ðə juˈnaɪtəd steɪts ðə ˈsɪtiz ðə ˈspɛʃəl ˈpleɪsəz ænd ðə ˈpipəl/', '<span>it''s</span> <span>an</span> <span>album</span> <span>of</span> <span>pictures</span> <span>of</span> <span>the</span> <span>united</span> <span>states,</span> <span>the</span> <span>cities,</span> <span>the</span> <span>special</span> <span>places,</span> <span>and</span> <span>the</span> <span>people.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 78, 296.12, 298.84, 'and these are pictures of people working.', '这些是人们正在工作的照片。', '/ænd ðiz ɑr ˈpɪktʃərz əv ˈpipəl ˈwɜrkɪŋ/', '<span>and</span> <span>these</span> <span>are</span> <span>pictures</span> <span>of</span> <span>people</span> <span>working.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 79, 298.84, 314.04, 'steel workers, bankers, police, street vendors, ambulance drivers, doctors.', '钢铁工人、银行家、警察、街头小贩、救护车司机、医生。', '/stil ˈwɜrkərz ˈbæŋkərz pəˈlis strit ˈvɛndərz ˈæmbjələns ˈdraɪvərz ˈdɑktərz/', '<span>steel</span> <span>workers,</span> <span>bankers,</span> <span>police,</span> <span>street</span> <span>vendors,</span> <span>ambulance</span> <span>drivers,</span> <span>doctors.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 80, 314.04, 315.52, 'uh, this is my father.', '呃，这是我父亲。', '/ʌ, ðɪs ɪz maɪ ˈfɑːðər/', '<span>uh,</span> <span>this</span> <span>is</span> <span>my</span> <span>father.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 81, 315.52, 318.24, 'he''s a doctor.', '他是一名医生。', '/hiz ə ˈdɑːktər/', '<span>he''s</span> <span>a</span> <span>doctor.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 82, 319.28, 320.48, 'this is my mother.', '这是我母亲。', '/ðɪs ɪz maɪ ˈmʌðər/', '<span>this</span> <span>is</span> <span>my</span> <span>mother.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 83, 320.48, 321.56, 'what''s her name?', '她叫什么名字？', '/wʌts hɜːr neɪm/', '<span>what''s</span> <span>her</span> <span>name?</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 84, 321.56, 323.92, 'ellen.', '艾伦。', '/ˈɛlən/', '<span>ellen.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 85, 324.64, 326.16, 'my younger brother, robbie.', '我的弟弟，罗比。', '/maɪ ˈjʌŋɡər ˈbrʌðər, ˈrɑːbi/', '<span>my</span> <span>younger</span> <span>brother,</span> <span>robbie.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 86, 326.16, 328.52, 'he goes to high school.', '他正在上高中。', '/hi ɡoʊz tə haɪ skuːl/', '<span>he</span> <span>goes</span> <span>to</span> <span>high</span> <span>school.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 87, 328.52, 330.44, 'this is my sister, susan.', '这是我妹妹，苏珊。', '/ðɪs ɪz maɪ ˈsɪstər, ˈsuːzən/', '<span>this</span> <span>is</span> <span>my</span> <span>sister,</span> <span>susan.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 88, 330.44, 333.88, 'she works for a toy company.', '她在一家玩具公司工作。', '/ʃi wɜːrks fɔːr ə tɔɪ ˈkʌmpəni/', '<span>she</span> <span>works</span> <span>for</span> <span>a</span> <span>toy</span> <span>company.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 89, 334.72, 336.16, 'here''s my grandfather.', '这是我爷爷。', '/hɪrz maɪ ˈɡrændˌfɑːðər/', '<span>here''s</span> <span>my</span> <span>grandfather.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 90, 336.16, 338.16, 'he lives in florida.', '他住在佛罗里达州。', '/hi lɪvz ɪn ˈflɔːrɪdə/', '<span>he</span> <span>lives</span> <span>in</span> <span>florida.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 91, 338.16, 339.92, 'and this is my wife, marilyn.', '这是我妻子，玛丽莲。', '/ænd ðɪs ɪz maɪ waɪf, ˈmærɪlɪn/', '<span>and</span> <span>this</span> <span>is</span> <span>my</span> <span>wife,</span> <span>marilyn.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 92, 339.92, 341.56, 'oh, she''s very pretty.', '哦，她非常漂亮。', '/oʊ, ʃiz ˈvɛri ˈprɪti/', '<span>oh,</span> <span>she''s</span> <span>very</span> <span>pretty.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 93, 341.56, 342.56, 'thanks.', '谢谢。', '/θæŋks/', '<span>thanks.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 94, 342.56, 345.04, 'and what about your family?', '那你的家人呢？', '/ænd wʌt əˈbaʊt jɔːr ˈfæmɪli/', '<span>and</span> <span>what</span> <span>about</span> <span>your</span> <span>family?</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 95, 345.04, 346.84, 'they are in thessaloniki.', '他们在塞萨洛尼基。', '/ðeɪ ɑːr ɪn ˌθɛsəˈloʊnɪki/', '<span>they</span> <span>are</span> <span>in</span> <span>thessaloniki.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 96, 346.84, 347.84, 'mhm.', '嗯。', '/m̩ˈhm/', '<span>mhm.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 97, 347.84, 350.36, 'that''s a large city in northern greece.', '那是希腊北部的一座大城市。', '/ðæts ə lɑːrdʒ ˈsɪti ɪn ˈnɔːrðərn ɡriːs/', '<span>that''s</span> <span>a</span> <span>large</span> <span>city</span> <span>in</span> <span>northern</span> <span>greece.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 98, 350.36, 353.2, 'but now i''m living in the bronx.', '但现在我住在布朗克斯区。', '/bʌt naʊ aɪm ˈlɪvɪŋ ɪn ðə brɑːŋks/', '<span>but</span> <span>now</span> <span>i''m</span> <span>living</span> <span>in</span> <span>the</span> <span>bronx.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 99, 353.2, 355.0, 'with a greek-american family?', '在一个希腊裔美国家庭里？', '/wɪð ə ɡriːk əˈmɛrɪkən ˈfæməli/', '<span>with</span> <span>a</span> <span>greek-american</span> <span>family?</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 100, 355.0, 358.24, 'no, hispanic.', '不，他是西班牙裔。', '/noʊ hɪˈspænɪk/', '<span>no,</span> <span>hispanic.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 101, 360.84, 362.48, 'oh, no.', '哦，不。', '/oʊ noʊ/', '<span>oh,</span> <span>no.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 102, 362.48, 365.56, 'it''s 5:30. um, will you excuse me?', '现在 5:30 了。嗯，打扰一下，可以离开了吗？', '/ɪts faɪv ˈθɜːrti ʌm wɪl juː ɪkˈskjuːz miː/', '<span>it''s</span> <span>5:30.</span> <span>um,</span> <span>will</span> <span>you</span> <span>excuse</span> <span>me?</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 103, 365.56, 366.72, 'i have to meet my wife.', '我得去见我的妻子。', '/aɪ hæv tə miːt maɪ waɪf/', '<span>i</span> <span>have</span> <span>to</span> <span>meet</span> <span>my</span> <span>wife.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 104, 366.72, 368.12, 'oh.', '哦。', '/oʊ/', '<span>oh.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 105, 368.12, 369.2, 'it''s nice meeting you.', '很高兴见到你。', '/ɪts naɪs ˈmiːtɪŋ juː/', '<span>it''s</span> <span>nice</span> <span>meeting</span> <span>you.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 106, 369.2, 371.28, 'oh, it was a pleasure meeting you, too.', '哦，能与你见面也很愉快。', '/oʊ ɪt wʌz ə ˈplɛʒər ˈmiːtɪŋ juː tuː/', '<span>oh,</span> <span>it</span> <span>was</span> <span>a</span> <span>pleasure</span> <span>meeting</span> <span>you,</span> <span>too.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 107, 371.28, 374.08, 'thanks for your help, and good luck.', '谢谢你的帮助，祝你好运。', '/θæŋks fɔːr jɔːr hɛlp ænd ɡʊd lʌk/', '<span>thanks</span> <span>for</span> <span>your</span> <span>help,</span> <span>and</span> <span>good</span> <span>luck.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 108, 374.08, 375.48, 'um, i''ve got to go.', '嗯，我得走了。', '/ʌm aɪv ɡɑːt tə ɡoʊ/', '<span>um,</span> <span>i''ve</span> <span>got</span> <span>to</span> <span>go.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 109, 375.48, 376.6, 'by the way, i''m richard.', '顺便说一下，我叫理查德。', '/baɪ ðə weɪ aɪm ˈrɪtʃərd/', '<span>by</span> <span>the</span> <span>way,</span> <span>i''m</span> <span>richard.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 110, 376.6, 377.44, 'what''s your name?', '你叫什么名字？', '/wʌts jɔːr neɪm/', '<span>what''s</span> <span>your</span> <span>name?</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 111, 377.44, 379.16, 'alexandra.', '亚历山德拉。', '/ˌælɪɡˈzændrə/', '<span>alexandra.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 112, 379.16, 379.96, 'bye-bye, alexandra.', '再见了，亚历山德拉。', '/baɪ baɪ ˌælɪɡˈzændrə/', '<span>bye-bye,</span> <span>alexandra.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 113, 379.96, 380.6, 'thanks.', '谢谢。', '/θæŋks/', '<span>thanks.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 114, 380.6, 383.28, 'bye-bye.', '再见了。', '/baɪ baɪ/', '<span>bye-bye.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 115, 384.6, 385.52, 'richard!', '理查德！', '/ˈrɪtʃərd/', '<span>richard!</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 116, 385.52, 389.44, 'richard, you left your bag!', '理查德，你忘了拿你的包！', '/ˈrɪtʃərd ju lɛft jɔr bæɡ/', '<span>richard,</span> <span>you</span> <span>left</span> <span>your</span> <span>bag!</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 117, 399.2, 401.56, 'family album usa.', '美国家庭相册。', '/ˈfæməli ˈælbəm juˈɛs eɪ/', '<span>family</span> <span>album</span> <span>usa.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 118, 401.56, 404.76, 'it''s an album of pictures of the united states.', '这是一本记录美国各地风景的照片集。', '/ɪts ən ˈælbəm əv ˈpɪktʃərz əv ðə juˈnaɪtɪd steɪts/', '<span>it''s</span> <span>an</span> <span>album</span> <span>of</span> <span>pictures</span> <span>of</span> <span>the</span> <span>united</span> <span>states.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 119, 404.76, 407.88, 'richard takes many pictures for his album.', '理查德为他的相册拍了很多照片。', '/ˈrɪtʃərd teɪks ˈmɛni ˈpɪktʃərz fɔr hɪz ˈælbəm/', '<span>richard</span> <span>takes</span> <span>many</span> <span>pictures</span> <span>for</span> <span>his</span> <span>album.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 120, 407.88, 413.04, 'he photographs the cities, like new york,', '他拍摄了纽约这样的城市。', '/hi ˈfoʊtəɡræfs ðə ˈsɪtiz, laɪk nu ˈjɔrk/', '<span>he</span> <span>photographs</span> <span>the</span> <span>cities,</span> <span>like</span> <span>new</span> <span>york,</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 121, 417.2, 420.84, 'and other special places.', '以及其他特殊场所。', '/ænd ˈʌðər ˈspeʃəl ˈpleɪsɪz/', '<span>and</span> <span>other</span> <span>special</span> <span>places.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 122, 432.8, 448.4, 'he photographs people working, police, ambulance drivers, steel workers, doctors.', '他拍摄那些正在工作的人：警察、救护车司机、钢铁工人、医生们。', '/hi ˈfoʊtəɡræfs ˈpipəl ˈwɜrkɪŋ, pəˈlis, ˈæmbjələns ˈdraɪvərz, stil ˈwɜrkərz, ˈdɑktərz/', '<span>he</span> <span>photographs</span> <span>people</span> <span>working,</span> <span>police,</span> <span>ambulance</span> <span>drivers,</span> <span>steel</span> <span>workers,</span> <span>doctors.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 123, 448.4, 452.36, 'philip stewart, richard''s father, is a doctor.', '理查德的父亲菲利普·斯图尔特是一名医生。', '/ˈfɪlɪp ˈstuərt, ˈrɪtʃərdz ˈfɑðər, ɪz ə ˈdɑktər/', '<span>philip</span> <span>stewart,</span> <span>richard''s</span> <span>father,</span> <span>is</span> <span>a</span> <span>doctor.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 124, 452.36, 457.48, 'he''s a pediatrician, a children''s doctor.', '他是一名儿科医生，专门治疗儿童的疾病。', '/hiz ə ˌpidiəˈtrɪʃən, ə ˈtʃɪldrənz ˈdɑktər/', '<span>he''s</span> <span>a</span> <span>pediatrician,</span> <span>a</span> <span>children''s</span> <span>doctor.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 125, 457.8, 463.64, 'and richard''s mother, ellen stewart, is a homemaker.', '理查德的母亲艾伦·斯图尔特则是一名家庭主妇。', '/ænd ˈrɪtʃərdz ˈmʌðər, ˈɛlən ˈstuərt, ɪz ə ˈhoʊmˌmeɪkər/', '<span>and</span> <span>richard''s</span> <span>mother,</span> <span>ellen</span> <span>stewart,</span> <span>is</span> <span>a</span> <span>homemaker.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 126, 464.32, 469.16, 'his brother, robbie, is a student at riverdale high school.', '他的弟弟罗比是河谷高中的学生。', '/hɪz ˈbrʌðər, ˈrɑbi, ɪz ə ˈstudənt æt ˈrɪvərdeɪl haɪ skul/', '<span>his</span> <span>brother,</span> <span>robbie,</span> <span>is</span> <span>a</span> <span>student</span> <span>at</span> <span>riverdale</span> <span>high</span> <span>school.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 127, 469.16, 474.92, 'he''s 17. richard has one sister.', '他 17 岁。理查德有一个妹妹。', '/hiz ˈsɛvəntin. ˈrɪtʃərd hæz wʌn ˈsɪstər/', '<span>he''s</span> <span>17.</span> <span>richard</span> <span>has</span> <span>one</span> <span>sister.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 128, 474.92, 476.6, 'her name is susan.', '她的名字叫苏珊。', '/hɜːr neɪm ɪz ˈsuzən/', '<span>her</span> <span>name</span> <span>is</span> <span>susan.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 129, 476.6, 481.48, 'she works for a toy company in new york city.', '她在纽约市的一家玩具公司工作。', '/ʃiː wɜːrks fɔːr ə tɔɪ ˈkʌmpəni ɪn nuː jɔːrk ˈsɪti/', '<span>she</span> <span>works</span> <span>for</span> <span>a</span> <span>toy</span> <span>company</span> <span>in</span> <span>new</span> <span>york</span> <span>city.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 130, 482.32, 485.08, 'malcolm stewart is richard''s grandfather.', '马尔科姆·斯图尔特是理查德的祖父。', '/ˈmælkəm ˈstuːərt ɪz ˈrɪtʃərdz ˈɡrændfɑːðər/', '<span>malcolm</span> <span>stewart</span> <span>is</span> <span>richard''s</span> <span>grandfather.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 131, 485.08, 489.84, 'he''s 72 years old and lives in florida.', '他 72 岁，住在佛罗里达州。', '/hiːz ˈsevənti tuː jɪrz oʊld ænd lɪvz ɪn ˈflɔːrɪdə/', '<span>he''s</span> <span>72</span> <span>years</span> <span>old</span> <span>and</span> <span>lives</span> <span>in</span> <span>florida.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 132, 489.84, 493.56, 'and this is richard''s wife, marilyn stewart.', '这位是理查德的妻子，玛丽莲·斯图尔特。', '/ænd ðɪs ɪz ˈrɪtʃərdz waɪf ˈmɛrɪlɪn ˈstuːərt/', '<span>and</span> <span>this</span> <span>is</span> <span>richard''s</span> <span>wife,</span> <span>marilyn</span> <span>stewart.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 133, 493.56, 499.32, 'she''s a fashion designer and a sales clerk in a boutique in new york city.', '她是一名时装设计师，同时也在纽约市的一家精品店担任销售员。', '/ʃiːz ə ˈfæʃən dɪˈzaɪnər ænd ə seɪlz klɜːrk ɪn ə buːˈtiːk ɪn nuː jɔːrk ˈsɪti/', '<span>she''s</span> <span>a</span> <span>fashion</span> <span>designer</span> <span>and</span> <span>a</span> <span>sales</span> <span>clerk</span> <span>in</span> <span>a</span> <span>boutique</span> <span>in</span> <span>new</span> <span>york</span> <span>city.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 134, 499.32, 503.68, 'you''ll meet marilyn stewart and all the other stewarts in family album usa.', '在《Family Album USA》中，你将见到玛丽莲·斯图尔特以及所有姓斯图尔特的人。', '/juːl miːt ˈmɛrɪlɪn ˈstuːərt ænd ɔːl ðə ˈʌðər ˈstuːərts ɪn ˈfæməli ˈælbəm jʊˈeɪ/', '<span>you''ll</span> <span>meet</span> <span>marilyn</span> <span>stewart</span> <span>and</span> <span>all</span> <span>the</span> <span>other</span> <span>stewarts</span> <span>in</span> <span>family</span> <span>album</span> <span>usa.</span>'
FROM episodes e WHERE e.video_id = 'NrkfL2tex-OvHfg';

-- episode 216: ZhYyJok4mt460Ak
UPDATE user_word_lookups SET subtitle_id = NULL WHERE subtitle_id IN (SELECT s.id FROM subtitles s JOIN episodes e ON s.episode_id = e.id WHERE e.video_id = 'ZhYyJok4mt460Ak');
UPDATE user_vocabulary_items SET source_subtitle_id = NULL WHERE source_subtitle_id IN (SELECT s.id FROM subtitles s JOIN episodes e ON s.episode_id = e.id WHERE e.video_id = 'ZhYyJok4mt460Ak');
DELETE FROM user_subtitle_progress WHERE subtitle_id IN (SELECT s.id FROM subtitles s JOIN episodes e ON s.episode_id = e.id WHERE e.video_id = 'ZhYyJok4mt460Ak');
DELETE FROM user_subtitle_progress WHERE episode_id = (SELECT id FROM episodes WHERE video_id = 'ZhYyJok4mt460Ak');
DELETE FROM subtitles WHERE episode_id = (SELECT id FROM episodes WHERE video_id = 'ZhYyJok4mt460Ak');
DELETE FROM episode_tags WHERE episode_id = (SELECT id FROM episodes WHERE video_id = 'ZhYyJok4mt460Ak');
INSERT INTO episodes (
  index, video_id, short_title, summary, remark, stars, voca_size,
  subtitle_count, clip_length, cover, video_url, audio_url, thumbnail_url,
  original_video_url, author_id, series_id, series_index,
  submitted_by_user_id, rejection_reason,
  created_at, is_demo, status, published_at
) VALUES (
  216, 'ZhYyJok4mt460Ak', '走遍美国完整版 - 第2集',
  '', '',
  3, 153, 31,
  372.24, 'http://oss.sxakgs.com/en/CxMIqt2SWXQ/cover.webp',
  'http://oss.sxakgs.com/en/CxMIqt2SWXQ/video.mp4', 'http://oss.sxakgs.com/en/CxMIqt2SWXQ/audio.mp3',
  'http://oss.sxakgs.com/en/CxMIqt2SWXQ/cover.webp', 'https://www.youtube.com/watch?v=CxMIqt2SWXQ',
  (SELECT id FROM authors WHERE name = 'da.vinci sarga' AND accent = '美国' LIMIT 1),
  (SELECT id FROM episode_series WHERE slug = '走遍美国视频版-1-78全集' LIMIT 1), 2,
  NULL, NULL,
  '2026-07-13 15:59:08'::timestamp,
  FALSE, 'published',
  '2026-07-13 15:59:08'::timestamp
)
ON CONFLICT (video_id) DO UPDATE SET
  index = EXCLUDED.index,
  short_title = EXCLUDED.short_title,
  summary = EXCLUDED.summary,
  remark = EXCLUDED.remark,
  stars = EXCLUDED.stars,
  voca_size = EXCLUDED.voca_size,
  subtitle_count = EXCLUDED.subtitle_count,
  clip_length = EXCLUDED.clip_length,
  cover = EXCLUDED.cover,
  video_url = EXCLUDED.video_url,
  audio_url = EXCLUDED.audio_url,
  thumbnail_url = EXCLUDED.thumbnail_url,
  original_video_url = EXCLUDED.original_video_url,
  author_id = EXCLUDED.author_id,
  series_id = EXCLUDED.series_id,
  series_index = EXCLUDED.series_index,
  submitted_by_user_id = EXCLUDED.submitted_by_user_id,
  rejection_reason = EXCLUDED.rejection_reason,
  is_demo = EXCLUDED.is_demo,
  status = EXCLUDED.status,
  published_at = EXCLUDED.published_at;

INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 0, 3.52, 12.16, 'in act two alexandra tries to find richard she wants to return his camera bag can you tell me how to get to lyen street', '在第二幕中，亚历山德拉试图找到理查德。 她想把他的相机包还给他。 你能告诉我怎么去连恩街吗？', '/ɪn ækt tuː ælɪɡˈzændrə traɪz tu faɪnd ˈrɪtʃərd ʃi wɑnts tu rɪˈtɜːrn hɪz ˈkæmərə bæɡ kæn ju tɛl mi haʊ tu ɡɛt tu ˈlaɪən striːt/', '<span>in</span> <span>act</span> <span>two</span> <span>alexandra</span> <span>tries</span> <span>to</span> <span>find</span> <span>richard</span> <span>she</span> <span>wants</span> <span>to</span> <span>return</span> <span>his</span> <span>camera</span> <span>bag</span> <span>can</span> <span>you</span> <span>tell</span> <span>me</span> <span>how</span> <span>to</span> <span>get</span> <span>to</span> <span>lyen</span> <span>street</span>'
FROM episodes e WHERE e.video_id = 'ZhYyJok4mt460Ak';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 1, 12.16, 27.199, 'and riverdale richard stewart 46 lyen street riverdale new york you should take the number one subway richard''s wife marilyn is waiting for him where''s my husband later richard arrives', '还有河谷镇的理查德·斯图尔特：纽约州河谷镇莱恩街 46 号。您应该乘坐 1 路公交车前往。 理查德的妻子玛丽莲在地铁站等他。“我丈夫去哪儿了？”过了一会儿，理查德终于到了。', '/ænd ˈrɪvərdeɪl ˈrɪtʃərd ˈstuːərt ˈfɔːrti sɪks ˈlaɪən striːt ˈrɪvərdeɪl njuː jɔːrk ju ʃʊd teɪk ðə ˈnʌmbər wʌn ˈsʌbweɪ ˈrɪtʃərdz waɪf ˈmɛrəlɪn ɪz ˈweɪtɪŋ fɔːr hɪm wɛrz maɪ ˈhʌzbənd ˈleɪtər ˈrɪtʃərd əˈraɪvz/', '<span>and</span> <span>riverdale</span> <span>richard</span> <span>stewart</span> <span>46</span> <span>lyen</span> <span>street</span> <span>riverdale</span> <span>new</span> <span>york</span> <span>you</span> <span>should</span> <span>take</span> <span>the</span> <span>number</span> <span>one</span> <span>subway</span> <span>richard''s</span> <span>wife</span> <span>marilyn</span> <span>is</span> <span>waiting</span> <span>for</span> <span>him</span> <span>where''s</span> <span>my</span> <span>husband</span> <span>later</span> <span>richard</span> <span>arrives</span>'
FROM episodes e WHERE e.video_id = 'ZhYyJok4mt460Ak';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 2, 27.199, 36.2, 'but he''s late i''m sorry i''m so late i have a really bad day marilyn tries to find richard''s bag hello', '但他迟到了，很抱歉，我真的来晚了，今天过得糟透了。 玛丽莲试图找到理查德的包。 你好', '/bʌt hiːz leɪt aɪm ˈsɔri aɪm soʊ leɪt aɪ hæv ə ˈrɪli bæd deɪ ˈmɛrəlɪn traɪz tu faɪnd ˈrɪtʃərdz bæɡ həˈloʊ/', '<span>but</span> <span>he''s</span> <span>late</span> <span>i''m</span> <span>sorry</span> <span>i''m</span> <span>so</span> <span>late</span> <span>i</span> <span>have</span> <span>a</span> <span>really</span> <span>bad</span> <span>day</span> <span>marilyn</span> <span>tries</span> <span>to</span> <span>find</span> <span>richard''s</span> <span>bag</span> <span>hello</span>'
FROM episodes e WHERE e.video_id = 'ZhYyJok4mt460Ak';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 3, 36.2, 44.8, 'yes the number please of the staten island ferry lost and found office will maryland find the bag', '是的，请告诉我斯塔滕岛渡轮的失物招领办公室的号码，这样我就能在马里兰找到那个包了。', '/jɛs ðə ˈnʌmbər pliːz ʌv ðə ˈsteɪtən aɪlənd ˈfɛri lɔːst ænd faʊnd ˈɔfɪs wɪl ˈmɛrələnd faɪnd ðə bæɡ/', '<span>yes</span> <span>the</span> <span>number</span> <span>please</span> <span>of</span> <span>the</span> <span>staten</span> <span>island</span> <span>ferry</span> <span>lost</span> <span>and</span> <span>found</span> <span>office</span> <span>will</span> <span>maryland</span> <span>find</span> <span>the</span> <span>bag</span>'
FROM episodes e WHERE e.video_id = 'ZhYyJok4mt460Ak';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 4, 46.01, 49.09, '[music]', '[音乐]', '/ˈmjuːzɪk/', '<span>[music]</span>'
FROM episodes e WHERE e.video_id = 'ZhYyJok4mt460Ak';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 5, 61.879, 73.72, 'excuse me officer can can you help me sure can you tell me how to get to lynon street in riverdale richard stewart 46 lindon street riverdale new york you should take the number one subway', '打扰一下，警官，您能帮助我吗？当然可以。 你能告诉我如何前往河谷城的莱农街吗？ 理查德·斯图尔特，46 号林登街，里弗代尔，纽约。你应该乘坐 1 号线地铁。', '/ɪkˈskjuːz mi ˈɔfɪsər kæn kæn ju hɛlp mi ʃʊr kæn ju tɛl mi haʊ tu ɡɛt tu ˈlaɪnən striːt ɪn ˈrɪvərdeɪl ˈrɪtʃərd ˈstuːərt ˈfɔːrti sɪks ˈlɪndən striːt ˈrɪvərdeɪl njuː jɔːrk ju ʃʊd teɪk ðə ˈnʌmbər wʌn ˈsʌbweɪ/', '<span>excuse</span> <span>me</span> <span>officer</span> <span>can</span> <span>can</span> <span>you</span> <span>help</span> <span>me</span> <span>sure</span> <span>can</span> <span>you</span> <span>tell</span> <span>me</span> <span>how</span> <span>to</span> <span>get</span> <span>to</span> <span>lynon</span> <span>street</span> <span>in</span> <span>riverdale</span> <span>richard</span> <span>stewart</span> <span>46</span> <span>lindon</span> <span>street</span> <span>riverdale</span> <span>new</span> <span>york</span> <span>you</span> <span>should</span> <span>take</span> <span>the</span> <span>number</span> <span>one</span> <span>subway</span>'
FROM episodes e WHERE e.video_id = 'ZhYyJok4mt460Ak';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 6, 73.72, 79.6, 'is there a station near here yes the station''s that way you should take the number one train to van courland park', '这里附近有车站吗？ 是的，车站就在那边。 你应该乘坐 1 号列车前往范库尔兰公园。', '/ɪz ðɛr ə ˈsteɪʃən nɪr hɪr jɛs ðə ˈsteɪʃənz ðæt weɪ ju ʃʊd teɪk ðə ˈnʌmbər wʌn treɪn tu væn ˈkɔːrlənd pɑːrk/', '<span>is</span> <span>there</span> <span>a</span> <span>station</span> <span>near</span> <span>here</span> <span>yes</span> <span>the</span> <span>station''s</span> <span>that</span> <span>way</span> <span>you</span> <span>should</span> <span>take</span> <span>the</span> <span>number</span> <span>one</span> <span>train</span> <span>to</span> <span>van</span> <span>courland</span> <span>park</span>'
FROM episodes e WHERE e.video_id = 'ZhYyJok4mt460Ak';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 7, 79.6, 90.68, 'number one train to van courland park thank you anytime good luck remember the number one train the uptown platform thank you', '前往范库兰公园的第一班火车 随时欢迎您。祝您好运。请记住：头等舱在市区方向的站台上。谢谢。', '/ˈnʌmbər wʌn treɪn tu væn ˈkɔːrlənd pɑːrk θæŋk ju ˈɛnitaɪm ɡʊd lʌk rɪˈmɛmbər ðə ˈnʌmbər wʌn treɪn ði ˈʌptaʊn ˈplætfɔːrm θæŋk ju/', '<span>number</span> <span>one</span> <span>train</span> <span>to</span> <span>van</span> <span>courland</span> <span>park</span> <span>thank</span> <span>you</span> <span>anytime</span> <span>good</span> <span>luck</span> <span>remember</span> <span>the</span> <span>number</span> <span>one</span> <span>train</span> <span>the</span> <span>uptown</span> <span>platform</span> <span>thank</span> <span>you</span>'
FROM episodes e WHERE e.video_id = 'ZhYyJok4mt460Ak';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 8, 103.73, 113.159, '[music] is this pink too bright for me mhm it is a very bright', '[音乐] 这种粉色对我来说是不是太鲜艳了？ 嗯，它的亮度确实很高。', '/ˈmjuːzɪk ɪz ðɪs pɪŋk tuː ˈbraɪt fɔːr miː m̩ ɪt ɪz ə ˈvɛri braɪt/', '<span>[music]</span> <span>is</span> <span>this</span> <span>pink</span> <span>too</span> <span>bright</span> <span>for</span> <span>me</span> <span>mhm</span> <span>it</span> <span>is</span> <span>a</span> <span>very</span> <span>bright</span>'
FROM episodes e WHERE e.video_id = 'ZhYyJok4mt460Ak';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 9, 117.88, 136.319, 'pink try this it''s size eight but i wear size 10 how about green it''s size 10 let me try it on i''m taking too much of your', '粉色，试试看吧。 它是 8 号尺寸的。 但我穿 10 码的鞋子。 怎么样呢？ 绿色的，尺码是 10 号，让我试试看。 哎，我占用你的时间太多了。', '/pɪŋk traɪ ðɪs ɪts saɪz eɪt bʌt aɪ wɛr saɪz tɛn haʊ əˈbaʊt ɡriːn ɪts saɪz tɛn lɛt miː traɪ ɪt ɑːn aɪm ˈteɪkɪŋ tuː mʌtʃ ʌv jɔːr/', '<span>pink</span> <span>try</span> <span>this</span> <span>it''s</span> <span>size</span> <span>eight</span> <span>but</span> <span>i</span> <span>wear</span> <span>size</span> <span>10</span> <span>how</span> <span>about</span> <span>green</span> <span>it''s</span> <span>size</span> <span>10</span> <span>let</span> <span>me</span> <span>try</span> <span>it</span> <span>on</span> <span>i''m</span> <span>taking</span> <span>too</span> <span>much</span> <span>of</span> <span>your</span>'
FROM episodes e WHERE e.video_id = 'ZhYyJok4mt460Ak';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 10, 137.64, 146.2, 'time it''s 6:00 where''s my husband i was expecting him here at 5:45 don''t worry the traffic is very heavy at this hour', '时间 现在 6 点了，我的丈夫在哪儿呢？ 我原本预计他会在 5:45 来到这里。 别担心，这个时段交通总是很拥堵的。', '/taɪm ɪts sɪks əˈklɑːk wɛrz maɪ ˈhʌzbənd aɪ wəz ɪkˈspɛktɪŋ hɪm hɪr æt faɪv ˈfɔːrti faɪv doʊnt ˈwɜːri ðə ˈtræfɪk ɪz ˈvɛri ˈhɛvi æt ðɪs ˈaʊər/', '<span>time</span> <span>it''s</span> <span>6:00</span> <span>where''s</span> <span>my</span> <span>husband</span> <span>i</span> <span>was</span> <span>expecting</span> <span>him</span> <span>here</span> <span>at</span> <span>5:45</span> <span>don''t</span> <span>worry</span> <span>the</span> <span>traffic</span> <span>is</span> <span>very</span> <span>heavy</span> <span>at</span> <span>this</span> <span>hour</span>'
FROM episodes e WHERE e.video_id = 'ZhYyJok4mt460Ak';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 11, 146.2, 153.56, 'i know but we''re going to be late for dinner i''ll take this green sweater i like the color on me don''t you', '我知道。 但我们吃晚饭要迟到了。 我选这件绿色毛衣吧。 我喜欢这种颜色穿在我身上，你呢？', '/aɪ noʊ bʌt wiːr ˈɡoʊɪŋ tuː bi leɪt fɔːr ˈdɪnər aɪl teɪk ðɪs ɡriːn ˈswɛtər aɪ laɪk ðə ˈkʌlər ɑːn miː doʊnt juː/', '<span>i</span> <span>know</span> <span>but</span> <span>we''re</span> <span>going</span> <span>to</span> <span>be</span> <span>late</span> <span>for</span> <span>dinner</span> <span>i''ll</span> <span>take</span> <span>this</span> <span>green</span> <span>sweater</span> <span>i</span> <span>like</span> <span>the</span> <span>color</span> <span>on</span> <span>me</span> <span>don''t</span> <span>you</span>'
FROM episodes e WHERE e.video_id = 'ZhYyJok4mt460Ak';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 12, 153.56, 156.8, 'i think it looks terrific on', '我觉得它看起来棒极了。', '/aɪ θɪŋk ɪt lʊks təˈrɪfɪk ɑːn/', '<span>i</span> <span>think</span> <span>it</span> <span>looks</span> <span>terrific</span> <span>on</span>'
FROM episodes e WHERE e.video_id = 'ZhYyJok4mt460Ak';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 13, 160.04, 169.519, 'you i''m sorry i''m so late i had a really bad day it''s 10 after 6 we''re late robie''s cooking tonight and dinner''s at 6:30', '对不起，我来晚了。今天真是糟糕透顶的一天。现在已经是 10 点了。 6 点过后我们就迟到了。罗比今晚要做饭，晚餐时间是在 6:30。', '/juː aɪm ˈsɑːri aɪm soʊ leɪt aɪ hæd ə ˈrɛli bæd deɪ ɪts tɛn ˈæftər sɪks wiːr leɪt ˈroʊbiz ˈkʊkɪŋ təˈnaɪt ænd ˈdɪnərz æt sɪks ˈθɜːrti/', '<span>you</span> <span>i''m</span> <span>sorry</span> <span>i''m</span> <span>so</span> <span>late</span> <span>i</span> <span>had</span> <span>a</span> <span>really</span> <span>bad</span> <span>day</span> <span>it''s</span> <span>10</span> <span>after</span> <span>6</span> <span>we''re</span> <span>late</span> <span>robie''s</span> <span>cooking</span> <span>tonight</span> <span>and</span> <span>dinner''s</span> <span>at</span> <span>6:30</span>'
FROM episodes e WHERE e.video_id = 'ZhYyJok4mt460Ak';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 14, 169.519, 179.239, 'i know i know i''m really sorry i left my bag of film on the ferry i went back forth but the ferry was gone i lost a whole day''s work', '我知道。 我知道自己真的非常抱歉。 我把装着胶卷的包忘在渡轮上了，不得不再次往返取回。 可是渡轮已经开走了，我因此损失了一整天的工作时间。', '/aɪ noʊ aɪ noʊ aɪm ˈrɛli ˈsɑːri aɪ lɛft maɪ bæɡ ʌv fɪlm ɑːn ðə ˈfɛri aɪ wɛnt bæk fɔːrθ bʌt ðə ˈfɛri wəz ɡɔːn aɪ lɔːst ə hoʊl deɪz wɜːrk/', '<span>i</span> <span>know</span> <span>i</span> <span>know</span> <span>i''m</span> <span>really</span> <span>sorry</span> <span>i</span> <span>left</span> <span>my</span> <span>bag</span> <span>of</span> <span>film</span> <span>on</span> <span>the</span> <span>ferry</span> <span>i</span> <span>went</span> <span>back</span> <span>forth</span> <span>but</span> <span>the</span> <span>ferry</span> <span>was</span> <span>gone</span> <span>i</span> <span>lost</span> <span>a</span> <span>whole</span> <span>day''s</span> <span>work</span>'
FROM episodes e WHERE e.video_id = 'ZhYyJok4mt460Ak';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 15, 179.239, 185.2, 'i''ll call the staten island fairy lost and found office i didn''t think of that', '我会打电话给斯塔滕岛的失物招领办公室。 我没想到这一点。', '/aɪl kɔːl ðə ˈstætən aɪlənd ˈfɛri lɔːst ænd faʊnd ˈɒfɪs aɪ dɪdnt θɪŋk ʌv ðæt/', '<span>i''ll</span> <span>call</span> <span>the</span> <span>staten</span> <span>island</span> <span>fairy</span> <span>lost</span> <span>and</span> <span>found</span> <span>office</span> <span>i</span> <span>didn''t</span> <span>think</span> <span>of</span> <span>that</span>'
FROM episodes e WHERE e.video_id = 'ZhYyJok4mt460Ak';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 16, 189.319, 200.28, 'thanks hello yes the number please of the staten island ferry lost and found office', '谢谢 你好 是的，请告诉我斯塔滕岛渡轮上的失物招领编号。 办公室/办公场所', '/θæŋks ˈhɛloʊ jɛs ðə ˈnʌmbər pliz əv ðə ˈstætən ˈaɪlənd ˈfɛri lɔːst ænd faʊnd ˈɔfəs/', '<span>thanks</span> <span>hello</span> <span>yes</span> <span>the</span> <span>number</span> <span>please</span> <span>of</span> <span>the</span> <span>staten</span> <span>island</span> <span>ferry</span> <span>lost</span> <span>and</span> <span>found</span> <span>office</span>'
FROM episodes e WHERE e.video_id = 'ZhYyJok4mt460Ak';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 17, 203.44, 216.879, '0808 thank you i really appreciate it marilyn hello did anyone find a camera bag this afternoon a small canvas', '0808 谢谢 你真的太好了，玛丽莲。 你好 今天下午有人找到一个小的帆布制相机包吗？', '/ˈoʊ eɪt oʊ eɪt θæŋk ju aɪ ˈrɪli ˈæprəʃieɪt ɪt ˈmɛrəlɪn ˈhɛloʊ dɪd ˈɛniwʌn faɪnd ə ˈkæmərə bæɡ ðɪs ˈæftərnun ə smɔːl ˈkænvəs/', '<span>0808</span> <span>thank</span> <span>you</span> <span>i</span> <span>really</span> <span>appreciate</span> <span>it</span> <span>marilyn</span> <span>hello</span> <span>did</span> <span>anyone</span> <span>find</span> <span>a</span> <span>camera</span> <span>bag</span> <span>this</span> <span>afternoon</span> <span>a</span> <span>small</span> <span>canvas</span>'
FROM episodes e WHERE e.video_id = 'ZhYyJok4mt460Ak';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 18, 216.879, 233.84, 'bag on the jf kennedy ferry no maybe someone will find it the name is stewart richard stewart and the telephone number is', '对约翰·F·肯尼迪的侮辱/对肯尼迪的蔑视 渡轮/摆渡船 也许会有人找到它吧，它的名字是斯图尔特·理查德·斯图尔特。 电话号码是', '/bæɡ ɑn ðə dʒeɪ ɛf ˈkɛnədi ˈfɛri noʊ ˈmeɪbi ˈsʌmwʌn wɪl faɪnd ɪt ðə neɪm ɪz ˈstuːərt ˈrɪtʃərd ˈstuːərt ænd ðə ˈtɛləfoʊn ˈnʌmbər ɪz/', '<span>bag</span> <span>on</span> <span>the</span> <span>jf</span> <span>kennedy</span> <span>ferry</span> <span>no</span> <span>maybe</span> <span>someone</span> <span>will</span> <span>find</span> <span>it</span> <span>the</span> <span>name</span> <span>is</span> <span>stewart</span> <span>richard</span> <span>stewart</span> <span>and</span> <span>the</span> <span>telephone</span> <span>number</span> <span>is</span>'
FROM episodes e WHERE e.video_id = 'ZhYyJok4mt460Ak';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 19, 236.12, 245.28, '55539 thank you sorry richard they don''t have it thanks', '55539 谢谢您 对不起，理查德，他们没有。 它表示了感谢。', '/ˈfaɪv faɪv θri naɪn θæŋk ju ˈsɑri ˈrɪtʃərd ðeɪ doʊnt hæv ɪt θæŋks/', '<span>55539</span> <span>thank</span> <span>you</span> <span>sorry</span> <span>richard</span> <span>they</span> <span>don''t</span> <span>have</span> <span>it</span> <span>thanks</span>'
FROM episodes e WHERE e.video_id = 'ZhYyJok4mt460Ak';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 20, 246.36, 252.48, 'anyway but there was a girl on the feries now tell me about it on the way', '不管怎样/无论如何 但假期里有个女孩在那里。 现在，路上再告诉我详情吧。', '/ˈɛniweɪ bʌt ðɛr wʌz ə gɜːrl ɑn ðə ˈfɛriz naʊ tɛl mi əˈbaʊt ɪt ɑn ðə weɪ/', '<span>anyway</span> <span>but</span> <span>there</span> <span>was</span> <span>a</span> <span>girl</span> <span>on</span> <span>the</span> <span>feries</span> <span>now</span> <span>tell</span> <span>me</span> <span>about</span> <span>it</span> <span>on</span> <span>the</span> <span>way</span>'
FROM episodes e WHERE e.video_id = 'ZhYyJok4mt460Ak';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 21, 259.68, 269.12, 'home thank you i appreciate your help thank you you''re welcome thank you you''re welcome thank you for your help', '家/故乡 谢谢，非常感谢你的帮助。不用客气。 谢谢，不客气。 感谢您的帮助。', '/hoʊm θæŋk ju aɪ əˈpriʃieɪt jɔr hɛlp θæŋk ju jʊr ˈwɛlkəm θæŋk ju jʊr ˈwɛlkəm θæŋk ju fɔr jɔr hɛlp/', '<span>home</span> <span>thank</span> <span>you</span> <span>i</span> <span>appreciate</span> <span>your</span> <span>help</span> <span>thank</span> <span>you</span> <span>you''re</span> <span>welcome</span> <span>thank</span> <span>you</span> <span>you''re</span> <span>welcome</span> <span>thank</span> <span>you</span> <span>for</span> <span>your</span> <span>help</span>'
FROM episodes e WHERE e.video_id = 'ZhYyJok4mt460Ak';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 22, 269.12, 280.84, 'thanks a lot i want to thank you for your help thank you glad that i could help don''t mention it i''m glad that i could help', '非常感谢！我想感谢您的帮助，谢谢您。 很高兴能帮上忙。 别客气，能帮上忙我很高兴。', '/θæŋks ə lɑt aɪ wɑnt tu θæŋk ju fɔr jɔr hɛlp θæŋk ju glæd ðæt aɪ kʊd hɛlp doʊnt ˈmɛnʃən ɪt aɪm glæd ðæt aɪ kʊd hɛlp/', '<span>thanks</span> <span>a</span> <span>lot</span> <span>i</span> <span>want</span> <span>to</span> <span>thank</span> <span>you</span> <span>for</span> <span>your</span> <span>help</span> <span>thank</span> <span>you</span> <span>glad</span> <span>that</span> <span>i</span> <span>could</span> <span>help</span> <span>don''t</span> <span>mention</span> <span>it</span> <span>i''m</span> <span>glad</span> <span>that</span> <span>i</span> <span>could</span> <span>help</span>'
FROM episodes e WHERE e.video_id = 'ZhYyJok4mt460Ak';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 23, 280.84, 295.08, 'thanks you''re welcome thank you girl and thank you mr man oh my pleasure thank you you''re welcome thank you very much it was very nice of you i appreciate', '谢谢，不客气。谢谢你，姑娘。 谢谢您，曼先生。 哦，太好了，谢谢您，不客气。 非常感谢您，您真是太好了，我真心感激。', '/θæŋks jʊr ˈwɛlkəm θæŋk ju gɜːrl ænd θæŋk ju mɪstər mæn oʊ maɪ ˈplɛʒər θæŋk ju jʊr ˈwɛlkəm θæŋk ju ˈvɛri mʌtʃ ɪt wʌz ˈvɛri naɪs əv ju aɪ əˈpriʃieɪt/', '<span>thanks</span> <span>you''re</span> <span>welcome</span> <span>thank</span> <span>you</span> <span>girl</span> <span>and</span> <span>thank</span> <span>you</span> <span>mr</span> <span>man</span> <span>oh</span> <span>my</span> <span>pleasure</span> <span>thank</span> <span>you</span> <span>you''re</span> <span>welcome</span> <span>thank</span> <span>you</span> <span>very</span> <span>much</span> <span>it</span> <span>was</span> <span>very</span> <span>nice</span> <span>of</span> <span>you</span> <span>i</span> <span>appreciate</span>'
FROM episodes e WHERE e.video_id = 'ZhYyJok4mt460Ak';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 24, 295.08, 307.4, 'it thanks a lot thank you you''re welcome don''t mention it i''m glad that i could help my pleasure it was nothing you''re welcome', '非常感谢。 不用客气/不客气啦 别客气，能帮上忙我很高兴。不用客气，不值一提。', '/ɪt θæŋks ə lɑt θæŋk ju jʊr ˈwɛlkəm doʊnt ˈmɛnʃən ɪt aɪm glæd ðæt aɪ kʊd hɛlp maɪ ˈplɛʒər ɪt wʌz ˈnʌθɪŋ jʊr ˈwɛlkəm/', '<span>it</span> <span>thanks</span> <span>a</span> <span>lot</span> <span>thank</span> <span>you</span> <span>you''re</span> <span>welcome</span> <span>don''t</span> <span>mention</span> <span>it</span> <span>i''m</span> <span>glad</span> <span>that</span> <span>i</span> <span>could</span> <span>help</span> <span>my</span> <span>pleasure</span> <span>it</span> <span>was</span> <span>nothing</span> <span>you''re</span> <span>welcome</span>'
FROM episodes e WHERE e.video_id = 'ZhYyJok4mt460Ak';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 25, 307.4, 317.36, 'number one train again courland park thank you any times good luck thank you very much it was very nice of you i appreciate', '又是库兰帕克的第一班火车 谢谢您，祝您好运。 非常感谢您，您真是太好了，我真心感激。', '/ˈnʌmbər wʌn treɪn əˈɡɛn ˈkɜrlənd pɑrk θæŋk ju ˈɛni taɪmz ɡʊd lʌk θæŋk ju ˈvɛri mʌtʃ ɪt wʌz ˈvɛri naɪs əv ju aɪ əˈpriʃiˌeɪt/', '<span>number</span> <span>one</span> <span>train</span> <span>again</span> <span>courland</span> <span>park</span> <span>thank</span> <span>you</span> <span>any</span> <span>times</span> <span>good</span> <span>luck</span> <span>thank</span> <span>you</span> <span>very</span> <span>much</span> <span>it</span> <span>was</span> <span>very</span> <span>nice</span> <span>of</span> <span>you</span> <span>i</span> <span>appreciate</span>'
FROM episodes e WHERE e.video_id = 'ZhYyJok4mt460Ak';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 26, 317.36, 329.8, 'it thanks a lot thank you you''re welcome don''t mention it i''m glad that i could help my pleasure it was nothing you''re welcome', '非常感谢。 不用客气/不客气啦 别客气，能帮上忙我很高兴。 不客气，这是我应该做的。/请别客气。', '/ɪt θæŋks ə lɑt θæŋk ju jʊr ˈwɛlkəm doʊnt ˈmɛnʃən ɪt aɪm glæd ðæt aɪ kʊd hɛlp maɪ ˈplɛʒər ɪt wʌz ˈnʌθɪŋ jʊr ˈwɛlkəm/', '<span>it</span> <span>thanks</span> <span>a</span> <span>lot</span> <span>thank</span> <span>you</span> <span>you''re</span> <span>welcome</span> <span>don''t</span> <span>mention</span> <span>it</span> <span>i''m</span> <span>glad</span> <span>that</span> <span>i</span> <span>could</span> <span>help</span> <span>my</span> <span>pleasure</span> <span>it</span> <span>was</span> <span>nothing</span> <span>you''re</span> <span>welcome</span>'
FROM episodes e WHERE e.video_id = 'ZhYyJok4mt460Ak';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 27, 329.8, 340.56, 'thank you for your help thanks a lot i want to thank you for your help thank you glad that i could help', '感谢您的帮助。 非常感谢！我想感谢您的帮助，谢谢您。 很高兴能帮上忙。', '/θæŋk ju fɔr jɔr hɛlp θæŋks ə lɑt aɪ wɑnt tə θæŋk ju fɔr jɔr hɛlp θæŋk ju glæd ðæt aɪ kʊd hɛlp/', '<span>thank</span> <span>you</span> <span>for</span> <span>your</span> <span>help</span> <span>thanks</span> <span>a</span> <span>lot</span> <span>i</span> <span>want</span> <span>to</span> <span>thank</span> <span>you</span> <span>for</span> <span>your</span> <span>help</span> <span>thank</span> <span>you</span> <span>glad</span> <span>that</span> <span>i</span> <span>could</span> <span>help</span>'
FROM episodes e WHERE e.video_id = 'ZhYyJok4mt460Ak';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 28, 340.56, 352.0, 'don''t mention it i''m glad that i could help thanks you''re welcome thank you sorry richard they don''t have it', '别客气，能帮上忙我很高兴。 谢谢，不用客气。 理查德，很抱歉，他们没有那个东西。', '/doʊnt ˈmɛnʃən ɪt aɪm glæd ðæt aɪ kʊd hɛlp θæŋks jʊr ˈwɛlkəm θæŋk ju ˈsɑri ˈrɪtʃərd ðeɪ doʊnt hæv ɪt/', '<span>don''t</span> <span>mention</span> <span>it</span> <span>i''m</span> <span>glad</span> <span>that</span> <span>i</span> <span>could</span> <span>help</span> <span>thanks</span> <span>you''re</span> <span>welcome</span> <span>thank</span> <span>you</span> <span>sorry</span> <span>richard</span> <span>they</span> <span>don''t</span> <span>have</span> <span>it</span>'
FROM episodes e WHERE e.video_id = 'ZhYyJok4mt460Ak';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 29, 352.0, 370.16, 'thanks anyway thanks anyway it was nice of you to try i appreciate it thanks a lot thank you anytime don''t mention it i really try to help you''re welcome my pleasure', '不管怎样，还是谢谢了。谢谢啦。 你愿意尝试一下，真是太好了。我很感激，谢谢你了。 随时都可以找我帮忙，不用客气，这是我应该做的。', '/θæŋks ˈɛniˌweɪ θæŋks ˈɛniˌweɪ ɪt wʌz naɪs əv ju tə traɪ aɪ əˈpriʃiˌeɪt ɪt θæŋks ə lɑt θæŋk ju ˈɛniˌtaɪm doʊnt ˈmɛnʃən ɪt aɪ ˈrɪli traɪ tə hɛlp jʊr ˈwɛlkəm maɪ ˈplɛʒər/', '<span>thanks</span> <span>anyway</span> <span>thanks</span> <span>anyway</span> <span>it</span> <span>was</span> <span>nice</span> <span>of</span> <span>you</span> <span>to</span> <span>try</span> <span>i</span> <span>appreciate</span> <span>it</span> <span>thanks</span> <span>a</span> <span>lot</span> <span>thank</span> <span>you</span> <span>anytime</span> <span>don''t</span> <span>mention</span> <span>it</span> <span>i</span> <span>really</span> <span>try</span> <span>to</span> <span>help</span> <span>you''re</span> <span>welcome</span> <span>my</span> <span>pleasure</span>'
FROM episodes e WHERE e.video_id = 'ZhYyJok4mt460Ak';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 30, 370.16, 372.24, 'anytime thank you you''re welcome', '随时都可以，谢谢您，不客气。', '/ˈɛniˌtaɪm θæŋk ju jʊr ˈwɛlkəm/', '<span>anytime</span> <span>thank</span> <span>you</span> <span>you''re</span> <span>welcome</span>'
FROM episodes e WHERE e.video_id = 'ZhYyJok4mt460Ak';

-- episode 217: HU7atRpOuXDCURA
UPDATE user_word_lookups SET subtitle_id = NULL WHERE subtitle_id IN (SELECT s.id FROM subtitles s JOIN episodes e ON s.episode_id = e.id WHERE e.video_id = 'HU7atRpOuXDCURA');
UPDATE user_vocabulary_items SET source_subtitle_id = NULL WHERE source_subtitle_id IN (SELECT s.id FROM subtitles s JOIN episodes e ON s.episode_id = e.id WHERE e.video_id = 'HU7atRpOuXDCURA');
DELETE FROM user_subtitle_progress WHERE subtitle_id IN (SELECT s.id FROM subtitles s JOIN episodes e ON s.episode_id = e.id WHERE e.video_id = 'HU7atRpOuXDCURA');
DELETE FROM user_subtitle_progress WHERE episode_id = (SELECT id FROM episodes WHERE video_id = 'HU7atRpOuXDCURA');
DELETE FROM subtitles WHERE episode_id = (SELECT id FROM episodes WHERE video_id = 'HU7atRpOuXDCURA');
DELETE FROM episode_tags WHERE episode_id = (SELECT id FROM episodes WHERE video_id = 'HU7atRpOuXDCURA');
INSERT INTO episodes (
  index, video_id, short_title, summary, remark, stars, voca_size,
  subtitle_count, clip_length, cover, video_url, audio_url, thumbnail_url,
  original_video_url, author_id, series_id, series_index,
  submitted_by_user_id, rejection_reason,
  created_at, is_demo, status, published_at
) VALUES (
  217, 'HU7atRpOuXDCURA', '走遍美国完整版 - 第3集',
  '', '',
  2, 231, 174,
  471.92, 'http://oss.sxakgs.com/en/nkKoipVtObU/cover.webp',
  'http://oss.sxakgs.com/en/nkKoipVtObU/video.mp4', 'http://oss.sxakgs.com/en/nkKoipVtObU/audio.mp3',
  'http://oss.sxakgs.com/en/nkKoipVtObU/cover.webp', 'https://www.youtube.com/watch?v=nkKoipVtObU',
  (SELECT id FROM authors WHERE name = 'da.vinci sarga' AND accent = '美国' LIMIT 1),
  (SELECT id FROM episode_series WHERE slug = '走遍美国视频版-1-78全集' LIMIT 1), 3,
  NULL, NULL,
  '2026-07-13 16:12:15'::timestamp,
  FALSE, 'published',
  '2026-07-13 16:12:38'::timestamp
)
ON CONFLICT (video_id) DO UPDATE SET
  index = EXCLUDED.index,
  short_title = EXCLUDED.short_title,
  summary = EXCLUDED.summary,
  remark = EXCLUDED.remark,
  stars = EXCLUDED.stars,
  voca_size = EXCLUDED.voca_size,
  subtitle_count = EXCLUDED.subtitle_count,
  clip_length = EXCLUDED.clip_length,
  cover = EXCLUDED.cover,
  video_url = EXCLUDED.video_url,
  audio_url = EXCLUDED.audio_url,
  thumbnail_url = EXCLUDED.thumbnail_url,
  original_video_url = EXCLUDED.original_video_url,
  author_id = EXCLUDED.author_id,
  series_id = EXCLUDED.series_id,
  series_index = EXCLUDED.series_index,
  submitted_by_user_id = EXCLUDED.submitted_by_user_id,
  rejection_reason = EXCLUDED.rejection_reason,
  is_demo = EXCLUDED.is_demo,
  status = EXCLUDED.status,
  published_at = EXCLUDED.published_at;

INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 0, 2.68, 7.08, 'in act three, the stewart family has dinner together.', '在第三幕中，斯图尔特一家一起共进晚餐。', '/ɪn ækt θriː, ðə ˈstuːərt ˈfæməli hæz ˈdɪnər təˈɡɛðər/', '<span>in</span> <span>act</span> <span>three,</span> <span>the</span> <span>stewart</span> <span>family</span> <span>has</span> <span>dinner</span> <span>together.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 1, 7.08, 11.2, 'robbie, the dinner was terrific.', '罗比，这顿晚餐真是棒极了。', '/ˈrɑbi, ðə ˈdɪnər wəz təˈrɪfɪk/', '<span>robbie,</span> <span>the</span> <span>dinner</span> <span>was</span> <span>terrific.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 2, 11.2, 14.4, 'richard is upset about losing his camera bag.', '理查德因为丢失了相机包而很沮丧。', '/ˈrɪtʃərd ɪz ʌpˈsɛt əˈbaʊt ˈluzɪŋ hɪz ˈkæmərə bæɡ/', '<span>richard</span> <span>is</span> <span>upset</span> <span>about</span> <span>losing</span> <span>his</span> <span>camera</span> <span>bag.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 3, 14.4, 17.6, 'thinking about that bag of film.', '想着那袋胶卷的事。', '/ˈθɪŋkɪŋ əˈbaʊt ðæt bæɡ əv fɪlm/', '<span>thinking</span> <span>about</span> <span>that</span> <span>bag</span> <span>of</span> <span>film.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 4, 17.6, 22.48, 'and his mother, ellen, tries to help.', '他的母亲艾伦也试图提供帮助。', '/ənd hɪz ˈmʌðər, ˈɛlən, traɪz tə hɛlp/', '<span>and</span> <span>his</span> <span>mother,</span> <span>ellen,</span> <span>tries</span> <span>to</span> <span>help.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 5, 22.48, 23.8, 'don''t worry, richard.', '别担心，理查德。', '/doʊnt ˈwɜri, ˈrɪtʃərd/', '<span>don''t</span> <span>worry,</span> <span>richard.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 6, 23.8, 25.32, 'someone will find it.', '总会有人找到的。', '/ˈsʌmwʌn wɪl faɪnd ɪt/', '<span>someone</span> <span>will</span> <span>find</span> <span>it.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 7, 25.32, 28.96, 'then, the doorbell rings.', '这时，门铃响了。', '/ðɛn, ðə ˈdɔrbɛl rɪŋz/', '<span>then,</span> <span>the</span> <span>doorbell</span> <span>rings.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 8, 28.96, 32.28, 'who is at the door?', '谁在门口？', '/huː ɪz æt ðə dɔːr/', '<span>who</span> <span>is</span> <span>at</span> <span>the</span> <span>door?</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 9, 50.16, 53.92, 'and give her a teaspoon of the medicine after every meal.', '每餐后给她服用一茶匙这种药。', '/ænd ɡɪv hɜːr ə ˈtiːspuːn əv ðə ˈmɛdɪsɪn ˈæftər ˈɛvri miːl/', '<span>and</span> <span>give</span> <span>her</span> <span>a</span> <span>teaspoon</span> <span>of</span> <span>the</span> <span>medicine</span> <span>after</span> <span>every</span> <span>meal.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 10, 53.92, 56.76, 'don''t worry, she''ll be fine.', '别担心，她不会有事的。', '/doʊnt ˈwɜːri ʃiːl biː faɪn/', '<span>don''t</span> <span>worry,</span> <span>she''ll</span> <span>be</span> <span>fine.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 11, 56.76, 58.68, 'you''re welcome.', '不客气。', '/jʊr ˈwɛlkəm/', '<span>you''re</span> <span>welcome.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 12, 58.68, 61.2, 'goodbye.', '再见。', '/ɡʊdˈbaɪ/', '<span>goodbye.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 13, 71.04, 72.4, 'how are you?', '你怎么样？', '/haʊ ɑːr juː/', '<span>how</span> <span>are</span> <span>you?</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 14, 72.4, 73.92, 'i''m tired.', '我累了。', '/aɪm ˈtaɪərd/', '<span>i''m</span> <span>tired.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 15, 73.92, 74.76, 'i''m hungry.', '我饿了。', '/aɪm ˈhʌŋɡri/', '<span>i''m</span> <span>hungry.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 16, 74.76, 76.92, 'well, marilyn and richard called.', '嗯，玛丽莲和理查德打过电话来。', '/wɛl ˈmɛrəlɪn ənd ˈrɪtʃərd kɔld/', '<span>well,</span> <span>marilyn</span> <span>and</span> <span>richard</span> <span>called.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 17, 76.92, 79.2, 'they''ll be here soon, and then we''ll eat.', '他们很快就会到，到时我们就开始吃饭吧。', '/ðeɪl bi hɪr sun ənd ðɛn wil it/', '<span>they''ll</span> <span>be</span> <span>here</span> <span>soon,</span> <span>and</span> <span>then</span> <span>we''ll</span> <span>eat.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 18, 79.2, 79.76, 'all right.', '好吧。', '/ɔl raɪt/', '<span>all</span> <span>right.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 19, 79.76, 82.56, 'is is susan coming?', '苏珊要来了吗？', '/ɪz ɪz ˈsuzən ˈkʌmɪŋ/', '<span>is</span> <span>is</span> <span>susan</span> <span>coming?</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 20, 82.56, 83.56, 'no, she''ll be here later.', '不，她稍后会到这里。', '/noʊ ʃil bi hɪr ˈleɪtər/', '<span>no,</span> <span>she''ll</span> <span>be</span> <span>here</span> <span>later.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 21, 83.56, 85.32, 'she has to work late tonight.', '她今晚不得不加班到很晚。', '/ʃi hæz tə wɜrk leɪt təˈnaɪt/', '<span>she</span> <span>has</span> <span>to</span> <span>work</span> <span>late</span> <span>tonight.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 22, 85.32, 88.6, 'and what''s robbie cooking for dinner?', '罗比打算做些什么当晚餐呢？', '/ənd wʌts ˈrɑbi ˈkʊkɪŋ fər ˈdɪnər/', '<span>and</span> <span>what''s</span> <span>robbie</span> <span>cooking</span> <span>for</span> <span>dinner?</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 23, 88.6, 91.04, 'it''s a surprise.', '真是个惊喜。', '/ɪts ə sərˈpraɪz/', '<span>it''s</span> <span>a</span> <span>surprise.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 24, 91.04, 94.04, 'i hope it''s pasta.', '希望那是意大利面吧。', '/aɪ hoʊp ɪts ˈpɑːstə/', '<span>i</span> <span>hope</span> <span>it''s</span> <span>pasta.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 25, 97.0, 99.56, 'robbie, the dinner was terrific.', '罗比，这顿晚餐真是棒极了。', '/ˈrɑːbi ðə ˈdɪnər wəz təˈrɪfɪk/', '<span>robbie,</span> <span>the</span> <span>dinner</span> <span>was</span> <span>terrific.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 26, 99.56, 103.28, 'yes, it was delicious.', '是的，味道真不错。', '/jɛs ɪt wəz dɪˈlɪʃəs/', '<span>yes,</span> <span>it</span> <span>was</span> <span>delicious.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 27, 103.76, 105.68, 'what''s for dessert?', '甜点是什么？', '/wʌts fɔr dɪˈzɜːrt/', '<span>what''s</span> <span>for</span> <span>dessert?</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 28, 105.68, 108.96, 'i forgot dessert.', '我忘了吃甜点了。', '/aɪ fərˈɡɑːt dɪˈzɜːrt/', '<span>i</span> <span>forgot</span> <span>dessert.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 29, 109.44, 110.76, 'don''t worry.', '别担心。', '/doʊnt ˈwɜːri/', '<span>don''t</span> <span>worry.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 30, 110.76, 112.48, 'we''ve got lots of ice cream.', '我们有大量的冰淇淋。', '/wiːv ɡɑːt lɑːts əv aɪs kriːm/', '<span>we''ve</span> <span>got</span> <span>lots</span> <span>of</span> <span>ice</span> <span>cream.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 31, 112.48, 115.48, 'oh, i''d love some ice cream.', '哦，我想要些冰淇淋。', '/oʊ aɪd lʌv sʌm aɪs kriːm/', '<span>oh,</span> <span>i''d</span> <span>love</span> <span>some</span> <span>ice</span> <span>cream.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 32, 115.48, 120.76, 'well, there''s um chocolate and coffee and a little vanilla.', '嗯，有啊。 嗯，巧克力、咖啡，再加点香草味。', '/wɛl ðɛrz əm ˈtʃɔklət ənd ˈkɔfi ənd ə ˈlɪtl vəˈnɪlə/', '<span>well,</span> <span>there''s</span> <span>um</span> <span>chocolate</span> <span>and</span> <span>coffee</span> <span>and</span> <span>a</span> <span>little</span> <span>vanilla.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 33, 120.76, 122.0, 'i''ll have vanilla.', '我要香草味的。', '/aɪl hæv vəˈnɪlə/', '<span>i''ll</span> <span>have</span> <span>vanilla.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 34, 122.0, 123.84, 'is that all right with everyone?', '大家都没意见吧？', '/ɪz ðæt ɔl raɪt wɪð ˈɛvriwʌn/', '<span>is</span> <span>that</span> <span>all</span> <span>right</span> <span>with</span> <span>everyone?</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 35, 123.84, 124.76, 'i''ll have chocolate.', '我要巧克力。', '/aɪl hæv ˈtʃɔklət/', '<span>i''ll</span> <span>have</span> <span>chocolate.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 36, 124.76, 127.08, 'me, too.', '我也是。', '/mi tu/', '<span>me,</span> <span>too.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 37, 127.08, 133.32, 'um one scoop of coffee and one scoop of chocolate for me.', '请给我一勺咖啡和一勺巧克力。', '/əm wʌn skup əv ˈkɔfi ənd wʌn skup əv ˈtʃɔklət fɔr mi/', '<span>um</span> <span>one</span> <span>scoop</span> <span>of</span> <span>coffee</span> <span>and</span> <span>one</span> <span>scoop</span> <span>of</span> <span>chocolate</span> <span>for</span> <span>me.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 38, 133.48, 137.16, 'robbie, will you help me serve?', '罗比，你能帮我端菜吗？', '/ˈrɑbi wɪl ju hɛlp mi sɜrv/', '<span>robbie,</span> <span>will</span> <span>you</span> <span>help</span> <span>me</span> <span>serve?</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 39, 146.52, 150.0, 'i keep thinking about that bag of film.', '我一直在想着那袋胶卷的事。', '/aɪ kip ˈθɪŋkɪŋ əˈbaʊt ðæt bæɡ əv fɪlm/', '<span>i</span> <span>keep</span> <span>thinking</span> <span>about</span> <span>that</span> <span>bag</span> <span>of</span> <span>film.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 40, 150.0, 153.24, 'eight rolls, a whole day''s work.', '八卷纸，相当于一整天的工作量。', '/eɪt roʊlz ə hoʊl deɪz wɜːrk/', '<span>eight</span> <span>rolls,</span> <span>a</span> <span>whole</span> <span>day''s</span> <span>work.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 41, 153.24, 155.0, 'and good stuff, too.', '而且都是好东西。', '/ænd ɡʊd stʌf tuː/', '<span>and</span> <span>good</span> <span>stuff,</span> <span>too.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 42, 155.0, 156.28, 'don''t worry, richard.', '别担心，理查德。', '/doʊnt ˈwɜːri ˈrɪtʃərd/', '<span>don''t</span> <span>worry,</span> <span>richard.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 43, 156.28, 159.52, 'someone will find it.', '总会有人找到的。', '/ˈsʌmwʌn wɪl faɪnd ɪt/', '<span>someone</span> <span>will</span> <span>find</span> <span>it.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 44, 162.28, 164.96, 'i''ll get it.', '我会拿到的。', '/aɪl ɡɛt ɪt/', '<span>i''ll</span> <span>get</span> <span>it.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 45, 168.92, 170.08, 'hello.', '你好。', '/həˈloʊ/', '<span>hello.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 46, 170.08, 171.84, 'hello.', '你好。', '/həˈloʊ/', '<span>hello.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 47, 171.84, 173.88, 'does richard stewart live here?', '理查德·斯图尔特住在这里吗？', '/dʌz ˈrɪtʃərd ˈstuːərt lɪv hɪr/', '<span>does</span> <span>richard</span> <span>stewart</span> <span>live</span> <span>here?</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 48, 173.88, 176.2, 'yes, he''s my brother.', '是的，他是我哥哥。', '/jɛs, hiz maɪ ˈbrʌðər./', '<span>yes,</span> <span>he''s</span> <span>my</span> <span>brother.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 49, 176.2, 178.32, 'i''m robbie, robbie stewart.', '我是罗比，罗比·斯图尔特。', '/aɪm ˈrɑbi, ˈrɑbi ˈstuərt./', '<span>i''m</span> <span>robbie,</span> <span>robbie</span> <span>stewart.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 50, 178.32, 180.12, 'i''m alexandra pappas.', '我是亚历山德拉·帕帕斯。', '/aɪm ˌælɪɡˈzændrə ˈpæpəs./', '<span>i''m</span> <span>alexandra</span> <span>pappas.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 51, 180.12, 182.84, 'how do you do?', '您好！', '/haʊ duː juː duː?/', '<span>how</span> <span>do</span> <span>you</span> <span>do?</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 52, 182.92, 185.64, 'your brother left his bag of film on the ferry boat.', '你哥哥把装着胶卷的包忘在渡轮上了。', '/jɔr ˈbrʌðər lɛft hɪz bæɡ əv fɪlm ɑn ðə ˈfɛri boʊt./', '<span>your</span> <span>brother</span> <span>left</span> <span>his</span> <span>bag</span> <span>of</span> <span>film</span> <span>on</span> <span>the</span> <span>ferry</span> <span>boat.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 53, 185.64, 186.72, 'i found it.', '我找到它了。', '/aɪ faʊnd ɪt./', '<span>i</span> <span>found</span> <span>it.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 54, 186.72, 189.16, 'i''m really glad to see you.', '真高兴见到你。', '/aɪm ˈrɪli glæd tə siː juː./', '<span>i''m</span> <span>really</span> <span>glad</span> <span>to</span> <span>see</span> <span>you.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 55, 189.16, 192.84, 'i i mean, my brother will be really glad to see you.', '我的意思是，我哥哥见到你一定会很高兴的。', '/aɪ aɪ min, maɪ ˈbrʌðər wɪl bi ˈrɪli glæd tə siː juː./', '<span>i</span> <span>i</span> <span>mean,</span> <span>my</span> <span>brother</span> <span>will</span> <span>be</span> <span>really</span> <span>glad</span> <span>to</span> <span>see</span> <span>you.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 56, 192.84, 193.96, 'robbie?', '罗比？', '/ˈrɑbi/', '<span>robbie?</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 57, 193.96, 194.72, 'who is it?', '是谁啊？', '/hu ɪz ɪt/', '<span>who</span> <span>is</span> <span>it?</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 58, 194.72, 196.72, 'it''s richard''s film.', '这是理查德的电影。', '/ɪts ˈrɪtʃərdz fɪlm/', '<span>it''s</span> <span>richard''s</span> <span>film.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 59, 196.72, 200.24, 'i mean, alexandra pappas.', '我的意思是，亚历山德拉·帕帕斯。', '/aɪ min ˌælɪɡˈzændrə ˈpæpəs/', '<span>i</span> <span>mean,</span> <span>alexandra</span> <span>pappas.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 60, 200.24, 203.28, 'come in, please.', '请进吧。', '/kʌm ɪn pliz/', '<span>come</span> <span>in,</span> <span>please.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 61, 207.12, 208.2, 'alexandra!', '亚历山德拉！', '/ˌælɪɡˈzændrə/', '<span>alexandra!</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 62, 208.2, 209.36, 'hello, richard.', '你好，理查德。', '/həˈloʊ ˈrɪtʃərd/', '<span>hello,</span> <span>richard.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 63, 209.36, 210.88, 'i found your bag.', '我找到了你的包。', '/aɪ faʊnd jɔr bæɡ/', '<span>i</span> <span>found</span> <span>your</span> <span>bag.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 64, 210.88, 212.8, 'oh, thank you.', '哦，谢谢。', '/oʊ θæŋk juː/', '<span>oh,</span> <span>thank</span> <span>you.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 65, 212.8, 214.24, 'thank you.', '谢谢。', '/θæŋk juː/', '<span>thank</span> <span>you.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 66, 214.24, 216.24, 'um alexandra, let me introduce you.', '嗯，亚历山德拉，让我来介绍一下你吧。', '/əm ælɪɡˈzændrə lɛt miː ˌɪntrəˈduːs juː/', '<span>um</span> <span>alexandra,</span> <span>let</span> <span>me</span> <span>introduce</span> <span>you.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 67, 216.24, 217.88, 'this is my wife, marilyn.', '这是我妻子，玛丽莲。', '/ðɪs ɪz maɪ waɪf ˈmɛrɪlɪn/', '<span>this</span> <span>is</span> <span>my</span> <span>wife,</span> <span>marilyn.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 68, 217.88, 219.92, 'richard showed me your photo.', '理查德给我看了你的照片。', '/ˈrɪtʃərd ʃoʊd miː jʊər ˈfoʊtoʊ/', '<span>richard</span> <span>showed</span> <span>me</span> <span>your</span> <span>photo.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 69, 219.92, 220.72, 'how do you do?', '您好！', '/haʊ duː juː duː/', '<span>how</span> <span>do</span> <span>you</span> <span>do?</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 70, 220.72, 221.6, 'oh, yes.', '哦，是的。', '/oʊ jɛs/', '<span>oh,</span> <span>yes.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 71, 221.6, 223.12, 'richard told us all about you.', '理查德把关于你的所有事情都告诉了我们。', '/ˈrɪtʃərd toʊld ʌs ɔːl əˈbaʊt juː/', '<span>richard</span> <span>told</span> <span>us</span> <span>all</span> <span>about</span> <span>you.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 72, 223.12, 224.68, 'it''s nice to meet you.', '很高兴见到你。', '/ɪts naɪs tə miːt juː/', '<span>it''s</span> <span>nice</span> <span>to</span> <span>meet</span> <span>you.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 73, 224.68, 226.72, 'and this is my mother, ellen stewart.', '这是我母亲，埃伦·斯图尔特。', '/ænd ðɪs ɪz maɪ ˈmʌðər, ˈɛlən ˈstuːərt/', '<span>and</span> <span>this</span> <span>is</span> <span>my</span> <span>mother,</span> <span>ellen</span> <span>stewart.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 74, 226.72, 227.76, 'how do you do?', '您好！', '/haʊ duː juː duː/', '<span>how</span> <span>do</span> <span>you</span> <span>do?</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 75, 227.76, 229.08, 'and my father, dr.', '还有我的父亲，博士。', '/ænd maɪ ˈfɑːðər, ˈdɑːktər/', '<span>and</span> <span>my</span> <span>father,</span> <span>dr.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 76, 229.08, 230.2, 'philip stewart.', '菲利普·斯图尔特。', '/ˈfɪlɪp ˈstuːərt/', '<span>philip</span> <span>stewart.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 77, 230.2, 231.64, 'nice to meet you, alexandra.', '很高兴见到你，亚历山德拉。', '/naɪs tə miːt juː, ˌælɪɡˈzændrə/', '<span>nice</span> <span>to</span> <span>meet</span> <span>you,</span> <span>alexandra.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 78, 231.64, 233.04, 'and you met robbie.', '你还遇到了罗比。', '/ænd juː mɛt ˈrɑːbi/', '<span>and</span> <span>you</span> <span>met</span> <span>robbie.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 79, 233.04, 234.6, 'yes.', '是的。', '/jɛs/', '<span>yes.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 80, 234.6, 236.0, 'and you must be susan.', '你一定就是苏珊吧。', '/ænd ju mʌst bi ˈsuzən/', '<span>and</span> <span>you</span> <span>must</span> <span>be</span> <span>susan.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 81, 236.0, 236.56, 'hi.', '嗨。', '/haɪ/', '<span>hi.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 82, 236.56, 237.28, 'hi.', '嗨。', '/haɪ/', '<span>hi.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 83, 237.28, 238.0, 'welcome.', '欢迎。', '/ˈwɛlkəm/', '<span>welcome.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 84, 238.0, 242.08, 'i''m so glad you found the bag and took the time and trouble to return it.', '我很高兴你找到了那个包，并且还不厌其烦地把它送了回来。', '/aɪm soʊ glæd ju faʊnd ðə bæɡ ænd tʊk ðə taɪm ænd ˈtrʌbəl tə rɪˈtɜːrn ɪt/', '<span>i''m</span> <span>so</span> <span>glad</span> <span>you</span> <span>found</span> <span>the</span> <span>bag</span> <span>and</span> <span>took</span> <span>the</span> <span>time</span> <span>and</span> <span>trouble</span> <span>to</span> <span>return</span> <span>it.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 85, 242.08, 243.88, 'oh, it was no trouble.', '哦，没什么麻烦的。', '/oʊ ɪt wʌz noʊ ˈtrʌbəl/', '<span>oh,</span> <span>it</span> <span>was</span> <span>no</span> <span>trouble.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 86, 243.88, 245.96, 'i just took the wrong train.', '我坐错火车了。', '/aɪ dʒʌst tʊk ðə rɒŋ treɪn/', '<span>i</span> <span>just</span> <span>took</span> <span>the</span> <span>wrong</span> <span>train.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 87, 245.96, 247.4, 'would you like something to eat?', '你想吃点什么吗？', '/wʊd ju laɪk ˈsʌmθɪŋ tə iːt/', '<span>would</span> <span>you</span> <span>like</span> <span>something</span> <span>to</span> <span>eat?</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 88, 247.4, 248.8, 'thank you, no.', '谢谢，不用了。', '/θæŋk juː, noʊ./', '<span>thank</span> <span>you,</span> <span>no.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 89, 248.8, 250.52, 'i''m late for dinner at my house.', '我回家吃晚饭要迟到了。', '/aɪm leɪt fɔːr ˈdɪnər æt maɪ haʊs./', '<span>i''m</span> <span>late</span> <span>for</span> <span>dinner</span> <span>at</span> <span>my</span> <span>house.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 90, 250.52, 251.88, 'i really have to go.', '我真的得走了。', '/aɪ ˈrɪəli hæv tə goʊ./', '<span>i</span> <span>really</span> <span>have</span> <span>to</span> <span>go.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 91, 251.88, 253.84, 'would you like to call home?', '你想给家里打电话吗？', '/wʊd juː laɪk tə kɔːl hoʊm?/', '<span>would</span> <span>you</span> <span>like</span> <span>to</span> <span>call</span> <span>home?</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 92, 253.84, 255.4, 'i''d appreciate that.', '我会很感激的。', '/aɪd əˈpriːʃieɪt ðæt./', '<span>i''d</span> <span>appreciate</span> <span>that.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 93, 255.4, 257.0, 'please, use the phone.', '请使用电话吧。', '/pliːz, juːz ðə foʊn./', '<span>please,</span> <span>use</span> <span>the</span> <span>phone.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 94, 257.0, 257.56, 'thanks.', '谢谢。', '/θæŋks./', '<span>thanks.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 95, 257.56, 259.238, 'excuse me.', '打扰一下。', '/ɪkˈskjuːz miː./', '<span>excuse</span> <span>me.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 96, 259.238, 262.12, 'alexandra''s a high school exchange student from greece.', '亚历山德拉是来自希腊的高中交换生。', '/ˌælɪɡˈzændrəz ə haɪ skuːl ɪksˈtʃeɪndʒ ˈstuːdənt frəm ˈɡriːs/', '<span>alexandra''s</span> <span>a</span> <span>high</span> <span>school</span> <span>exchange</span> <span>student</span> <span>from</span> <span>greece.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 97, 262.12, 263.64, 'where does she live?', '她住在哪里？', '/wɛr dʌz ʃi lɪv/', '<span>where</span> <span>does</span> <span>she</span> <span>live?</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 98, 263.64, 265.48, 'with a family in the bronx.', '在布朗克斯有个家。', '/wɪð ə ˈfæməli ɪn ðə brɑːŋks/', '<span>with</span> <span>a</span> <span>family</span> <span>in</span> <span>the</span> <span>bronx.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 99, 265.48, 267.6, 'oh, that''s not too far from here.', '哦，那地方离这里不太远。', '/oʊ ðæts nɑːt tuː fɑːr frəm hɪr/', '<span>oh,</span> <span>that''s</span> <span>not</span> <span>too</span> <span>far</span> <span>from</span> <span>here.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 100, 267.6, 270.64, 'take it easy, robbie.', '放松点，罗比。', '/teɪk ɪt ˈiːzi ˈrɑːbi/', '<span>take</span> <span>it</span> <span>easy,</span> <span>robbie.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 101, 270.64, 271.72, 'thank you.', '谢谢。', '/θæŋk ju/', '<span>thank</span> <span>you.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 102, 271.72, 275.16, 'i can only stay a few minutes.', '我只能待几分钟而已。', '/aɪ kæn ˈoʊnli steɪ ə ˈfjuː ˈmɪnɪts/', '<span>i</span> <span>can</span> <span>only</span> <span>stay</span> <span>a</span> <span>few</span> <span>minutes.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 103, 275.16, 277.2, 'have some iced tea.', '来点冰茶吧。', '/hæv sʌm aɪs tiː/', '<span>have</span> <span>some</span> <span>iced</span> <span>tea.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 104, 277.2, 277.84, 'thanks, mrs.', '谢谢您，夫人。', '/θæŋks ˈmɪsɪz/', '<span>thanks,</span> <span>mrs.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 105, 277.84, 278.68, 'stewart.', '斯图尔特。', '/ˈstuːərt/', '<span>stewart.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 106, 278.68, 282.2, 'please, sit down, alexandra.', '请坐吧，亚历山德拉。', '/pliːz sɪt daʊn ˌælɪɡˈzændrə/', '<span>please,</span> <span>sit</span> <span>down,</span> <span>alexandra.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 107, 287.04, 289.92, 'so, you''re an exchange student.', '所以，你是一名交换生啊。', '/soʊ jər ən ɪksˈtʃeɪndʒ ˈstuːdənt/', '<span>so,</span> <span>you''re</span> <span>an</span> <span>exchange</span> <span>student.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 108, 289.92, 292.04, 'where do you go to school?', '你在哪里上学呢？', '/wɛr duː juː goʊ tuː skuːl/', '<span>where</span> <span>do</span> <span>you</span> <span>go</span> <span>to</span> <span>school?</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 109, 292.04, 294.08, 'at the bronx high school of science.', '在布朗克斯科学高中。', '/æt ðə brɑːŋks haɪ skuːl əv ˈsaɪəns/', '<span>at</span> <span>the</span> <span>bronx</span> <span>high</span> <span>school</span> <span>of</span> <span>science.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 110, 294.08, 297.08, 'oh, that''s a very good school.', '哦，那是一所非常好的学校。', '/oʊ ðæts ə ˈvɛri gʊd skuːl/', '<span>oh,</span> <span>that''s</span> <span>a</span> <span>very</span> <span>good</span> <span>school.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 111, 297.08, 298.96, 'what are your favorite subjects?', '你最喜欢的科目是什么？', '/wʌt ɑːr jɔːr ˈfeɪvərɪt ˈsʌbdʒɪkts/', '<span>what</span> <span>are</span> <span>your</span> <span>favorite</span> <span>subjects?</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 112, 298.96, 301.08, 'biology and mathematics.', '生物学与数学。', '/baɪˈɑːlədʒi ænd ˌmæθəˈmætɪks/', '<span>biology</span> <span>and</span> <span>mathematics.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 113, 301.08, 303.12, 'richard tells me you''re a doctor.', '理查德告诉我，你是一名医生。', '/ˈrɪtʃərd tɛlz miː jʊr ə ˈdɑːktər/', '<span>richard</span> <span>tells</span> <span>me</span> <span>you''re</span> <span>a</span> <span>doctor.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 114, 303.12, 305.16, 'yes, a pediatrician.', '是的，是一名儿科医生。', '/jɛs, ə ˌpiːdiəˈtrɪʃən/', '<span>yes,</span> <span>a</span> <span>pediatrician.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 115, 305.16, 306.96, 'and what does your father do?', '你父亲是做什么工作的呢？', '/ænd wʌt dʌz jʊr ˈfɑːðər duː/', '<span>and</span> <span>what</span> <span>does</span> <span>your</span> <span>father</span> <span>do?</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 116, 306.96, 308.88, 'he''s a lawyer in thessaloniki.', '他是塞萨洛尼基的一名律师。', '/hiz ə ˈlɔːjər ɪn ˌθɛsələˈniːki/', '<span>he''s</span> <span>a</span> <span>lawyer</span> <span>in</span> <span>thessaloniki.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 117, 308.88, 309.48, 'mm.', '嗯。', '/mm/', '<span>mm.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 118, 309.48, 310.72, 'would you like some pasta?', '你想来点意大利面吗？', '/wʊd juː laɪk sʌm ˈpɑːstə/', '<span>would</span> <span>you</span> <span>like</span> <span>some</span> <span>pasta?</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 119, 310.72, 312.44, 'i made it myself.', '这是我亲手制作的。', '/aɪ meɪd ɪt maɪˈsɛlf/', '<span>i</span> <span>made</span> <span>it</span> <span>myself.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 120, 312.44, 314.8, 'it might be a little cold.', '可能会有点冷。', '/ɪt maɪt bi ə ˈlɪtəl koʊld/', '<span>it</span> <span>might</span> <span>be</span> <span>a</span> <span>little</span> <span>cold.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 121, 314.8, 316.72, 'thanks, no.', '谢谢，不用了。', '/θæŋks, noʊ/', '<span>thanks,</span> <span>no.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 122, 316.72, 318.8, 'i do have to go.', '我确实得走了。', '/aɪ du hæv tə goʊ/', '<span>i</span> <span>do</span> <span>have</span> <span>to</span> <span>go.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 123, 318.8, 320.2, 'it was nice meeting you all.', '很高兴能和大家见面。', '/ɪt wʌz naɪs ˈmitɪŋ ju ɔl/', '<span>it</span> <span>was</span> <span>nice</span> <span>meeting</span> <span>you</span> <span>all.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 124, 320.2, 325.52, 'well, maybe you''ll come for lunch some sunday so we can really thank you for bringing richard''s bag back.', '嗯， 也许吧 某个周日你过来吃午饭吧，这样我们就能好好聚一聚了。 谢谢 感谢你带来的一切。 理查德的 包/袋子 后退。', '/wɛl, ˈmeɪbi jul kʌm fɔr lʌntʃ sʌm ˈsʌndeɪ soʊ wi kən ˈrɪli θæŋk ju fɔr ˈbrɪŋɪŋ ˈrɪtʃərdz bæg bæk/', '<span>well,</span> <span>maybe</span> <span>you''ll</span> <span>come</span> <span>for</span> <span>lunch</span> <span>some</span> <span>sunday</span> <span>so</span> <span>we</span> <span>can</span> <span>really</span> <span>thank</span> <span>you</span> <span>for</span> <span>bringing</span> <span>richard''s</span> <span>bag</span> <span>back.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 125, 325.52, 326.64, 'maybe.', '也许吧。', '/ˈmeɪbi/', '<span>maybe.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 126, 326.64, 328.36, 'you''re welcome, anytime.', '不客气，随时欢迎。', '/jʊr ˈwɛlkəm, ˈɛnitaɪm/', '<span>you''re</span> <span>welcome,</span> <span>anytime.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 127, 328.36, 331.08, 'goodbye.', '再见。', '/ɡʊdˈbaɪ/', '<span>goodbye.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 128, 335.96, 337.44, 'can i drive you home?', '我可以送你回家吗？', '/kæn aɪ draɪv juː hoʊm/', '<span>can</span> <span>i</span> <span>drive</span> <span>you</span> <span>home?</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 129, 337.44, 338.12, 'no, thanks.', '不用了，谢谢。', '/noʊ θæŋks/', '<span>no,</span> <span>thanks.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 130, 338.12, 339.4, 'the train is just up the street.', '火车就在街那头。', '/ðə treɪn ɪz dʒʌst ʌp ðə striːt/', '<span>the</span> <span>train</span> <span>is</span> <span>just</span> <span>up</span> <span>the</span> <span>street.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 131, 339.4, 341.28, 'it won''t take me long at all.', '用不了多长时间而已。', '/ɪt woʊnt teɪk miː lɔːŋ æt ɔːl/', '<span>it</span> <span>won''t</span> <span>take</span> <span>me</span> <span>long</span> <span>at</span> <span>all.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 132, 341.28, 344.28, 'you really saved the day for me, alexandra.', '你真的帮了我大忙，亚历山德拉。', '/juː ˈrɪli seɪvd ðə deɪ fɔːr miː ˌælɪɡˈzændrə/', '<span>you</span> <span>really</span> <span>saved</span> <span>the</span> <span>day</span> <span>for</span> <span>me,</span> <span>alexandra.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 133, 344.28, 344.92, 'bye.', '再见。', '/baɪ/', '<span>bye.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 134, 344.92, 345.52, 'bye-bye.', '再见了。', '/baɪ baɪ/', '<span>bye-bye.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 135, 345.52, 348.24, 'good night.', '晚安。', '/ɡʊd naɪt/', '<span>good</span> <span>night.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 136, 355.24, 358.64, 'she''s a smart young lady and very nice.', '她是个聪明又友善的年轻女士。', '/ʃiz ə smɑːrt jʌŋ ˈleɪdi ænd ˈvɛri naɪs/', '<span>she''s</span> <span>a</span> <span>smart</span> <span>young</span> <span>lady</span> <span>and</span> <span>very</span> <span>nice.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 137, 358.64, 360.88, 'very.', '非常。', '/ˈvɛri/', '<span>very.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 138, 360.88, 362.56, 'hey, she forgot her bag.', '嘿，她忘了带包。', '/heɪ ʃi fərˈɡɑːt hɜːr bæɡ/', '<span>hey,</span> <span>she</span> <span>forgot</span> <span>her</span> <span>bag.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 139, 362.56, 365.72, 'oh, i guess we''ll be seeing alexandra again.', '哦，看来我们还会再见到亚历山德拉的。', '/oʊ aɪ ɡɛs wiːl bi ˈsiːɪŋ ˌælɪɡˈzændrə əˈɡɛn/', '<span>oh,</span> <span>i</span> <span>guess</span> <span>we''ll</span> <span>be</span> <span>seeing</span> <span>alexandra</span> <span>again.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 140, 365.72, 368.48, 'right, robbie?', '对吧，罗比？', '/raɪt ˈrɑːbi/', '<span>right,</span> <span>robbie?</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 141, 384.52, 385.76, 'my name is richard stewart.', '我叫理查德·斯图尔特。', '/maɪ neɪm ɪz ˈrɪtʃərd ˈstuːərt/', '<span>my</span> <span>name</span> <span>is</span> <span>richard</span> <span>stewart.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 142, 385.76, 388.84, 'i''m a photographer.', '我是一名摄影师。', '/aɪm ə fəˈtɑːɡrəfər/', '<span>i''m</span> <span>a</span> <span>photographer.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 143, 389.96, 393.0, 'i''m martha van.', '我是玛莎·范。', '/aɪm ˈmɑːrθə væn/', '<span>i''m</span> <span>martha</span> <span>van.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 144, 394.56, 395.72, 'i''m richard.', '我是理查德。', '/aɪm ˈrɪtʃərd/', '<span>i''m</span> <span>richard.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 145, 395.72, 396.52, 'what''s your name?', '你叫什么名字？', '/wʌts jɔːr neɪm/', '<span>what''s</span> <span>your</span> <span>name?</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 146, 396.52, 399.4, 'sarah.', '莎拉。', '/ˈsɛrə/', '<span>sarah.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 147, 399.4, 400.52, 'by the way, i''m richard.', '顺便说一下，我叫理查德。', '/baɪ ðə weɪ aɪm ˈrɪtʃərd/', '<span>by</span> <span>the</span> <span>way,</span> <span>i''m</span> <span>richard.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 148, 400.52, 401.28, 'what''s your name?', '你叫什么名字？', '/wʌts jɔːr neɪm/', '<span>what''s</span> <span>your</span> <span>name?</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 149, 401.28, 404.16, 'alexandra.', '亚历山德拉。', '/ˌælɪɡˈzændrə/', '<span>alexandra.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 150, 413.52, 416.96, 'we live in california.', '我们住在加利福尼亚州。', '/wi lɪv ɪn ˌkælɪˈfɔːrnjə/', '<span>we</span> <span>live</span> <span>in</span> <span>california.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 151, 417.84, 419.28, 'are you from new york?', '你来自纽约吗？', '/ɑːr juː frəm nuː jɔːrk/', '<span>are</span> <span>you</span> <span>from</span> <span>new</span> <span>york?</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 152, 419.28, 422.56, 'no, i''m from greece.', '不，我来自希腊。', '/noʊ aɪm frəm griːs/', '<span>no,</span> <span>i''m</span> <span>from</span> <span>greece.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 153, 428.44, 430.56, 'i''m robbie, robbie stewart.', '我是罗比，罗比·斯图尔特。', '/aɪm ˈrɑbi ˈrɑbi ˈstuərt/', '<span>i''m</span> <span>robbie,</span> <span>robbie</span> <span>stewart.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 154, 430.56, 432.32, 'i''m alexandra pappas.', '我是亚历山德拉·帕帕斯。', '/aɪm ˌælɪɡˈzændrə ˈpæpəs/', '<span>i''m</span> <span>alexandra</span> <span>pappas.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 155, 432.32, 435.08, 'how do you do?', '您好！', '/haʊ də ju du/', '<span>how</span> <span>do</span> <span>you</span> <span>do?</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 156, 436.48, 437.84, 'alexandra, let me introduce you.', '亚历山德拉，让我来介绍一下你。', '/ˌælɪɡˈzændrə lɛt mi ˌɪntrəˈdus ju/', '<span>alexandra,</span> <span>let</span> <span>me</span> <span>introduce</span> <span>you.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 157, 437.84, 441.2, 'this is my wife, marilyn.', '这是我妻子，玛丽莲。', '/ðɪs ɪz maɪ waɪf ˈmɛrəlɪn/', '<span>this</span> <span>is</span> <span>my</span> <span>wife,</span> <span>marilyn.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 158, 441.4, 443.44, 'richard showed me your photo.', '理查德给我看了你的照片。', '/ˈrɪtʃərd ʃoʊd mi jɔr ˈfoʊtoʊ/', '<span>richard</span> <span>showed</span> <span>me</span> <span>your</span> <span>photo.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 159, 443.44, 446.16, 'how do you do?', '您好！', '/haʊ də ju du/', '<span>how</span> <span>do</span> <span>you</span> <span>do?</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 160, 446.16, 447.08, 'oh, yes.', '哦，是的。', '/oʊ jɛs/', '<span>oh,</span> <span>yes.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 161, 447.08, 448.6, 'richard told us all about you.', '理查德把关于你的所有事情都告诉了我们。', '/ˈrɪtʃərd toʊld ʌs ɔːl əˈbaʊt juː/', '<span>richard</span> <span>told</span> <span>us</span> <span>all</span> <span>about</span> <span>you.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 162, 448.6, 451.72, 'it''s nice to meet you.', '很高兴见到你。', '/ɪts naɪs tə miːt juː/', '<span>it''s</span> <span>nice</span> <span>to</span> <span>meet</span> <span>you.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 163, 452.08, 454.12, 'and this is my mother, ellen stewart.', '这是我母亲，埃伦·斯图尔特。', '/ænd ðɪs ɪz maɪ ˈmʌðər ˈɛlən ˈstuːərt/', '<span>and</span> <span>this</span> <span>is</span> <span>my</span> <span>mother,</span> <span>ellen</span> <span>stewart.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 164, 454.12, 456.88, 'how do you do?', '您好！', '/haʊ duː juː duː/', '<span>how</span> <span>do</span> <span>you</span> <span>do?</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 165, 457.12, 458.48, 'and my father, dr.', '还有我的父亲，博士。', '/ænd maɪ ˈfɑːðər ˈdɑːktər/', '<span>and</span> <span>my</span> <span>father,</span> <span>dr.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 166, 458.48, 459.6, 'philip stewart.', '菲利普·斯图尔特。', '/ˈfɪlɪp ˈstuːərt/', '<span>philip</span> <span>stewart.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 167, 459.6, 462.96, 'nice to meet you, alexandra.', '很高兴见到你，亚历山德拉。', '/naɪs tə miːt juː ˌælɪɡˈzændrə/', '<span>nice</span> <span>to</span> <span>meet</span> <span>you,</span> <span>alexandra.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 168, 463.04, 464.52, 'and you met robbie.', '你还遇到了罗比。', '/ænd juː mɛt ˈrɑbi/', '<span>and</span> <span>you</span> <span>met</span> <span>robbie.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 169, 464.52, 466.0, 'yes.', '是的。', '/jɛs/', '<span>yes.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 170, 466.0, 467.44, 'and you must be susan.', '你一定就是苏珊吧。', '/ænd juː mʌst biː ˈsuzən/', '<span>and</span> <span>you</span> <span>must</span> <span>be</span> <span>susan.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 171, 467.44, 467.96, 'hi.', '嗨。', '/haɪ/', '<span>hi.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 172, 467.96, 470.52, 'hi.', '嗨。', '/haɪ/', '<span>hi.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 173, 470.92, 471.92, 'it was nice meeting you all.', '很高兴能和大家见面。', '/ɪt wʌz naɪs ˈmitɪŋ juː ɔl/', '<span>it</span> <span>was</span> <span>nice</span> <span>meeting</span> <span>you</span> <span>all.</span>'
FROM episodes e WHERE e.video_id = 'HU7atRpOuXDCURA';

-- episode 218: f9EienS-MatNvZU
UPDATE user_word_lookups SET subtitle_id = NULL WHERE subtitle_id IN (SELECT s.id FROM subtitles s JOIN episodes e ON s.episode_id = e.id WHERE e.video_id = 'f9EienS-MatNvZU');
UPDATE user_vocabulary_items SET source_subtitle_id = NULL WHERE source_subtitle_id IN (SELECT s.id FROM subtitles s JOIN episodes e ON s.episode_id = e.id WHERE e.video_id = 'f9EienS-MatNvZU');
DELETE FROM user_subtitle_progress WHERE subtitle_id IN (SELECT s.id FROM subtitles s JOIN episodes e ON s.episode_id = e.id WHERE e.video_id = 'f9EienS-MatNvZU');
DELETE FROM user_subtitle_progress WHERE episode_id = (SELECT id FROM episodes WHERE video_id = 'f9EienS-MatNvZU');
DELETE FROM subtitles WHERE episode_id = (SELECT id FROM episodes WHERE video_id = 'f9EienS-MatNvZU');
DELETE FROM episode_tags WHERE episode_id = (SELECT id FROM episodes WHERE video_id = 'f9EienS-MatNvZU');
INSERT INTO episodes (
  index, video_id, short_title, summary, remark, stars, voca_size,
  subtitle_count, clip_length, cover, video_url, audio_url, thumbnail_url,
  original_video_url, author_id, series_id, series_index,
  submitted_by_user_id, rejection_reason,
  created_at, is_demo, status, published_at
) VALUES (
  218, 'f9EienS-MatNvZU', '第一集 - 李深初到美国纽约生活',
  '', '',
  1, 56, 33,
  59.84, 'http://oss.sxakgs.com/en/7LEXDSq6vpg/cover.webp',
  'http://oss.sxakgs.com/en/7LEXDSq6vpg/video.mp4', 'http://oss.sxakgs.com/en/7LEXDSq6vpg/audio.mp3',
  'http://oss.sxakgs.com/en/7LEXDSq6vpg/cover.webp', 'https://www.youtube.com/watch?v=7LEXDSq6vpg',
  (SELECT id FROM authors WHERE name = '润人巧记' AND accent = '美国' LIMIT 1),
  (SELECT id FROM episode_series WHERE slug = '华尔街英语-李深闯美' LIMIT 1), 1,
  NULL, NULL,
  '2026-07-13 16:19:13'::timestamp,
  FALSE, 'published',
  '2026-07-13 16:19:13'::timestamp
)
ON CONFLICT (video_id) DO UPDATE SET
  index = EXCLUDED.index,
  short_title = EXCLUDED.short_title,
  summary = EXCLUDED.summary,
  remark = EXCLUDED.remark,
  stars = EXCLUDED.stars,
  voca_size = EXCLUDED.voca_size,
  subtitle_count = EXCLUDED.subtitle_count,
  clip_length = EXCLUDED.clip_length,
  cover = EXCLUDED.cover,
  video_url = EXCLUDED.video_url,
  audio_url = EXCLUDED.audio_url,
  thumbnail_url = EXCLUDED.thumbnail_url,
  original_video_url = EXCLUDED.original_video_url,
  author_id = EXCLUDED.author_id,
  series_id = EXCLUDED.series_id,
  series_index = EXCLUDED.series_index,
  submitted_by_user_id = EXCLUDED.submitted_by_user_id,
  rejection_reason = EXCLUDED.rejection_reason,
  is_demo = EXCLUDED.is_demo,
  status = EXCLUDED.status,
  published_at = EXCLUDED.published_at;

INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 0, 1.36, 3.04, 'what''s your name?', '你叫什么名字？', '/wʌts jʊr neɪm/', '<span>what''s</span> <span>your</span> <span>name?</span>'
FROM episodes e WHERE e.video_id = 'f9EienS-MatNvZU';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 1, 3.04, 5.6, 'my name''s shen lee.', '我的名字是沈李。', '/maɪ neɪmz ʃɛn li/', '<span>my</span> <span>name''s</span> <span>shen</span> <span>lee.</span>'
FROM episodes e WHERE e.video_id = 'f9EienS-MatNvZU';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 2, 5.6, 6.4, 'shen.', '沈。', '/ʃɛn/', '<span>shen.</span>'
FROM episodes e WHERE e.video_id = 'f9EienS-MatNvZU';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 3, 6.4, 8.32, 'shen lee.', '沈李。', '/ʃɛn li/', '<span>shen</span> <span>lee.</span>'
FROM episodes e WHERE e.video_id = 'f9EienS-MatNvZU';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 4, 8.32, 10.4, 'can you spell shen lee?', '你能拼出“沈李”这两个字吗？', '/kæn ju spɛl ʃɛn li/', '<span>can</span> <span>you</span> <span>spell</span> <span>shen</span> <span>lee?</span>'
FROM episodes e WHERE e.video_id = 'f9EienS-MatNvZU';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 5, 10.4, 11.12, 'yes.', '是的。', '/jɛs/', '<span>yes.</span>'
FROM episodes e WHERE e.video_id = 'f9EienS-MatNvZU';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 6, 11.12, 13.12, 's h e n l i.', '沈莉。', '/ɛs eɪtʃ i ɛn ɛl aɪ/', '<span>s</span> <span>h</span> <span>e</span> <span>n</span> <span>l</span> <span>i.</span>'
FROM episodes e WHERE e.video_id = 'f9EienS-MatNvZU';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 7, 13.12, 14.639, 'shen lee.', '沈李。', '/ʃɛn li/', '<span>shen</span> <span>lee.</span>'
FROM episodes e WHERE e.video_id = 'f9EienS-MatNvZU';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 8, 14.639, 16.239, 'thank you.', '谢谢。', '/θæŋk juː/', '<span>thank</span> <span>you.</span>'
FROM episodes e WHERE e.video_id = 'f9EienS-MatNvZU';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 9, 16.239, 17.359, 'welcome to america, mr.', '欢迎来到美国，先生。', '/ˈwɛlkəm tə əˈmɛrɪkə, ˈmɪstər/', '<span>welcome</span> <span>to</span> <span>america,</span> <span>mr.</span>'
FROM episodes e WHERE e.video_id = 'f9EienS-MatNvZU';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 10, 17.359, 20.359, 'lee.', '李。', '/liː/', '<span>lee.</span>'
FROM episodes e WHERE e.video_id = 'f9EienS-MatNvZU';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 11, 22.56, 24.24, 'what''s your name?', '你叫什么名字？', '/wʌts jɔːr neɪm/', '<span>what''s</span> <span>your</span> <span>name?</span>'
FROM episodes e WHERE e.video_id = 'f9EienS-MatNvZU';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 12, 24.24, 26.8, 'my name''s shen lee.', '我的名字是沈李。', '/maɪ neɪmz ʃɛn liː/', '<span>my</span> <span>name''s</span> <span>shen</span> <span>lee.</span>'
FROM episodes e WHERE e.video_id = 'f9EienS-MatNvZU';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 13, 26.8, 27.599, 'shen.', '沈。', '/ʃɛn/', '<span>shen.</span>'
FROM episodes e WHERE e.video_id = 'f9EienS-MatNvZU';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 14, 27.599, 29.439, 'shen lee.', '沈李。', '/ʃɛn liː/', '<span>shen</span> <span>lee.</span>'
FROM episodes e WHERE e.video_id = 'f9EienS-MatNvZU';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 15, 29.439, 31.599, 'can you spell shen lee?', '你能拼出“沈李”这两个字吗？', '/kæn juː spɛl ʃɛn liː/', '<span>can</span> <span>you</span> <span>spell</span> <span>shen</span> <span>lee?</span>'
FROM episodes e WHERE e.video_id = 'f9EienS-MatNvZU';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 16, 31.599, 32.32, 'yes.', '是的。', '/jɛs/', '<span>yes.</span>'
FROM episodes e WHERE e.video_id = 'f9EienS-MatNvZU';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 17, 32.32, 34.239, 's h e n l i.', '申莉。', '/ɛs eɪtʃ iː ɛn ɛl aɪ/', '<span>s</span> <span>h</span> <span>e</span> <span>n</span> <span>l</span> <span>i.</span>'
FROM episodes e WHERE e.video_id = 'f9EienS-MatNvZU';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 18, 34.239, 35.76, 'shen lee.', '沈李。', '/ʃɛn liː/', '<span>shen</span> <span>lee.</span>'
FROM episodes e WHERE e.video_id = 'f9EienS-MatNvZU';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 19, 35.76, 37.44, 'thank you.', '谢谢。', '/θæŋk juː/', '<span>thank</span> <span>you.</span>'
FROM episodes e WHERE e.video_id = 'f9EienS-MatNvZU';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 20, 37.44, 38.48, 'welcome to america, mr.', '欢迎来到美国，先生。', '/ˈwɛlkəm tə əˈmɛrɪkə, ˈmɪstər/', '<span>welcome</span> <span>to</span> <span>america,</span> <span>mr.</span>'
FROM episodes e WHERE e.video_id = 'f9EienS-MatNvZU';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 21, 38.48, 41.48, 'lee.', '李。', '/liː/', '<span>lee.</span>'
FROM episodes e WHERE e.video_id = 'f9EienS-MatNvZU';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 22, 43.92, 45.6, 'what''s your name?', '你叫什么名字？', '/wʌts jɔːr neɪm/', '<span>what''s</span> <span>your</span> <span>name?</span>'
FROM episodes e WHERE e.video_id = 'f9EienS-MatNvZU';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 23, 45.6, 48.16, 'my name is shen lee.', '我的名字是沈李。', '/maɪ neɪm ɪz ʃɛn liː/', '<span>my</span> <span>name</span> <span>is</span> <span>shen</span> <span>lee.</span>'
FROM episodes e WHERE e.video_id = 'f9EienS-MatNvZU';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 24, 48.16, 48.96, 'shen.', '沈。', '/ʃɛn/', '<span>shen.</span>'
FROM episodes e WHERE e.video_id = 'f9EienS-MatNvZU';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 25, 48.96, 50.8, 'shen lee.', '沈李。', '/ʃɛn liː/', '<span>shen</span> <span>lee.</span>'
FROM episodes e WHERE e.video_id = 'f9EienS-MatNvZU';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 26, 50.8, 52.96, 'can you spell shen lee?', '你能拼出“沈李”这个名字吗？', '/kæn juː spɛl ʃɛn liː/', '<span>can</span> <span>you</span> <span>spell</span> <span>shen</span> <span>lee?</span>'
FROM episodes e WHERE e.video_id = 'f9EienS-MatNvZU';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 27, 52.96, 53.68, 'yes.', '是的。', '/jɛs/', '<span>yes.</span>'
FROM episodes e WHERE e.video_id = 'f9EienS-MatNvZU';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 28, 53.68, 55.6, 's h e n l i.', '申莉。', '/ɛs eɪtʃ iː ɛn ɛl aɪ/', '<span>s</span> <span>h</span> <span>e</span> <span>n</span> <span>l</span> <span>i.</span>'
FROM episodes e WHERE e.video_id = 'f9EienS-MatNvZU';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 29, 55.6, 57.12, 'shen lee.', '沈李。', '/ʃɛn liː/', '<span>shen</span> <span>lee.</span>'
FROM episodes e WHERE e.video_id = 'f9EienS-MatNvZU';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 30, 57.12, 58.719, 'thank you.', '谢谢。', '/θæŋk juː/', '<span>thank</span> <span>you.</span>'
FROM episodes e WHERE e.video_id = 'f9EienS-MatNvZU';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 31, 58.719, 59.84, 'welcome to america, mr.', '欢迎来到美国，先生。', '/ˈwɛlkəm tuː əˈmɛrɪkə, ˈmɪstər/', '<span>welcome</span> <span>to</span> <span>america,</span> <span>mr.</span>'
FROM episodes e WHERE e.video_id = 'f9EienS-MatNvZU';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 32, 59.84, 59.84, 'lee.', '李。', '/liː/', '<span>lee.</span>'
FROM episodes e WHERE e.video_id = 'f9EienS-MatNvZU';

-- episode 219: ouWRU5IZOyqaCDE
UPDATE user_word_lookups SET subtitle_id = NULL WHERE subtitle_id IN (SELECT s.id FROM subtitles s JOIN episodes e ON s.episode_id = e.id WHERE e.video_id = 'ouWRU5IZOyqaCDE');
UPDATE user_vocabulary_items SET source_subtitle_id = NULL WHERE source_subtitle_id IN (SELECT s.id FROM subtitles s JOIN episodes e ON s.episode_id = e.id WHERE e.video_id = 'ouWRU5IZOyqaCDE');
DELETE FROM user_subtitle_progress WHERE subtitle_id IN (SELECT s.id FROM subtitles s JOIN episodes e ON s.episode_id = e.id WHERE e.video_id = 'ouWRU5IZOyqaCDE');
DELETE FROM user_subtitle_progress WHERE episode_id = (SELECT id FROM episodes WHERE video_id = 'ouWRU5IZOyqaCDE');
DELETE FROM subtitles WHERE episode_id = (SELECT id FROM episodes WHERE video_id = 'ouWRU5IZOyqaCDE');
DELETE FROM episode_tags WHERE episode_id = (SELECT id FROM episodes WHERE video_id = 'ouWRU5IZOyqaCDE');
INSERT INTO episodes (
  index, video_id, short_title, summary, remark, stars, voca_size,
  subtitle_count, clip_length, cover, video_url, audio_url, thumbnail_url,
  original_video_url, author_id, series_id, series_index,
  submitted_by_user_id, rejection_reason,
  created_at, is_demo, status, published_at
) VALUES (
  219, 'ouWRU5IZOyqaCDE', '第二集 - 李深在美国纽约的英语生活交流',
  '李深是一个中国人，刚从中国来到美国工作生活，让我们跟随他的视角来美国纽约生活交流吧！', '',
  1, 0, 24,
  67.84, 'http://oss.sxakgs.com/en/psCcKyvDXT0/cover.webp',
  'http://oss.sxakgs.com/en/psCcKyvDXT0/video.mp4', 'http://oss.sxakgs.com/en/psCcKyvDXT0/audio.mp3',
  'http://oss.sxakgs.com/en/psCcKyvDXT0/cover.webp', 'https://www.youtube.com/watch?v=psCcKyvDXT0',
  (SELECT id FROM authors WHERE name = '润人巧记' AND accent = '美国' LIMIT 1),
  (SELECT id FROM episode_series WHERE slug = '华尔街英语-李深闯美' LIMIT 1), 2,
  NULL, NULL,
  '2026-07-13 16:23:02'::timestamp,
  FALSE, 'published',
  '2026-07-13 16:23:02'::timestamp
)
ON CONFLICT (video_id) DO UPDATE SET
  index = EXCLUDED.index,
  short_title = EXCLUDED.short_title,
  summary = EXCLUDED.summary,
  remark = EXCLUDED.remark,
  stars = EXCLUDED.stars,
  voca_size = EXCLUDED.voca_size,
  subtitle_count = EXCLUDED.subtitle_count,
  clip_length = EXCLUDED.clip_length,
  cover = EXCLUDED.cover,
  video_url = EXCLUDED.video_url,
  audio_url = EXCLUDED.audio_url,
  thumbnail_url = EXCLUDED.thumbnail_url,
  original_video_url = EXCLUDED.original_video_url,
  author_id = EXCLUDED.author_id,
  series_id = EXCLUDED.series_id,
  series_index = EXCLUDED.series_index,
  submitted_by_user_id = EXCLUDED.submitted_by_user_id,
  rejection_reason = EXCLUDED.rejection_reason,
  is_demo = EXCLUDED.is_demo,
  status = EXCLUDED.status,
  published_at = EXCLUDED.published_at;

INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 0, 0.0, 3.02, '[music]', '[音乐]', '/ˈmjuːzɪk/', '<span>[music]</span>'
FROM episodes e WHERE e.video_id = 'ouWRU5IZOyqaCDE';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 1, 8.639, 9.679, 'thank you.', '谢谢。', '/θæŋk juː/', '<span>thank</span> <span>you.</span>'
FROM episodes e WHERE e.video_id = 'ouWRU5IZOyqaCDE';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 2, 9.679, 11.92, 'you''re welcome.', '不客气。', '/jʊr ˈwɛlkəm/', '<span>you''re</span> <span>welcome.</span>'
FROM episodes e WHERE e.video_id = 'ouWRU5IZOyqaCDE';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 3, 11.92, 13.04, 'excuse me.', '打扰一下。', '/ɪkˈskjuːz miː/', '<span>excuse</span> <span>me.</span>'
FROM episodes e WHERE e.video_id = 'ouWRU5IZOyqaCDE';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 4, 13.04, 15.519, 'yes.', '是的。', '/jɛs/', '<span>yes.</span>'
FROM episodes e WHERE e.video_id = 'ouWRU5IZOyqaCDE';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 5, 15.519, 18.24, 'it''s my home.', '这是我的家。', '/ɪts maɪ hoʊm/', '<span>it''s</span> <span>my</span> <span>home.</span>'
FROM episodes e WHERE e.video_id = 'ouWRU5IZOyqaCDE';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 6, 18.24, 20.64, 'yes, it''s your home.', '没错，这是你的家。', '/jɛs ɪts jʊr hoʊm/', '<span>yes,</span> <span>it''s</span> <span>your</span> <span>home.</span>'
FROM episodes e WHERE e.video_id = 'ouWRU5IZOyqaCDE';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 7, 20.64, 21.76, 'thank you.', '谢谢。', '/θæŋk juː/', '<span>thank</span> <span>you.</span>'
FROM episodes e WHERE e.video_id = 'ouWRU5IZOyqaCDE';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 8, 21.76, 25.0, 'you''re welcome.', '不客气。', '/jɔːr ˈwɛlkəm/', '<span>you''re</span> <span>welcome.</span>'
FROM episodes e WHERE e.video_id = 'ouWRU5IZOyqaCDE';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 9, 31.76, 32.8, 'thank you.', '谢谢。', '/θæŋk juː/', '<span>thank</span> <span>you.</span>'
FROM episodes e WHERE e.video_id = 'ouWRU5IZOyqaCDE';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 10, 32.8, 35.12, 'you''re welcome.', '不客气。', '/jɔːr ˈwɛlkəm/', '<span>you''re</span> <span>welcome.</span>'
FROM episodes e WHERE e.video_id = 'ouWRU5IZOyqaCDE';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 11, 35.12, 36.239, 'excuse me.', '打扰一下。', '/ɪkˈskjuːz miː/', '<span>excuse</span> <span>me.</span>'
FROM episodes e WHERE e.video_id = 'ouWRU5IZOyqaCDE';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 12, 36.239, 38.719, 'yes.', '是的。', '/jɛs/', '<span>yes.</span>'
FROM episodes e WHERE e.video_id = 'ouWRU5IZOyqaCDE';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 13, 38.719, 41.44, 'it''s my home.', '这是我的家。', '/ɪts maɪ hoʊm/', '<span>it''s</span> <span>my</span> <span>home.</span>'
FROM episodes e WHERE e.video_id = 'ouWRU5IZOyqaCDE';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 14, 41.44, 43.84, 'yes, it''s your home.', '没错，这是你的家。', '/jɛs ɪts jɔːr hoʊm/', '<span>yes,</span> <span>it''s</span> <span>your</span> <span>home.</span>'
FROM episodes e WHERE e.video_id = 'ouWRU5IZOyqaCDE';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 15, 43.84, 44.96, 'thank you.', '谢谢。', '/θæŋk juː/', '<span>thank</span> <span>you.</span>'
FROM episodes e WHERE e.video_id = 'ouWRU5IZOyqaCDE';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 16, 44.96, 48.2, 'you''re welcome.', '不客气。', '/jʊr ˈwɛlkəm/', '<span>you''re</span> <span>welcome.</span>'
FROM episodes e WHERE e.video_id = 'ouWRU5IZOyqaCDE';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 17, 54.48, 55.44, 'thank you.', '谢谢。', '/θæŋk juː/', '<span>thank</span> <span>you.</span>'
FROM episodes e WHERE e.video_id = 'ouWRU5IZOyqaCDE';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 18, 55.44, 57.76, 'you''re welcome.', '不客气。', '/jʊr ˈwɛlkəm/', '<span>you''re</span> <span>welcome.</span>'
FROM episodes e WHERE e.video_id = 'ouWRU5IZOyqaCDE';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 19, 57.76, 58.879, 'excuse me.', '打扰一下。', '/ɪkˈskjuːz miː/', '<span>excuse</span> <span>me.</span>'
FROM episodes e WHERE e.video_id = 'ouWRU5IZOyqaCDE';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 20, 58.879, 64.08, 'yes, it''s my home.', '没错， 这是我的家。', '/jɛs ɪts maɪ hoʊm/', '<span>yes,</span> <span>it''s</span> <span>my</span> <span>home.</span>'
FROM episodes e WHERE e.video_id = 'ouWRU5IZOyqaCDE';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 21, 64.08, 66.479, 'yes, it''s your home.', '没错，这是你的家。', '/jɛs ɪts jʊr hoʊm/', '<span>yes,</span> <span>it''s</span> <span>your</span> <span>home.</span>'
FROM episodes e WHERE e.video_id = 'ouWRU5IZOyqaCDE';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 22, 66.479, 67.6, 'thank you.', '谢谢。', '/θæŋk juː/', '<span>thank</span> <span>you.</span>'
FROM episodes e WHERE e.video_id = 'ouWRU5IZOyqaCDE';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 23, 67.6, 67.84, 'you''re welcome.', '不客气。', '/jʊr ˈwɛlkəm/', '<span>you''re</span> <span>welcome.</span>'
FROM episodes e WHERE e.video_id = 'ouWRU5IZOyqaCDE';

-- episode 220: -ivVMCWegdd1WT8
UPDATE user_word_lookups SET subtitle_id = NULL WHERE subtitle_id IN (SELECT s.id FROM subtitles s JOIN episodes e ON s.episode_id = e.id WHERE e.video_id = '-ivVMCWegdd1WT8');
UPDATE user_vocabulary_items SET source_subtitle_id = NULL WHERE source_subtitle_id IN (SELECT s.id FROM subtitles s JOIN episodes e ON s.episode_id = e.id WHERE e.video_id = '-ivVMCWegdd1WT8');
DELETE FROM user_subtitle_progress WHERE subtitle_id IN (SELECT s.id FROM subtitles s JOIN episodes e ON s.episode_id = e.id WHERE e.video_id = '-ivVMCWegdd1WT8');
DELETE FROM user_subtitle_progress WHERE episode_id = (SELECT id FROM episodes WHERE video_id = '-ivVMCWegdd1WT8');
DELETE FROM subtitles WHERE episode_id = (SELECT id FROM episodes WHERE video_id = '-ivVMCWegdd1WT8');
DELETE FROM episode_tags WHERE episode_id = (SELECT id FROM episodes WHERE video_id = '-ivVMCWegdd1WT8');
INSERT INTO episodes (
  index, video_id, short_title, summary, remark, stars, voca_size,
  subtitle_count, clip_length, cover, video_url, audio_url, thumbnail_url,
  original_video_url, author_id, series_id, series_index,
  submitted_by_user_id, rejection_reason,
  created_at, is_demo, status, published_at
) VALUES (
  220, '-ivVMCWegdd1WT8', '第三集 - 在美剧里找自己的英语环境',
  '', '',
  1, 5, 37,
  119.439, 'http://oss.sxakgs.com/en/hgHUgZZRvYc/cover.webp',
  'http://oss.sxakgs.com/en/hgHUgZZRvYc/video.mp4', 'http://oss.sxakgs.com/en/hgHUgZZRvYc/audio.mp3',
  'http://oss.sxakgs.com/en/hgHUgZZRvYc/cover.webp', 'https://www.youtube.com/watch?v=hgHUgZZRvYc',
  (SELECT id FROM authors WHERE name = '润人巧记' AND accent = '美国' LIMIT 1),
  (SELECT id FROM episode_series WHERE slug = '华尔街英语-李深闯美' LIMIT 1), 3,
  NULL, NULL,
  '2026-07-13 16:30:14'::timestamp,
  FALSE, 'published',
  '2026-07-13 16:30:14'::timestamp
)
ON CONFLICT (video_id) DO UPDATE SET
  index = EXCLUDED.index,
  short_title = EXCLUDED.short_title,
  summary = EXCLUDED.summary,
  remark = EXCLUDED.remark,
  stars = EXCLUDED.stars,
  voca_size = EXCLUDED.voca_size,
  subtitle_count = EXCLUDED.subtitle_count,
  clip_length = EXCLUDED.clip_length,
  cover = EXCLUDED.cover,
  video_url = EXCLUDED.video_url,
  audio_url = EXCLUDED.audio_url,
  thumbnail_url = EXCLUDED.thumbnail_url,
  original_video_url = EXCLUDED.original_video_url,
  author_id = EXCLUDED.author_id,
  series_id = EXCLUDED.series_id,
  series_index = EXCLUDED.series_index,
  submitted_by_user_id = EXCLUDED.submitted_by_user_id,
  rejection_reason = EXCLUDED.rejection_reason,
  is_demo = EXCLUDED.is_demo,
  status = EXCLUDED.status,
  published_at = EXCLUDED.published_at;

INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 0, 1.52, 4.72, 'benny king.', '本尼·金。', '/ˈbɛni kɪŋ/', '<span>benny</span> <span>king.</span>'
FROM episodes e WHERE e.video_id = '-ivVMCWegdd1WT8';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 1, 4.72, 18.92, 'a b c d e f g h i j k king. a b c d e f g h i j k king.', '', '/eɪ bi si di i ɛf dʒi eɪtʃ aɪ dʒeɪ keɪ kɪŋ. eɪ bi si di i ɛf dʒi eɪtʃ aɪ dʒeɪ keɪ kɪŋ/', '<span>a</span> <span>b</span> <span>c</span> <span>d</span> <span>e</span> <span>f</span> <span>g</span> <span>h</span> <span>i</span> <span>j</span> <span>k</span> <span>king.</span> <span>a</span> <span>b</span> <span>c</span> <span>d</span> <span>e</span> <span>f</span> <span>g</span> <span>h</span> <span>i</span> <span>j</span> <span>k</span> <span>king.</span>'
FROM episodes e WHERE e.video_id = '-ivVMCWegdd1WT8';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 2, 20.32, 21.6, 'excuse me.', '打扰一下。', '/ɪkˈskjuz mi/', '<span>excuse</span> <span>me.</span>'
FROM episodes e WHERE e.video_id = '-ivVMCWegdd1WT8';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 3, 21.6, 22.64, 'yes.', '是的。', '/jɛs/', '<span>yes.</span>'
FROM episodes e WHERE e.video_id = '-ivVMCWegdd1WT8';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 4, 22.64, 23.92, 'my name is shen.', '我的名字是沈。', '/maɪ neɪm ɪz ʃɛn/', '<span>my</span> <span>name</span> <span>is</span> <span>shen.</span>'
FROM episodes e WHERE e.video_id = '-ivVMCWegdd1WT8';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 5, 23.92, 25.279, 'what''s your name?', '你叫什么名字？', '/wʌts jɔːr neɪm/', '<span>what''s</span> <span>your</span> <span>name?</span>'
FROM episodes e WHERE e.video_id = '-ivVMCWegdd1WT8';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 6, 25.279, 26.72, 'my name is steve.', '我的名字是史蒂夫。', '/maɪ neɪm ɪz stiv/', '<span>my</span> <span>name</span> <span>is</span> <span>steve.</span>'
FROM episodes e WHERE e.video_id = '-ivVMCWegdd1WT8';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 7, 26.72, 28.48, 'hi, steve.', '嗨，史蒂夫。', '/haɪ stiv/', '<span>hi,</span> <span>steve.</span>'
FROM episodes e WHERE e.video_id = '-ivVMCWegdd1WT8';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 8, 28.48, 32.119, 'it''s my home.', '这是我的家。', '/ɪts maɪ hoʊm/', '<span>it''s</span> <span>my</span> <span>home.</span>'
FROM episodes e WHERE e.video_id = '-ivVMCWegdd1WT8';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 9, 34.559, 35.44, 'sorry.', '抱歉。', '/ˈsɑri/', '<span>sorry.</span>'
FROM episodes e WHERE e.video_id = '-ivVMCWegdd1WT8';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 10, 35.44, 36.8, 'it''s okay.', '没关系。', '/ɪts oʊˈkeɪ/', '<span>it''s</span> <span>okay.</span>'
FROM episodes e WHERE e.video_id = '-ivVMCWegdd1WT8';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 11, 36.8, 38.719, 'your home.', '你的家。', '/jɔr hoʊm/', '<span>your</span> <span>home.</span>'
FROM episodes e WHERE e.video_id = '-ivVMCWegdd1WT8';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 12, 38.719, 44.879, 'thank you, benny king.', '谢谢你，本尼·金。', '/θæŋk ju ˈbɛni kɪŋ/', '<span>thank</span> <span>you,</span> <span>benny</span> <span>king.</span>'
FROM episodes e WHERE e.video_id = '-ivVMCWegdd1WT8';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 13, 44.879, 59.16, 'a b c d e f g h i j k king. a b c d e f g h i j k king.', '', '/eɪ bi si di i ɛf dʒi eɪtʃ aɪ dʒeɪ keɪ kɪŋ. eɪ bi si di i ɛf dʒi eɪtʃ aɪ dʒeɪ keɪ kɪŋ/', '<span>a</span> <span>b</span> <span>c</span> <span>d</span> <span>e</span> <span>f</span> <span>g</span> <span>h</span> <span>i</span> <span>j</span> <span>k</span> <span>king.</span> <span>a</span> <span>b</span> <span>c</span> <span>d</span> <span>e</span> <span>f</span> <span>g</span> <span>h</span> <span>i</span> <span>j</span> <span>k</span> <span>king.</span>'
FROM episodes e WHERE e.video_id = '-ivVMCWegdd1WT8';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 14, 60.559, 61.76, 'excuse me.', '打扰一下。', '/ɪkˈskjuz mi/', '<span>excuse</span> <span>me.</span>'
FROM episodes e WHERE e.video_id = '-ivVMCWegdd1WT8';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 15, 61.76, 62.8, 'yes.', '是的。', '/jɛs/', '<span>yes.</span>'
FROM episodes e WHERE e.video_id = '-ivVMCWegdd1WT8';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 16, 62.8, 64.159, 'my name is shen.', '我的名字叫沈。', '/maɪ neɪm ɪz ʃɛn/', '<span>my</span> <span>name</span> <span>is</span> <span>shen.</span>'
FROM episodes e WHERE e.video_id = '-ivVMCWegdd1WT8';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 17, 64.159, 65.438, 'what''s your name?', '你叫什么名字？', '/wʌts jʊr neɪm/', '<span>what''s</span> <span>your</span> <span>name?</span>'
FROM episodes e WHERE e.video_id = '-ivVMCWegdd1WT8';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 18, 65.438, 66.88, 'my name is steve.', '我的名字叫史蒂夫。', '/maɪ neɪm ɪz stiv/', '<span>my</span> <span>name</span> <span>is</span> <span>steve.</span>'
FROM episodes e WHERE e.video_id = '-ivVMCWegdd1WT8';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 19, 66.88, 68.72, 'hi, steve.', '嗨，史蒂夫。', '/haɪ stiv/', '<span>hi,</span> <span>steve.</span>'
FROM episodes e WHERE e.video_id = '-ivVMCWegdd1WT8';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 20, 68.72, 72.36, 'it''s my home.', '这是我的家。', '/ɪts maɪ hoʊm/', '<span>it''s</span> <span>my</span> <span>home.</span>'
FROM episodes e WHERE e.video_id = '-ivVMCWegdd1WT8';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 21, 74.72, 75.68, 'sorry.', '对不起。', '/ˈsɑri/', '<span>sorry.</span>'
FROM episodes e WHERE e.video_id = '-ivVMCWegdd1WT8';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 22, 75.68, 77.04, 'it''s okay.', '没关系。', '/ɪts oʊˈkeɪ/', '<span>it''s</span> <span>okay.</span>'
FROM episodes e WHERE e.video_id = '-ivVMCWegdd1WT8';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 23, 77.04, 78.96, 'you''re home.', '你回家了。', '/jʊr hoʊm/', '<span>you''re</span> <span>home.</span>'
FROM episodes e WHERE e.video_id = '-ivVMCWegdd1WT8';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 24, 78.96, 85.2, 'thank you, benny king.', '谢谢你， 本尼·金。', '/θæŋk juː ˈbɛni kɪŋ/', '<span>thank</span> <span>you,</span> <span>benny</span> <span>king.</span>'
FROM episodes e WHERE e.video_id = '-ivVMCWegdd1WT8';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 25, 85.2, 100.799, 'a b c d e f g h i j k king. a b c d e f g h i j k king.', '', '/eɪ biː siː diː iː ɛf dʒiː eɪtʃ aɪ dʒeɪ keɪ kɪŋ. eɪ biː siː diː iː ɛf dʒiː eɪtʃ aɪ dʒeɪ keɪ kɪŋ/', '<span>a</span> <span>b</span> <span>c</span> <span>d</span> <span>e</span> <span>f</span> <span>g</span> <span>h</span> <span>i</span> <span>j</span> <span>k</span> <span>king.</span> <span>a</span> <span>b</span> <span>c</span> <span>d</span> <span>e</span> <span>f</span> <span>g</span> <span>h</span> <span>i</span> <span>j</span> <span>k</span> <span>king.</span>'
FROM episodes e WHERE e.video_id = '-ivVMCWegdd1WT8';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 26, 100.799, 102.0, 'excuse me.', '打扰一下。', '/ɪkˈskjuːz miː/', '<span>excuse</span> <span>me.</span>'
FROM episodes e WHERE e.video_id = '-ivVMCWegdd1WT8';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 27, 102.0, 103.04, 'yes.', '是的。', '/jɛs/', '<span>yes.</span>'
FROM episodes e WHERE e.video_id = '-ivVMCWegdd1WT8';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 28, 103.04, 104.4, 'my name is shen.', '我的名字叫沈。', '/maɪ neɪm ɪz ʃɛn/', '<span>my</span> <span>name</span> <span>is</span> <span>shen.</span>'
FROM episodes e WHERE e.video_id = '-ivVMCWegdd1WT8';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 29, 104.4, 105.68, 'what''s your name?', '你叫什么名字？', '/wʌts jɔːr neɪm/', '<span>what''s</span> <span>your</span> <span>name?</span>'
FROM episodes e WHERE e.video_id = '-ivVMCWegdd1WT8';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 30, 105.68, 107.119, 'my name is steve.', '我的名字叫史蒂夫。', '/maɪ neɪm ɪz stiːv/', '<span>my</span> <span>name</span> <span>is</span> <span>steve.</span>'
FROM episodes e WHERE e.video_id = '-ivVMCWegdd1WT8';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 31, 107.119, 108.96, 'hi, steve.', '嗨，史蒂夫。', '/haɪ stiːv/', '<span>hi,</span> <span>steve.</span>'
FROM episodes e WHERE e.video_id = '-ivVMCWegdd1WT8';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 32, 108.96, 112.6, 'it''s my home.', '这是我的家。', '/ɪts maɪ hoʊm/', '<span>it''s</span> <span>my</span> <span>home.</span>'
FROM episodes e WHERE e.video_id = '-ivVMCWegdd1WT8';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 33, 114.96, 115.92, 'sorry.', '抱歉。', '/ˈsɑri/', '<span>sorry.</span>'
FROM episodes e WHERE e.video_id = '-ivVMCWegdd1WT8';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 34, 115.92, 117.28, 'it''s okay.', '没关系。', '/ɪts oʊˈkeɪ/', '<span>it''s</span> <span>okay.</span>'
FROM episodes e WHERE e.video_id = '-ivVMCWegdd1WT8';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 35, 117.28, 119.2, 'your home.', '你的家。', '/jɔr hoʊm/', '<span>your</span> <span>home.</span>'
FROM episodes e WHERE e.video_id = '-ivVMCWegdd1WT8';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 36, 119.2, 119.439, 'thank you.', '谢谢。', '/θæŋk ju/', '<span>thank</span> <span>you.</span>'
FROM episodes e WHERE e.video_id = '-ivVMCWegdd1WT8';

-- episode 221: 5JoJwDJ8s3whUZ0
UPDATE user_word_lookups SET subtitle_id = NULL WHERE subtitle_id IN (SELECT s.id FROM subtitles s JOIN episodes e ON s.episode_id = e.id WHERE e.video_id = '5JoJwDJ8s3whUZ0');
UPDATE user_vocabulary_items SET source_subtitle_id = NULL WHERE source_subtitle_id IN (SELECT s.id FROM subtitles s JOIN episodes e ON s.episode_id = e.id WHERE e.video_id = '5JoJwDJ8s3whUZ0');
DELETE FROM user_subtitle_progress WHERE subtitle_id IN (SELECT s.id FROM subtitles s JOIN episodes e ON s.episode_id = e.id WHERE e.video_id = '5JoJwDJ8s3whUZ0');
DELETE FROM user_subtitle_progress WHERE episode_id = (SELECT id FROM episodes WHERE video_id = '5JoJwDJ8s3whUZ0');
DELETE FROM subtitles WHERE episode_id = (SELECT id FROM episodes WHERE video_id = '5JoJwDJ8s3whUZ0');
DELETE FROM episode_tags WHERE episode_id = (SELECT id FROM episodes WHERE video_id = '5JoJwDJ8s3whUZ0');
INSERT INTO episodes (
  index, video_id, short_title, summary, remark, stars, voca_size,
  subtitle_count, clip_length, cover, video_url, audio_url, thumbnail_url,
  original_video_url, author_id, series_id, series_index,
  submitted_by_user_id, rejection_reason,
  created_at, is_demo, status, published_at
) VALUES (
  221, '5JoJwDJ8s3whUZ0', '第四集 - 纽约生活实用英语',
  '', '',
  1, 5, 42,
  129.119, 'http://oss.sxakgs.com/en/yX3TzacD0Og/cover.webp',
  'http://oss.sxakgs.com/en/yX3TzacD0Og/video.mp4', 'http://oss.sxakgs.com/en/yX3TzacD0Og/audio.mp3',
  'http://oss.sxakgs.com/en/yX3TzacD0Og/cover.webp', 'https://www.youtube.com/watch?v=yX3TzacD0Og',
  (SELECT id FROM authors WHERE name = '润人巧记' AND accent = '美国' LIMIT 1),
  (SELECT id FROM episode_series WHERE slug = '华尔街英语-李深闯美' LIMIT 1), 4,
  NULL, NULL,
  '2026-07-13 16:33:09'::timestamp,
  FALSE, 'published',
  '2026-07-13 16:33:09'::timestamp
)
ON CONFLICT (video_id) DO UPDATE SET
  index = EXCLUDED.index,
  short_title = EXCLUDED.short_title,
  summary = EXCLUDED.summary,
  remark = EXCLUDED.remark,
  stars = EXCLUDED.stars,
  voca_size = EXCLUDED.voca_size,
  subtitle_count = EXCLUDED.subtitle_count,
  clip_length = EXCLUDED.clip_length,
  cover = EXCLUDED.cover,
  video_url = EXCLUDED.video_url,
  audio_url = EXCLUDED.audio_url,
  thumbnail_url = EXCLUDED.thumbnail_url,
  original_video_url = EXCLUDED.original_video_url,
  author_id = EXCLUDED.author_id,
  series_id = EXCLUDED.series_id,
  series_index = EXCLUDED.series_index,
  submitted_by_user_id = EXCLUDED.submitted_by_user_id,
  rejection_reason = EXCLUDED.rejection_reason,
  is_demo = EXCLUDED.is_demo,
  status = EXCLUDED.status,
  published_at = EXCLUDED.published_at;

INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 0, 2.639, 14.559, 'a b c d e f g h i j k yes.', 'a b c d e f g h i j k 是的。', '/eɪ biː siː diː iː ɛf dʒiː eɪtʃ aɪ dʒeɪ keɪ jɛs/', '<span>a</span> <span>b</span> <span>c</span> <span>d</span> <span>e</span> <span>f</span> <span>g</span> <span>h</span> <span>i</span> <span>j</span> <span>k</span> <span>yes.</span>'
FROM episodes e WHERE e.video_id = '5JoJwDJ8s3whUZ0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 1, 14.559, 15.36, 'king.', '国王。', '/kɪŋ/', '<span>king.</span>'
FROM episodes e WHERE e.video_id = '5JoJwDJ8s3whUZ0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 2, 15.36, 17.68, 'oh, please excuse me.', '哦，请原谅我。', '/oʊ pliːz ɪkˈskjuːz miː/', '<span>oh,</span> <span>please</span> <span>excuse</span> <span>me.</span>'
FROM episodes e WHERE e.video_id = '5JoJwDJ8s3whUZ0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 3, 17.68, 20.8, 'i''m sorry.', '对不起。', '/aɪm ˈsɑri/', '<span>i''m</span> <span>sorry.</span>'
FROM episodes e WHERE e.video_id = '5JoJwDJ8s3whUZ0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 4, 20.8, 22.4, 'my name is shen.', '我的名字是沈。', '/maɪ neɪm ɪz ʃɛn/', '<span>my</span> <span>name</span> <span>is</span> <span>shen.</span>'
FROM episodes e WHERE e.video_id = '5JoJwDJ8s3whUZ0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 5, 22.4, 24.8, 'my name is sophie puna.', '我的名字是索菲·普纳。', '/maɪ neɪm ɪz ˈsoʊfi ˈpunə/', '<span>my</span> <span>name</span> <span>is</span> <span>sophie</span> <span>puna.</span>'
FROM episodes e WHERE e.video_id = '5JoJwDJ8s3whUZ0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 6, 24.8, 26.56, 'sophie pura.', '索菲·普拉。', '/ˈsoʊfi ˈpʊrə/', '<span>sophie</span> <span>pura.</span>'
FROM episodes e WHERE e.video_id = '5JoJwDJ8s3whUZ0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 7, 26.56, 30.32, 'can you spell sophie puru?', '你能拼出“Sophie Puru”这个名字吗？', '/kæn juː spɛl ˈsoʊfi ˈpʊruː/', '<span>can</span> <span>you</span> <span>spell</span> <span>sophie</span> <span>puru?</span>'
FROM episodes e WHERE e.video_id = '5JoJwDJ8s3whUZ0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 8, 30.32, 35.28, 's o f i p o u l a i n.', '索菲·普拉兰。', '/soʊ fiː puː leɪn/', '<span>s</span> <span>o</span> <span>f</span> <span>i</span> <span>p</span> <span>o</span> <span>u</span> <span>l</span> <span>a</span> <span>i</span> <span>n.</span>'
FROM episodes e WHERE e.video_id = '5JoJwDJ8s3whUZ0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 9, 35.28, 36.96, 'ah, okay.', '啊，好的。', '/ɑː oʊˈkeɪ/', '<span>ah,</span> <span>okay.</span>'
FROM episodes e WHERE e.video_id = '5JoJwDJ8s3whUZ0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 10, 36.96, 37.84, 'hi, sophie.', '嗨，索菲。', '/haɪ ˈsoʊfi/', '<span>hi,</span> <span>sophie.</span>'
FROM episodes e WHERE e.video_id = '5JoJwDJ8s3whUZ0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 11, 37.84, 40.32, 'hi, shen.', '嗨，沈。', '/haɪ ʃɛn/', '<span>hi,</span> <span>shen.</span>'
FROM episodes e WHERE e.video_id = '5JoJwDJ8s3whUZ0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 12, 40.32, 41.12, 'i''m sorry.', '对不起。', '/aɪm ˈsɑri/', '<span>i''m</span> <span>sorry.</span>'
FROM episodes e WHERE e.video_id = '5JoJwDJ8s3whUZ0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 13, 41.12, 44.12, 'goodbye.', '再见。', '/ɡʊdˈbaɪ/', '<span>goodbye.</span>'
FROM episodes e WHERE e.video_id = '5JoJwDJ8s3whUZ0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 14, 46.64, 58.559, 'a b c d e f g h i j k yes.', 'a b c d e f g h i j k 是的。', '/eɪ biː siː diː iː ɛf dʒiː eɪtʃ aɪ dʒeɪ keɪ jɛs/', '<span>a</span> <span>b</span> <span>c</span> <span>d</span> <span>e</span> <span>f</span> <span>g</span> <span>h</span> <span>i</span> <span>j</span> <span>k</span> <span>yes.</span>'
FROM episodes e WHERE e.video_id = '5JoJwDJ8s3whUZ0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 15, 58.559, 59.44, 'king.', '国王。', '/kɪŋ/', '<span>king.</span>'
FROM episodes e WHERE e.video_id = '5JoJwDJ8s3whUZ0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 16, 59.44, 61.76, 'oh, please excuse me.', '哦，请原谅我。', '/oʊ pliːz ɪkˈskjuːz miː/', '<span>oh,</span> <span>please</span> <span>excuse</span> <span>me.</span>'
FROM episodes e WHERE e.video_id = '5JoJwDJ8s3whUZ0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 17, 61.76, 64.799, 'i''m sorry.', '对不起。', '/aɪm ˈsɑːri/', '<span>i''m</span> <span>sorry.</span>'
FROM episodes e WHERE e.video_id = '5JoJwDJ8s3whUZ0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 18, 64.799, 66.4, 'my name is shen.', '我的名字叫沈。', '/maɪ neɪm ɪz ʃɛn/', '<span>my</span> <span>name</span> <span>is</span> <span>shen.</span>'
FROM episodes e WHERE e.video_id = '5JoJwDJ8s3whUZ0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 19, 66.4, 68.88, 'my name is sophie puna.', '我的名字是索菲·普纳。', '/maɪ neɪm ɪz ˈsoʊfi ˈpuːnə/', '<span>my</span> <span>name</span> <span>is</span> <span>sophie</span> <span>puna.</span>'
FROM episodes e WHERE e.video_id = '5JoJwDJ8s3whUZ0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 20, 68.88, 70.64, 'sophie pura.', '索菲·普拉。', '/ˈsoʊfi ˈpʊrə/', '<span>sophie</span> <span>pura.</span>'
FROM episodes e WHERE e.video_id = '5JoJwDJ8s3whUZ0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 21, 70.64, 74.4, 'can you spell sophie puru?', '你能拼出“Sophie Puru”这个名字吗？', '/kæn juː spɛl ˈsoʊfi ˈpʊruː/', '<span>can</span> <span>you</span> <span>spell</span> <span>sophie</span> <span>puru?</span>'
FROM episodes e WHERE e.video_id = '5JoJwDJ8s3whUZ0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 22, 74.4, 79.36, 's o f i p o u l a i n.', '索菲·普拉兰。', '/ɛs oʊ ɛf aɪ poʊ uː eɪl aɪ n/', '<span>s</span> <span>o</span> <span>f</span> <span>i</span> <span>p</span> <span>o</span> <span>u</span> <span>l</span> <span>a</span> <span>i</span> <span>n.</span>'
FROM episodes e WHERE e.video_id = '5JoJwDJ8s3whUZ0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 23, 79.36, 80.96, 'ah, okay.', '啊，好的。', '/ɑː oʊˈkeɪ/', '<span>ah,</span> <span>okay.</span>'
FROM episodes e WHERE e.video_id = '5JoJwDJ8s3whUZ0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 24, 80.96, 81.84, 'hi, sophie.', '嗨，索菲。', '/haɪ ˈsoʊfi/', '<span>hi,</span> <span>sophie.</span>'
FROM episodes e WHERE e.video_id = '5JoJwDJ8s3whUZ0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 25, 81.84, 84.32, 'hi, shen.', '嗨，沈。', '/haɪ ʃɛn/', '<span>hi,</span> <span>shen.</span>'
FROM episodes e WHERE e.video_id = '5JoJwDJ8s3whUZ0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 26, 84.32, 85.2, 'i''m sorry.', '对不起。', '/aɪm ˈsɑri/', '<span>i''m</span> <span>sorry.</span>'
FROM episodes e WHERE e.video_id = '5JoJwDJ8s3whUZ0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 27, 85.2, 88.2, 'goodbye.', '再见。', '/ɡʊdˈbaɪ/', '<span>goodbye.</span>'
FROM episodes e WHERE e.video_id = '5JoJwDJ8s3whUZ0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 28, 90.56, 102.479, 'a b c d e f g h i j k yes.', 'a b c d e f g h i j k 是的。', '/eɪ bi si di i ɛf dʒi eɪtʃ aɪ dʒeɪ keɪ jɛs/', '<span>a</span> <span>b</span> <span>c</span> <span>d</span> <span>e</span> <span>f</span> <span>g</span> <span>h</span> <span>i</span> <span>j</span> <span>k</span> <span>yes.</span>'
FROM episodes e WHERE e.video_id = '5JoJwDJ8s3whUZ0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 29, 102.479, 103.36, 'king.', '国王。', '/kɪŋ/', '<span>king.</span>'
FROM episodes e WHERE e.video_id = '5JoJwDJ8s3whUZ0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 30, 103.36, 105.68, 'oh, please excuse me.', '哦，请原谅我。', '/oʊ pliz ɪkˈskjuz mi/', '<span>oh,</span> <span>please</span> <span>excuse</span> <span>me.</span>'
FROM episodes e WHERE e.video_id = '5JoJwDJ8s3whUZ0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 31, 105.68, 108.72, 'i''m sorry.', '对不起。', '/aɪm ˈsɑri/', '<span>i''m</span> <span>sorry.</span>'
FROM episodes e WHERE e.video_id = '5JoJwDJ8s3whUZ0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 32, 108.72, 110.32, 'my name is shen.', '我的名字叫沈。', '/maɪ neɪm ɪz ʃɛn/', '<span>my</span> <span>name</span> <span>is</span> <span>shen.</span>'
FROM episodes e WHERE e.video_id = '5JoJwDJ8s3whUZ0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 33, 110.32, 112.799, 'my name is sophie puna.', '我的名字是索菲·普纳。', '/maɪ neɪm ɪz ˈsoʊfi ˈpunə/', '<span>my</span> <span>name</span> <span>is</span> <span>sophie</span> <span>puna.</span>'
FROM episodes e WHERE e.video_id = '5JoJwDJ8s3whUZ0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 34, 112.799, 114.56, 'sophie pura.', '索菲·普拉。', '/ˈsoʊfi ˈpʊrə/', '<span>sophie</span> <span>pura.</span>'
FROM episodes e WHERE e.video_id = '5JoJwDJ8s3whUZ0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 35, 114.56, 118.32, 'can you spell sophie puru?', '你能正确拼写“Sophie Puru”这个词吗？', '/kæn ju spɛl ˈsoʊfi ˈpʊru/', '<span>can</span> <span>you</span> <span>spell</span> <span>sophie</span> <span>puru?</span>'
FROM episodes e WHERE e.video_id = '5JoJwDJ8s3whUZ0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 36, 118.32, 123.28, 's o f i p o u l a i n.', '索菲普乌拉因。', '/ɛs oʊ ɛf aɪ poʊ uː l eɪ ɪn/', '<span>s</span> <span>o</span> <span>f</span> <span>i</span> <span>p</span> <span>o</span> <span>u</span> <span>l</span> <span>a</span> <span>i</span> <span>n.</span>'
FROM episodes e WHERE e.video_id = '5JoJwDJ8s3whUZ0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 37, 123.28, 124.88, 'ah, okay.', '啊，好的。', '/ɑː oʊˈkeɪ/', '<span>ah,</span> <span>okay.</span>'
FROM episodes e WHERE e.video_id = '5JoJwDJ8s3whUZ0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 38, 124.88, 125.84, 'hi, sophie.', '嗨，索菲。', '/haɪ ˈsoʊfi/', '<span>hi,</span> <span>sophie.</span>'
FROM episodes e WHERE e.video_id = '5JoJwDJ8s3whUZ0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 39, 125.84, 128.239, 'hi, shen.', '嗨，沈。', '/haɪ ʃɛn/', '<span>hi,</span> <span>shen.</span>'
FROM episodes e WHERE e.video_id = '5JoJwDJ8s3whUZ0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 40, 128.239, 129.119, 'i''m sorry.', '对不起。', '/aɪm ˈsɑri/', '<span>i''m</span> <span>sorry.</span>'
FROM episodes e WHERE e.video_id = '5JoJwDJ8s3whUZ0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 41, 129.119, 129.119, 'goodbye.', '再见。', '/ɡʊdˈbaɪ/', '<span>goodbye.</span>'
FROM episodes e WHERE e.video_id = '5JoJwDJ8s3whUZ0';

-- episode 222: jju55UMeBeHLG9c
UPDATE user_word_lookups SET subtitle_id = NULL WHERE subtitle_id IN (SELECT s.id FROM subtitles s JOIN episodes e ON s.episode_id = e.id WHERE e.video_id = 'jju55UMeBeHLG9c');
UPDATE user_vocabulary_items SET source_subtitle_id = NULL WHERE source_subtitle_id IN (SELECT s.id FROM subtitles s JOIN episodes e ON s.episode_id = e.id WHERE e.video_id = 'jju55UMeBeHLG9c');
DELETE FROM user_subtitle_progress WHERE subtitle_id IN (SELECT s.id FROM subtitles s JOIN episodes e ON s.episode_id = e.id WHERE e.video_id = 'jju55UMeBeHLG9c');
DELETE FROM user_subtitle_progress WHERE episode_id = (SELECT id FROM episodes WHERE video_id = 'jju55UMeBeHLG9c');
DELETE FROM subtitles WHERE episode_id = (SELECT id FROM episodes WHERE video_id = 'jju55UMeBeHLG9c');
DELETE FROM episode_tags WHERE episode_id = (SELECT id FROM episodes WHERE video_id = 'jju55UMeBeHLG9c');
INSERT INTO episodes (
  index, video_id, short_title, summary, remark, stars, voca_size,
  subtitle_count, clip_length, cover, video_url, audio_url, thumbnail_url,
  original_video_url, author_id, series_id, series_index,
  submitted_by_user_id, rejection_reason,
  created_at, is_demo, status, published_at
) VALUES (
  222, 'jju55UMeBeHLG9c', '第五集 - 英语环境体验',
  '', '',
  1, 5, 84,
  182.159, 'http://oss.sxakgs.com/en/dA-xWaIcF18/cover.webp',
  'http://oss.sxakgs.com/en/dA-xWaIcF18/video.mp4', 'http://oss.sxakgs.com/en/dA-xWaIcF18/audio.mp3',
  'http://oss.sxakgs.com/en/dA-xWaIcF18/cover.webp', 'https://www.youtube.com/watch?v=dA-xWaIcF18',
  (SELECT id FROM authors WHERE name = '润人巧记' AND accent = '美国' LIMIT 1),
  (SELECT id FROM episode_series WHERE slug = '华尔街英语-李深闯美' LIMIT 1), 5,
  NULL, NULL,
  '2026-07-13 16:36:35'::timestamp,
  FALSE, 'published',
  '2026-07-13 16:36:35'::timestamp
)
ON CONFLICT (video_id) DO UPDATE SET
  index = EXCLUDED.index,
  short_title = EXCLUDED.short_title,
  summary = EXCLUDED.summary,
  remark = EXCLUDED.remark,
  stars = EXCLUDED.stars,
  voca_size = EXCLUDED.voca_size,
  subtitle_count = EXCLUDED.subtitle_count,
  clip_length = EXCLUDED.clip_length,
  cover = EXCLUDED.cover,
  video_url = EXCLUDED.video_url,
  audio_url = EXCLUDED.audio_url,
  thumbnail_url = EXCLUDED.thumbnail_url,
  original_video_url = EXCLUDED.original_video_url,
  author_id = EXCLUDED.author_id,
  series_id = EXCLUDED.series_id,
  series_index = EXCLUDED.series_index,
  submitted_by_user_id = EXCLUDED.submitted_by_user_id,
  rejection_reason = EXCLUDED.rejection_reason,
  is_demo = EXCLUDED.is_demo,
  status = EXCLUDED.status,
  published_at = EXCLUDED.published_at;

INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 0, 2.24, 3.84, 'what''s your name?', '你叫什么名字？', '/wʌts jɔːr neɪm/', '<span>what''s</span> <span>your</span> <span>name?</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 1, 3.84, 4.799, 'my name''s shen.', '我的名字叫沈。', '/maɪ neɪmz ʃɛn/', '<span>my</span> <span>name''s</span> <span>shen.</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 2, 4.799, 6.4, 'what''s your name?', '你叫什么名字？', '/wʌts jɔːr neɪm/', '<span>what''s</span> <span>your</span> <span>name?</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 3, 6.4, 7.68, 'my name''s bill.', '我的名字叫比尔。', '/maɪ neɪmz bɪl/', '<span>my</span> <span>name''s</span> <span>bill.</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 4, 7.68, 8.32, 'benny king.', '本尼·金。', '/ˈbɛni kɪŋ/', '<span>benny</span> <span>king.</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 5, 8.32, 9.76, 'it''s his pizza.', '那是他的披萨。', '/ɪts hɪz ˈpiːtsə/', '<span>it''s</span> <span>his</span> <span>pizza.</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 6, 9.76, 10.88, 'it''s his pizza.', '那是他的披萨。', '/ɪts hɪz ˈpiːtsə/', '<span>it''s</span> <span>his</span> <span>pizza.</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 7, 10.88, 12.16, 'benny?', '本尼？', '/ˈbɛni/', '<span>benny?</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 8, 12.16, 12.8, 'yes.', '是的。', '/jɛs/', '<span>yes.</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 9, 12.8, 13.599, 'hello.', '你好。', '/həˈloʊ/', '<span>hello.</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 10, 13.599, 15.36, 'hello.', '你好。', '/həˈloʊ/', '<span>hello.</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 11, 15.36, 17.84, 'benny is my roommate.', '本尼是我的室友。', '/ˈbɛni ɪz maɪ ˈruːmmeɪt/', '<span>benny</span> <span>is</span> <span>my</span> <span>roommate.</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 12, 17.84, 19.279, 'your roommate?', '你的室友？', '/jɔːr ˈruːmmeɪt/', '<span>your</span> <span>roommate?</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 13, 19.279, 22.279, 'yes.', '是的。', '/jɛs/', '<span>yes.</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 14, 26.88, 28.48, 'thank you.', '谢谢。', '/θæŋk juː/', '<span>thank</span> <span>you.</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 15, 28.48, 31.359, 'you''re welcome.', '不客气。', '/jɔːr ˈwɛlkəm/', '<span>you''re</span> <span>welcome.</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 16, 33.44, 37.84, 'sorry, it''s my pizza.', '对不起，那是我的披萨。', '/ˈsɑri ɪts maɪ ˈpitsə/', '<span>sorry,</span> <span>it''s</span> <span>my</span> <span>pizza.</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 17, 37.84, 39.52, 'it''s your pizza?', '这是你的披萨吗？', '/ɪts jɔr ˈpitsə/', '<span>it''s</span> <span>your</span> <span>pizza?</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 18, 39.52, 42.399, 'yes, it''s my pizza.', '是的，那是我点的披萨。', '/jɛs ɪts maɪ ˈpitsə/', '<span>yes,</span> <span>it''s</span> <span>my</span> <span>pizza.</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 19, 42.399, 43.76, 'what''s your name?', '你叫什么名字？', '/wʌts jɔr neɪm/', '<span>what''s</span> <span>your</span> <span>name?</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 20, 43.76, 46.399, 'my name is benny king.', '我的名字是本尼·金。', '/maɪ neɪm ɪz ˈbɛni kɪŋ/', '<span>my</span> <span>name</span> <span>is</span> <span>benny</span> <span>king.</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 21, 46.399, 48.719, 'my name''s shen lee.', '我的名字是沈李。', '/maɪ neɪmz ʃɛn li/', '<span>my</span> <span>name''s</span> <span>shen</span> <span>lee.</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 22, 48.719, 51.68, 'shenley, my roommate, shen lee.', '沈莉，我的室友。', '/ˈʃɛnli maɪ ˈrummeɪt ʃɛn li/', '<span>shenley,</span> <span>my</span> <span>roommate,</span> <span>shen</span> <span>lee.</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 23, 51.68, 55.12, 'yes, my name''s shen, your roommate.', '是的，我叫沈，是你的室友。', '/jɛs maɪ neɪmz ʃɛn jɔr ˈrummeɪt/', '<span>yes,</span> <span>my</span> <span>name''s</span> <span>shen,</span> <span>your</span> <span>roommate.</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 24, 55.12, 59.239, 'welcome to america, shen.', '欢迎来到美国，沈。', '/ˈwɛlkəm tə əˈmɛrɪkə, ʃɛn./', '<span>welcome</span> <span>to</span> <span>america,</span> <span>shen.</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 25, 59.28, 62.079, 'thank you.', '谢谢。', '/θæŋk juː./', '<span>thank</span> <span>you.</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 26, 62.079, 63.6, 'hello.', '你好。', '/həˈloʊ./', '<span>hello.</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 27, 63.6, 65.04, 'what''s your name?', '你叫什么名字？', '/wʌts jʊr neɪm?/', '<span>what''s</span> <span>your</span> <span>name?</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 28, 65.04, 66.08, 'my name''s shen.', '我的名字叫沈。', '/maɪ neɪmz ʃɛn./', '<span>my</span> <span>name''s</span> <span>shen.</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 29, 66.08, 67.68, 'what''s your name?', '你叫什么名字？', '/wʌts jʊr neɪm?/', '<span>what''s</span> <span>your</span> <span>name?</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 30, 67.68, 68.96, 'my name''s bill.', '我的名字叫比尔。', '/maɪ neɪmz bɪl./', '<span>my</span> <span>name''s</span> <span>bill.</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 31, 68.96, 69.6, 'benny king.', '本尼·金。', '/ˈbɛni kɪŋ./', '<span>benny</span> <span>king.</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 32, 69.6, 71.04, 'it''s his pizza.', '那是他的披萨。', '/ɪts hɪz ˈpiːtsə/', '<span>it''s</span> <span>his</span> <span>pizza.</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 33, 71.04, 72.159, 'it''s his pizza.', '那是他的披萨。', '/ɪts hɪz ˈpiːtsə/', '<span>it''s</span> <span>his</span> <span>pizza.</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 34, 72.159, 73.439, 'benny?', '本尼？', '/ˈbɛni/', '<span>benny?</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 35, 73.439, 74.08, 'yes.', '是的。', '/jɛs/', '<span>yes.</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 36, 74.08, 74.88, 'hello.', '你好。', '/həˈloʊ/', '<span>hello.</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 37, 74.88, 76.64, 'hello.', '你好。', '/həˈloʊ/', '<span>hello.</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 38, 76.64, 79.119, 'benny is my roommate.', '本尼是我的室友。', '/ˈbɛni ɪz maɪ ˈruːmmeɪt/', '<span>benny</span> <span>is</span> <span>my</span> <span>roommate.</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 39, 79.119, 80.56, 'your roommate?', '你的室友？', '/jɔːr ˈruːmmeɪt/', '<span>your</span> <span>roommate?</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 40, 80.56, 83.56, 'yes.', '是的。', '/jɛs/', '<span>yes.</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 41, 88.159, 89.759, 'thank you.', '谢谢。', '/θæŋk juː/', '<span>thank</span> <span>you.</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 42, 89.759, 93.0, 'you''re welcome.', '不客气。', '/jʊr ˈwɛlkəm/', '<span>you''re</span> <span>welcome.</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 43, 94.72, 99.119, 'sorry, it''s my pizza.', '抱歉，那是我的披萨。', '/ˈsɑri ɪts maɪ ˈpiːtsə/', '<span>sorry,</span> <span>it''s</span> <span>my</span> <span>pizza.</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 44, 99.119, 100.799, 'it''s your pizza?', '这是你的披萨吗？', '/ɪts jʊr ˈpiːtsə/', '<span>it''s</span> <span>your</span> <span>pizza?</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 45, 100.799, 103.68, 'yes, it''s my pizza.', '是的，那是我点的披萨。', '/jɛs ɪts maɪ ˈpiːtsə/', '<span>yes,</span> <span>it''s</span> <span>my</span> <span>pizza.</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 46, 103.68, 105.04, 'what''s your name?', '你叫什么名字？', '/wʌts jʊr neɪm/', '<span>what''s</span> <span>your</span> <span>name?</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 47, 105.04, 107.68, 'my name is benny king.', '我的名字是本尼·金。', '/maɪ neɪm ɪz ˈbɛni kɪŋ/', '<span>my</span> <span>name</span> <span>is</span> <span>benny</span> <span>king.</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 48, 107.68, 110.0, 'my name''s shen lee.', '我的名字是沈李。', '/maɪ neɪmz ʃɛn liː/', '<span>my</span> <span>name''s</span> <span>shen</span> <span>lee.</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 49, 110.0, 111.36, 'shenley.', '沈雷。', '/ˈʃɛnliː/', '<span>shenley.</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 50, 111.36, 112.96, 'my roommate shen lee.', '我的室友是沈莉。', '/maɪ ˈruːmmeɪt ʃɛn liː/', '<span>my</span> <span>roommate</span> <span>shen</span> <span>lee.</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 51, 112.96, 114.88, 'yes, my name''s shen.', '是的，我叫沈。', '/jɛs maɪ neɪmz ʃɛn/', '<span>yes,</span> <span>my</span> <span>name''s</span> <span>shen.</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 52, 114.88, 116.399, 'your roommate.', '你的室友。', '/jɔːr ˈruːmmeɪt/', '<span>your</span> <span>roommate.</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 53, 116.399, 120.52, 'welcome to america shed.', '欢迎来到美国的“棚屋区”。', '/ˈwɛlkəm tuː əˈmɛrɪkə ʃɛd/', '<span>welcome</span> <span>to</span> <span>america</span> <span>shed.</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 54, 120.64, 123.439, 'thank you.', '谢谢。', '/θæŋk juː/', '<span>thank</span> <span>you.</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 55, 123.439, 124.88, 'hello.', '你好。', '/həˈloʊ/', '<span>hello.</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 56, 124.88, 126.399, 'what''s your name?', '你叫什么名字？', '/wʌts jʊr neɪm/', '<span>what''s</span> <span>your</span> <span>name?</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 57, 126.399, 127.439, 'my name''s shen.', '我的名字叫沈。', '/maɪ neɪmz ʃɛn/', '<span>my</span> <span>name''s</span> <span>shen.</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 58, 127.439, 128.959, 'what''s your name?', '你叫什么名字？', '/wʌts jʊr neɪm/', '<span>what''s</span> <span>your</span> <span>name?</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 59, 128.959, 130.239, 'my name''s bill.', '我的名字叫比尔。', '/maɪ neɪmz bɪl/', '<span>my</span> <span>name''s</span> <span>bill.</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 60, 130.239, 130.878, 'benny king.', '本尼·金。', '/ˈbɛni kɪŋ/', '<span>benny</span> <span>king.</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 61, 130.878, 132.319, 'it''s his pizza.', '那是他的披萨。', '/ɪts hɪz ˈpiːtsə/', '<span>it''s</span> <span>his</span> <span>pizza.</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 62, 132.319, 133.44, 'it''s his pizza.', '那是他的披萨。', '/ɪts hɪz ˈpiːtsə/', '<span>it''s</span> <span>his</span> <span>pizza.</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 63, 133.44, 134.72, 'benny?', '本尼？', '/ˈbɛni/', '<span>benny?</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 64, 134.72, 135.36, 'yes.', '是的。', '/jɛs/', '<span>yes.</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 65, 135.36, 136.16, 'hello.', '你好。', '/həˈloʊ/', '<span>hello.</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 66, 136.16, 137.92, 'hello.', '你好。', '/həˈloʊ/', '<span>hello.</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 67, 137.92, 140.4, 'benny is my roommate.', '本尼是我的室友。', '/ˈbɛni ɪz maɪ ˈruːmmeɪt/', '<span>benny</span> <span>is</span> <span>my</span> <span>roommate.</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 68, 140.4, 141.84, 'your roommate?', '你的室友？', '/jɔːr ˈruːmmeɪt/', '<span>your</span> <span>roommate?</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 69, 141.84, 144.84, 'yes.', '是的。', '/jɛs/', '<span>yes.</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 70, 149.44, 151.04, 'thank you.', '谢谢。', '/θæŋk juː/', '<span>thank</span> <span>you.</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 71, 151.04, 154.36, 'you''re welcome.', '不客气。', '/jɔːr ˈwɛlkəm/', '<span>you''re</span> <span>welcome.</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 72, 156.0, 158.48, 'sorry.', '抱歉。', '/ˈsɑri/', '<span>sorry.</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 73, 158.48, 160.4, 'it''s my pizza.', '那是我的披萨。', '/ɪts maɪ ˈpiːtsə/', '<span>it''s</span> <span>my</span> <span>pizza.</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 74, 160.4, 162.08, 'it''s your pizza.', '那是你的披萨。', '/ɪts jɔːr ˈpiːtsə/', '<span>it''s</span> <span>your</span> <span>pizza.</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 75, 162.08, 165.04, 'yes, it''s my pizza.', '是的，那是我点的披萨。', '/jɛs ɪts maɪ ˈpiːtsə/', '<span>yes,</span> <span>it''s</span> <span>my</span> <span>pizza.</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 76, 165.04, 166.4, 'what''s your name?', '你叫什么名字？', '/wʌts jɔːr neɪm/', '<span>what''s</span> <span>your</span> <span>name?</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 77, 166.4, 168.959, 'my name is benny king.', '我的名字是本尼·金。', '/maɪ neɪm ɪz ˈbɛni kɪŋ/', '<span>my</span> <span>name</span> <span>is</span> <span>benny</span> <span>king.</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 78, 168.959, 171.28, 'my name''s shen lee.', '我的名字是沈李。', '/maɪ neɪmz ʃɛn li/', '<span>my</span> <span>name''s</span> <span>shen</span> <span>lee.</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 79, 171.28, 172.72, 'shenley.', '沈雷。', '/ˈʃɛnli/', '<span>shenley.</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 80, 172.72, 174.239, 'my roommate, shen lee.', '我的室友，沈莉。', '/maɪ ˈruːmmeɪt, ʃɛn liː/', '<span>my</span> <span>roommate,</span> <span>shen</span> <span>lee.</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 81, 174.239, 177.68, 'yes, my name''s shen, your roommate.', '是的，我叫沈，是你的室友。', '/jɛs, maɪ neɪmz ʃɛn, jɔːr ˈruːmmeɪt/', '<span>yes,</span> <span>my</span> <span>name''s</span> <span>shen,</span> <span>your</span> <span>roommate.</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 82, 177.68, 181.8, 'welcome to america, shen.', '欢迎来到美国，沈。', '/ˈwɛlkəm tə əˈmɛrɪkə, ʃɛn/', '<span>welcome</span> <span>to</span> <span>america,</span> <span>shen.</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 83, 181.92, 182.159, 'thank you.', '谢谢。', '/θæŋk juː/', '<span>thank</span> <span>you.</span>'
FROM episodes e WHERE e.video_id = 'jju55UMeBeHLG9c';

-- sync id sequences if present
SELECT setval(
  pg_get_serial_sequence('tags', 'id'),
  GREATEST(COALESCE((SELECT MAX(id) FROM tags), 1), 1)
) WHERE pg_get_serial_sequence('tags', 'id') IS NOT NULL;
SELECT setval(
  pg_get_serial_sequence('subtitles', 'id'),
  GREATEST(COALESCE((SELECT MAX(id) FROM subtitles), 1), 1)
) WHERE pg_get_serial_sequence('subtitles', 'id') IS NOT NULL;
SELECT setval(
  pg_get_serial_sequence('episode_series', 'id'),
  GREATEST(COALESCE((SELECT MAX(id) FROM episode_series), 1), 1)
) WHERE pg_get_serial_sequence('episode_series', 'id') IS NOT NULL;
SELECT setval(
  pg_get_serial_sequence('episodes', 'id'),
  GREATEST(COALESCE((SELECT MAX(id) FROM episodes), 1), 1)
) WHERE pg_get_serial_sequence('episodes', 'id') IS NOT NULL;

COMMIT;

-- imported video_ids: 5FAegfs5fTHS8Ac, NrkfL2tex-OvHfg, ZhYyJok4mt460Ak, HU7atRpOuXDCURA, f9EienS-MatNvZU, ouWRU5IZOyqaCDE, -ivVMCWegdd1WT8, 5JoJwDJ8s3whUZ0, jju55UMeBeHLG9c
