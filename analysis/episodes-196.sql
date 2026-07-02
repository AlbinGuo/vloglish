-- vlogish episode import SQL
-- generated: 2026-07-02T16:13:13.974534Z
-- episodes: 1 (index 196..196)
-- Run on production PostgreSQL inside transaction.

BEGIN;

INSERT INTO authors (name, gender, nationality, accent)
SELECT '41NBC', 'm', '', '美国'
WHERE NOT EXISTS (
  SELECT 1 FROM authors x
  WHERE x.name = '41NBC' AND x.accent = '美国'
);


-- episode 196: Nsl7OCGum9FSB2U
INSERT INTO episodes (
  index, video_id, short_title, summary, remark, stars, voca_size,
  subtitle_count, clip_length, cover, video_url, audio_url, thumbnail_url,
  original_video_url, author_id, submitted_by_user_id, rejection_reason,
  created_at, is_demo, status, published_at
) VALUES (
  196, 'Nsl7OCGum9FSB2U', '特朗普政府计划修改USMCA，道指创历史新高',
  '特朗普政府表示不会以当前形式续签《美墨加协定》（USMCA）。', '',
  3, 0, 98,
  0.0, 'http://oss.sxakgs.com/en/_DrXKYUToHc/cover.webp',
  'http://oss.sxakgs.com/en/_DrXKYUToHc/video.mp4', 'http://oss.sxakgs.com/en/_DrXKYUToHc/audio.mp3',
  'http://oss.sxakgs.com/en/_DrXKYUToHc/cover.webp', 'https://www.youtube.com/watch?v=_DrXKYUToHc',
  (SELECT id FROM authors WHERE name = '41NBC' AND accent = '美国' LIMIT 1),
  NULL, NULL,
  '2026-07-02 15:43:20'::timestamp,
  FALSE, 'published',
  '2026-07-02 15:43:20'::timestamp
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
  is_demo = EXCLUDED.is_demo,
  status = EXCLUDED.status,
  published_at = EXCLUDED.published_at;

DELETE FROM user_subtitle_progress WHERE subtitle_id IN (
  SELECT s.id FROM subtitles s JOIN episodes e ON s.episode_id = e.id WHERE e.video_id = 'Nsl7OCGum9FSB2U'
);
DELETE FROM subtitles WHERE episode_id = (SELECT id FROM episodes WHERE video_id = 'Nsl7OCGum9FSB2U');
DELETE FROM episode_tags WHERE episode_id = (SELECT id FROM episodes WHERE video_id = 'Nsl7OCGum9FSB2U');

INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 0, 3.429, 0.0, 'Welcome back. Airports are stocking up', '欢迎回来。机场正在囤货', '/ˈwɛlkəm bæk. ˈɛrˌpɔrts ɑːr ˈstɑːkɪŋ ʌp/', '<span>Welcome</span><span>back</span><span>.</span><span tid="50001" class="highlight highlight-a">Airports</span><span>are</span><span>stocking</span><span>up</span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 1, 3.439, 0.0, 'Welcome back. Airports are stocking up on<00:00:03.679><c> a</c><00:00:03.919><c> hot</c><00:00:04.240><c> World</c><00:00:04.560><c> Cup</c><00:00:04.880><c> souvenir</c><00:00:05.680><c> rant</c>', '欢迎回来。机场正在囤积世界杯纪念品', '/ˈwɛlkəm bæk. ˈɛrˌpɔrts ɑːr ˈstɑːkɪŋ ʌp ɑːn ə hɑt wɜːrld kʌp ˌsuːvəˈnɪr rænt/', '<span>Welcome</span><span>back.</span><span>Airports</span><span>are</span><span>stocking</span><span>up</span><span>on<00:00:03.679><c></span><span>a</c><00:00:03.919><c></span><span>hot</c><00:00:04.240><c></span><span>World</c><00:00:04.560><c></span><span>Cup</c><00:00:04.880><c></span><span>souvenir</c><00:00:05.680><c></span><span>rant</c></span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 2, 6.309, 0.0, 'on a hot World Cup souvenir rant', '关于世界杯纪念品的热门话题', '/ɑːn ə hɑt wɜːrld kʌp ˌsuːvəˈnɪr rænt/', '<span>on</span><span>a</span><span>hot</span><span>World</span><span>Cup</span><span tid="50002" class="highlight highlight-a">souvenir</span><span tid="50003" class="highlight highlight-a">rant</span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 3, 6.319, 0.0, 'on a hot World Cup souvenir rant dressing.<00:00:07.120><c> That''s</c><00:00:07.680><c> interesting.</c><00:00:08.480><c> And</c><00:00:08.720><c> the</c>', '关于世界杯纪念品的热门话题调料。这很有趣。而且', '/ɑːn ə hɑt wɜːrld kʌp ˌsuːvəˈnɪr rænt ˈdrɛsɪŋ. ðæts ˈɪntrəstɪŋ. ænd ðə/', '<span>on</span><span>a</span><span>hot</span><span>World</span><span>Cup</span><span>souvenir</span><span>rant</span><span>dressing.<00:00:07.120><c></span><span>That''s</c><00:00:07.680><c></span><span>interesting.</c><00:00:08.480><c></span><span>And</c><00:00:08.720><c></span><span>the</c></span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 4, 8.87, 0.0, 'dressing. That''s interesting. And the', '调料。这很有趣。而且', '/ˈdrɛsɪŋ. ðæts ˈɪntrəstɪŋ. ænd ðə/', '<span tid="50004" class="highlight highlight-a">dressing</span><span>.</span><span>That''s</span><span>interesting</span><span>.</span><span>And</span><span>the</span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 5, 8.88, 0.0, 'dressing. That''s interesting. And the Trump<00:00:09.200><c> administration</c><00:00:10.000><c> declines</c><00:00:10.480><c> to</c><00:00:10.639><c> renew</c><00:00:11.040><c> a</c>', '调料。这很有趣。而且特朗普政府拒绝续签', '/ˈdrɛsɪŋ. ðæts ˈɪntrəstɪŋ. ænd ðə trʌmp ædˌmɪnɪˈstreɪʃən dɪˈklaɪnz tuː rɪˈnuː ə/', '<span>dressing.</span><span>That''s</span><span>interesting.</span><span>And</span><span>the</span><span>Trump<00:00:09.200><c></span><span>administration</c><00:00:10.000><c></span><span>declines</c><00:00:10.480><c></span><span>to</c><00:00:10.639><c></span><span>renew</c><00:00:11.040><c></span><span>a</c></span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 6, 11.27, 0.0, 'Trump administration declines to renew a', '特朗普政府拒绝续签', '/trʌmp ædˌmɪnɪˈstreɪʃən dɪˈklaɪnz tuː rɪˈnuː ə/', '<span>Trump</span><span tid="50005" class="highlight highlight-a">administration</span><span tid="50006" class="highlight highlight-a">declines</span><span>to</span><span tid="50007" class="highlight highlight-a">renew</span><span>a</span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 7, 11.28, 0.0, 'Trump administration declines to renew a major<00:00:11.679><c> trade</c><00:00:12.000><c> deal</c><00:00:12.240><c> with</c><00:00:12.559><c> Canada</c><00:00:12.960><c> and</c><00:00:13.280><c> Mexico.</c>', '特朗普政府拒绝续签一项与加拿大和墨西哥的重大贸易协议。', '/trʌmp ædˌmɪnɪˈstreɪʃən dɪˈklaɪnz tuː rɪˈnuː ə ˈmeɪdʒər treɪd diːl wɪð ˈkænədə ænd ˈmɛksɪkoʊ./', '<span>Trump</span><span>administration</span><span>declines</span><span>to</span><span>renew</span><span>a</span><span>major<00:00:11.679><c></span><span>trade</c><00:00:12.000><c></span><span>deal</c><00:00:12.240><c></span><span>with</c><00:00:12.559><c></span><span>Canada</c><00:00:12.960><c></span><span>and</c><00:00:13.280><c></span><span>Mexico.</c></span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 8, 14.15, 0.0, 'major trade deal with Canada and Mexico.', '与加拿大和墨西哥的重大贸易协议。', '/ˈmeɪdʒər treɪd diːl wɪð ˈkænədə ænd ˈmɛksɪkoʊ./', '<span tid="50008" class="highlight highlight-a">major</span><span>trade</span><span tid="50009" class="highlight highlight-a">deal</span><span>with</span><span>Canada</span><span>and</span><span>Mexico.</span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 9, 14.16, 0.0, 'major trade deal with Canada and Mexico. Jane<00:00:14.400><c> Kings</c><00:00:14.719><c> at</c><00:00:14.880><c> the</c><00:00:15.040><c> New</c><00:00:15.120><c> York</c><00:00:15.280><c> Stock</c>', '与加拿大和墨西哥的重大贸易协议。简·金斯在纽约证券交易所', '/ˈmeɪdʒər treɪd diːl wɪð ˈkænədə ænd ˈmɛksɪkoʊ. dʒeɪn kɪŋz æt ðə njuː jɔːrk stɑːk/', '<span>major</span><span>trade</span><span>deal</span><span>with</span><span>Canada</span><span>and</span><span>Mexico.</span><span>Jane<00:00:14.400><c></span><span>Kings</c><00:00:14.719><c></span><span>at</c><00:00:14.880><c></span><span>the</c><00:00:15.040><c></span><span>New</c><00:00:15.120><c></span><span>York</c><00:00:15.280><c></span><span>Stock</c></span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 10, 15.589, 0.0, 'Jane Kings at the New York Stock', '简·金斯在纽约证券交易所', '/dʒeɪn kɪŋz æt ðə njuː jɔːrk stɑːk/', '<span>Jane</span><span>Kings</span><span>at</span><span>the</span><span>New</span><span>York</span><span>Stock</span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 11, 15.599, 0.0, 'Jane Kings at the New York Stock Exchange<00:00:16.000><c> with</c><00:00:16.240><c> those</c><00:00:16.480><c> stories</c><00:00:16.800><c> and</c><00:00:17.039><c> more</c><00:00:17.359><c> in</c>', '简·金斯在纽约证券交易所带来这些故事和更多', '/dʒeɪn kɪŋz æt ðə njuː jɔːrk stɑːk ɪksˈtʃeɪndʒ wɪð ðoʊz ˈstɔːriz ænd mɔːr ɪn/', '<span>Jane</span><span>Kings</span><span>at</span><span>the</span><span>New</span><span>York</span><span>Stock</span><span>Exchange<00:00:16.000><c></span><span>with</c><00:00:16.240><c></span><span>those</c><00:00:16.480><c></span><span>stories</c><00:00:16.800><c></span><span>and</c><00:00:17.039><c></span><span>more</c><00:00:17.359><c></span><span>in</c></span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 12, 17.67, 0.0, 'Exchange with those stories and more in', '交易所带来这些故事和更多', '/ɪksˈtʃeɪndʒ wɪð ðoʊz ˈstɔːriz ænd mɔːr ɪn/', '<span tid="50010" class="highlight highlight-a">Exchange</span><span>with</span><span>those</span><span>stories</span><span>and</span><span>more</span><span>in</span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 13, 17.68, 0.0, 'Exchange with those stories and more in today''s<00:00:18.000><c> morning</c><00:00:18.320><c> business</c><00:00:18.640><c> report.</c>', '交易所带来这些故事和更多在今天的早间商业报道中。', '/ɪksˈtʃeɪndʒ wɪð ðoʊz ˈstɔːriz ænd mɔːr ɪn təˈdeɪz ˈmɔːrnɪŋ ˈbɪznəs rɪˈpɔːrt./', '<span>Exchange</span><span>with</span><span>those</span><span>stories</span><span>and</span><span>more</span><span>in</span><span>today''s<00:00:18.000><c></span><span>morning</c><00:00:18.320><c></span><span>business</c><00:00:18.640><c></span><span>report.</c></span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 14, 20.39, 0.0, 'today''s morning business report.', '今天的早间商业报道。', '/təˈdeɪz ˈmɔːrnɪŋ ˈbɪznəs rɪˈpɔːrt./', '<span>today''s</span><span>morning</span><span>business</span><span>report.</span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 15, 20.4, 0.0, 'today''s morning business report. &gt;&gt; Good<00:00:20.720><c> morning.</c><00:00:20.960><c> The</c><00:00:21.119><c> Trump</c><00:00:21.439><c> administration</c>', '今天的早间商业报道。>> 早上好。特朗普政府', '/təˈdeɪz ˈmɔːrnɪŋ ˈbɪznəs rɪˈpɔːrt. ɡʊd ˈmɔːrnɪŋ. ðə trʌmp ædˌmɪnɪˈstreɪʃən/', '<span>today''s</span><span>morning</span><span>business</span><span>report.</span><span>&gt;&gt;</span><span>Good<00:00:20.720><c></span><span>morning.</c><00:00:20.960><c></span><span>The</c><00:00:21.119><c></span><span>Trump</c><00:00:21.439><c></span><span>administration</c></span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 16, 22.23, 0.0, '&gt;&gt; Good morning. The Trump administration', '>> 早上好。特朗普政府', '/ɡʊd ˈmɔːrnɪŋ. ðə trʌmp ædˌmɪnɪˈstreɪʃən/', '<span>&gt;&gt;</span> <span>Good</span> <span>morning.</span> <span>The</span> <span>Trump</span> <span>administration</span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 17, 22.24, 0.0, '&gt;&gt; Good morning. The Trump administration will<00:00:22.560><c> not</c><00:00:22.880><c> renew</c><00:00:23.359><c> the</c><00:00:23.760><c> US</c><00:00:24.320><c> MCA,</c><00:00:25.199><c> at</c><00:00:25.199><c> least</c><00:00:25.519><c> in</c>', '>> 早上好。特朗普政府将不会续签USMCA，至少不会', '/ɡʊd ˈmɔːrnɪŋ. ðə trʌmp ædˌmɪnɪˈstreɪʃən wɪl nɑt rɪˈnuː ðə juː ɛs siː eɪ, æt liːst ɪn/', '<span>&gt;&gt;</span> <span>Good</span> <span>morning.</span> <span>The</span> <span>Trump</span> <span>administration</span> <span>will<00:00:22.560><c></span> <span>not</c><00:00:22.880><c></span> <span>renew</c><00:00:23.359><c></span> <span>the</c><00:00:23.760><c></span> <span>US</c><00:00:24.320><c></span> <span>MCA,</c><00:00:25.199><c></span> <span>at</c><00:00:25.199><c></span> <span>least</c><00:00:25.519><c></span> <span>in</c></span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 18, 25.67, 0.0, 'will not renew the US MCA, at least in', '将不会续签USMCA，至少不会', '/wɪl nɑt rɪˈnuː ðə juː ɛs siː eɪ, æt liːst ɪn/', '<span>will</span> <span>not</span> <span>renew</span> <span>the</span> <span>US</span> <span>MCA,</span> <span>at</span> <span>least</span> <span>in</span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 19, 25.68, 0.0, 'will not renew the US MCA, at least in its<00:00:26.000><c> current</c><00:00:26.320><c> form.</c><00:00:27.039><c> Now,</c><00:00:27.439><c> this</c><00:00:27.680><c> begins</c><00:00:28.000><c> a</c>', '将不会续签USMCA，至少不会以目前的形式。现在，这开启了一个', '/wɪl nɑt rɪˈnuː ðə juː ɛs siː eɪ, æt liːst ɪn ɪts ˈkɜːrənt fɔːrm. naʊ, ðɪs bɪˈɡɪnz ə/', '<span>will</span> <span>not</span> <span>renew</span> <span>the</span> <span>US</span> <span>MCA,</span> <span>at</span> <span>least</span> <span>in</span> <span>its<00:00:26.000><c></span> <span>current</c><00:00:26.320><c></span> <span>form.</c><00:00:27.039><c></span> <span>Now,</c><00:00:27.439><c></span> <span>this</c><00:00:27.680><c></span> <span>begins</c><00:00:28.000><c></span> <span>a</c></span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 20, 28.23, 0.0, 'its current form. Now, this begins a', '以目前的形式。现在，这开启了一个', '/ɪts ˈkɜːrənt fɔːrm. naʊ, ðɪs bɪˈɡɪnz ə/', '<span>its</span> <span>current</span> <span>form.</span> <span>Now,</span> <span>this</span> <span>begins</span> <span>a</span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 21, 28.24, 0.0, 'its current form. Now, this begins a cycle<00:00:28.560><c> of</c><00:00:28.880><c> annual</c><00:00:29.359><c> reviews</c><00:00:30.000><c> of</c><00:00:30.160><c> the</c><00:00:30.400><c> trade</c>', '以目前的形式。现在，这开启了一个每年审查贸易协议的周期', '/ɪts ˈkɜːrənt fɔːrm. naʊ, ðɪs bɪˈɡɪnz ə ˈsaɪkəl ʌv ˈænjuəl rɪˈvjuːz ʌv ðə treɪd/', '<span>its</span> <span>current</span> <span>form.</span> <span>Now,</span> <span>this</span> <span>begins</span> <span>a</span> <span>cycle<00:00:28.560><c></span> <span>of</c><00:00:28.880><c></span> <span>annual</c><00:00:29.359><c></span> <span>reviews</c><00:00:30.000><c></span> <span>of</c><00:00:30.160><c></span> <span>the</c><00:00:30.400><c></span> <span>trade</c></span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 22, 30.63, 0.0, 'cycle of annual reviews of the trade', '每年审查贸易协议的周期', '/ˈsaɪkəl ʌv ˈænjuəl rɪˈvjuːz ʌv ðə treɪd/', '<span>cycle</span> <span>of</span> <span>annual</span> <span>reviews</span> <span>of</span> <span>the</span> <span>trade</span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 23, 30.64, 0.0, 'cycle of annual reviews of the trade agreement<00:00:30.960><c> that</c><00:00:31.199><c> could</c><00:00:31.359><c> result</c><00:00:31.519><c> in</c><00:00:31.679><c> the</c>', '每年审查贸易协议的周期，可能导致', '/ˈsaɪkəl ʌv ˈænjuəl rɪˈvjuːz ʌv ðə treɪd əˈɡriːmənt ðæt kʊd rɪˈzʌlt ɪn ðə/', '<span>cycle</span> <span>of</span> <span>annual</span> <span>reviews</span> <span>of</span> <span>the</span> <span>trade</span> <span>agreement<00:00:30.960><c></span> <span>that</c><00:00:31.199><c></span> <span>could</c><00:00:31.359><c></span> <span>result</c><00:00:31.519><c></span> <span>in</c><00:00:31.679><c></span> <span>the</c></span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 24, 31.83, 0.0, 'agreement that could result in the', '协议，可能导致', '/əˈɡriːmənt ðæt kʊd rɪˈzʌlt ɪn ðə/', '<span>agreement</span> <span>that</span> <span>could</span> <span>result</span> <span>in</span> <span>the</span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 25, 31.84, 0.0, 'agreement that could result in the termination<00:00:32.239><c> of</c><00:00:32.399><c> the</c><00:00:32.559><c> deal</c><00:00:32.719><c> in</c><00:00:32.960><c> a</c><00:00:33.120><c> decade.</c><00:00:33.760><c> The</c>', '协议，可能导致十年后该协议的终止。', '/əˈɡriːmənt ðæt kʊd rɪˈzʌlt ɪn ðə ˌtɜːrmɪˈneɪʃən ʌv ðə diːl ɪn ə dɪˈkeɪd. ðə/', '<span>agreement</span> <span>that</span> <span>could</span> <span>result</span> <span>in</span> <span>the</span> <span>termination<00:00:32.239><c></span> <span>of</c><00:00:32.399><c></span> <span>the</c><00:00:32.559><c></span> <span>deal</c><00:00:32.719><c></span> <span>in</c><00:00:32.960><c></span> <span>a</c><00:00:33.120><c></span> <span>decade.</c><00:00:33.760><c></span> <span>The</c></span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 26, 33.99, 0.0, 'termination of the deal in a decade. The', '十年后该协议的终止。', '/ˌtɜːrmɪˈneɪʃən ʌv ðə diːl ɪn ə dɪˈkeɪd. ðə/', '<span>termination</span> <span>of</span> <span>the</span> <span>deal</span> <span>in</span> <span>a</span> <span>decade.</span> <span>The</span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 27, 34.0, 0.0, 'termination of the deal in a decade. The three<00:00:34.239><c> nations,</c><00:00:34.719><c> the</c><00:00:35.040><c> US,</c><00:00:35.520><c> Mexico,</c><00:00:36.000><c> and</c>', '十年后该协议的终止。这三个国家，美国、墨西哥和', '/ˌtɜːrmɪˈneɪʃən ʌv ðə diːl ɪn ə dɪˈkeɪd. ðə θriː ˈneɪʃənz, ðə juː ɛs, ˈmɛksɪkoʊ, ænd/', '<span>termination</span> <span>of</span> <span>the</span> <span>deal</span> <span>in</span> <span>a</span> <span>decade.</span> <span>The</span> <span>three<00:00:34.239><c></span> <span>nations,</c><00:00:34.719><c></span> <span>the</c><00:00:35.040><c></span> <span>US,</c><00:00:35.520><c></span> <span>Mexico,</c><00:00:36.000><c></span> <span>and</c></span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 28, 36.229, 0.0, 'three nations, the US, Mexico, and', '这三个国家，美国、墨西哥和', '/θriː ˈneɪʃənz, ðə juː ɛs, ˈmɛksɪkoʊ, ænd/', '<span>three</span> <span>nations,</span> <span>the</span> <span>US,</span> <span>Mexico,</span> <span>and</span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 29, 36.239, 0.0, 'three nations, the US, Mexico, and Canada,<00:00:37.040><c> are</c><00:00:37.280><c> still</c><00:00:37.600><c> holding</c><00:00:38.079><c> talks</c><00:00:38.559><c> over</c><00:00:38.800><c> the</c>', '这三个国家，美国、墨西哥和加拿大，仍在就', '/θriː ˈneɪʃənz, ðə juː ɛs, ˈmɛksɪkoʊ, ænd ˈkænədə, ɑːr stɪl ˈhoʊldɪŋ tɔːks ˈoʊvər ðə/', '<span>three</span> <span>nations,</span> <span>the</span> <span>US,</span> <span>Mexico,</span> <span>and</span> <span>Canada,<00:00:37.040><c></span> <span>are</c><00:00:37.280><c></span> <span>still</c><00:00:37.600><c></span> <span>holding</c><00:00:38.079><c></span> <span>talks</c><00:00:38.559><c></span> <span>over</c><00:00:38.800><c></span> <span>the</c></span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 30, 38.95, 0.0, 'Canada, are still holding talks over the', '', '', '<span>Canada,</span> <span>are</span> <span>still</span> <span>holding</span> <span>talks</span> <span>over</span> <span>the</span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 31, 38.96, 0.0, 'Canada, are still holding talks over the deal.<00:00:39.600><c> Last</c><00:00:39.920><c> year,</c><00:00:40.079><c> the</c><00:00:40.239><c> US</c><00:00:40.480><c> had</c><00:00:40.640><c> a</c><00:00:40.879><c> 46</c><00:00:41.440><c> billion</c>', '', '', '<span>Canada,</span> <span>are</span> <span>still</span> <span>holding</span> <span>talks</span> <span>over</span> <span>the</span> <span>deal.<00:00:39.600><c></span> <span>Last</c><00:00:39.920><c></span> <span>year,</c><00:00:40.079><c></span> <span>the</c><00:00:40.239><c></span> <span>US</c><00:00:40.480><c></span> <span>had</c><00:00:40.640><c></span> <span>a</c><00:00:40.879><c></span> <span>46</c><00:00:41.440><c></span> <span>billion</c></span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 32, 42.069, 0.0, 'deal. Last year, the US had a 46 billion', '', '', '<span>deal.</span> <span>Last</span> <span>year,</span> <span>the</span> <span>US</span> <span>had</span> <span>a</span> <span>46</span> <span>billion</span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 33, 42.079, 0.0, 'deal. Last year, the US had a 46 billion trade<00:00:42.480><c> deficit</c><00:00:42.960><c> with</c><00:00:43.200><c> Canada</c><00:00:43.920><c> and</c><00:00:44.079><c> a</c><00:00:44.879><c> 197</c>', '', '', '<span>deal.</span> <span>Last</span> <span>year,</span> <span>the</span> <span>US</span> <span>had</span> <span>a</span> <span>46</span> <span>billion</span> <span>trade<00:00:42.480><c></span> <span>deficit</c><00:00:42.960><c></span> <span>with</c><00:00:43.200><c></span> <span>Canada</c><00:00:43.920><c></span> <span>and</c><00:00:44.079><c></span> <span>a</c><00:00:44.879><c></span> <span>197</c></span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 34, 45.67, 0.0, 'trade deficit with Canada and a 197', '', '', '<span>trade</span> <span>deficit</span> <span>with</span> <span>Canada</span> <span>and</span> <span>a</span> <span>197</span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 35, 45.68, 0.0, 'trade deficit with Canada and a 197 billion<00:00:46.239><c> deficit</c><00:00:46.719><c> with</c><00:00:46.960><c> Mexico,</c><00:00:47.520><c> according</c>', '', '', '<span>trade</span> <span>deficit</span> <span>with</span> <span>Canada</span> <span>and</span> <span>a</span> <span>197</span> <span>billion<00:00:46.239><c></span> <span>deficit</c><00:00:46.719><c></span> <span>with</c><00:00:46.960><c></span> <span>Mexico,</c><00:00:47.520><c></span> <span>according</c></span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 36, 47.75, 0.0, 'billion deficit with Mexico, according', '', '', '<span>billion</span> <span>deficit</span> <span>with</span> <span>Mexico,</span> <span>according</span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 37, 47.76, 0.0, 'billion deficit with Mexico, according to<00:00:47.840><c> Reuters,</c><00:00:48.399><c> which</c><00:00:48.640><c> means</c><00:00:49.039><c> we</c><00:00:49.280><c> bought</c><00:00:49.520><c> more</c>', '', '', '<span>billion</span> <span>deficit</span> <span>with</span> <span>Mexico,</span> <span>according</span> <span>to<00:00:47.840><c></span> <span>Reuters,</c><00:00:48.399><c></span> <span>which</c><00:00:48.640><c></span> <span>means</c><00:00:49.039><c></span> <span>we</c><00:00:49.280><c></span> <span>bought</c><00:00:49.520><c></span> <span>more</c></span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 38, 49.75, 0.0, 'to Reuters, which means we bought more', '', '', '<span>to</span> <span>Reuters,</span> <span>which</span> <span>means</span> <span>we</span> <span>bought</span> <span>more</span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 39, 49.76, 0.0, 'to Reuters, which means we bought more than<00:00:50.000><c> those</c><00:00:50.320><c> from</c><00:00:50.640><c> those</c><00:00:50.879><c> countries</c><00:00:51.200><c> than</c>', '', '', '<span>to</span> <span>Reuters,</span> <span>which</span> <span>means</span> <span>we</span> <span>bought</span> <span>more</span> <span>than<00:00:50.000><c></span> <span>those</c><00:00:50.320><c></span> <span>from</c><00:00:50.640><c></span> <span>those</c><00:00:50.879><c></span> <span>countries</c><00:00:51.200><c></span> <span>than</c></span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 40, 51.43, 0.0, 'than those from those countries than', '', '', '<span>than</span> <span>those</span> <span>from</span> <span>those</span> <span>countries</span> <span>than</span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 41, 51.44, 0.0, 'than those from those countries than they<00:00:51.680><c> bought</c><00:00:52.000><c> from</c><00:00:52.160><c> us.</c><00:00:52.719><c> Well,</c><00:00:52.960><c> the</c><00:00:53.120><c> head</c><00:00:53.360><c> of</c>', '', '', '<span>than</span> <span>those</span> <span>from</span> <span>those</span> <span>countries</span> <span>than</span> <span>they<00:00:51.680><c></span> <span>bought</c><00:00:52.000><c></span> <span>from</c><00:00:52.160><c></span> <span>us.</c><00:00:52.719><c></span> <span>Well,</c><00:00:52.960><c></span> <span>the</c><00:00:53.120><c></span> <span>head</c><00:00:53.360><c></span> <span>of</c></span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 42, 53.43, 0.0, 'they bought from us. Well, the head of', '', '', '<span>they</span> <span>bought</span> <span>from</span> <span>us.</span> <span>Well,</span> <span>the</span> <span>head</span> <span>of</span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 43, 53.44, 0.0, 'they bought from us. Well, the head of Bank<00:00:53.680><c> of</c><00:00:53.840><c> America</c><00:00:54.399><c> walking</c><00:00:54.879><c> back</c><00:00:55.199><c> his</c>', '', '', '<span>they</span> <span>bought</span> <span>from</span> <span>us.</span> <span>Well,</span> <span>the</span> <span>head</span> <span>of</span> <span>Bank<00:00:53.680><c></span> <span>of</c><00:00:53.840><c></span> <span>America</c><00:00:54.399><c></span> <span>walking</c><00:00:54.879><c></span> <span>back</c><00:00:55.199><c></span> <span>his</c></span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 44, 55.51, 0.0, 'Bank of America walking back his', '', '', '<span>Bank</span> <span>of</span> <span>America</span> <span>walking</span> <span>back</span> <span>his</span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 45, 55.52, 0.0, 'Bank of America walking back his prediction<00:00:55.840><c> of</c><00:00:56.000><c> a</c><00:00:56.239><c> recession.</c><00:00:56.719><c> CEO</c><00:00:57.039><c> Brian</c>', '', '', '<span>Bank</span> <span>of</span> <span>America</span> <span>walking</span> <span>back</span> <span>his</span> <span>prediction<00:00:55.840><c></span> <span>of</c><00:00:56.000><c></span> <span>a</c><00:00:56.239><c></span> <span>recession.</c><00:00:56.719><c></span> <span>CEO</c><00:00:57.039><c></span> <span>Brian</c></span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 46, 57.27, 0.0, 'prediction of a recession. CEO Brian', '', '', '<span>prediction</span> <span>of</span> <span>a</span> <span>recession.</span> <span>CEO</span> <span>Brian</span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 47, 57.28, 0.0, 'prediction of a recession. CEO Brian Moyahan<00:00:58.160><c> argued</c><00:00:58.640><c> higher</c><00:00:58.960><c> interest</c><00:00:59.280><c> rates</c>', '', '', '<span>prediction</span> <span>of</span> <span>a</span> <span>recession.</span> <span>CEO</span> <span>Brian</span> <span>Moyahan<00:00:58.160><c></span> <span>argued</c><00:00:58.640><c></span> <span>higher</c><00:00:58.960><c></span> <span>interest</c><00:00:59.280><c></span> <span>rates</c></span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 48, 59.67, 0.0, 'Moyahan argued higher interest rates', '', '', '<span>Moyahan</span> <span>argued</span> <span>higher</span> <span>interest</span> <span>rates</span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 49, 59.68, 0.0, 'Moyahan argued higher interest rates reflect<00:01:00.079><c> a</c><00:01:00.399><c> strong</c><00:01:00.719><c> US</c><00:01:01.120><c> economy</c><00:01:01.840><c> and</c><00:01:02.000><c> the</c><00:01:02.160><c> new</c>', '', '', '<span>Moyahan</span> <span>argued</span> <span>higher</span> <span>interest</span> <span>rates</span> <span>reflect<00:01:00.079><c></span> <span>a</c><00:01:00.399><c></span> <span>strong</c><00:01:00.719><c></span> <span>US</c><00:01:01.120><c></span> <span>economy</c><00:01:01.840><c></span> <span>and</c><00:01:02.000><c></span> <span>the</c><00:01:02.160><c></span> <span>new</c></span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 50, 62.31, 0.0, 'reflect a strong US economy and the new', '', '', '<span>reflect</span> <span>a</span> <span>strong</span> <span>US</span> <span>economy</span> <span>and</span> <span>the</span> <span>new</span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 51, 62.32, 0.0, 'reflect a strong US economy and the new Fed<00:01:02.640><c> chair</c><00:01:03.039><c> Kevin</c><00:01:03.359><c> Worsh</c><00:01:03.840><c> he</c><00:01:04.000><c> says</c>', '', '', '<span>reflect</span> <span>a</span> <span>strong</span> <span>US</span> <span>economy</span> <span>and</span> <span>the</span> <span>new</span> <span>Fed<00:01:02.640><c></span> <span>chair</c><00:01:03.039><c></span> <span>Kevin</c><00:01:03.359><c></span> <span>Worsh</c><00:01:03.840><c></span> <span>he</c><00:01:04.000><c></span> <span>says</c></span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 52, 64.31, 0.0, 'Fed chair Kevin Worsh he says', '', '', '<span>Fed</span> <span>chair</span> <span>Kevin</span> <span>Worsh</span> <span>he</span> <span>says</span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 53, 64.32, 0.0, 'Fed chair Kevin Worsh he says prioritizes<00:01:05.119><c> price</c><00:01:05.439><c> stability.</c><00:01:06.159><c> Well,</c><00:01:06.320><c> the</c>', '', '', '<span>Fed</span> <span>chair</span> <span>Kevin</span> <span>Worsh</span> <span>he</span> <span>says</span> <span>prioritizes<00:01:05.119><c></span> <span>price</c><00:01:05.439><c></span> <span>stability.</c><00:01:06.159><c></span> <span>Well,</c><00:01:06.320><c></span> <span>the</c></span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 54, 66.469, 0.0, 'prioritizes price stability. Well, the', '', '', '<span>prioritizes</span> <span>price</span> <span>stability.</span> <span>Well,</span> <span>the</span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 55, 66.479, 0.0, 'prioritizes price stability. Well, the Dow<00:01:06.720><c> Jones</c><00:01:07.040><c> scaled</c><00:01:07.360><c> to</c><00:01:07.600><c> a</c><00:01:07.760><c> record</c><00:01:08.159><c> high</c><00:01:08.400><c> before</c>', '', '', '<span>prioritizes</span> <span>price</span> <span>stability.</span> <span>Well,</span> <span>the</span> <span>Dow<00:01:06.720><c></span> <span>Jones</c><00:01:07.040><c></span> <span>scaled</c><00:01:07.360><c></span> <span>to</c><00:01:07.600><c></span> <span>a</c><00:01:07.760><c></span> <span>record</c><00:01:08.159><c></span> <span>high</c><00:01:08.400><c></span> <span>before</c></span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 56, 68.789, 0.0, 'Dow Jones scaled to a record high before', '', '', '<span>Dow</span> <span>Jones</span> <span>scaled</span> <span>to</span> <span>a</span> <span>record</span> <span>high</span> <span>before</span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 57, 68.799, 0.0, 'Dow Jones scaled to a record high before cooling<00:01:09.200><c> yesterday.</c><00:01:09.920><c> The</c><00:01:10.159><c> NASDAQ</c><00:01:10.720><c> struggled</c>', '', '', '<span>Dow</span> <span>Jones</span> <span>scaled</span> <span>to</span> <span>a</span> <span>record</span> <span>high</span> <span>before</span> <span>cooling<00:01:09.200><c></span> <span>yesterday.</c><00:01:09.920><c></span> <span>The</c><00:01:10.159><c></span> <span>NASDAQ</c><00:01:10.720><c></span> <span>struggled</c></span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 58, 71.19, 0.0, 'cooling yesterday. The NASDAQ struggled', '', '', '<span>cooling</span> <span>yesterday.</span> <span>The</span> <span>NASDAQ</span> <span>struggled</span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 59, 71.2, 0.0, 'cooling yesterday. The NASDAQ struggled amid<00:01:11.520><c> declines</c><00:01:11.920><c> in</c><00:01:12.080><c> the</c><00:01:12.240><c> chip</c><00:01:12.560><c> makers.</c>', '', '', '<span>cooling</span> <span>yesterday.</span> <span>The</span> <span>NASDAQ</span> <span>struggled</span> <span>amid<00:01:11.520><c></span> <span>declines</c><00:01:11.920><c></span> <span>in</c><00:01:12.080><c></span> <span>the</c><00:01:12.240><c></span> <span>chip</c><00:01:12.560><c></span> <span>makers.</c></span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 60, 73.19, 0.0, 'amid declines in the chip makers.', '', '', '<span>amid</span> <span>declines</span> <span>in</span> <span>the</span> <span>chip</span> <span>makers.</span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 61, 73.2, 0.0, 'amid declines in the chip makers. Investors<00:01:13.840><c> sat</c><00:01:14.159><c> on</c><00:01:14.320><c> the</c><00:01:14.479><c> sidelines</c><00:01:14.880><c> ahead</c><00:01:15.119><c> of</c>', '', '', '<span>amid</span> <span>declines</span> <span>in</span> <span>the</span> <span>chip</span> <span>makers.</span> <span>Investors<00:01:13.840><c></span> <span>sat</c><00:01:14.159><c></span> <span>on</c><00:01:14.320><c></span> <span>the</c><00:01:14.479><c></span> <span>sidelines</c><00:01:14.880><c></span> <span>ahead</c><00:01:15.119><c></span> <span>of</c></span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 62, 75.19, 0.0, 'Investors sat on the sidelines ahead of', '', '', '<span>Investors</span> <span>sat</span> <span>on</span> <span>the</span> <span>sidelines</span> <span>ahead</span> <span>of</span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 63, 75.2, 0.0, 'Investors sat on the sidelines ahead of the<00:01:15.360><c> jobs</c><00:01:15.760><c> report</c><00:01:16.080><c> today</c><00:01:16.400><c> as</c><00:01:16.640><c> well.</c><00:01:17.200><c> The</c>', '', '', '<span>Investors</span> <span>sat</span> <span>on</span> <span>the</span> <span>sidelines</span> <span>ahead</span> <span>of</span> <span>the<00:01:15.360><c></span> <span>jobs</c><00:01:15.760><c></span> <span>report</c><00:01:16.080><c></span> <span>today</c><00:01:16.400><c></span> <span>as</c><00:01:16.640><c></span> <span>well.</c><00:01:17.200><c></span> <span>The</c></span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 64, 77.429, 0.0, 'the jobs report today as well. The', '', '', '<span>the</span> <span>jobs</span> <span>report</span> <span>today</span> <span>as</span> <span>well.</span> <span>The</span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 65, 77.439, 0.0, 'the jobs report today as well. The markets<00:01:17.759><c> will</c><00:01:17.920><c> be</c><00:01:18.080><c> closed</c><00:01:18.479><c> tomorrow</c><00:01:19.119><c> in</c>', '', '', '<span>the</span> <span>jobs</span> <span>report</span> <span>today</span> <span>as</span> <span>well.</span> <span>The</span> <span>markets<00:01:17.759><c></span> <span>will</c><00:01:17.920><c></span> <span>be</c><00:01:18.080><c></span> <span>closed</c><00:01:18.479><c></span> <span>tomorrow</c><00:01:19.119><c></span> <span>in</c></span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 66, 79.429, 0.0, 'markets will be closed tomorrow in', '', '', '<span>markets</span> <span>will</span> <span>be</span> <span>closed</span> <span>tomorrow</span> <span>in</span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 67, 79.439, 0.0, 'markets will be closed tomorrow in observance<00:01:20.000><c> of</c><00:01:20.240><c> Independence</c><00:01:20.799><c> Day.</c><00:01:21.360><c> Well,</c><00:01:21.600><c> J</c>', '', '', '<span>markets</span> <span>will</span> <span>be</span> <span>closed</span> <span>tomorrow</span> <span>in</span> <span>observance<00:01:20.000><c></span> <span>of</c><00:01:20.240><c></span> <span>Independence</c><00:01:20.799><c></span> <span>Day.</c><00:01:21.360><c></span> <span>Well,</c><00:01:21.600><c></span> <span>J</c></span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 68, 81.59, 0.0, 'observance of Independence Day. Well, J', '', '', '<span>observance</span> <span>of</span> <span>Independence</span> <span>Day.</span> <span>Well,</span> <span>J</span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 69, 81.6, 0.0, 'observance of Independence Day. Well, J C<00:01:21.920><c> Penney</c><00:01:22.240><c> is</c><00:01:22.400><c> closing</c><00:01:22.720><c> some</c><00:01:22.960><c> stores</c><00:01:23.280><c> and</c>', '', '', '<span>observance</span> <span>of</span> <span>Independence</span> <span>Day.</span> <span>Well,</span> <span>J</span> <span>C<00:01:21.920><c></span> <span>Penney</c><00:01:22.240><c></span> <span>is</c><00:01:22.400><c></span> <span>closing</c><00:01:22.720><c></span> <span>some</c><00:01:22.960><c></span> <span>stores</c><00:01:23.280><c></span> <span>and</c></span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 70, 83.51, 0.0, 'C Penney is closing some stores and', '', '', '<span>C</span> <span>Penney</span> <span>is</span> <span>closing</span> <span>some</span> <span>stores</span> <span>and</span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 71, 83.52, 0.0, 'C Penney is closing some stores and shoppers<00:01:23.920><c> are</c><00:01:24.080><c> snapping</c><00:01:24.400><c> up</c><00:01:24.640><c> deals.</c><00:01:24.960><c> The</c><00:01:25.119><c> New</c>', '', '', '<span>C</span> <span>Penney</span> <span>is</span> <span>closing</span> <span>some</span> <span>stores</span> <span>and</span> <span>shoppers<00:01:23.920><c></span> <span>are</c><00:01:24.080><c></span> <span>snapping</c><00:01:24.400><c></span> <span>up</c><00:01:24.640><c></span> <span>deals.</c><00:01:24.960><c></span> <span>The</c><00:01:25.119><c></span> <span>New</c></span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 72, 85.27, 0.0, 'shoppers are snapping up deals. The New', '', '', '<span>shoppers</span> <span>are</span> <span>snapping</span> <span>up</span> <span>deals.</span> <span>The</span> <span>New</span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 73, 85.28, 0.0, 'shoppers are snapping up deals. The New York<00:01:25.439><c> Post</c><00:01:25.680><c> says</c><00:01:26.080><c> some</c><00:01:26.400><c> items</c><00:01:26.720><c> are</c><00:01:27.040><c> 88%</c><00:01:27.840><c> off.</c>', '', '', '<span>shoppers</span> <span>are</span> <span>snapping</span> <span>up</span> <span>deals.</span> <span>The</span> <span>New</span> <span>York<00:01:25.439><c></span> <span>Post</c><00:01:25.680><c></span> <span>says</c><00:01:26.080><c></span> <span>some</c><00:01:26.400><c></span> <span>items</c><00:01:26.720><c></span> <span>are</c><00:01:27.040><c></span> <span>88%</c><00:01:27.840><c></span> <span>off.</c></span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 74, 88.469, 0.0, 'York Post says some items are 88% off.', '', '', '<span>York</span> <span>Post</span> <span>says</span> <span>some</span> <span>items</span> <span>are</span> <span>88%</span> <span>off.</span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 75, 88.479, 0.0, 'York Post says some items are 88% off. For<00:01:28.720><c> decades,</c><00:01:29.200><c> J.</c><00:01:29.360><c> C.</c><00:01:29.520><c> Penney</c><00:01:29.840><c> was</c><00:01:30.080><c> a</c><00:01:30.320><c> staple</c>', '', '', '<span>York</span> <span>Post</span> <span>says</span> <span>some</span> <span>items</span> <span>are</span> <span>88%</span> <span>off.</span> <span>For<00:01:28.720><c></span> <span>decades,</c><00:01:29.200><c></span> <span>J.</c><00:01:29.360><c></span> <span>C.</c><00:01:29.520><c></span> <span>Penney</c><00:01:29.840><c></span> <span>was</c><00:01:30.080><c></span> <span>a</c><00:01:30.320><c></span> <span>staple</c></span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 76, 90.87, 0.0, 'For decades, J. C. Penney was a staple', '', '', '<span>For</span> <span>decades,</span> <span>J.</span> <span>C.</span> <span>Penney</span> <span>was</span> <span>a</span> <span>staple</span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 77, 90.88, 0.0, 'For decades, J. C. Penney was a staple anchor<00:01:31.360><c> store</c><00:01:31.680><c> in</c><00:01:31.920><c> suburban</c><00:01:32.400><c> malls</c><00:01:32.799><c> across</c>', '', '', '<span>For</span> <span>decades,</span> <span>J.</span> <span>C.</span> <span>Penney</span> <span>was</span> <span>a</span> <span>staple</span> <span>anchor<00:01:31.360><c></span> <span>store</c><00:01:31.680><c></span> <span>in</c><00:01:31.920><c></span> <span>suburban</c><00:01:32.400><c></span> <span>malls</c><00:01:32.799><c></span> <span>across</c></span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 78, 93.109, 0.0, 'anchor store in suburban malls across', '', '', '<span>anchor</span> <span>store</span> <span>in</span> <span>suburban</span> <span>malls</span> <span>across</span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 79, 93.119, 0.0, 'anchor store in suburban malls across the<00:01:33.280><c> US</c><00:01:33.600><c> as</c><00:01:34.079><c> online</c><00:01:34.640><c> shopping</c><00:01:35.040><c> grew</c><00:01:35.600><c> and</c><00:01:35.759><c> the</c>', '', '', '<span>anchor</span> <span>store</span> <span>in</span> <span>suburban</span> <span>malls</span> <span>across</span> <span>the<00:01:33.280><c></span> <span>US</c><00:01:33.600><c></span> <span>as</c><00:01:34.079><c></span> <span>online</c><00:01:34.640><c></span> <span>shopping</c><00:01:35.040><c></span> <span>grew</c><00:01:35.600><c></span> <span>and</c><00:01:35.759><c></span> <span>the</c></span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 80, 95.99, 0.0, 'the US as online shopping grew and the', '', '', '<span>the</span> <span>US</span> <span>as</span> <span>online</span> <span>shopping</span> <span>grew</span> <span>and</span> <span>the</span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 81, 96.0, 0.0, 'the US as online shopping grew and the company<00:01:36.320><c> struggled</c><00:01:36.720><c> with</c><00:01:36.880><c> debt.</c><00:01:37.439><c> Well,</c><00:01:37.759><c> World</c>', '', '', '<span>the</span> <span>US</span> <span>as</span> <span>online</span> <span>shopping</span> <span>grew</span> <span>and</span> <span>the</span> <span>company<00:01:36.320><c></span> <span>struggled</c><00:01:36.720><c></span> <span>with</c><00:01:36.880><c></span> <span>debt.</c><00:01:37.439><c></span> <span>Well,</c><00:01:37.759><c></span> <span>World</c></span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 82, 97.99, 0.0, 'company struggled with debt. Well, World', '', '', '<span>company</span> <span>struggled</span> <span>with</span> <span>debt.</span> <span>Well,</span> <span>World</span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 83, 98.0, 0.0, 'company struggled with debt. Well, World Cup<00:01:38.320><c> spectators</c><00:01:38.880><c> have</c><00:01:39.040><c> developed</c><00:01:39.360><c> a</c><00:01:39.600><c> taste</c>', '', '', '<span>company</span> <span>struggled</span> <span>with</span> <span>debt.</span> <span>Well,</span> <span>World</span> <span>Cup<00:01:38.320><c></span> <span>spectators</c><00:01:38.880><c></span> <span>have</c><00:01:39.040><c></span> <span>developed</c><00:01:39.360><c></span> <span>a</c><00:01:39.600><c></span> <span>taste</c></span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 84, 99.91, 0.0, 'Cup spectators have developed a taste', '', '', '<span>Cup</span> <span>spectators</span> <span>have</span> <span>developed</span> <span>a</span> <span>taste</span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 85, 99.92, 0.0, 'Cup spectators have developed a taste for<00:01:40.240><c> ranch</c><00:01:40.640><c> dressing</c><00:01:41.040><c> while</c><00:01:41.280><c> visiting</c><00:01:41.600><c> the</c><00:01:41.840><c> US</c>', '', '', '<span>Cup</span> <span>spectators</span> <span>have</span> <span>developed</span> <span>a</span> <span>taste</span> <span>for<00:01:40.240><c></span> <span>ranch</c><00:01:40.640><c></span> <span>dressing</c><00:01:41.040><c></span> <span>while</c><00:01:41.280><c></span> <span>visiting</c><00:01:41.600><c></span> <span>the</c><00:01:41.840><c></span> <span>US</c></span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 86, 101.99, 0.0, 'for ranch dressing while visiting the US', '', '', '<span>for</span> <span>ranch</span> <span>dressing</span> <span>while</span> <span>visiting</span> <span>the</span> <span>US</span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 87, 102.0, 0.0, 'for ranch dressing while visiting the US for<00:01:42.240><c> games.</c><00:01:42.799><c> They''ve</c><00:01:43.040><c> been</c><00:01:43.200><c> on</c><00:01:43.360><c> social</c><00:01:43.600><c> media</c>', '', '', '<span>for</span> <span>ranch</span> <span>dressing</span> <span>while</span> <span>visiting</span> <span>the</span> <span>US</span> <span>for<00:01:42.240><c></span> <span>games.</c><00:01:42.799><c></span> <span>They''ve</c><00:01:43.040><c></span> <span>been</c><00:01:43.200><c></span> <span>on</c><00:01:43.360><c></span> <span>social</c><00:01:43.600><c></span> <span>media</c></span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 88, 104.069, 0.0, 'for games. They''ve been on social media', '', '', '<span>for</span> <span>games.</span> <span>They''ve</span> <span>been</span> <span>on</span> <span>social</span> <span>media</span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 89, 104.079, 0.0, 'for games. They''ve been on social media talking<00:01:44.400><c> about</c><00:01:44.720><c> how</c><00:01:44.960><c> amazing</c><00:01:45.360><c> it</c><00:01:45.600><c> is.</c><00:01:46.240><c> Some</c>', '', '', '<span>for</span> <span>games.</span> <span>They''ve</span> <span>been</span> <span>on</span> <span>social</span> <span>media</span> <span>talking<00:01:44.400><c></span> <span>about</c><00:01:44.720><c></span> <span>how</c><00:01:44.960><c></span> <span>amazing</c><00:01:45.360><c></span> <span>it</c><00:01:45.600><c></span> <span>is.</c><00:01:46.240><c></span> <span>Some</c></span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 90, 106.55, 0.0, 'talking about how amazing it is. Some', '', '', '<span>talking</span> <span>about</span> <span>how</span> <span>amazing</span> <span>it</span> <span>is.</span> <span>Some</span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 91, 106.56, 0.0, 'talking about how amazing it is. Some airport<00:01:46.960><c> shops</c><00:01:47.280><c> are</c><00:01:47.439><c> now</c><00:01:47.680><c> selling</c><00:01:48.079><c> ranch</c><00:01:48.479><c> to</c>', '', '', '<span>talking</span> <span>about</span> <span>how</span> <span>amazing</span> <span>it</span> <span>is.</span> <span>Some</span> <span>airport<00:01:46.960><c></span> <span>shops</c><00:01:47.280><c></span> <span>are</c><00:01:47.439><c></span> <span>now</c><00:01:47.680><c></span> <span>selling</c><00:01:48.079><c></span> <span>ranch</c><00:01:48.479><c></span> <span>to</c></span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 92, 108.71, 0.0, 'airport shops are now selling ranch to', '', '', '<span>airport</span> <span>shops</span> <span>are</span> <span>now</span> <span>selling</span> <span>ranch</span> <span>to</span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 93, 108.72, 0.0, 'airport shops are now selling ranch to meet<00:01:48.960><c> demand</c><00:01:49.439><c> from</c><00:01:49.680><c> travelers.</c><00:01:50.479><c> The</c><00:01:50.640><c> TSA</c>', '', '', '<span>airport</span> <span>shops</span> <span>are</span> <span>now</span> <span>selling</span> <span>ranch</span> <span>to</span> <span>meet<00:01:48.960><c></span> <span>demand</c><00:01:49.439><c></span> <span>from</c><00:01:49.680><c></span> <span>travelers.</c><00:01:50.479><c></span> <span>The</c><00:01:50.640><c></span> <span>TSA</c></span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 94, 111.27, 0.0, 'meet demand from travelers. The TSA', '', '', '<span>meet</span> <span>demand</span> <span>from</span> <span>travelers.</span> <span>The</span> <span>TSA</span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 95, 111.28, 0.0, 'meet demand from travelers. The TSA reminded<00:01:51.680><c> visitors</c><00:01:52.399><c> not</c><00:01:52.720><c> to</c><00:01:52.880><c> pack</c><00:01:53.280><c> ranch</c>', '', '', '<span>meet</span> <span>demand</span> <span>from</span> <span>travelers.</span> <span>The</span> <span>TSA</span> <span>reminded<00:01:51.680><c></span> <span>visitors</c><00:01:52.399><c></span> <span>not</c><00:01:52.720><c></span> <span>to</c><00:01:52.880><c></span> <span>pack</c><00:01:53.280><c></span> <span>ranch</c></span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 96, 113.67, 0.0, 'reminded visitors not to pack ranch', '', '', '<span>reminded</span> <span>visitors</span> <span>not</span> <span>to</span> <span>pack</span> <span>ranch</span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 97, 113.68, 0.0, 'reminded visitors not to pack ranch dressing<00:01:54.000><c> in</c><00:01:54.159><c> their</c><00:01:54.320><c> carry-ons.</c>', '', '', '<span>reminded</span> <span>visitors</span> <span>not</span> <span>to</span> <span>pack</span> <span>ranch</span> <span>dressing<00:01:54.000><c></span> <span>in</c><00:01:54.159><c></span> <span>their</c><00:01:54.320><c></span> <span>carry-ons.</c></span>'
FROM episodes e WHERE e.video_id = 'Nsl7OCGum9FSB2U';

-- sync id sequences if present
SELECT setval(
  pg_get_serial_sequence('tags', 'id'),
  GREATEST(COALESCE((SELECT MAX(id) FROM tags), 1), 1)
) WHERE pg_get_serial_sequence('tags', 'id') IS NOT NULL;
SELECT setval(
  pg_get_serial_sequence('subtitles', 'id'),
  GREATEST(COALESCE((SELECT MAX(id) FROM subtitles), 1), 1)
) WHERE pg_get_serial_sequence('subtitles', 'id') IS NOT NULL;

COMMIT;

-- imported video_ids: Nsl7OCGum9FSB2U
