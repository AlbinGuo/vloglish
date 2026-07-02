-- vlogish episode import SQL
-- generated: 2026-07-02T16:13:13.191698Z
-- episodes: 5 (index 191..195)
-- Run on production PostgreSQL inside transaction.

BEGIN;

INSERT INTO authors (name, gender, nationality, accent)
SELECT '孫燕姿國際後援會 Stefanie Sun Yanzi International Fan Club', 'f', '🇺🇸', '美国'
WHERE NOT EXISTS (
  SELECT 1 FROM authors x
  WHERE x.name = '孫燕姿國際後援會 Stefanie Sun Yanzi International Fan Club' AND x.accent = '美国'
);
INSERT INTO authors (name, gender, nationality, accent)
SELECT 'Jimmy Kimmel Live', 'm', '', '美国'
WHERE NOT EXISTS (
  SELECT 1 FROM authors x
  WHERE x.name = 'Jimmy Kimmel Live' AND x.accent = '美国'
);
INSERT INTO authors (name, gender, nationality, accent)
SELECT 'Campus Movie Fest', 'm', '', '美国'
WHERE NOT EXISTS (
  SELECT 1 FROM authors x
  WHERE x.name = 'Campus Movie Fest' AND x.accent = '美国'
);
INSERT INTO authors (name, gender, nationality, accent)
SELECT 'News', 'f', '🇺🇸', '美国'
WHERE NOT EXISTS (
  SELECT 1 FROM authors x
  WHERE x.name = 'News' AND x.accent = '美国'
);
INSERT INTO authors (name, gender, nationality, accent)
SELECT '飞翔xmfly', 'm', '', '美国'
WHERE NOT EXISTS (
  SELECT 1 FROM authors x
  WHERE x.name = '飞翔xmfly' AND x.accent = '美国'
);

INSERT INTO tags (id, name)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM tags), '采访'
WHERE NOT EXISTS (SELECT 1 FROM tags WHERE name = '采访');

-- episode 191: pgdzTec-K5LxriI
INSERT INTO episodes (
  index, video_id, short_title, summary, remark, stars, voca_size,
  subtitle_count, clip_length, cover, video_url, audio_url, thumbnail_url,
  original_video_url, author_id, submitted_by_user_id, rejection_reason,
  created_at, is_demo, status, published_at
) VALUES (
  191, 'pgdzTec-K5LxriI', '孙燕姿英文-分享快乐秘诀',
  '【中文字幕】Kindversations Ep6 Stefanie Sun shares her secret to happiness 孫燕姿分享快樂秘訣', '',
  3, 0, 372,
  0.0, 'http://oss.sxakgs.com/en/OGMiPimlZzk/cover.webp',
  'http://oss.sxakgs.com/en/OGMiPimlZzk/video.mp4', 'http://oss.sxakgs.com/en/OGMiPimlZzk/audio.mp3',
  'http://oss.sxakgs.com/en/OGMiPimlZzk/cover.webp', 'https://www.youtube.com/watch?v=OGMiPimlZzk',
  (SELECT id FROM authors WHERE name = '孫燕姿國際後援會 Stefanie Sun Yanzi International Fan Club' AND accent = '美国' LIMIT 1),
  NULL, NULL,
  '2026-07-02 15:33:11'::timestamp,
  FALSE, 'published',
  '2026-07-02 15:33:11'::timestamp
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
  SELECT s.id FROM subtitles s JOIN episodes e ON s.episode_id = e.id WHERE e.video_id = 'pgdzTec-K5LxriI'
);
DELETE FROM subtitles WHERE episode_id = (SELECT id FROM episodes WHERE video_id = 'pgdzTec-K5LxriI');
DELETE FROM episode_tags WHERE episode_id = (SELECT id FROM episodes WHERE video_id = 'pgdzTec-K5LxriI');

INSERT INTO episode_tags (episode_id, tag_id)
SELECT e.id, t.id FROM episodes e, tags t
WHERE e.video_id = 'pgdzTec-K5LxriI' AND t.name = '采访'
ON CONFLICT DO NOTHING;
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 0, 8.71, 0.0, 'Hi, I''m Sarah and 11 years old. I go to', '嗨，我是莎拉，11岁。我去', '/haɪ aɪm ˈsɛrə ænd ɪˈlɛvən jɪrz oʊld aɪ ɡoʊ tu/', '<span>Hi</span><span>,</span><span>I</span><span>''m</span><span>Sarah</span><span>and</span><span>11</span><span>years</span><span>old</span><span>.</span><span>I</span><span>go</span><span>to</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 1, 8.72, 0.0, 'Hi, I''m Sarah and 11 years old. I go to SCGS.<00:00:09.720><c> I</c><00:00:09.880><c> am</c><00:00:10.040><c> in</c><00:00:10.160><c> a</c><00:00:10.200><c> choir</c><00:00:10.560><c> and</c><00:00:10.760><c> I</c><00:00:10.800><c> love</c><00:00:11.120><c> to</c>', '嗨，我是莎拉，11岁。我去SCGS。我参加了一个合唱团，我喜欢', '/haɪ aɪm ˈsɛrə ænd ɪˈlɛvən jɪrz oʊld aɪ ɡoʊ tu ɛs si dʒi ɛs aɪ æm ɪn ə ˈkwaɪər ænd aɪ lʌv tu/', '<span>Hi,</span><span>I''m</span><span>Sarah</span><span>and</span><span>11</span><span>years</span><span>old.</span><span>I</span><span>go</span><span>to</span><span>SCGS.<00:00:09.720><c></span><span>I</c><00:00:09.880><c></span><span>am</c><00:00:10.040><c></span><span>in</c><00:00:10.160><c></span><span>a</c><00:00:10.200><c></span><span>choir</c><00:00:10.560><c></span><span>and</c><00:00:10.760><c></span><span>I</c><00:00:10.800><c></span><span>love</c><00:00:11.120><c></span><span>to</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 2, 11.23, 0.0, 'SCGS. I am in a choir and I love to', 'SCGS。我参加了一个合唱团，我喜欢', '/ɛs si dʒi ɛs aɪ æm ɪn ə ˈkwaɪər ænd aɪ lʌv tu/', '<span tid="50001" class="highlight highlight-a">SCGS</span><span>.</span><span>I</span><span>am</span><span>in</span><span>a</span><span tid="50002" class="highlight highlight-a">choir</span><span>and</span><span>I</span><span>love</span><span>to</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 3, 11.24, 0.0, 'SCGS. I am in a choir and I love to sing.<00:00:11.760><c> So,</c><00:00:12.160><c> I</c><00:00:12.320><c> am</c><00:00:12.480><c> very</c><00:00:12.800><c> excited</c><00:00:13.360><c> to</c><00:00:13.480><c> talk</c><00:00:13.760><c> to</c><00:00:13.920><c> a</c>', 'SCGS。我参加了一个合唱团，我喜欢唱歌。所以，我非常兴奋能', '/ɛs si dʒi ɛs aɪ æm ɪn ə ˈkwaɪər ænd aɪ lʌv tu sɪŋ soʊ aɪ æm ˈvɛri ɪkˈsaɪtɪd tu tɔːk tu ə/', '<span>SCGS.</span><span>I</span><span>am</span><span>in</span><span>a</span><span>choir</span><span>and</span><span>I</span><span>love</span><span>to</span><span>sing.<00:00:11.760><c></span><span>So,</c><00:00:12.160><c></span><span>I</c><00:00:12.320><c></span><span>am</c><00:00:12.480><c></span><span>very</c><00:00:12.800><c></span><span>excited</c><00:00:13.360><c></span><span>to</c><00:00:13.480><c></span><span>talk</c><00:00:13.760><c></span><span>to</c><00:00:13.920><c></span><span>a</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 4, 13.99, 0.0, 'sing. So, I am very excited to talk to a', '唱歌。所以，我非常兴奋能', '/sɪŋ soʊ aɪ æm ˈvɛri ɪkˈsaɪtɪd tu tɔːk tu ə/', '<span tid="50003" class="highlight highlight-a">sing</span><span>.</span><span>So</span><span>,</span><span>I</span><span>am</span><span>very</span><span tid="50004" class="highlight highlight-a">excited</span><span>to</span><span>talk</span><span>to</span><span>a</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 5, 14.0, 0.0, 'sing. So, I am very excited to talk to a very<00:00:14.400><c> famous</c><00:00:14.760><c> singer</c><00:00:15.040><c> today.</c><00:00:15.720><c> She</c><00:00:15.920><c> is</c><00:00:16.040><c> none</c>', '唱歌。所以，我非常兴奋能和一个非常著名的歌手交谈今天。她不是别人', '/sɪŋ soʊ aɪ æm ˈvɛri ɪkˈsaɪtɪd tu tɔːk tu ə ˈvɛri ˈfeɪməs ˈsɪŋər təˈdeɪ ʃi ɪz nʌn/', '<span>sing.</span><span>So,</span><span>I</span><span>am</span><span>very</span><span>excited</span><span>to</span><span>talk</span><span>to</span><span>a</span><span>very<00:00:14.400><c></span><span>famous</c><00:00:14.760><c></span><span>singer</c><00:00:15.040><c></span><span>today.</c><00:00:15.720><c></span><span>She</c><00:00:15.920><c></span><span>is</c><00:00:16.040><c></span><span>none</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 6, 16.31, 0.0, 'very famous singer today. She is none', '非常著名的歌手今天。她不是别人', '/ˈvɛri ˈfeɪməs ˈsɪŋər təˈdeɪ ʃi ɪz nʌn/', '<span>very</span><span tid="50005" class="highlight highlight-a">famous</span><span tid="50006" class="highlight highlight-a">singer</span><span>today</span><span>.</span><span>She</span><span>is</span><span>none</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 7, 16.32, 0.0, 'very famous singer today. She is none other<00:00:16.560><c> than</c><00:00:16.720><c> Singapore''s</c><00:00:17.280><c> Mandopop</c><00:00:17.960><c> queen,</c>', '非常著名的歌手今天。她不是别人，正是新加坡的华语流行乐女王，', '/ˈvɛri ˈfeɪməs ˈsɪŋər təˈdeɪ ʃi ɪz nʌn ˈʌðər ðæn ˌsɪŋəˈpɔːrz ˈmændoʊpɑp kwiːn/', '<span>very</span><span>famous</span><span>singer</span><span>today.</span><span>She</span><span>is</span><span>none</span><span>other<00:00:16.560><c></span><span>than</c><00:00:16.720><c></span><span>Singapore''s</c><00:00:17.280><c></span><span>Mandopop</c><00:00:17.960><c></span><span>queen,</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 8, 18.35, 0.0, 'other than Singapore''s Mandopop queen,', '不是别人，正是新加坡的华语流行乐女王，', '/ˈʌðər ðæn ˌsɪŋəˈpɔːrz ˈmændoʊpɑp kwiːn/', '<span pid="501" class="highlight highlight-c">other than</span><span>Singapore''s</span><span tid="50007" class="highlight highlight-a">Mandopop</span><span>queen,</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 9, 18.36, 0.0, 'other than Singapore''s Mandopop queen, Stefanie<00:00:18.840><c> Sun.</c><00:00:19.240><c> Who</c><00:00:19.480><c> are</c><00:00:19.560><c> your</c><00:00:19.720><c> favorite</c>', '不是别人，正是新加坡的华语流行乐女王，孙燕姿。你最喜欢的', '/ˈʌðər ðæn ˌsɪŋəˈpɔːrz ˈmændoʊpɑp kwiːn ˈstɛfəni sʌn huː ɑːr jɔːr ˈfeɪvərɪt/', '<span>other</span><span>than</span><span>Singapore''s</span><span>Mandopop</span><span>queen,</span><span>Stefanie<00:00:18.840><c></span><span>Sun.</c><00:00:19.240><c></span><span>Who</c><00:00:19.480><c></span><span>are</c><00:00:19.560><c></span><span>your</c><00:00:19.720><c></span><span>favorite</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 10, 20.19, 0.0, 'Stefanie Sun. Who are your favorite', '孙燕姿。你最喜欢的', '/ˈstɛfəni sʌn huː ɑːr jɔːr ˈfeɪvərɪt/', '<span>Stefanie</span><span>Sun.</span><span>Who</span><span>are</span><span>your</span><span>favorite</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 11, 20.2, 0.0, 'Stefanie Sun. Who are your favorite artists<00:00:20.600><c> when</c><00:00:20.800><c> you</c><00:00:20.920><c> were</c><00:00:21.040><c> my</c><00:00:21.400><c> age?</c>', '孙燕姿。你最喜欢的歌手在你像我这么大的时候？', '/ˈstɛfəni sʌn huː ɑːr jɔːr ˈfeɪvərɪt ˈɑːrtɪsts wɛn juː wɜːr maɪ eɪdʒ/', '<span>Stefanie</span><span>Sun.</span><span>Who</span><span>are</span><span>your</span><span>favorite</span><span>artists<00:00:20.600><c></span><span>when</c><00:00:20.800><c></span><span>you</c><00:00:20.920><c></span><span>were</c><00:00:21.040><c></span><span>my</c><00:00:21.400><c></span><span>age?</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 12, 22.07, 0.0, 'artists when you were my age?', '歌手在你像我这么大的时候？', '/ˈɑːrtɪsts wɛn juː wɜːr maɪ eɪdʒ/', '<span>artists</span><span>when</span><span>you</span><span>were</span><span>my</span><span>age?</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 13, 22.08, 0.0, 'artists when you were my age? How<00:00:22.200><c> old</c><00:00:22.360><c> are</c><00:00:22.440><c> you?</c>', '歌手在你像我这么大的时候？你多大了？', '/ˈɑːrtɪsts wɛn juː wɜːr maɪ eɪdʒ haʊ oʊld ɑːr juː/', '<span>artists</span><span>when</span><span>you</span><span>were</span><span>my</span><span>age?</span><span>How<00:00:22.200><c></span><span>old</c><00:00:22.360><c></span><span>are</c><00:00:22.440><c></span><span>you?</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 14, 22.95, 0.0, 'How old are you?', '你多大了？', '/haʊ oʊld ɑːr juː/', '<span>How</span><span>old</span><span>are</span><span>you?</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 15, 22.96, 0.0, 'How old are you? 11.', '你多大了？11。', '/haʊ oʊld ɑːr juː ɪˈlɛvən/', '<span>How</span><span>old</span><span>are</span><span>you?</span><span>11.</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 16, 24.67, 0.0, '11.', '11。', '/ɪˈlɛvən/', '<span>11.</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 17, 24.68, 0.0, '11. 11,<00:00:25.120><c> that</c><00:00:25.280><c> would</c><00:00:25.440><c> be</c><00:00:26.480><c> primary</c><00:00:27.040><c> five?</c>', '11。11，那应该是五年级？', '/ɪˈlɛvən ɪˈlɛvən ðæt wʊd biː ˈpraɪmɛri faɪv/', '<span>11.</span><span>11,<00:00:25.120><c></span><span>that</c><00:00:25.280><c></span><span>would</c><00:00:25.440><c></span><span>be</c><00:00:26.480><c></span><span>primary</c><00:00:27.040><c></span><span>five?</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 18, 27.75, 0.0, '11, that would be primary five?', '11，那应该是五年级？', '/ɪˈlɛvən ðæt wʊd biː ˈpraɪmɛri faɪv/', '<span>11,</span><span>that</span><span>would</span><span>be</span><span tid="50008" class="highlight highlight-a">primary</span><span>five?</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 19, 27.76, 0.0, '11, that would be primary five? Yeah.', '11，那应该是五年级？是的。', '/ɪˈlɛvən ðæt wʊd biː ˈpraɪmɛri faɪv jɛə/', '<span>11,</span><span>that</span><span>would</span><span>be</span><span tid="50009" class="highlight highlight-a">primary</span><span>five?</span><span>Yeah.</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 20, 28.51, 0.0, 'Yeah.', '是的。', '/jɛə/', '<span>Yeah.</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 21, 28.52, 0.0, 'Yeah. Primary<00:00:28.840><c> five,</c><00:00:29.080><c> I</c><00:00:29.120><c> remember</c><00:00:29.440><c> I</c><00:00:29.480><c> had</c><00:00:29.680><c> my</c><00:00:29.880><c> first</c>', '是的。五年级，我记得我有我的第一', '/jɛə ˈpraɪmɛri faɪv aɪ rɪˈmɛmbər aɪ hæd maɪ fɜːrst/', '<span>Yeah.</span><span>Primary<00:00:28.840><c></span><span>five,</c><00:00:29.080><c></span><span>I</c><00:00:29.120><c></span><span>remember</c><00:00:29.440><c></span><span>I</c><00:00:29.480><c></span><span>had</c><00:00:29.680><c></span><span>my</c><00:00:29.880><c></span><span>first</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 22, 31.27, 0.0, 'Primary five, I remember I had my first', '五年级，我记得我有我的第一', '/ˈpraɪmɛri faɪv aɪ rɪˈmɛmbər aɪ hæd maɪ fɜːrst/', '<span tid="50010" class="highlight highlight-a">Primary</span><span>five,</span><span>I</span><span>remember</span><span>I</span><span>had</span><span>my</span><span>first</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 23, 31.28, 0.0, 'Primary five, I remember I had my first cassette<00:00:31.800><c> tape.</c><00:00:32.080><c> Do</c><00:00:32.119><c> you</c><00:00:32.200><c> know</c><00:00:32.279><c> what</c><00:00:32.400><c> a</c>', '五年级，我记得我有我的第一盒磁带。你知道什么是', '/ˈpraɪmɛri faɪv aɪ rɪˈmɛmbər aɪ hæd maɪ fɜːrst kəˈsɛt teɪp duː juː noʊ wʌt ə/', '<span>Primary</span><span>five,</span><span>I</span><span>remember</span><span>I</span><span>had</span><span>my</span><span>first</span><span>cassette<00:00:31.800><c></span><span>tape.</c><00:00:32.080><c></span><span>Do</c><00:00:32.119><c></span><span>you</c><00:00:32.200><c></span><span>know</c><00:00:32.279><c></span><span>what</c><00:00:32.400><c></span><span>a</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 24, 32.429, 0.0, 'cassette tape. Do you know what a', '磁带。你知道什么是', '/kəˈsɛt teɪp duː juː noʊ wʌt ə/', '<span pid="502" class="highlight highlight-a">cassette tape.</span><span>Do</span><span>you</span><span>know</span><span>what</span><span>a</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 25, 32.439, 0.0, 'cassette tape. Do you know what a cassette<00:00:33.120><c> is?</c>', '磁带。你知道什么是磁带吗？', '/kəˈsɛt teɪp duː juː noʊ wʌt ə kəˈsɛt ɪz/', '<span>cassette</span><span>tape.</span><span>Do</span><span>you</span><span>know</span><span>what</span><span>a</span><span>cassette<00:00:33.120><c></span><span>is?</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 26, 33.35, 0.0, 'cassette is?', '磁带吗？', '/kəˈsɛt ɪz/', '<span tid="50011" class="highlight highlight-a">cassette</span><span>is?</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 27, 33.36, 0.0, 'cassette is? No.', '磁带吗？不知道。', '/kəˈsɛt ɪz noʊ/', '<span tid="50012" class="highlight highlight-a">cassette</span><span>is?</span><span>No.</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 28, 33.95, 0.0, 'No.', '不知道。', '/noʊ/', '<span>No.</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 29, 33.96, 0.0, 'No. It''s<00:00:34.240><c> basically</c><00:00:34.760><c> a</c><00:00:35.120><c> a</c><00:00:35.160><c> tape</c><00:00:35.400><c> that''s</c><00:00:35.600><c> the</c><00:00:35.720><c> size</c>', '不知道。它基本上是一个磁带，大小', '/noʊ ɪts ˈbeɪsɪkli ə teɪp ðæts ðə saɪz/', '<span>No.</span><span>It''s<00:00:34.240><c></span><span>basically</c><00:00:34.760><c></span><span>a</c><00:00:35.120><c></span><span>a</c><00:00:35.160><c></span><span>tape</c><00:00:35.400><c></span><span>that''s</c><00:00:35.600><c></span><span>the</c><00:00:35.720><c></span><span>size</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 30, 36.47, 0.0, 'It''s basically a a tape that''s the size', '这基本上是一个磁带，大小', '/ɪts ˈbeɪsɪkli ə teɪp ðæts ðə saɪz/', '<span>It''s</span><span tid="50013" class="highlight highlight-a">basically</span><span>a</span><span>a</span><span tid="50014" class="highlight highlight-a">tape</span><span>that''s</span><span>the</span><span>size</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 31, 36.48, 0.0, 'It''s basically a a tape that''s the size and<00:00:36.560><c> then</c><00:00:36.720><c> there''s</c><00:00:36.840><c> a</c><00:00:36.920><c> tape</c><00:00:37.160><c> that</c><00:00:37.280><c> goes</c><00:00:38.160><c> round</c>', '这基本上是一个磁带，大小然后有一个磁带绕圈', '/ɪts ˈbeɪsɪkli ə teɪp ðæts ðə saɪz ænd ðɛn ðɛrz ə teɪp ðæt ɡoʊz raʊnd/', '<span>It''s</span><span>basically</span><span>a</span><span>a</span><span>tape</span><span>that''s</span><span>the</span><span>size</span><span>and<00:00:36.560><c></span><span>then</c><00:00:36.720><c></span><span>there''s</c><00:00:36.840><c></span><span>a</c><00:00:36.920><c></span><span>tape</c><00:00:37.160><c></span><span>that</c><00:00:37.280><c></span><span>goes</c><00:00:38.160><c></span><span>round</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 32, 38.71, 0.0, 'and then there''s a tape that goes round', '然后有一个磁带绕圈', '/ænd ðɛn ðɛrz ə teɪp ðæt ɡoʊz raʊnd/', '<span>and</span> <span>then</span> <span>there''s</span> <span>a</span> <span>tape</span> <span>that</span> <span>goes</span> <span>round</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 33, 38.72, 0.0, 'and then there''s a tape that goes round instead<00:00:39.000><c> of</c><00:00:39.160><c> digital</c><00:00:39.640><c> like</c><00:00:39.840><c> here</c><00:00:40.000><c> on</c><00:00:40.080><c> the</c>', '然后有一个磁带绕圈，而不是数字的像这里', '/ænd ðɛn ðɛrz ə teɪp ðæt ɡoʊz raʊnd ɪnˈstɛd əv ˈdɪdʒɪtl laɪk hɪr ɑn ðə/', '<span>and</span> <span>then</span> <span>there''s</span> <span>a</span> <span>tape</span> <span>that</span> <span>goes</span> <span>round</span> <span>instead<00:00:39.000><c></span> <span>of</c><00:00:39.160><c></span> <span>digital</c><00:00:39.640><c></span> <span>like</c><00:00:39.840><c></span> <span>here</c><00:00:40.000><c></span> <span>on</c><00:00:40.080><c></span> <span>the</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 34, 40.15, 0.0, 'instead of digital like here on the', '而不是数字的像这里', '/ɪnˈstɛd əv ˈdɪdʒɪtl laɪk hɪr ɑn ðə/', '<span>instead</span> <span>of</span> <span>digital</span> <span>like</span> <span>here</span> <span>on</span> <span>the</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 35, 40.16, 0.0, 'instead of digital like here on the phone.<00:00:40.720><c> My</c><00:00:40.840><c> first</c><00:00:41.080><c> cassette</c><00:00:41.400><c> tape</c><00:00:41.520><c> was</c><00:00:41.760><c> MC</c>', '而不是数字的像这里的手机。我的第一盒磁带是MC', '/ɪnˈstɛd əv ˈdɪdʒɪtl laɪk hɪr ɑn ðə foʊn. maɪ fɜːrst ˈkæsɛt teɪp wʌz ɛm siː/', '<span>instead</span> <span>of</span> <span>digital</span> <span>like</span> <span>here</span> <span>on</span> <span>the</span> <span>phone.<00:00:40.720><c></span> <span>My</c><00:00:40.840><c></span> <span>first</c><00:00:41.080><c></span> <span>cassette</c><00:00:41.400><c></span> <span>tape</c><00:00:41.520><c></span> <span>was</c><00:00:41.760><c></span> <span>MC</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 36, 42.15, 0.0, 'phone. My first cassette tape was MC', '手机。我的第一盒磁带是MC', '/foʊn. maɪ fɜːrst ˈkæsɛt teɪp wʌz ɛm siː/', '<span>phone.</span> <span>My</span> <span>first</span> <span>cassette</span> <span>tape</span> <span>was</span> <span>MC</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 37, 42.16, 0.0, 'phone. My first cassette tape was MC Hammer.', '手机。我的第一盒磁带是MC Hammer。', '/foʊn. maɪ fɜːrst ˈkæsɛt teɪp wʌz ɛm siː ˈhæmər/', '<span>phone.</span> <span>My</span> <span>first</span> <span>cassette</span> <span>tape</span> <span>was</span> <span>MC</span> <span>Hammer.</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 38, 43.23, 0.0, 'Hammer.', 'Hammer。', '/ˈhæmər/', '<span>Hammer.</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 39, 43.24, 0.0, 'Hammer. Too<00:00:43.400><c> legit.</c><00:00:44.320><c> Is</c><00:00:44.400><c> that</c><00:00:44.640><c> ding</c><00:00:44.800><c> ding</c><00:00:44.960><c> ding</c><00:00:45.120><c> ding?</c>', 'Hammer。太合法了。那是叮叮叮叮吗？', '/ˈhæmər. tuː ˈlɛdʒɪt. ɪz ðæt dɪŋ dɪŋ dɪŋ dɪŋ/', '<span>Hammer.</span> <span>Too<00:00:43.400><c></span> <span>legit.</c><00:00:44.320><c></span> <span>Is</c><00:00:44.400><c></span> <span>that</c><00:00:44.640><c></span> <span>ding</c><00:00:44.800><c></span> <span>ding</c><00:00:44.960><c></span> <span>ding</c><00:00:45.120><c></span> <span>ding?</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 40, 45.35, 0.0, 'Too legit. Is that ding ding ding ding?', '太合法了。那是叮叮叮叮吗？', '/tuː ˈlɛdʒɪt. ɪz ðæt dɪŋ dɪŋ dɪŋ dɪŋ/', '<span>Too</span> <span>legit.</span> <span>Is</span> <span>that</span> <span>ding</span> <span>ding</span> <span>ding</span> <span>ding?</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 41, 45.36, 0.0, 'Too legit. Is that ding ding ding ding? You<00:00:45.400><c> guys</c><00:00:45.520><c> heard</c><00:00:45.720><c> all</c><00:00:45.840><c> the</c><00:00:45.960><c> cassette</c><00:00:46.280><c> tapes</c>', '太合法了。那是叮叮叮叮吗？你们听过所有的磁带', '/tuː ˈlɛdʒɪt. ɪz ðæt dɪŋ dɪŋ dɪŋ dɪŋ? juː ɡaɪz hɜːrd ɔːl ðə ˈkæsɛt teɪps/', '<span>Too</span> <span>legit.</span> <span>Is</span> <span>that</span> <span>ding</span> <span>ding</span> <span>ding</span> <span>ding?</span> <span>You<00:00:45.400><c></span> <span>guys</c><00:00:45.520><c></span> <span>heard</c><00:00:45.720><c></span> <span>all</c><00:00:45.840><c></span> <span>the</c><00:00:45.960><c></span> <span>cassette</c><00:00:46.280><c></span> <span>tapes</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 42, 46.43, 0.0, 'You guys heard all the cassette tapes', '你们听过所有的磁带', '/juː ɡaɪz hɜːrd ɔːl ðə ˈkæsɛt teɪps/', '<span>You</span> <span>guys</span> <span>heard</span> <span>all</span> <span>the</span> <span>cassette</span> <span>tapes</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 43, 46.44, 0.0, 'You guys heard all the cassette tapes here.', '你们听过这里所有的磁带。', '/juː ɡaɪz hɜːrd ɔːl ðə ˈkæsɛt teɪps hɪr/', '<span>You</span> <span>guys</span> <span>heard</span> <span>all</span> <span>the</span> <span>cassette</span> <span>tapes</span> <span>here.</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 44, 48.31, 0.0, 'here.', '这里。', '/hɪr/', '<span>here.</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 45, 48.32, 0.0, 'here. MC<00:00:48.680><c> Hammer,</c><00:00:49.360><c> he''s</c><00:00:49.600><c> a</c><00:00:49.760><c> rap</c><00:00:50.120><c> artist.</c><00:00:51.080><c> Yeah,</c><00:00:51.280><c> I</c>', '这里。MC Hammer，他是个说唱歌手。是的，我', '/hɪr. ɛm siː ˈhæmər, hiːz ə ræp ˈɑːrtɪst. jɛs, aɪ/', '<span>here.</span> <span>MC<00:00:48.680><c></span> <span>Hammer,</c><00:00:49.360><c></span> <span>he''s</c><00:00:49.600><c></span> <span>a</c><00:00:49.760><c></span> <span>rap</c><00:00:50.120><c></span> <span>artist.</c><00:00:51.080><c></span> <span>Yeah,</c><00:00:51.280><c></span> <span>I</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 46, 51.31, 0.0, 'MC Hammer, he''s a rap artist. Yeah, I', 'MC Hammer，他是个说唱歌手。是的，我', '/ɛm siː ˈhæmər, hiːz ə ræp ˈɑːrtɪst. jɛs, aɪ/', '<span>MC</span> <span>Hammer,</span> <span>he''s</span> <span>a</span> <span>rap</span> <span>artist.</span> <span>Yeah,</span> <span>I</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 47, 51.32, 0.0, 'MC Hammer, he''s a rap artist. Yeah, I listen<00:00:51.680><c> to</c><00:00:51.800><c> a</c><00:00:51.840><c> lot</c><00:00:52.160><c> of</c><00:00:52.400><c> English</c><00:00:53.400><c> western</c>', 'MC Hammer，他是个说唱歌手。是的，我听很多英语西部', '/ɛm siː ˈhæmər, hiːz ə ræp ˈɑːrtɪst. jɛs, aɪ ˈlɪsən tuː ə lɑːt əv ˈɪŋɡlɪʃ ˈwɛstərn/', '<span>MC</span> <span>Hammer,</span> <span>he''s</span> <span>a</span> <span>rap</span> <span>artist.</span> <span>Yeah,</span> <span>I</span> <span>listen<00:00:51.680><c></span> <span>to</c><00:00:51.800><c></span> <span>a</c><00:00:51.840><c></span> <span>lot</c><00:00:52.160><c></span> <span>of</c><00:00:52.400><c></span> <span>English</c><00:00:53.400><c></span> <span>western</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 48, 53.95, 0.0, 'listen to a lot of English western', '听很多英语西部', '/ˈlɪsən tuː ə lɑːt əv ˈɪŋɡlɪʃ ˈwɛstərn/', '<span>listen</span> <span>to</span> <span>a</span> <span>lot</span> <span>of</span> <span>English</span> <span>western</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 49, 53.96, 0.0, 'listen to a lot of English western stuff.', '听很多英语西部的东西。', '/ˈlɪsən tuː ə lɑːt əv ˈɪŋɡlɪʃ ˈwɛstərn stʌf/', '<span>listen</span> <span>to</span> <span>a</span> <span>lot</span> <span>of</span> <span>English</span> <span>western</span> <span>stuff.</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 50, 54.75, 0.0, 'stuff.', '东西。', '/stʌf/', '<span>stuff.</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 51, 54.76, 0.0, 'stuff. Being<00:00:55.240><c> a</c><00:00:55.320><c> celebrity</c><00:00:55.960><c> means</c><00:00:56.320><c> that</c><00:00:56.520><c> you</c><00:00:56.720><c> always</c>', '东西。作为一个名人意味着你总是', '/stʌf. ˈbiːɪŋ ə səˈlɛbrəti miːnz ðæt juː ˈɔːlweɪz/', '<span>stuff.</span> <span>Being<00:00:55.240><c></span> <span>a</c><00:00:55.320><c></span> <span>celebrity</c><00:00:55.960><c></span> <span>means</c><00:00:56.320><c></span> <span>that</c><00:00:56.520><c></span> <span>you</c><00:00:56.720><c></span> <span>always</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 52, 57.03, 0.0, 'Being a celebrity means that you always', '作为一个名人意味着你总是', '/ˈbiːɪŋ ə səˈlɛbrəti miːnz ðæt juː ˈɔːlweɪz/', '<span>Being</span> <span>a</span> <span>celebrity</span> <span>means</span> <span>that</span> <span>you</span> <span>always</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 53, 57.04, 0.0, 'Being a celebrity means that you always get<00:00:57.200><c> a</c><00:00:57.280><c> lot</c><00:00:57.440><c> of</c><00:00:57.560><c> attention.</c><00:00:58.480><c> Do</c><00:00:58.640><c> you</c><00:00:58.760><c> ever</c><00:00:59.080><c> find</c>', '作为一个名人意味着你总是得到很多关注。你有没有觉得', '/ˈbiːɪŋ ə səˈlɛbrəti miːnz ðæt juː ˈɔːlweɪz ɡɛt ə lɑːt əv əˈtɛnʃən. duː juː ˈɛvər faɪnd/', '<span>Being</span> <span>a</span> <span>celebrity</span> <span>means</span> <span>that</span> <span>you</span> <span>always</span> <span>get<00:00:57.200><c></span> <span>a</c><00:00:57.280><c></span> <span>lot</c><00:00:57.440><c></span> <span>of</c><00:00:57.560><c></span> <span>attention.</c><00:00:58.480><c></span> <span>Do</c><00:00:58.640><c></span> <span>you</c><00:00:58.760><c></span> <span>ever</c><00:00:59.080><c></span> <span>find</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 54, 59.39, 0.0, 'get a lot of attention. Do you ever find', '得到很多关注。你有没有觉得', '/ɡɛt ə lɑːt əv əˈtɛnʃən. duː juː ˈɛvər faɪnd/', '<span>get</span> <span>a</span> <span>lot</span> <span>of</span> <span>attention.</span> <span>Do</span> <span>you</span> <span>ever</span> <span>find</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 55, 59.4, 0.0, 'get a lot of attention. Do you ever find it<00:00:59.520><c> tiring?</c>', '得到很多关注。你有没有觉得它累人？', '/ɡɛt ə lɑːt əv əˈtɛnʃən. duː juː ˈɛvər faɪnd ɪt ˈtaɪərɪŋ/', '<span>get</span> <span>a</span> <span>lot</span> <span>of</span> <span>attention.</span> <span>Do</span> <span>you</span> <span>ever</span> <span>find</span> <span>it<00:00:59.520><c></span> <span>tiring?</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 56, 60.35, 0.0, 'it tiring?', '它累人？', '/ɪt ˈtaɪərɪŋ/', '<span>it</span> <span>tiring?</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 57, 60.36, 0.0, 'it tiring? Yes.', '它累人？是的。', '/ɪt ˈtaɪərɪŋ? jɛs/', '<span>it</span> <span>tiring?</span> <span>Yes.</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 58, 62.55, 0.0, 'Yes.', '是的。', '/jɛs/', '<span>Yes.</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 59, 62.56, 0.0, 'Yes. Please.', '是的。请。', '/jɛs. pliːz/', '<span>Yes.</span> <span>Please.</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 60, 63.75, 0.0, 'Please.', '请。', '/pliːz/', '<span>Please.</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 61, 63.76, 0.0, 'Please. Um<00:01:04.239><c> it''s</c><00:01:04.440><c> like</c><00:01:04.680><c> how</c><00:01:04.800><c> they</c><00:01:04.960><c> say,</c><00:01:05.120><c> "Oh</c><00:01:05.199><c> Sarah,</c>', '请。嗯，就像他们说的，', '/pliːz. əm ɪts laɪk haʊ ðeɪ seɪ/', '<span>Please.</span> <span>Um<00:01:04.239><c></span> <span>it''s</c><00:01:04.440><c></span> <span>like</c><00:01:04.680><c></span> <span>how</c><00:01:04.800><c></span> <span>they</c><00:01:04.960><c></span> <span>say,</c><00:01:05.120><c></span> <span>"Oh</c><00:01:05.199><c></span> <span>Sarah,</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 62, 65.55, 0.0, 'Um it''s like how they say, "Oh Sarah,', '嗯，就像他们说的，“哦，莎拉，”', '/əm ɪts laɪk haʊ ðeɪ seɪ oʊ ˈsɛrə/', '<span>Um</span> <span>it''s</span> <span>like</span> <span>how</span> <span>they</span> <span>say,</span> <span>"Oh</span> <span>Sarah,</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 63, 65.56, 0.0, 'Um it''s like how they say, "Oh Sarah, smile<00:01:06.000><c> more.</c><00:01:06.360><c> Sit</c><00:01:06.600><c> up</c><00:01:06.720><c> straight."</c><00:01:07.080><c> You</c><00:01:07.160><c> know,</c>', '嗯，就像他们说的，“哦，莎拉，多笑一笑。坐直了。”你知道，', '/əm ɪts laɪk haʊ ðeɪ seɪ oʊ ˈsɛrə smaɪl mɔːr. sɪt ʌp streɪt. ju noʊ/', '<span>Um</span> <span>it''s</span> <span>like</span> <span>how</span> <span>they</span> <span>say,</span> <span>"Oh</span> <span>Sarah,</span> <span>smile<00:01:06.000><c></span> <span>more.</c><00:01:06.360><c></span> <span>Sit</c><00:01:06.600><c></span> <span>up</c><00:01:06.720><c></span> <span>straight."</c><00:01:07.080><c></span> <span>You</c><00:01:07.160><c></span> <span>know,</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 64, 67.27, 0.0, 'smile more. Sit up straight." You know,', '多笑一笑。坐直了。”你知道，', '/smaɪl mɔːr. sɪt ʌp streɪt. ju noʊ/', '<span>smile</span> <span>more.</span> <span>Sit</span> <span>up</span> <span>straight."</span> <span>You</span> <span>know,</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 65, 67.28, 0.0, 'smile more. Sit up straight." You know, it''s<00:01:07.480><c> it''s</c><00:01:07.800><c> there''s</c><00:01:08.040><c> a</c><00:01:08.080><c> lot</c><00:01:08.240><c> of</c><00:01:08.320><c> things</c><00:01:08.520><c> to</c>', '多笑一笑。坐直了。”你知道，有很多事情要', '/smaɪl mɔːr. sɪt ʌp streɪt. ju noʊ ɪts ɪts ðɛrz ə lɑt əv θɪŋz tu/', '<span>smile</span> <span>more.</span> <span>Sit</span> <span>up</span> <span>straight."</span> <span>You</span> <span>know,</span> <span>it''s<00:01:07.480><c></span> <span>it''s</c><00:01:07.800><c></span> <span>there''s</c><00:01:08.040><c></span> <span>a</c><00:01:08.080><c></span> <span>lot</c><00:01:08.240><c></span> <span>of</c><00:01:08.320><c></span> <span>things</c><00:01:08.520><c></span> <span>to</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 66, 68.71, 0.0, 'it''s it''s there''s a lot of things to', '有很多事情要', '/ɪts ɪts ðɛrz ə lɑt əv θɪŋz tu/', '<span>it''s</span> <span>it''s</span> <span>there''s</span> <span>a</span> <span>lot</span> <span>of</span> <span>things</span> <span>to</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 67, 68.72, 0.0, 'it''s it''s there''s a lot of things to look<00:01:08.920><c> out</c><00:01:09.080><c> for.</c><00:01:09.840><c> You</c><00:01:10.000><c> feel</c><00:01:10.240><c> like</c><00:01:10.600><c> there''s</c>', '有很多事情要注意。你会觉得有', '/ɪts ɪts ðɛrz ə lɑt əv θɪŋz tu lʊk aʊt fɔːr. ju fil laɪk ðɛrz/', '<span>it''s</span> <span>it''s</span> <span>there''s</span> <span>a</span> <span>lot</span> <span>of</span> <span>things</span> <span>to</span> <span>look<00:01:08.920><c></span> <span>out</c><00:01:09.080><c></span> <span>for.</c><00:01:09.840><c></span> <span>You</c><00:01:10.000><c></span> <span>feel</c><00:01:10.240><c></span> <span>like</c><00:01:10.600><c></span> <span>there''s</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 68, 70.83, 0.0, 'look out for. You feel like there''s', '要注意。你会觉得有', '/lʊk aʊt fɔːr. ju fil laɪk ðɛrz/', '<span>look</span> <span>out</span> <span>for.</span> <span>You</span> <span>feel</span> <span>like</span> <span>there''s</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 69, 70.84, 0.0, 'look out for. You feel like there''s quite<00:01:11.000><c> a</c><00:01:11.080><c> bit</c><00:01:11.200><c> of</c><00:01:11.280><c> scrutiny</c><00:01:11.960><c> being</c><00:01:12.120><c> a</c>', '要注意。你会觉得作为名人要承受相当多的审视。', '/lʊk aʊt fɔːr. ju fil laɪk ðɛrz kwaɪt ə bɪt əv ˈskrutəni ˈbiɪŋ ə/', '<span>look</span> <span>out</span> <span>for.</span> <span>You</span> <span>feel</span> <span>like</span> <span>there''s</span> <span>quite<00:01:11.000><c></span> <span>a</c><00:01:11.080><c></span> <span>bit</c><00:01:11.200><c></span> <span>of</c><00:01:11.280><c></span> <span>scrutiny</c><00:01:11.960><c></span> <span>being</c><00:01:12.120><c></span> <span>a</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 70, 72.19, 0.0, 'quite a bit of scrutiny being a', '相当多的审视，作为', '/kwaɪt ə bɪt əv ˈskrutəni ˈbiɪŋ ə/', '<span>quite</span> <span>a</span> <span>bit</span> <span>of</span> <span>scrutiny</span> <span>being</span> <span>a</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 71, 72.2, 0.0, 'quite a bit of scrutiny being a celebrity.', '相当多的审视，作为名人。', '/kwaɪt ə bɪt əv ˈskrutəni ˈbiɪŋ ə səˈlɛbrəti/', '<span>quite</span> <span>a</span> <span>bit</span> <span>of</span> <span>scrutiny</span> <span>being</span> <span>a</span> <span>celebrity.</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 72, 73.55, 0.0, 'celebrity.', '名人。', '/səˈlɛbrəti/', '<span>celebrity.</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 73, 73.56, 0.0, 'celebrity. Um', '名人。嗯', '/səˈlɛbrəti. əm/', '<span>celebrity.</span> <span>Um</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 74, 74.11, 0.0, 'Um', '嗯', '/əm/', '<span>Um</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 75, 74.12, 0.0, 'Um so,<00:01:14.320><c> it</c><00:01:14.520><c> is</c><00:01:14.640><c> a</c><00:01:14.680><c> bit</c><00:01:14.880><c> tiring,</c><00:01:15.720><c> but</c><00:01:16.120><c> the</c><00:01:16.240><c> main</c>', '所以，这有点累人，但主要', '/əm soʊ ɪt ɪz ə bɪt ˈtaɪərɪŋ bʌt ðə meɪn/', '<span>Um</span> <span>so,<00:01:14.320><c></span> <span>it</c><00:01:14.520><c></span> <span>is</c><00:01:14.640><c></span> <span>a</c><00:01:14.680><c></span> <span>bit</c><00:01:14.880><c></span> <span>tiring,</c><00:01:15.720><c></span> <span>but</c><00:01:16.120><c></span> <span>the</c><00:01:16.240><c></span> <span>main</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 76, 76.47, 0.0, 'so, it is a bit tiring, but the main', '所以，这有点累人，但主要', '/soʊ ɪt ɪz ə bɪt ˈtaɪərɪŋ bʌt ðə meɪn/', '<span>so,</span> <span>it</span> <span>is</span> <span>a</span> <span>bit</span> <span>tiring,</span> <span>but</span> <span>the</span> <span>main</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 77, 76.48, 0.0, 'so, it is a bit tiring, but the main thing<00:01:16.640><c> is</c><00:01:16.800><c> always</c><00:01:17.320><c> that</c><00:01:17.600><c> I''m</c><00:01:17.760><c> doing</c><00:01:18.000><c> what</c><00:01:18.160><c> I</c>', '所以，这有点累人，但最重要的是我一直在做我', '/soʊ ɪt ɪz ə bɪt ˈtaɪərɪŋ bʌt ðə meɪn θɪŋ ɪz ˈɔːlweɪz ðæt aɪm ˈduɪŋ wʌt aɪ/', '<span>so,</span> <span>it</span> <span>is</span> <span>a</span> <span>bit</span> <span>tiring,</span> <span>but</span> <span>the</span> <span>main</span> <span>thing<00:01:16.640><c></span> <span>is</c><00:01:16.800><c></span> <span>always</c><00:01:17.320><c></span> <span>that</c><00:01:17.600><c></span> <span>I''m</c><00:01:17.760><c></span> <span>doing</c><00:01:18.000><c></span> <span>what</c><00:01:18.160><c></span> <span>I</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 78, 78.31, 0.0, 'thing is always that I''m doing what I', '最重要的是我一直在做我', '/θɪŋ ɪz ˈɔːlweɪz ðæt aɪm ˈduɪŋ wʌt aɪ/', '<span>thing</span> <span>is</span> <span>always</span> <span>that</span> <span>I''m</span> <span>doing</span> <span>what</span> <span>I</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 79, 78.32, 0.0, 'thing is always that I''m doing what I really<00:01:18.760><c> love,</c><00:01:19.440><c> that</c><00:01:19.760><c> singing.</c><00:01:20.760><c> It''s</c><00:01:20.960><c> tiring,</c>', '最重要的是我一直在做我真正热爱的事情，那就是唱歌。这很累人，', '/θɪŋ ɪz ˈɔːlweɪz ðæt aɪm ˈduɪŋ wʌt aɪ ˈrɪli lʌv ðæt ˈsɪŋɪŋ. ɪts ˈtaɪərɪŋ/', '<span>thing</span> <span>is</span> <span>always</span> <span>that</span> <span>I''m</span> <span>doing</span> <span>what</span> <span>I</span> <span>really<00:01:18.760><c></span> <span>love,</c><00:01:19.440><c></span> <span>that</c><00:01:19.760><c></span> <span>singing.</c><00:01:20.760><c></span> <span>It''s</c><00:01:20.960><c></span> <span>tiring,</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 80, 81.43, 0.0, 'really love, that singing. It''s tiring,', '真正热爱的事情，那就是唱歌。这很累人，', '/ˈrɪli lʌv ðæt ˈsɪŋɪŋ. ɪts ˈtaɪərɪŋ/', '<span>really</span> <span>love,</span> <span>that</span> <span>singing.</span> <span>It''s</span> <span>tiring,</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 81, 81.44, 0.0, 'really love, that singing. It''s tiring, but<00:01:21.600><c> I</c><00:01:21.720><c> really</c><00:01:22.160><c> do</c><00:01:22.360><c> make</c><00:01:22.520><c> people</c><00:01:22.720><c> happy.</c><00:01:23.040><c> I</c>', '真正热爱的事情，那就是唱歌。这很累人，但我确实让人们开心。我', '/ˈrɪli lʌv ðæt ˈsɪŋɪŋ. ɪts ˈtaɪərɪŋ bʌt aɪ ˈrɪli du meɪk ˈpiːpəl ˈhæpi. aɪ/', '<span>really</span> <span>love,</span> <span>that</span> <span>singing.</span> <span>It''s</span> <span>tiring,</span> <span>but<00:01:21.600><c></span> <span>I</c><00:01:21.720><c></span> <span>really</c><00:01:22.160><c></span> <span>do</c><00:01:22.360><c></span> <span>make</c><00:01:22.520><c></span> <span>people</c><00:01:22.720><c></span> <span>happy.</c><00:01:23.040><c></span> <span>I</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 82, 83.11, 0.0, 'but I really do make people happy. I', '但我确实让人们开心。我', '/bʌt aɪ ˈrɪli du meɪk ˈpiːpəl ˈhæpi. aɪ/', '<span>but</span> <span>I</span> <span>really</span> <span>do</span> <span>make</span> <span>people</span> <span>happy.</span> <span>I</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 83, 83.12, 0.0, 'but I really do make people happy. I feel<00:01:23.480><c> that</c><00:01:23.720><c> I</c><00:01:23.800><c> do</c><00:01:24.040><c> like</c><00:01:24.280><c> when</c><00:01:24.400><c> I</c><00:01:24.480><c> take</c><00:01:24.720><c> a</c>', '但我确实让人们开心。我觉得我喜欢当我', '/bʌt aɪ ˈrɪli du meɪk ˈpiːpəl ˈhæpi. aɪ fil ðæt aɪ du laɪk wɛn aɪ teɪk ə/', '<span>but</span> <span>I</span> <span>really</span> <span>do</span> <span>make</span> <span>people</span> <span>happy.</span> <span>I</span> <span>feel<00:01:23.480><c></span> <span>that</c><00:01:23.720><c></span> <span>I</c><00:01:23.800><c></span> <span>do</c><00:01:24.040><c></span> <span>like</c><00:01:24.280><c></span> <span>when</c><00:01:24.400><c></span> <span>I</c><00:01:24.480><c></span> <span>take</c><00:01:24.720><c></span> <span>a</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 84, 84.75, 0.0, 'feel that I do like when I take a', '我觉得我喜欢当我', '/fil ðæt aɪ du laɪk wɛn aɪ teɪk ə/', '<span>feel</span> <span>that</span> <span>I</span> <span>do</span> <span>like</span> <span>when</span> <span>I</span> <span>take</span> <span>a</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 85, 84.76, 0.0, 'feel that I do like when I take a picture<00:01:25.120><c> with</c><00:01:25.280><c> them</c><00:01:25.600><c> or,</c><00:01:26.200><c> you</c><00:01:26.280><c> know,</c><00:01:26.400><c> when</c><00:01:26.560><c> I</c>', '我觉得我喜欢当我跟他们合影或者，你知道，当我', '/fil ðæt aɪ du laɪk wɛn aɪ teɪk ə ˈpɪktʃər wɪð ðɛm ɔːr ju noʊ wɛn aɪ/', '<span>feel</span> <span>that</span> <span>I</span> <span>do</span> <span>like</span> <span>when</span> <span>I</span> <span>take</span> <span>a</span> <span>picture<00:01:25.120><c></span> <span>with</c><00:01:25.280><c></span> <span>them</c><00:01:25.600><c></span> <span>or,</c><00:01:26.200><c></span> <span>you</c><00:01:26.280><c></span> <span>know,</c><00:01:26.400><c></span> <span>when</c><00:01:26.560><c></span> <span>I</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 86, 86.63, 0.0, 'picture with them or, you know, when I', '跟他们合影或者，你知道，当我', '/ˈpɪktʃər wɪð ðɛm ɔːr ju noʊ wɛn aɪ/', '<span>picture</span> <span>with</span> <span>them</span> <span>or,</span> <span>you</span> <span>know,</span> <span>when</span> <span>I</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 87, 86.64, 0.0, 'picture with them or, you know, when I do<00:01:26.840><c> a</c><00:01:27.360><c> autograph</c><00:01:27.800><c> for</c><00:01:27.920><c> them.</c><00:01:28.040><c> It''s</c><00:01:28.280><c> it</c><00:01:28.360><c> takes</c>', '跟他们合影或者，你知道，当我给他们签个名。这只需要', '/ˈpɪktʃər wɪð ðɛm ɔːr ju noʊ wɛn aɪ du ə ˈɔːtəɡræf fɔːr ðɛm. ɪts ɪt teɪks/', '<span>picture</span> <span>with</span> <span>them</span> <span>or,</span> <span>you</span> <span>know,</span> <span>when</span> <span>I</span> <span>do<00:01:26.840><c></span> <span>a</c><00:01:27.360><c></span> <span>autograph</c><00:01:27.800><c></span> <span>for</c><00:01:27.920><c></span> <span>them.</c><00:01:28.040><c></span> <span>It''s</c><00:01:28.280><c></span> <span>it</c><00:01:28.360><c></span> <span>takes</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 88, 88.51, 0.0, 'do a autograph for them. It''s it takes', '给他们签个名。这只需要', '/du ə ˈɔːtəɡræf fɔːr ðɛm. ɪts ɪt teɪks/', '<span>do</span> <span>a</span> <span>autograph</span> <span>for</span> <span>them.</span> <span>It''s</span> <span>it</span> <span>takes</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 89, 88.52, 0.0, 'do a autograph for them. It''s it takes me<00:01:28.720><c> 5</c><00:01:28.960><c> seconds</c><00:01:29.920><c> and</c><00:01:30.320><c> it</c><00:01:30.400><c> makes</c><00:01:30.560><c> them</c><00:01:30.760><c> happy.</c>', '给他们签个名。这只需要我五秒钟，就能让他们开心。', '/du ə ˈɔːtəɡræf fɔːr ðɛm. ɪts ɪt teɪks mi faɪv ˈsɛkəndz ænd ɪt meɪks ðɛm ˈhæpi/', '<span>do</span> <span>a</span> <span>autograph</span> <span>for</span> <span>them.</span> <span>It''s</span> <span>it</span> <span>takes</span> <span>me<00:01:28.720><c></span> <span>5</c><00:01:28.960><c></span> <span>seconds</c><00:01:29.920><c></span> <span>and</c><00:01:30.320><c></span> <span>it</c><00:01:30.400><c></span> <span>makes</c><00:01:30.560><c></span> <span>them</c><00:01:30.760><c></span> <span>happy.</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 90, 91.11, 0.0, 'me 5 seconds and it makes them happy.', '', '', '<span>me</span> <span>5</span> <span>seconds</span> <span>and</span> <span>it</span> <span>makes</span> <span>them</span> <span>happy.</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 91, 91.12, 0.0, 'me 5 seconds and it makes them happy. So,<00:01:31.520><c> I''m</c><00:01:31.640><c> quite</c><00:01:32.040><c> happy</c><00:01:32.600><c> doing</c><00:01:32.920><c> it.</c><00:01:33.040><c> I</c><00:01:33.080><c> think</c>', '', '', '<span>me</span> <span>5</span> <span>seconds</span> <span>and</span> <span>it</span> <span>makes</span> <span>them</span> <span>happy.</span> <span>So,<00:01:31.520><c></span> <span>I''m</c><00:01:31.640><c></span> <span>quite</c><00:01:32.040><c></span> <span>happy</c><00:01:32.600><c></span> <span>doing</c><00:01:32.920><c></span> <span>it.</c><00:01:33.040><c></span> <span>I</c><00:01:33.080><c></span> <span>think</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 92, 93.27, 0.0, 'So, I''m quite happy doing it. I think', '', '', '<span>So,</span> <span>I''m</span> <span>quite</span> <span>happy</span> <span>doing</span> <span>it.</span> <span>I</span> <span>think</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 93, 93.28, 0.0, 'So, I''m quite happy doing it. I think that''s<00:01:33.480><c> worth</c><00:01:33.680><c> it.</c><00:01:33.840><c> It''s</c><00:01:34.040><c> not</c><00:01:34.240><c> tiring.</c>', '', '', '<span>So,</span> <span>I''m</span> <span>quite</span> <span>happy</span> <span>doing</span> <span>it.</span> <span>I</span> <span>think</span> <span>that''s<00:01:33.480><c></span> <span>worth</c><00:01:33.680><c></span> <span>it.</c><00:01:33.840><c></span> <span>It''s</c><00:01:34.040><c></span> <span>not</c><00:01:34.240><c></span> <span>tiring.</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 94, 94.87, 0.0, 'that''s worth it. It''s not tiring.', '', '', '<span>that''s</span> <span>worth</span> <span>it.</span> <span>It''s</span> <span>not</span> <span>tiring.</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 95, 94.88, 0.0, 'that''s worth it. It''s not tiring. Since<00:01:35.120><c> people</c><00:01:35.480><c> are</c><00:01:35.600><c> watching</c><00:01:35.960><c> you</c><00:01:36.120><c> all</c><00:01:36.240><c> the</c>', '', '', '<span>that''s</span> <span>worth</span> <span>it.</span> <span>It''s</span> <span>not</span> <span>tiring.</span> <span>Since<00:01:35.120><c></span> <span>people</c><00:01:35.480><c></span> <span>are</c><00:01:35.600><c></span> <span>watching</c><00:01:35.960><c></span> <span>you</c><00:01:36.120><c></span> <span>all</c><00:01:36.240><c></span> <span>the</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 96, 96.35, 0.0, 'Since people are watching you all the', '', '', '<span>Since</span> <span>people</span> <span>are</span> <span>watching</span> <span>you</span> <span>all</span> <span>the</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 97, 96.36, 0.0, 'Since people are watching you all the time,<00:01:37.040><c> do</c><00:01:37.240><c> you</c><00:01:37.360><c> make</c><00:01:37.560><c> sure</c><00:01:37.760><c> you''re</c><00:01:38.000><c> always</c><00:01:38.320><c> a</c>', '', '', '<span>Since</span> <span>people</span> <span>are</span> <span>watching</span> <span>you</span> <span>all</span> <span>the</span> <span>time,<00:01:37.040><c></span> <span>do</c><00:01:37.240><c></span> <span>you</c><00:01:37.360><c></span> <span>make</c><00:01:37.560><c></span> <span>sure</c><00:01:37.760><c></span> <span>you''re</c><00:01:38.000><c></span> <span>always</c><00:01:38.320><c></span> <span>a</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 98, 98.39, 0.0, 'time, do you make sure you''re always a', '', '', '<span>time,</span> <span>do</span> <span>you</span> <span>make</span> <span>sure</span> <span>you''re</span> <span>always</span> <span>a</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 99, 98.4, 0.0, 'time, do you make sure you''re always a good<00:01:38.680><c> role</c><00:01:38.880><c> model?</c>', '', '', '<span>time,</span> <span>do</span> <span>you</span> <span>make</span> <span>sure</span> <span>you''re</span> <span>always</span> <span>a</span> <span>good<00:01:38.680><c></span> <span>role</c><00:01:38.880><c></span> <span>model?</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 100, 99.75, 0.0, 'good role model?', '', '', '<span>good</span> <span>role</span> <span>model?</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 101, 99.76, 0.0, 'good role model? I<00:01:39.920><c> feel</c><00:01:40.280><c> that</c>', '', '', '<span>good</span> <span>role</span> <span>model?</span> <span>I<00:01:39.920><c></span> <span>feel</c><00:01:40.280><c></span> <span>that</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 102, 101.39, 0.0, 'I feel that', '', '', '<span>I</span> <span>feel</span> <span>that</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 103, 101.4, 0.0, 'I feel that I<00:01:41.520><c> don''t</c><00:01:41.880><c> make</c><00:01:42.080><c> sure</c><00:01:42.240><c> that</c><00:01:42.360><c> I''m</c><00:01:42.480><c> a</c><00:01:42.600><c> good</c><00:01:42.960><c> role</c>', '', '', '<span>I</span> <span>feel</span> <span>that</span> <span>I<00:01:41.520><c></span> <span>don''t</c><00:01:41.880><c></span> <span>make</c><00:01:42.080><c></span> <span>sure</c><00:01:42.240><c></span> <span>that</c><00:01:42.360><c></span> <span>I''m</c><00:01:42.480><c></span> <span>a</c><00:01:42.600><c></span> <span>good</c><00:01:42.960><c></span> <span>role</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 104, 103.15, 0.0, 'I don''t make sure that I''m a good role', '', '', '<span>I</span> <span>don''t</span> <span>make</span> <span>sure</span> <span>that</span> <span>I''m</span> <span>a</span> <span>good</span> <span>role</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 105, 103.16, 0.0, 'I don''t make sure that I''m a good role model.<00:01:43.600><c> I</c><00:01:43.680><c> just</c><00:01:43.840><c> make</c><00:01:43.960><c> sure</c><00:01:44.040><c> I''m</c><00:01:44.120><c> not</c><00:01:44.240><c> a</c><00:01:44.280><c> bad</c>', '', '', '<span>I</span> <span>don''t</span> <span>make</span> <span>sure</span> <span>that</span> <span>I''m</span> <span>a</span> <span>good</span> <span>role</span> <span>model.<00:01:43.600><c></span> <span>I</c><00:01:43.680><c></span> <span>just</c><00:01:43.840><c></span> <span>make</c><00:01:43.960><c></span> <span>sure</c><00:01:44.040><c></span> <span>I''m</c><00:01:44.120><c></span> <span>not</c><00:01:44.240><c></span> <span>a</c><00:01:44.280><c></span> <span>bad</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 106, 105.19, 0.0, 'model. I just make sure I''m not a bad', '', '', '<span>model.</span> <span>I</span> <span>just</span> <span>make</span> <span>sure</span> <span>I''m</span> <span>not</span> <span>a</span> <span>bad</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 107, 105.2, 0.0, 'model. I just make sure I''m not a bad role<00:01:45.360><c> model.</c><00:01:45.880><c> I</c><00:01:46.000><c> think</c><00:01:46.240><c> that''s</c><00:01:46.440><c> very</c>', '', '', '<span>model.</span> <span>I</span> <span>just</span> <span>make</span> <span>sure</span> <span>I''m</span> <span>not</span> <span>a</span> <span>bad</span> <span>role<00:01:45.360><c></span> <span>model.</c><00:01:45.880><c></span> <span>I</c><00:01:46.000><c></span> <span>think</c><00:01:46.240><c></span> <span>that''s</c><00:01:46.440><c></span> <span>very</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 108, 106.59, 0.0, 'role model. I think that''s very', '', '', '<span>role</span> <span>model.</span> <span>I</span> <span>think</span> <span>that''s</span> <span>very</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 109, 106.6, 0.0, 'role model. I think that''s very important.<00:01:47.360><c> It''s</c><00:01:47.440><c> good</c><00:01:47.600><c> to</c><00:01:47.760><c> aspire</c><00:01:48.240><c> high</c><00:01:48.480><c> for</c>', '', '', '<span>role</span> <span>model.</span> <span>I</span> <span>think</span> <span>that''s</span> <span>very</span> <span>important.<00:01:47.360><c></span> <span>It''s</c><00:01:47.440><c></span> <span>good</c><00:01:47.600><c></span> <span>to</c><00:01:47.760><c></span> <span>aspire</c><00:01:48.240><c></span> <span>high</c><00:01:48.480><c></span> <span>for</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 110, 108.67, 0.0, 'important. It''s good to aspire high for', '', '', '<span>important.</span> <span>It''s</span> <span>good</span> <span>to</span> <span>aspire</span> <span>high</span> <span>for</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 111, 108.68, 0.0, 'important. It''s good to aspire high for sure,<00:01:48.920><c> but</c><00:01:49.280><c> I</c><00:01:49.360><c> think</c><00:01:50.000><c> sometimes</c><00:01:50.400><c> people</c>', '', '', '<span>important.</span> <span>It''s</span> <span>good</span> <span>to</span> <span>aspire</span> <span>high</span> <span>for</span> <span>sure,<00:01:48.920><c></span> <span>but</c><00:01:49.280><c></span> <span>I</c><00:01:49.360><c></span> <span>think</c><00:01:50.000><c></span> <span>sometimes</c><00:01:50.400><c></span> <span>people</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 112, 110.67, 0.0, 'sure, but I think sometimes people', '', '', '<span>sure,</span> <span>but</span> <span>I</span> <span>think</span> <span>sometimes</span> <span>people</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 113, 110.68, 0.0, 'sure, but I think sometimes people forget.<00:01:51.200><c> Just</c><00:01:51.440><c> don''t</c><00:01:51.680><c> do</c><00:01:52.160><c> silly</c><00:01:52.520><c> things.</c>', '', '', '<span>sure,</span> <span>but</span> <span>I</span> <span>think</span> <span>sometimes</span> <span>people</span> <span>forget.<00:01:51.200><c></span> <span>Just</c><00:01:51.440><c></span> <span>don''t</c><00:01:51.680><c></span> <span>do</c><00:01:52.160><c></span> <span>silly</c><00:01:52.520><c></span> <span>things.</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 114, 112.95, 0.0, 'forget. Just don''t do silly things.', '', '', '<span>forget.</span> <span>Just</span> <span>don''t</span> <span>do</span> <span>silly</span> <span>things.</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 115, 112.96, 0.0, 'forget. Just don''t do silly things. Don''t<00:01:53.200><c> do</c><00:01:53.320><c> selfish</c><00:01:53.880><c> things.</c><00:01:54.160><c> Don''t</c><00:01:54.440><c> do</c><00:01:55.160><c> things</c>', '', '', '<span>forget.</span> <span>Just</span> <span>don''t</span> <span>do</span> <span>silly</span> <span>things.</span> <span>Don''t<00:01:53.200><c></span> <span>do</c><00:01:53.320><c></span> <span>selfish</c><00:01:53.880><c></span> <span>things.</c><00:01:54.160><c></span> <span>Don''t</c><00:01:54.440><c></span> <span>do</c><00:01:55.160><c></span> <span>things</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 116, 115.47, 0.0, 'Don''t do selfish things. Don''t do things', '', '', '<span>Don''t</span> <span>do</span> <span>selfish</span> <span>things.</span> <span>Don''t</span> <span>do</span> <span>things</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 117, 115.48, 0.0, 'Don''t do selfish things. Don''t do things that<00:01:55.640><c> make</c><00:01:55.840><c> people</c><00:01:56.400><c> uncomfortable.</c><00:01:57.360><c> I</c><00:01:57.520><c> think</c>', '', '', '<span>Don''t</span> <span>do</span> <span>selfish</span> <span>things.</span> <span>Don''t</span> <span>do</span> <span>things</span> <span>that<00:01:55.640><c></span> <span>make</c><00:01:55.840><c></span> <span>people</c><00:01:56.400><c></span> <span>uncomfortable.</c><00:01:57.360><c></span> <span>I</c><00:01:57.520><c></span> <span>think</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 118, 117.71, 0.0, 'that make people uncomfortable. I think', '', '', '<span>that</span> <span>make</span> <span>people</span> <span>uncomfortable.</span> <span>I</span> <span>think</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 119, 117.72, 0.0, 'that make people uncomfortable. I think that''s<00:01:57.920><c> very</c><00:01:58.160><c> basic.</c>', '', '', '<span>that</span> <span>make</span> <span>people</span> <span>uncomfortable.</span> <span>I</span> <span>think</span> <span>that''s<00:01:57.920><c></span> <span>very</c><00:01:58.160><c></span> <span>basic.</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 120, 118.83, 0.0, 'that''s very basic.', '', '', '<span>that''s</span> <span>very</span> <span>basic.</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 121, 118.84, 0.0, 'that''s very basic. Do<00:01:58.880><c> you</c><00:01:59.040><c> believe</c><00:01:59.400><c> in</c><00:01:59.560><c> using</c><00:01:59.880><c> your</c><00:02:00.040><c> influence</c>', '', '', '<span>that''s</span> <span>very</span> <span>basic.</span> <span>Do<00:01:58.880><c></span> <span>you</c><00:01:59.040><c></span> <span>believe</c><00:01:59.400><c></span> <span>in</c><00:01:59.560><c></span> <span>using</c><00:01:59.880><c></span> <span>your</c><00:02:00.040><c></span> <span>influence</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 122, 120.63, 0.0, 'Do you believe in using your influence', '', '', '<span>Do</span> <span>you</span> <span>believe</span> <span>in</span> <span>using</span> <span>your</span> <span>influence</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 123, 120.64, 0.0, 'Do you believe in using your influence to<00:02:00.720><c> make</c><00:02:00.920><c> the</c><00:02:01.040><c> world</c><00:02:01.280><c> a</c><00:02:01.360><c> better</c><00:02:01.640><c> place?</c>', '', '', '<span>Do</span> <span>you</span> <span>believe</span> <span>in</span> <span>using</span> <span>your</span> <span>influence</span> <span>to<00:02:00.720><c></span> <span>make</c><00:02:00.920><c></span> <span>the</c><00:02:01.040><c></span> <span>world</c><00:02:01.280><c></span> <span>a</c><00:02:01.360><c></span> <span>better</c><00:02:01.640><c></span> <span>place?</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 124, 122.39, 0.0, 'to make the world a better place?', '', '', '<span>to</span> <span>make</span> <span>the</span> <span>world</span> <span>a</span> <span>better</span> <span>place?</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 125, 122.4, 0.0, 'to make the world a better place? Uh<00:02:02.760><c> I</c><00:02:02.880><c> do.</c><00:02:03.560><c> That''s</c><00:02:03.720><c> a</c><00:02:03.760><c> good</c><00:02:03.920><c> question,</c><00:02:04.560><c> by</c><00:02:04.680><c> the</c>', '', '', '<span>to</span> <span>make</span> <span>the</span> <span>world</span> <span>a</span> <span>better</span> <span>place?</span> <span>Uh<00:02:02.760><c></span> <span>I</c><00:02:02.880><c></span> <span>do.</c><00:02:03.560><c></span> <span>That''s</c><00:02:03.720><c></span> <span>a</c><00:02:03.760><c></span> <span>good</c><00:02:03.920><c></span> <span>question,</c><00:02:04.560><c></span> <span>by</c><00:02:04.680><c></span> <span>the</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 126, 124.75, 0.0, 'Uh I do. That''s a good question, by the', '', '', '<span>Uh</span> <span>I</span> <span>do.</span> <span>That''s</span> <span>a</span> <span>good</span> <span>question,</span> <span>by</span> <span>the</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 127, 124.76, 0.0, 'Uh I do. That''s a good question, by the way.<00:02:05.160><c> When</c><00:02:05.360><c> you</c><00:02:05.479><c> look</c><00:02:05.640><c> at</c><00:02:05.760><c> people</c><00:02:06.040><c> you</c><00:02:06.160><c> like,</c>', '', '', '<span>Uh</span> <span>I</span> <span>do.</span> <span>That''s</span> <span>a</span> <span>good</span> <span>question,</span> <span>by</span> <span>the</span> <span>way.<00:02:05.160><c></span> <span>When</c><00:02:05.360><c></span> <span>you</c><00:02:05.479><c></span> <span>look</c><00:02:05.640><c></span> <span>at</c><00:02:05.760><c></span> <span>people</c><00:02:06.040><c></span> <span>you</c><00:02:06.160><c></span> <span>like,</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 128, 127.15, 0.0, 'way. When you look at people you like,', '', '', '<span>way.</span> <span>When</span> <span>you</span> <span>look</span> <span>at</span> <span>people</span> <span>you</span> <span>like,</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 129, 127.16, 0.0, 'way. When you look at people you like, and<00:02:07.280><c> then</c><00:02:07.400><c> they</c><00:02:07.520><c> do</c><00:02:07.840><c> things</c><00:02:08.520><c> that</c><00:02:08.960><c> are</c>', '', '', '<span>way.</span> <span>When</span> <span>you</span> <span>look</span> <span>at</span> <span>people</span> <span>you</span> <span>like,</span> <span>and<00:02:07.280><c></span> <span>then</c><00:02:07.400><c></span> <span>they</c><00:02:07.520><c></span> <span>do</c><00:02:07.840><c></span> <span>things</c><00:02:08.520><c></span> <span>that</c><00:02:08.960><c></span> <span>are</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 130, 129.07, 0.0, 'and then they do things that are', '', '', '<span>and</span> <span>then</span> <span>they</span> <span>do</span> <span>things</span> <span>that</span> <span>are</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 131, 129.08, 0.0, 'and then they do things that are meaningful<00:02:09.880><c> or</c><00:02:10.000><c> kind,</c><00:02:10.880><c> I</c><00:02:10.960><c> think</c><00:02:11.760><c> uh</c><00:02:12.040><c> it</c>', '', '', '<span>and</span> <span>then</span> <span>they</span> <span>do</span> <span>things</span> <span>that</span> <span>are</span> <span>meaningful<00:02:09.880><c></span> <span>or</c><00:02:10.000><c></span> <span>kind,</c><00:02:10.880><c></span> <span>I</c><00:02:10.960><c></span> <span>think</c><00:02:11.760><c></span> <span>uh</c><00:02:12.040><c></span> <span>it</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 132, 132.15, 0.0, 'meaningful or kind, I think uh it', '', '', '<span>meaningful</span> <span>or</span> <span>kind,</span> <span>I</span> <span>think</span> <span>uh</span> <span>it</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 133, 132.16, 0.0, 'meaningful or kind, I think uh it translates.<00:02:13.360><c> It</c><00:02:13.480><c> gets</c><00:02:13.640><c> people</c><00:02:13.959><c> thinking,</c><00:02:14.560><c> "Oh</c>', '', '', '<span>meaningful</span> <span>or</span> <span>kind,</span> <span>I</span> <span>think</span> <span>uh</span> <span>it</span> <span>translates.<00:02:13.360><c></span> <span>It</c><00:02:13.480><c></span> <span>gets</c><00:02:13.640><c></span> <span>people</c><00:02:13.959><c></span> <span>thinking,</c><00:02:14.560><c></span> <span>"Oh</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 134, 134.67, 0.0, 'translates. It gets people thinking, "Oh', '', '', '<span>translates.</span> <span>It</span> <span>gets</span> <span>people</span> <span>thinking,</span> <span>"Oh</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 135, 134.68, 0.0, 'translates. It gets people thinking, "Oh yeah,<00:02:15.120><c> I</c><00:02:15.200><c> actually</c><00:02:15.600><c> think</c><00:02:16.360><c> I</c><00:02:16.480><c> should</c><00:02:17.040><c> be</c><00:02:17.240><c> a</c>', '', '', '<span>translates.</span> <span>It</span> <span>gets</span> <span>people</span> <span>thinking,</span> <span>"Oh</span> <span>yeah,<00:02:15.120><c></span> <span>I</c><00:02:15.200><c></span> <span>actually</c><00:02:15.600><c></span> <span>think</c><00:02:16.360><c></span> <span>I</c><00:02:16.480><c></span> <span>should</c><00:02:17.040><c></span> <span>be</c><00:02:17.240><c></span> <span>a</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 136, 137.31, 0.0, 'yeah, I actually think I should be a', '', '', '<span>yeah,</span> <span>I</span> <span>actually</span> <span>think</span> <span>I</span> <span>should</span> <span>be</span> <span>a</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 137, 137.32, 0.0, 'yeah, I actually think I should be a more<00:02:17.560><c> aware</c><00:02:17.840><c> of</c><00:02:18.040><c> the</c><00:02:18.680><c> this</c><00:02:18.880><c> group</c><00:02:19.040><c> of</c><00:02:19.160><c> people."</c>', '', '', '<span>yeah,</span> <span>I</span> <span>actually</span> <span>think</span> <span>I</span> <span>should</span> <span>be</span> <span>a</span> <span>more<00:02:17.560><c></span> <span>aware</c><00:02:17.840><c></span> <span>of</c><00:02:18.040><c></span> <span>the</c><00:02:18.680><c></span> <span>this</c><00:02:18.880><c></span> <span>group</c><00:02:19.040><c></span> <span>of</c><00:02:19.160><c></span> <span>people."</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 138, 139.87, 0.0, 'more aware of the this group of people."', '', '', '<span>more</span> <span>aware</span> <span>of</span> <span>the</span> <span>this</span> <span>group</span> <span>of</span> <span>people."</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 139, 139.88, 0.0, 'more aware of the this group of people." So,<00:02:20.480><c> um</c>', '', '', '<span>more</span> <span>aware</span> <span>of</span> <span>the</span> <span>this</span> <span>group</span> <span>of</span> <span>people."</span> <span>So,<00:02:20.480><c></span> <span>um</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 140, 141.11, 0.0, 'So, um', '', '', '<span>So,</span> <span>um</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 141, 141.12, 0.0, 'So, um I''m<00:02:21.240><c> active</c><00:02:21.600><c> in</c><00:02:21.640><c> my</c><00:02:21.800><c> own</c><00:02:22.040><c> way.</c><00:02:22.920><c> Uh</c><00:02:23.320><c> I</c><00:02:23.440><c> donate</c><00:02:23.880><c> to</c>', '', '', '<span>So,</span> <span>um</span> <span>I''m<00:02:21.240><c></span> <span>active</c><00:02:21.600><c></span> <span>in</c><00:02:21.640><c></span> <span>my</c><00:02:21.800><c></span> <span>own</c><00:02:22.040><c></span> <span>way.</c><00:02:22.920><c></span> <span>Uh</c><00:02:23.320><c></span> <span>I</c><00:02:23.440><c></span> <span>donate</c><00:02:23.880><c></span> <span>to</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 142, 144.31, 0.0, 'I''m active in my own way. Uh I donate to', '', '', '<span>I''m</span> <span>active</span> <span>in</span> <span>my</span> <span>own</span> <span>way.</span> <span>Uh</span> <span>I</span> <span>donate</span> <span>to</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 143, 144.32, 0.0, 'I''m active in my own way. Uh I donate to causes<00:02:24.680><c> that</c><00:02:24.840><c> I</c><00:02:24.959><c> like.</c><00:02:25.640><c> It</c><00:02:25.720><c> might</c><00:02:25.880><c> be</c><00:02:26.120><c> stray</c>', '', '', '<span>I''m</span> <span>active</span> <span>in</span> <span>my</span> <span>own</span> <span>way.</span> <span>Uh</span> <span>I</span> <span>donate</span> <span>to</span> <span>causes<00:02:24.680><c></span> <span>that</c><00:02:24.840><c></span> <span>I</c><00:02:24.959><c></span> <span>like.</c><00:02:25.640><c></span> <span>It</c><00:02:25.720><c></span> <span>might</c><00:02:25.880><c></span> <span>be</c><00:02:26.120><c></span> <span>stray</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 144, 146.35, 0.0, 'causes that I like. It might be stray', '', '', '<span>causes</span> <span>that</span> <span>I</span> <span>like.</span> <span>It</span> <span>might</span> <span>be</span> <span>stray</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 145, 146.36, 0.0, 'causes that I like. It might be stray dogs<00:02:26.880><c> or</c><00:02:27.360><c> people</c><00:02:27.680><c> who</c><00:02:27.800><c> need</c><00:02:28.040><c> certain</c>', '', '', '<span>causes</span> <span>that</span> <span>I</span> <span>like.</span> <span>It</span> <span>might</span> <span>be</span> <span>stray</span> <span>dogs<00:02:26.880><c></span> <span>or</c><00:02:27.360><c></span> <span>people</c><00:02:27.680><c></span> <span>who</c><00:02:27.800><c></span> <span>need</c><00:02:28.040><c></span> <span>certain</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 146, 148.59, 0.0, 'dogs or people who need certain', '', '', '<span>dogs</span> <span>or</span> <span>people</span> <span>who</span> <span>need</span> <span>certain</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 147, 148.6, 0.0, 'dogs or people who need certain appliances.', '', '', '<span>dogs</span> <span>or</span> <span>people</span> <span>who</span> <span>need</span> <span>certain</span> <span>appliances.</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 148, 150.27, 0.0, 'appliances.', '', '', '<span>appliances.</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 149, 150.28, 0.0, 'appliances. Uh<00:02:30.360><c> I</c><00:02:30.400><c> like</c><00:02:30.600><c> Purple</c><00:02:30.920><c> Parade,</c><00:02:31.800><c> things</c><00:02:32.040><c> like</c>', '', '', '<span>appliances.</span> <span>Uh<00:02:30.360><c></span> <span>I</c><00:02:30.400><c></span> <span>like</c><00:02:30.600><c></span> <span>Purple</c><00:02:30.920><c></span> <span>Parade,</c><00:02:31.800><c></span> <span>things</c><00:02:32.040><c></span> <span>like</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 150, 152.19, 0.0, 'Uh I like Purple Parade, things like', '', '', '<span>Uh</span> <span>I</span> <span>like</span> <span>Purple</span> <span>Parade,</span> <span>things</span> <span>like</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 151, 152.2, 0.0, 'Uh I like Purple Parade, things like that.<00:02:32.440><c> Yeah.</c><00:02:32.840><c> I</c><00:02:33.480><c> I</c><00:02:33.520><c> think</c><00:02:33.720><c> everyone</c><00:02:34.200><c> has</c>', '', '', '<span>Uh</span> <span>I</span> <span>like</span> <span>Purple</span> <span>Parade,</span> <span>things</span> <span>like</span> <span>that.<00:02:32.440><c></span> <span>Yeah.</c><00:02:32.840><c></span> <span>I</c><00:02:33.480><c></span> <span>I</c><00:02:33.520><c></span> <span>think</c><00:02:33.720><c></span> <span>everyone</c><00:02:34.200><c></span> <span>has</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 152, 154.67, 0.0, 'that. Yeah. I I think everyone has', '', '', '<span>that.</span> <span>Yeah.</span> <span>I</span> <span>I</span> <span>think</span> <span>everyone</span> <span>has</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 153, 154.68, 0.0, 'that. Yeah. I I think everyone has causes<00:02:35.160><c> that</c><00:02:35.360><c> they</c><00:02:35.480><c> think</c><00:02:35.800><c> are</c><00:02:35.959><c> worth</c>', '', '', '<span>that.</span> <span>Yeah.</span> <span>I</span> <span>I</span> <span>think</span> <span>everyone</span> <span>has</span> <span>causes<00:02:35.160><c></span> <span>that</c><00:02:35.360><c></span> <span>they</c><00:02:35.480><c></span> <span>think</c><00:02:35.800><c></span> <span>are</c><00:02:35.959><c></span> <span>worth</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 154, 156.75, 0.0, 'causes that they think are worth', '', '', '<span>causes</span> <span>that</span> <span>they</span> <span>think</span> <span>are</span> <span>worth</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 155, 156.76, 0.0, 'causes that they think are worth supporting,<00:02:37.520><c> so</c><00:02:38.520><c> you</c><00:02:38.680><c> go</c><00:02:38.840><c> for</c><00:02:39.000><c> that.</c><00:02:39.840><c> Do</c><00:02:40.040><c> you</c>', '', '', '<span>causes</span> <span>that</span> <span>they</span> <span>think</span> <span>are</span> <span>worth</span> <span>supporting,<00:02:37.520><c></span> <span>so</c><00:02:38.520><c></span> <span>you</c><00:02:38.680><c></span> <span>go</c><00:02:38.840><c></span> <span>for</c><00:02:39.000><c></span> <span>that.</c><00:02:39.840><c></span> <span>Do</c><00:02:40.040><c></span> <span>you</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 156, 160.15, 0.0, 'supporting, so you go for that. Do you', '', '', '<span>supporting,</span> <span>so</span> <span>you</span> <span>go</span> <span>for</span> <span>that.</span> <span>Do</span> <span>you</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 157, 160.16, 0.0, 'supporting, so you go for that. Do you have<00:02:40.320><c> any</c><00:02:40.680><c> causes</c><00:02:41.200><c> that</c><00:02:41.360><c> you</c><00:02:41.480><c> like?</c><00:02:42.360><c> You</c><00:02:42.440><c> like</c>', '', '', '<span>supporting,</span> <span>so</span> <span>you</span> <span>go</span> <span>for</span> <span>that.</span> <span>Do</span> <span>you</span> <span>have<00:02:40.320><c></span> <span>any</c><00:02:40.680><c></span> <span>causes</c><00:02:41.200><c></span> <span>that</c><00:02:41.360><c></span> <span>you</c><00:02:41.480><c></span> <span>like?</c><00:02:42.360><c></span> <span>You</c><00:02:42.440><c></span> <span>like</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 158, 162.67, 0.0, 'have any causes that you like? You like', '', '', '<span>have</span> <span>any</span> <span>causes</span> <span>that</span> <span>you</span> <span>like?</span> <span>You</span> <span>like</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 159, 162.68, 0.0, 'have any causes that you like? You like animals?', '', '', '<span>have</span> <span>any</span> <span>causes</span> <span>that</span> <span>you</span> <span>like?</span> <span>You</span> <span>like</span> <span>animals?</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 160, 163.79, 0.0, 'animals?', '', '', '<span>animals?</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 161, 163.8, 0.0, 'animals? I<00:02:43.840><c> like</c><00:02:44.040><c> animals.</c>', '', '', '<span>animals?</span> <span>I<00:02:43.840><c></span> <span>like</c><00:02:44.040><c></span> <span>animals.</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 162, 164.87, 0.0, 'I like animals.', '', '', '<span>I</span> <span>like</span> <span>animals.</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 163, 164.88, 0.0, 'I like animals. Yeah.<00:02:45.480><c> So,</c><00:02:45.640><c> there</c><00:02:45.760><c> are</c><00:02:45.800><c> lost</c><00:02:46.080><c> stray</c><00:02:46.320><c> dogs,</c><00:02:47.200><c> you</c>', '', '', '<span>I</span> <span>like</span> <span>animals.</span> <span>Yeah.<00:02:45.480><c></span> <span>So,</c><00:02:45.640><c></span> <span>there</c><00:02:45.760><c></span> <span>are</c><00:02:45.800><c></span> <span>lost</c><00:02:46.080><c></span> <span>stray</c><00:02:46.320><c></span> <span>dogs,</c><00:02:47.200><c></span> <span>you</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 164, 167.27, 0.0, 'Yeah. So, there are lost stray dogs, you', '', '', '<span>Yeah.</span> <span>So,</span> <span>there</span> <span>are</span> <span>lost</span> <span>stray</span> <span>dogs,</span> <span>you</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 165, 167.28, 0.0, 'Yeah. So, there are lost stray dogs, you know,<00:02:47.560><c> that</c><00:02:48.200><c> that</c><00:02:48.400><c> they</c><00:02:48.720><c> have</c><00:02:48.880><c> to</c><00:02:49.000><c> cull,</c><00:02:49.600><c> so</c>', '', '', '<span>Yeah.</span> <span>So,</span> <span>there</span> <span>are</span> <span>lost</span> <span>stray</span> <span>dogs,</span> <span>you</span> <span>know,<00:02:47.560><c></span> <span>that</c><00:02:48.200><c></span> <span>that</c><00:02:48.400><c></span> <span>they</c><00:02:48.720><c></span> <span>have</c><00:02:48.880><c></span> <span>to</c><00:02:49.000><c></span> <span>cull,</c><00:02:49.600><c></span> <span>so</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 166, 169.87, 0.0, 'know, that that they have to cull, so', '', '', '<span>know,</span> <span>that</span> <span>that</span> <span>they</span> <span>have</span> <span>to</span> <span>cull,</span> <span>so</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 167, 169.88, 0.0, 'know, that that they have to cull, so it''s<00:02:50.040><c> good</c><00:02:50.400><c> if</c><00:02:50.560><c> you</c><00:02:50.800><c> bring</c><00:02:51.000><c> more</c><00:02:51.160><c> awareness,</c>', '', '', '<span>know,</span> <span>that</span> <span>that</span> <span>they</span> <span>have</span> <span>to</span> <span>cull,</span> <span>so</span> <span>it''s<00:02:50.040><c></span> <span>good</c><00:02:50.400><c></span> <span>if</c><00:02:50.560><c></span> <span>you</c><00:02:50.800><c></span> <span>bring</c><00:02:51.000><c></span> <span>more</c><00:02:51.160><c></span> <span>awareness,</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 168, 171.59, 0.0, 'it''s good if you bring more awareness,', '', '', '<span>it''s</span> <span>good</span> <span>if</span> <span>you</span> <span>bring</span> <span>more</span> <span>awareness,</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 169, 171.6, 0.0, 'it''s good if you bring more awareness, then<00:02:51.720><c> people</c><00:02:52.040><c> can</c><00:02:52.320><c> adopt.</c>', '', '', '<span>it''s</span> <span>good</span> <span>if</span> <span>you</span> <span>bring</span> <span>more</span> <span>awareness,</span> <span>then<00:02:51.720><c></span> <span>people</c><00:02:52.040><c></span> <span>can</c><00:02:52.320><c></span> <span>adopt.</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 170, 172.99, 0.0, 'then people can adopt.', '', '', '<span>then</span> <span>people</span> <span>can</span> <span>adopt.</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 171, 173.0, 0.0, 'then people can adopt. How<00:02:53.200><c> about</c><00:02:53.520><c> ordinary</c><00:02:54.080><c> people</c><00:02:54.440><c> like</c><00:02:54.720><c> me?</c><00:02:55.160><c> How</c>', '', '', '<span>then</span> <span>people</span> <span>can</span> <span>adopt.</span> <span>How<00:02:53.200><c></span> <span>about</c><00:02:53.520><c></span> <span>ordinary</c><00:02:54.080><c></span> <span>people</c><00:02:54.440><c></span> <span>like</c><00:02:54.720><c></span> <span>me?</c><00:02:55.160><c></span> <span>How</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 172, 175.31, 0.0, 'How about ordinary people like me? How', '', '', '<span>How</span> <span>about</span> <span>ordinary</span> <span>people</span> <span>like</span> <span>me?</span> <span>How</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 173, 175.32, 0.0, 'How about ordinary people like me? How can<00:02:55.560><c> I</c><00:02:55.680><c> make</c><00:02:55.880><c> the</c><00:02:56.000><c> world</c><00:02:56.200><c> a</c><00:02:56.240><c> better</c><00:02:56.480><c> place?</c>', '', '', '<span>How</span> <span>about</span> <span>ordinary</span> <span>people</span> <span>like</span> <span>me?</span> <span>How</span> <span>can<00:02:55.560><c></span> <span>I</c><00:02:55.680><c></span> <span>make</c><00:02:55.880><c></span> <span>the</c><00:02:56.000><c></span> <span>world</c><00:02:56.200><c></span> <span>a</c><00:02:56.240><c></span> <span>better</c><00:02:56.480><c></span> <span>place?</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 174, 177.15, 0.0, 'can I make the world a better place?', '', '', '<span>can</span> <span>I</span> <span>make</span> <span>the</span> <span>world</span> <span>a</span> <span>better</span> <span>place?</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 175, 177.16, 0.0, 'can I make the world a better place? I<00:02:57.360><c> feel</c><00:02:57.720><c> that</c><00:02:58.520><c> a</c><00:02:58.600><c> lot</c><00:02:58.760><c> of</c><00:02:58.840><c> things</c><00:02:59.040><c> comes</c><00:02:59.400><c> with</c>', '', '', '<span>can</span> <span>I</span> <span>make</span> <span>the</span> <span>world</span> <span>a</span> <span>better</span> <span>place?</span> <span>I<00:02:57.360><c></span> <span>feel</c><00:02:57.720><c></span> <span>that</c><00:02:58.520><c></span> <span>a</c><00:02:58.600><c></span> <span>lot</c><00:02:58.760><c></span> <span>of</c><00:02:58.840><c></span> <span>things</c><00:02:59.040><c></span> <span>comes</c><00:02:59.400><c></span> <span>with</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 176, 179.83, 0.0, 'I feel that a lot of things comes with', '', '', '<span>I</span> <span>feel</span> <span>that</span> <span>a</span> <span>lot</span> <span>of</span> <span>things</span> <span>comes</span> <span>with</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 177, 179.84, 0.0, 'I feel that a lot of things comes with practice.<00:03:00.760><c> I''m</c><00:03:00.920><c> sure</c><00:03:01.160><c> your</c><00:03:01.320><c> mom</c><00:03:01.720><c> has</c><00:03:01.880><c> taught</c>', '', '', '<span>I</span> <span>feel</span> <span>that</span> <span>a</span> <span>lot</span> <span>of</span> <span>things</span> <span>comes</span> <span>with</span> <span>practice.<00:03:00.760><c></span> <span>I''m</c><00:03:00.920><c></span> <span>sure</c><00:03:01.160><c></span> <span>your</c><00:03:01.320><c></span> <span>mom</c><00:03:01.720><c></span> <span>has</c><00:03:01.880><c></span> <span>taught</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 178, 182.11, 0.0, 'practice. I''m sure your mom has taught', '', '', '<span>practice.</span> <span>I''m</span> <span>sure</span> <span>your</span> <span>mom</span> <span>has</span> <span>taught</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 179, 182.12, 0.0, 'practice. I''m sure your mom has taught you<00:03:02.280><c> well</c><00:03:03.080><c> to,</c><00:03:03.840><c> you</c><00:03:03.959><c> know,</c>', '', '', '<span>practice.</span> <span>I''m</span> <span>sure</span> <span>your</span> <span>mom</span> <span>has</span> <span>taught</span> <span>you<00:03:02.280><c></span> <span>well</c><00:03:03.080><c></span> <span>to,</c><00:03:03.840><c></span> <span>you</c><00:03:03.959><c></span> <span>know,</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 180, 184.91, 0.0, 'you well to, you know,', '', '', '<span>you</span> <span>well</span> <span>to,</span> <span>you</span> <span>know,</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 181, 184.92, 0.0, 'you well to, you know, just<00:03:05.080><c> look</c><00:03:05.239><c> around</c><00:03:05.640><c> a</c><00:03:05.680><c> bit</c><00:03:05.880><c> more</c><00:03:06.400><c> to</c><00:03:06.519><c> see</c><00:03:06.959><c> if</c>', '', '', '<span>you</span> <span>well</span> <span>to,</span> <span>you</span> <span>know,</span> <span>just<00:03:05.080><c></span> <span>look</c><00:03:05.239><c></span> <span>around</c><00:03:05.640><c></span> <span>a</c><00:03:05.680><c></span> <span>bit</c><00:03:05.880><c></span> <span>more</c><00:03:06.400><c></span> <span>to</c><00:03:06.519><c></span> <span>see</c><00:03:06.959><c></span> <span>if</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 182, 187.43, 0.0, 'just look around a bit more to see if', '', '', '<span>just</span> <span>look</span> <span>around</span> <span>a</span> <span>bit</span> <span>more</span> <span>to</span> <span>see</span> <span>if</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 183, 187.44, 0.0, 'just look around a bit more to see if there''s<00:03:07.560><c> something</c><00:03:07.800><c> you</c><00:03:07.880><c> can</c><00:03:08.120><c> do</c><00:03:08.600><c> every</c><00:03:08.840><c> day.</c>', '', '', '<span>just</span> <span>look</span> <span>around</span> <span>a</span> <span>bit</span> <span>more</span> <span>to</span> <span>see</span> <span>if</span> <span>there''s<00:03:07.560><c></span> <span>something</c><00:03:07.800><c></span> <span>you</c><00:03:07.880><c></span> <span>can</c><00:03:08.120><c></span> <span>do</c><00:03:08.600><c></span> <span>every</c><00:03:08.840><c></span> <span>day.</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 184, 189.19, 0.0, 'there''s something you can do every day.', '', '', '<span>there''s</span> <span>something</span> <span>you</span> <span>can</span> <span>do</span> <span>every</span> <span>day.</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 185, 189.2, 0.0, 'there''s something you can do every day. And<00:03:09.400><c> it</c><00:03:09.519><c> doesn''t</c><00:03:09.800><c> have</c><00:03:09.959><c> to</c><00:03:10.080><c> be</c><00:03:10.200><c> something</c><00:03:10.560><c> that</c>', '', '', '<span>there''s</span> <span>something</span> <span>you</span> <span>can</span> <span>do</span> <span>every</span> <span>day.</span> <span>And<00:03:09.400><c></span> <span>it</c><00:03:09.519><c></span> <span>doesn''t</c><00:03:09.800><c></span> <span>have</c><00:03:09.959><c></span> <span>to</c><00:03:10.080><c></span> <span>be</c><00:03:10.200><c></span> <span>something</c><00:03:10.560><c></span> <span>that</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 186, 190.91, 0.0, 'And it doesn''t have to be something that', '', '', '<span>And</span> <span>it</span> <span>doesn''t</span> <span>have</span> <span>to</span> <span>be</span> <span>something</span> <span>that</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 187, 190.92, 0.0, 'And it doesn''t have to be something that you<00:03:11.239><c> have</c><00:03:11.480><c> to</c><00:03:11.640><c> go</c><00:03:12.120><c> out</c><00:03:12.959><c> or</c><00:03:13.200><c> set</c><00:03:13.480><c> aside</c><00:03:13.959><c> time</c><00:03:14.400><c> and</c>', '', '', '<span>And</span> <span>it</span> <span>doesn''t</span> <span>have</span> <span>to</span> <span>be</span> <span>something</span> <span>that</span> <span>you<00:03:11.239><c></span> <span>have</c><00:03:11.480><c></span> <span>to</c><00:03:11.640><c></span> <span>go</c><00:03:12.120><c></span> <span>out</c><00:03:12.959><c></span> <span>or</c><00:03:13.200><c></span> <span>set</c><00:03:13.480><c></span> <span>aside</c><00:03:13.959><c></span> <span>time</c><00:03:14.400><c></span> <span>and</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 188, 194.67, 0.0, 'you have to go out or set aside time and', '', '', '<span>you</span> <span>have</span> <span>to</span> <span>go</span> <span>out</span> <span>or</span> <span>set</span> <span>aside</span> <span>time</span> <span>and</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 189, 194.68, 0.0, 'you have to go out or set aside time and do.<00:03:15.200><c> I</c><00:03:15.280><c> think</c><00:03:15.560><c> all</c><00:03:15.720><c> around</c><00:03:16.160><c> us</c><00:03:16.360><c> every</c><00:03:16.640><c> day</c>', '', '', '<span>you</span> <span>have</span> <span>to</span> <span>go</span> <span>out</span> <span>or</span> <span>set</span> <span>aside</span> <span>time</span> <span>and</span> <span>do.<00:03:15.200><c></span> <span>I</c><00:03:15.280><c></span> <span>think</c><00:03:15.560><c></span> <span>all</c><00:03:15.720><c></span> <span>around</c><00:03:16.160><c></span> <span>us</c><00:03:16.360><c></span> <span>every</c><00:03:16.640><c></span> <span>day</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 190, 196.79, 0.0, 'do. I think all around us every day', '', '', '<span>do.</span> <span>I</span> <span>think</span> <span>all</span> <span>around</span> <span>us</span> <span>every</span> <span>day</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 191, 196.8, 0.0, 'do. I think all around us every day there<00:03:16.959><c> are</c><00:03:17.000><c> people</c><00:03:17.360><c> who</c><00:03:17.560><c> need</c><00:03:17.840><c> something.</c>', '', '', '<span>do.</span> <span>I</span> <span>think</span> <span>all</span> <span>around</span> <span>us</span> <span>every</span> <span>day</span> <span>there<00:03:16.959><c></span> <span>are</c><00:03:17.000><c></span> <span>people</c><00:03:17.360><c></span> <span>who</c><00:03:17.560><c></span> <span>need</c><00:03:17.840><c></span> <span>something.</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 192, 198.59, 0.0, 'there are people who need something.', '', '', '<span>there</span> <span>are</span> <span>people</span> <span>who</span> <span>need</span> <span>something.</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 193, 198.6, 0.0, 'there are people who need something. There''s<00:03:18.840><c> always</c><00:03:19.120><c> a</c><00:03:19.200><c> little</c><00:03:19.480><c> something</c><00:03:20.120><c> you</c>', '', '', '<span>there</span> <span>are</span> <span>people</span> <span>who</span> <span>need</span> <span>something.</span> <span>There''s<00:03:18.840><c></span> <span>always</c><00:03:19.120><c></span> <span>a</c><00:03:19.200><c></span> <span>little</c><00:03:19.480><c></span> <span>something</c><00:03:20.120><c></span> <span>you</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 194, 200.19, 0.0, 'There''s always a little something you', '', '', '<span>There''s</span> <span>always</span> <span>a</span> <span>little</span> <span>something</span> <span>you</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 195, 200.2, 0.0, 'There''s always a little something you can<00:03:20.400><c> give</c><00:03:20.600><c> them,</c><00:03:20.840><c> you</c><00:03:20.920><c> know,</c><00:03:21.080><c> a</c><00:03:21.160><c> smile,</c><00:03:21.800><c> a</c><00:03:21.880><c> hug,</c>', '', '', '<span>There''s</span> <span>always</span> <span>a</span> <span>little</span> <span>something</span> <span>you</span> <span>can<00:03:20.400><c></span> <span>give</c><00:03:20.600><c></span> <span>them,</c><00:03:20.840><c></span> <span>you</c><00:03:20.920><c></span> <span>know,</c><00:03:21.080><c></span> <span>a</c><00:03:21.160><c></span> <span>smile,</c><00:03:21.800><c></span> <span>a</c><00:03:21.880><c></span> <span>hug,</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 196, 202.27, 0.0, 'can give them, you know, a smile, a hug,', '', '', '<span>can</span> <span>give</span> <span>them,</span> <span>you</span> <span>know,</span> <span>a</span> <span>smile,</span> <span>a</span> <span>hug,</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 197, 202.28, 0.0, 'can give them, you know, a smile, a hug, a<00:03:22.320><c> how</c><00:03:22.480><c> are</c><00:03:22.600><c> you,</c><00:03:22.800><c> you</c><00:03:22.880><c> know?</c><00:03:23.040><c> All</c><00:03:23.160><c> these</c><00:03:23.320><c> are</c>', '', '', '<span>can</span> <span>give</span> <span>them,</span> <span>you</span> <span>know,</span> <span>a</span> <span>smile,</span> <span>a</span> <span>hug,</span> <span>a<00:03:22.320><c></span> <span>how</c><00:03:22.480><c></span> <span>are</c><00:03:22.600><c></span> <span>you,</c><00:03:22.800><c></span> <span>you</c><00:03:22.880><c></span> <span>know?</c><00:03:23.040><c></span> <span>All</c><00:03:23.160><c></span> <span>these</c><00:03:23.320><c></span> <span>are</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 198, 203.39, 0.0, 'a how are you, you know? All these are', '', '', '<span>a</span> <span>how</span> <span>are</span> <span>you,</span> <span>you</span> <span>know?</span> <span>All</span> <span>these</span> <span>are</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 199, 203.4, 0.0, 'a how are you, you know? All these are acts<00:03:23.560><c> of</c><00:03:23.680><c> kindness,</c><00:03:24.120><c> to</c><00:03:24.239><c> me</c><00:03:24.440><c> lah,</c><00:03:24.600><c> to</c><00:03:24.760><c> me.</c><00:03:25.040><c> When</c>', '', '', '<span>a</span> <span>how</span> <span>are</span> <span>you,</span> <span>you</span> <span>know?</span> <span>All</span> <span>these</span> <span>are</span> <span>acts<00:03:23.560><c></span> <span>of</c><00:03:23.680><c></span> <span>kindness,</c><00:03:24.120><c></span> <span>to</c><00:03:24.239><c></span> <span>me</c><00:03:24.440><c></span> <span>lah,</c><00:03:24.600><c></span> <span>to</c><00:03:24.760><c></span> <span>me.</c><00:03:25.040><c></span> <span>When</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 200, 205.19, 0.0, 'acts of kindness, to me lah, to me. When', '', '', '<span>acts</span> <span>of</span> <span>kindness,</span> <span>to</span> <span>me</span> <span>lah,</span> <span>to</span> <span>me.</span> <span>When</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 201, 205.2, 0.0, 'acts of kindness, to me lah, to me. When you<00:03:25.320><c> have,</c><00:03:25.680><c> can</c><00:03:26.000><c> you</c><00:03:26.120><c> share?</c><00:03:26.760><c> If</c><00:03:26.880><c> you</c><00:03:27.000><c> can''t,</c>', '', '', '<span>acts</span> <span>of</span> <span>kindness,</span> <span>to</span> <span>me</span> <span>lah,</span> <span>to</span> <span>me.</span> <span>When</span> <span>you<00:03:25.320><c></span> <span>have,</c><00:03:25.680><c></span> <span>can</c><00:03:26.000><c></span> <span>you</c><00:03:26.120><c></span> <span>share?</c><00:03:26.760><c></span> <span>If</c><00:03:26.880><c></span> <span>you</c><00:03:27.000><c></span> <span>can''t,</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 202, 207.67, 0.0, 'you have, can you share? If you can''t,', '', '', '<span>you</span> <span>have,</span> <span>can</span> <span>you</span> <span>share?</span> <span>If</span> <span>you</span> <span>can''t,</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 203, 207.68, 0.0, 'you have, can you share? If you can''t, you<00:03:27.800><c> don''t</c><00:03:28.000><c> share.</c><00:03:28.160><c> That''s</c><00:03:28.400><c> fine.</c><00:03:28.720><c> I</c><00:03:28.800><c> think</c>', '', '', '<span>you</span> <span>have,</span> <span>can</span> <span>you</span> <span>share?</span> <span>If</span> <span>you</span> <span>can''t,</span> <span>you<00:03:27.800><c></span> <span>don''t</c><00:03:28.000><c></span> <span>share.</c><00:03:28.160><c></span> <span>That''s</c><00:03:28.400><c></span> <span>fine.</c><00:03:28.720><c></span> <span>I</c><00:03:28.800><c></span> <span>think</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 204, 209.75, 0.0, 'you don''t share. That''s fine. I think', '', '', '<span>you</span> <span>don''t</span> <span>share.</span> <span>That''s</span> <span>fine.</span> <span>I</span> <span>think</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 205, 209.76, 0.0, 'you don''t share. That''s fine. I think um<00:03:29.920><c> don''t</c><00:03:30.200><c> think</c><00:03:30.400><c> of</c><00:03:30.519><c> it</c><00:03:30.640><c> as</c><00:03:30.800><c> a</c><00:03:30.880><c> hard</c><00:03:31.320><c> thing.</c><00:03:31.880><c> It</c>', '', '', '<span>you</span> <span>don''t</span> <span>share.</span> <span>That''s</span> <span>fine.</span> <span>I</span> <span>think</span> <span>um<00:03:29.920><c></span> <span>don''t</c><00:03:30.200><c></span> <span>think</c><00:03:30.400><c></span> <span>of</c><00:03:30.519><c></span> <span>it</c><00:03:30.640><c></span> <span>as</c><00:03:30.800><c></span> <span>a</c><00:03:30.880><c></span> <span>hard</c><00:03:31.320><c></span> <span>thing.</c><00:03:31.880><c></span> <span>It</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 206, 212.03, 0.0, 'um don''t think of it as a hard thing. It', '', '', '<span>um</span> <span>don''t</span> <span>think</span> <span>of</span> <span>it</span> <span>as</span> <span>a</span> <span>hard</span> <span>thing.</span> <span>It</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 207, 212.04, 0.0, 'um don''t think of it as a hard thing. It can<00:03:32.560><c> just</c><00:03:32.840><c> be</c><00:03:33.400><c> with</c><00:03:33.600><c> you</c><00:03:33.880><c> all</c><00:03:34.080><c> the</c><00:03:34.200><c> time.</c>', '', '', '<span>um</span> <span>don''t</span> <span>think</span> <span>of</span> <span>it</span> <span>as</span> <span>a</span> <span>hard</span> <span>thing.</span> <span>It</span> <span>can<00:03:32.560><c></span> <span>just</c><00:03:32.840><c></span> <span>be</c><00:03:33.400><c></span> <span>with</c><00:03:33.600><c></span> <span>you</c><00:03:33.880><c></span> <span>all</c><00:03:34.080><c></span> <span>the</c><00:03:34.200><c></span> <span>time.</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 208, 214.75, 0.0, 'can just be with you all the time.', '', '', '<span>can</span> <span>just</span> <span>be</span> <span>with</span> <span>you</span> <span>all</span> <span>the</span> <span>time.</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 209, 214.76, 0.0, 'can just be with you all the time. Your<00:03:34.920><c> son</c><00:03:35.200><c> will</c><00:03:35.320><c> be</c><00:03:35.440><c> turning</c><00:03:35.880><c> five</c><00:03:36.200><c> soon,</c><00:03:36.480><c> no?</c>', '', '', '<span>can</span> <span>just</span> <span>be</span> <span>with</span> <span>you</span> <span>all</span> <span>the</span> <span>time.</span> <span>Your<00:03:34.920><c></span> <span>son</c><00:03:35.200><c></span> <span>will</c><00:03:35.320><c></span> <span>be</c><00:03:35.440><c></span> <span>turning</c><00:03:35.880><c></span> <span>five</c><00:03:36.200><c></span> <span>soon,</c><00:03:36.480><c></span> <span>no?</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 210, 216.67, 0.0, 'Your son will be turning five soon, no?', '', '', '<span>Your</span> <span>son</span> <span>will</span> <span>be</span> <span>turning</span> <span>five</span> <span>soon,</span> <span>no?</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 211, 216.68, 0.0, 'Your son will be turning five soon, no? Yes,<00:03:37.080><c> he</c><00:03:37.280><c> will.</c>', '', '', '<span>Your</span> <span>son</span> <span>will</span> <span>be</span> <span>turning</span> <span>five</span> <span>soon,</span> <span>no?</span> <span>Yes,<00:03:37.080><c></span> <span>he</c><00:03:37.280><c></span> <span>will.</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 212, 219.55, 0.0, 'Yes, he will.', '', '', '<span>Yes,</span> <span>he</span> <span>will.</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 213, 219.56, 0.0, 'Yes, he will. You<00:03:39.760><c> are</c><00:03:39.920><c> very</c><00:03:40.239><c> protective</c><00:03:40.880><c> of</c><00:03:41.040><c> him.</c><00:03:41.360><c> Why</c><00:03:41.560><c> is</c>', '', '', '<span>Yes,</span> <span>he</span> <span>will.</span> <span>You<00:03:39.760><c></span> <span>are</c><00:03:39.920><c></span> <span>very</c><00:03:40.239><c></span> <span>protective</c><00:03:40.880><c></span> <span>of</c><00:03:41.040><c></span> <span>him.</c><00:03:41.360><c></span> <span>Why</c><00:03:41.560><c></span> <span>is</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 214, 221.71, 0.0, 'You are very protective of him. Why is', '', '', '<span>You</span> <span>are</span> <span>very</span> <span>protective</span> <span>of</span> <span>him.</span> <span>Why</span> <span>is</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 215, 221.72, 0.0, 'You are very protective of him. Why is that<00:03:42.040><c> so?</c>', '', '', '<span>You</span> <span>are</span> <span>very</span> <span>protective</span> <span>of</span> <span>him.</span> <span>Why</span> <span>is</span> <span>that<00:03:42.040><c></span> <span>so?</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 216, 222.949, 0.0, 'that so?', '', '', '<span>that</span> <span>so?</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 217, 222.959, 0.0, 'that so? Well,<00:03:43.480><c> because</c><00:03:44.800><c> his</c><00:03:45.080><c> mom</c><00:03:45.920><c> is</c><00:03:46.120><c> famous.</c><00:03:47.080><c> So,</c><00:03:47.320><c> I</c>', '', '', '<span>that</span> <span>so?</span> <span>Well,<00:03:43.480><c></span> <span>because</c><00:03:44.800><c></span> <span>his</c><00:03:45.080><c></span> <span>mom</c><00:03:45.920><c></span> <span>is</c><00:03:46.120><c></span> <span>famous.</c><00:03:47.080><c></span> <span>So,</c><00:03:47.320><c></span> <span>I</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 218, 227.39, 0.0, 'Well, because his mom is famous. So, I', '', '', '<span>Well,</span> <span>because</span> <span>his</span> <span>mom</span> <span>is</span> <span>famous.</span> <span>So,</span> <span>I</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 219, 227.4, 0.0, 'Well, because his mom is famous. So, I don''t<00:03:47.560><c> know</c><00:03:47.680><c> what</c><00:03:47.840><c> it''s</c><00:03:48.040><c> like</c><00:03:48.519><c> to</c><00:03:48.680><c> have</c><00:03:48.880><c> a</c>', '', '', '<span>Well,</span> <span>because</span> <span>his</span> <span>mom</span> <span>is</span> <span>famous.</span> <span>So,</span> <span>I</span> <span>don''t<00:03:47.560><c></span> <span>know</c><00:03:47.680><c></span> <span>what</c><00:03:47.840><c></span> <span>it''s</c><00:03:48.040><c></span> <span>like</c><00:03:48.519><c></span> <span>to</c><00:03:48.680><c></span> <span>have</c><00:03:48.880><c></span> <span>a</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 220, 228.949, 0.0, 'don''t know what it''s like to have a', '', '', '<span>don''t</span> <span>know</span> <span>what</span> <span>it''s</span> <span>like</span> <span>to</span> <span>have</span> <span>a</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 221, 228.959, 0.0, 'don''t know what it''s like to have a famous<00:03:49.440><c> mom.</c><00:03:50.080><c> I</c><00:03:50.239><c> I</c><00:03:50.360><c> don''t</c><00:03:50.560><c> know.</c><00:03:51.160><c> Do</c><00:03:51.239><c> you</c><00:03:51.360><c> think</c>', '', '', '<span>don''t</span> <span>know</span> <span>what</span> <span>it''s</span> <span>like</span> <span>to</span> <span>have</span> <span>a</span> <span>famous<00:03:49.440><c></span> <span>mom.</c><00:03:50.080><c></span> <span>I</c><00:03:50.239><c></span> <span>I</c><00:03:50.360><c></span> <span>don''t</c><00:03:50.560><c></span> <span>know.</c><00:03:51.160><c></span> <span>Do</c><00:03:51.239><c></span> <span>you</c><00:03:51.360><c></span> <span>think</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 222, 231.59, 0.0, 'famous mom. I I don''t know. Do you think', '', '', '<span>famous</span> <span>mom.</span> <span>I</span> <span>I</span> <span>don''t</span> <span>know.</span> <span>Do</span> <span>you</span> <span>think</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 223, 231.6, 0.0, 'famous mom. I I don''t know. Do you think you<00:03:51.800><c> would</c><00:03:52.000><c> like</c><00:03:52.160><c> to</c><00:03:52.240><c> have</c><00:03:52.360><c> a</c><00:03:52.440><c> famous</c><00:03:52.840><c> mom?</c>', '', '', '<span>famous</span> <span>mom.</span> <span>I</span> <span>I</span> <span>don''t</span> <span>know.</span> <span>Do</span> <span>you</span> <span>think</span> <span>you<00:03:51.800><c></span> <span>would</c><00:03:52.000><c></span> <span>like</c><00:03:52.160><c></span> <span>to</c><00:03:52.240><c></span> <span>have</c><00:03:52.360><c></span> <span>a</c><00:03:52.440><c></span> <span>famous</c><00:03:52.840><c></span> <span>mom?</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 224, 233.31, 0.0, 'you would like to have a famous mom?', '', '', '<span>you</span> <span>would</span> <span>like</span> <span>to</span> <span>have</span> <span>a</span> <span>famous</span> <span>mom?</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 225, 233.32, 0.0, 'you would like to have a famous mom? Yeah.', '', '', '<span>you</span> <span>would</span> <span>like</span> <span>to</span> <span>have</span> <span>a</span> <span>famous</span> <span>mom?</span> <span>Yeah.</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 226, 233.91, 0.0, 'Yeah.', '', '', '<span>Yeah.</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 227, 233.92, 0.0, 'Yeah. Yeah,<00:03:54.160><c> I</c><00:03:54.400><c> a</c><00:03:54.440><c> lot</c><00:03:54.600><c> of</c><00:03:54.680><c> friends.</c><00:03:55.280><c> Yeah,</c><00:03:55.520><c> kind</c><00:03:55.800><c> of.</c>', '', '', '<span>Yeah.</span> <span>Yeah,<00:03:54.160><c></span> <span>I</c><00:03:54.400><c></span> <span>a</c><00:03:54.440><c></span> <span>lot</c><00:03:54.600><c></span> <span>of</c><00:03:54.680><c></span> <span>friends.</c><00:03:55.280><c></span> <span>Yeah,</c><00:03:55.520><c></span> <span>kind</c><00:03:55.800><c></span> <span>of.</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 228, 236.07, 0.0, 'Yeah, I a lot of friends. Yeah, kind of.', '', '', '<span>Yeah,</span> <span>I</span> <span>a</span> <span>lot</span> <span>of</span> <span>friends.</span> <span>Yeah,</span> <span>kind</span> <span>of.</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 229, 236.08, 0.0, 'Yeah, I a lot of friends. Yeah, kind of. What kind<00:03:56.200><c> of</c><00:03:56.280><c> friends</c><00:03:56.560><c> would</c><00:03:56.680><c> that</c><00:03:56.800><c> be?</c>', '', '', '<span>Yeah,</span> <span>I</span> <span>a</span> <span>lot</span> <span>of</span> <span>friends.</span> <span>Yeah,</span> <span>kind</span> <span>of.</span> <span>What</span> <span>kind<00:03:56.200><c></span> <span>of</c><00:03:56.280><c></span> <span>friends</c><00:03:56.560><c></span> <span>would</c><00:03:56.680><c></span> <span>that</c><00:03:56.800><c></span> <span>be?</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 230, 237.35, 0.0, 'What kind of friends would that be?', '', '', '<span>What</span> <span>kind</span> <span>of</span> <span>friends</span> <span>would</span> <span>that</span> <span>be?</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 231, 237.36, 0.0, 'What kind of friends would that be? Like<00:03:57.600><c> kind</c><00:03:57.760><c> of</c>', '', '', '<span>What</span> <span>kind</span> <span>of</span> <span>friends</span> <span>would</span> <span>that</span> <span>be?</span> <span>Like<00:03:57.600><c></span> <span>kind</c><00:03:57.760><c></span> <span>of</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 232, 237.83, 0.0, 'Like kind of', '', '', '<span>Like</span> <span>kind</span> <span>of</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 233, 237.84, 0.0, 'Like kind of Oh, your<00:03:57.960><c> mom</c><00:03:58.160><c> is</c><00:03:58.240><c> very</c><00:03:58.400><c> famous.</c><00:03:58.760><c> I</c><00:03:58.840><c> want</c><00:03:59.000><c> to</c>', '', '', '<span>Like</span> <span>kind</span> <span>of</span> <span>Oh,</span> <span>your<00:03:57.960><c></span> <span>mom</c><00:03:58.160><c></span> <span>is</c><00:03:58.240><c></span> <span>very</c><00:03:58.400><c></span> <span>famous.</c><00:03:58.760><c></span> <span>I</c><00:03:58.840><c></span> <span>want</c><00:03:59.000><c></span> <span>to</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 234, 239.07, 0.0, 'Oh, your mom is very famous. I want to', '', '', '<span>Oh,</span> <span>your</span> <span>mom</span> <span>is</span> <span>very</span> <span>famous.</span> <span>I</span> <span>want</span> <span>to</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 235, 239.08, 0.0, 'Oh, your mom is very famous. I want to be<00:03:59.160><c> your</c><00:03:59.280><c> friend.</c>', '', '', '<span>Oh,</span> <span>your</span> <span>mom</span> <span>is</span> <span>very</span> <span>famous.</span> <span>I</span> <span>want</span> <span>to</span> <span>be<00:03:59.160><c></span> <span>your</c><00:03:59.280><c></span> <span>friend.</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 236, 239.67, 0.0, 'be your friend.', '', '', '<span>be</span> <span>your</span> <span>friend.</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 237, 239.68, 0.0, 'be your friend. I<00:03:59.880><c> have</c><00:04:00.040><c> a</c><00:04:00.120><c> nephew.</c><00:04:01.240><c> Uh</c><00:04:01.400><c> he</c><00:04:01.640><c> thought</c><00:04:01.920><c> that</c><00:04:02.720><c> me</c>', '', '', '<span>be</span> <span>your</span> <span>friend.</span> <span>I<00:03:59.880><c></span> <span>have</c><00:04:00.040><c></span> <span>a</c><00:04:00.120><c></span> <span>nephew.</c><00:04:01.240><c></span> <span>Uh</c><00:04:01.400><c></span> <span>he</c><00:04:01.640><c></span> <span>thought</c><00:04:01.920><c></span> <span>that</c><00:04:02.720><c></span> <span>me</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 238, 242.95, 0.0, 'I have a nephew. Uh he thought that me', '', '', '<span>I</span> <span>have</span> <span>a</span> <span>nephew.</span> <span>Uh</span> <span>he</span> <span>thought</span> <span>that</span> <span>me</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 239, 242.96, 0.0, 'I have a nephew. Uh he thought that me being<00:04:03.160><c> a</c><00:04:03.240><c> singer</c><00:04:03.520><c> was</c><00:04:03.760><c> embarrassing.</c><00:04:04.800><c> It''s</c>', '', '', '<span>I</span> <span>have</span> <span>a</span> <span>nephew.</span> <span>Uh</span> <span>he</span> <span>thought</span> <span>that</span> <span>me</span> <span>being<00:04:03.160><c></span> <span>a</c><00:04:03.240><c></span> <span>singer</c><00:04:03.520><c></span> <span>was</c><00:04:03.760><c></span> <span>embarrassing.</c><00:04:04.800><c></span> <span>It''s</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 240, 244.99, 0.0, 'being a singer was embarrassing. It''s', '', '', '<span>being</span> <span>a</span> <span>singer</span> <span>was</span> <span>embarrassing.</span> <span>It''s</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 241, 245.0, 0.0, 'being a singer was embarrassing. It''s his<00:04:05.280><c> exact</c><00:04:05.800><c> words.</c><00:04:06.240><c> Embarrassing.</c>', '', '', '<span>being</span> <span>a</span> <span>singer</span> <span>was</span> <span>embarrassing.</span> <span>It''s</span> <span>his<00:04:05.280><c></span> <span>exact</c><00:04:05.800><c></span> <span>words.</c><00:04:06.240><c></span> <span>Embarrassing.</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 242, 248.07, 0.0, 'his exact words. Embarrassing.', '', '', '<span>his</span> <span>exact</span> <span>words.</span> <span>Embarrassing.</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 243, 248.08, 0.0, 'his exact words. Embarrassing. So,<00:04:09.080><c> uh</c><00:04:09.200><c> I</c><00:04:09.280><c> don''t</c><00:04:09.480><c> know.</c><00:04:09.680><c> I</c><00:04:09.760><c> don''t</c><00:04:09.920><c> know</c><00:04:10.000><c> what</c>', '', '', '<span>his</span> <span>exact</span> <span>words.</span> <span>Embarrassing.</span> <span>So,<00:04:09.080><c></span> <span>uh</c><00:04:09.200><c></span> <span>I</c><00:04:09.280><c></span> <span>don''t</c><00:04:09.480><c></span> <span>know.</c><00:04:09.680><c></span> <span>I</c><00:04:09.760><c></span> <span>don''t</c><00:04:09.920><c></span> <span>know</c><00:04:10.000><c></span> <span>what</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 244, 250.11, 0.0, 'So, uh I don''t know. I don''t know what', '', '', '<span>So,</span> <span>uh</span> <span>I</span> <span>don''t</span> <span>know.</span> <span>I</span> <span>don''t</span> <span>know</span> <span>what</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 245, 250.12, 0.0, 'So, uh I don''t know. I don''t know what my<00:04:10.240><c> son</c><00:04:10.520><c> thinks.</c><00:04:11.200><c> At</c><00:04:11.320><c> the</c><00:04:11.400><c> moment,</c><00:04:11.920><c> he''s</c><00:04:12.120><c> a</c><00:04:12.200><c> bit</c>', '', '', '<span>So,</span> <span>uh</span> <span>I</span> <span>don''t</span> <span>know.</span> <span>I</span> <span>don''t</span> <span>know</span> <span>what</span> <span>my<00:04:10.240><c></span> <span>son</c><00:04:10.520><c></span> <span>thinks.</c><00:04:11.200><c></span> <span>At</c><00:04:11.320><c></span> <span>the</c><00:04:11.400><c></span> <span>moment,</c><00:04:11.920><c></span> <span>he''s</c><00:04:12.120><c></span> <span>a</c><00:04:12.200><c></span> <span>bit</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 246, 252.71, 0.0, 'my son thinks. At the moment, he''s a bit', '', '', '<span>my</span> <span>son</span> <span>thinks.</span> <span>At</span> <span>the</span> <span>moment,</span> <span>he''s</span> <span>a</span> <span>bit</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 247, 252.72, 0.0, 'my son thinks. At the moment, he''s a bit bewildered.<00:04:13.480><c> Like,</c><00:04:13.840><c> "Oh,</c><00:04:14.120><c> Mommy,</c><00:04:14.560><c> why</c><00:04:14.680><c> are</c>', '', '', '<span>my</span> <span>son</span> <span>thinks.</span> <span>At</span> <span>the</span> <span>moment,</span> <span>he''s</span> <span>a</span> <span>bit</span> <span>bewildered.<00:04:13.480><c></span> <span>Like,</c><00:04:13.840><c></span> <span>"Oh,</c><00:04:14.120><c></span> <span>Mommy,</c><00:04:14.560><c></span> <span>why</c><00:04:14.680><c></span> <span>are</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 248, 254.71, 0.0, 'bewildered. Like, "Oh, Mommy, why are', '', '', '<span>bewildered.</span> <span>Like,</span> <span>"Oh,</span> <span>Mommy,</span> <span>why</span> <span>are</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 249, 254.72, 0.0, 'bewildered. Like, "Oh, Mommy, why are you<00:04:14.840><c> taking</c><00:04:15.160><c> pictures</c><00:04:15.800><c> with</c><00:04:16.040><c> people?</c><00:04:17.000><c> Like,</c>', '', '', '<span>bewildered.</span> <span>Like,</span> <span>"Oh,</span> <span>Mommy,</span> <span>why</span> <span>are</span> <span>you<00:04:14.840><c></span> <span>taking</c><00:04:15.160><c></span> <span>pictures</c><00:04:15.800><c></span> <span>with</c><00:04:16.040><c></span> <span>people?</c><00:04:17.000><c></span> <span>Like,</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 250, 257.31, 0.0, 'you taking pictures with people? Like,', '', '', '<span>you</span> <span>taking</span> <span>pictures</span> <span>with</span> <span>people?</span> <span>Like,</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 251, 257.32, 0.0, 'you taking pictures with people? Like, Mama,<00:04:17.920><c> let''s</c><00:04:18.160><c> go.</c><00:04:18.560><c> Let''s</c><00:04:18.840><c> go."</c>', '', '', '<span>you</span> <span>taking</span> <span>pictures</span> <span>with</span> <span>people?</span> <span>Like,</span> <span>Mama,<00:04:17.920><c></span> <span>let''s</c><00:04:18.160><c></span> <span>go.</c><00:04:18.560><c></span> <span>Let''s</c><00:04:18.840><c></span> <span>go."</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 252, 260.349, 0.0, 'Mama, let''s go. Let''s go."', '', '', '<span>Mama,</span> <span>let''s</span> <span>go.</span> <span>Let''s</span> <span>go."</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 253, 260.359, 0.0, 'Mama, let''s go. Let''s go." Like,<00:04:20.920><c> stop</c><00:04:21.239><c> taking</c><00:04:21.720><c> pictures</c><00:04:22.040><c> with</c>', '', '', '<span>Mama,</span> <span>let''s</span> <span>go.</span> <span>Let''s</span> <span>go."</span> <span>Like,<00:04:20.920><c></span> <span>stop</c><00:04:21.239><c></span> <span>taking</c><00:04:21.720><c></span> <span>pictures</c><00:04:22.040><c></span> <span>with</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 254, 262.11, 0.0, 'Like, stop taking pictures with', '', '', '<span>Like,</span> <span>stop</span> <span>taking</span> <span>pictures</span> <span>with</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 255, 262.12, 0.0, 'Like, stop taking pictures with Yeah.<00:04:22.360><c> Yeah.</c><00:04:22.400><c> Yeah.</c><00:04:22.480><c> Yeah.</c><00:04:22.600><c> Yeah.</c><00:04:22.680><c> He</c>', '', '', '<span>Like,</span> <span>stop</span> <span>taking</span> <span>pictures</span> <span>with</span> <span>Yeah.<00:04:22.360><c></span> <span>Yeah.</c><00:04:22.400><c></span> <span>Yeah.</c><00:04:22.480><c></span> <span>Yeah.</c><00:04:22.600><c></span> <span>Yeah.</c><00:04:22.680><c></span> <span>He</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 256, 263.59, 0.0, 'Yeah. Yeah. Yeah. Yeah. Yeah. He', '', '', '<span>Yeah.</span> <span>Yeah.</span> <span>Yeah.</span> <span>Yeah.</span> <span>Yeah.</span> <span>He</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 257, 263.6, 0.0, 'Yeah. Yeah. Yeah. Yeah. Yeah. He thinks<00:04:23.960><c> I</c><00:04:24.320><c> I''m</c><00:04:24.600><c> holding</c><00:04:24.880><c> him</c><00:04:25.040><c> up.</c><00:04:25.280><c> So,</c><00:04:26.000><c> yeah,</c>', '', '', '<span>Yeah.</span> <span>Yeah.</span> <span>Yeah.</span> <span>Yeah.</span> <span>Yeah.</span> <span>He</span> <span>thinks<00:04:23.960><c></span> <span>I</c><00:04:24.320><c></span> <span>I''m</c><00:04:24.600><c></span> <span>holding</c><00:04:24.880><c></span> <span>him</c><00:04:25.040><c></span> <span>up.</c><00:04:25.280><c></span> <span>So,</c><00:04:26.000><c></span> <span>yeah,</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 258, 266.23, 0.0, 'thinks I I''m holding him up. So, yeah,', '', '', '<span>thinks</span> <span>I</span> <span>I''m</span> <span>holding</span> <span>him</span> <span>up.</span> <span>So,</span> <span>yeah,</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 259, 266.24, 0.0, 'thinks I I''m holding him up. So, yeah, that<00:04:26.440><c> happens.</c>', '', '', '<span>thinks</span> <span>I</span> <span>I''m</span> <span>holding</span> <span>him</span> <span>up.</span> <span>So,</span> <span>yeah,</span> <span>that<00:04:26.440><c></span> <span>happens.</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 260, 267.35, 0.0, 'that happens.', '', '', '<span>that</span> <span>happens.</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 261, 267.36, 0.0, 'that happens. Lol.', '', '', '<span>that</span> <span>happens.</span> <span>Lol.</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 262, 267.909, 0.0, 'Lol.', '', '', '<span>Lol.</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 263, 267.919, 0.0, 'Lol. Did<00:04:28.040><c> you</c><00:04:28.120><c> just</c><00:04:28.240><c> say</c><00:04:28.360><c> lol?</c>', '', '', '<span>Lol.</span> <span>Did<00:04:28.040><c></span> <span>you</c><00:04:28.120><c></span> <span>just</c><00:04:28.240><c></span> <span>say</c><00:04:28.360><c></span> <span>lol?</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 264, 268.71, 0.0, 'Did you just say lol?', '', '', '<span>Did</span> <span>you</span> <span>just</span> <span>say</span> <span>lol?</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 265, 268.72, 0.0, 'Did you just say lol? Yeah.', '', '', '<span>Did</span> <span>you</span> <span>just</span> <span>say</span> <span>lol?</span> <span>Yeah.</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 266, 273.75, 0.0, 'I''m sure you hope your son grows up to', '', '', '<span>I''m</span> <span>sure</span> <span>you</span> <span>hope</span> <span>your</span> <span>son</span> <span>grows</span> <span>up</span> <span>to</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 267, 273.76, 0.0, 'I''m sure you hope your son grows up to be<00:04:33.880><c> a</c><00:04:34.000><c> good</c><00:04:34.240><c> and</c><00:04:34.360><c> kind</c><00:04:34.640><c> person.</c><00:04:35.280><c> Do</c><00:04:35.440><c> you</c><00:04:35.600><c> see</c><00:04:35.919><c> it</c>', '', '', '<span>I''m</span> <span>sure</span> <span>you</span> <span>hope</span> <span>your</span> <span>son</span> <span>grows</span> <span>up</span> <span>to</span> <span>be<00:04:33.880><c></span> <span>a</c><00:04:34.000><c></span> <span>good</c><00:04:34.240><c></span> <span>and</c><00:04:34.360><c></span> <span>kind</c><00:04:34.640><c></span> <span>person.</c><00:04:35.280><c></span> <span>Do</c><00:04:35.440><c></span> <span>you</c><00:04:35.600><c></span> <span>see</c><00:04:35.919><c></span> <span>it</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 268, 275.99, 0.0, 'be a good and kind person. Do you see it', '', '', '<span>be</span> <span>a</span> <span>good</span> <span>and</span> <span>kind</span> <span>person.</span> <span>Do</span> <span>you</span> <span>see</span> <span>it</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 269, 276.0, 0.0, 'be a good and kind person. Do you see it as<00:04:36.160><c> your</c><00:04:36.280><c> responsibility</c><00:04:37.240><c> to</c><00:04:37.360><c> make</c><00:04:37.640><c> that</c>', '', '', '<span>be</span> <span>a</span> <span>good</span> <span>and</span> <span>kind</span> <span>person.</span> <span>Do</span> <span>you</span> <span>see</span> <span>it</span> <span>as<00:04:36.160><c></span> <span>your</c><00:04:36.280><c></span> <span>responsibility</c><00:04:37.240><c></span> <span>to</c><00:04:37.360><c></span> <span>make</c><00:04:37.640><c></span> <span>that</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 270, 277.909, 0.0, 'as your responsibility to make that', '', '', '<span>as</span> <span>your</span> <span>responsibility</span> <span>to</span> <span>make</span> <span>that</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 271, 277.919, 0.0, 'as your responsibility to make that happen?', '', '', '<span>as</span> <span>your</span> <span>responsibility</span> <span>to</span> <span>make</span> <span>that</span> <span>happen?</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 272, 278.79, 0.0, 'happen?', '', '', '<span>happen?</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 273, 278.8, 0.0, 'happen? I<00:04:38.960><c> do</c><00:04:39.200><c> think</c><00:04:39.440><c> me</c><00:04:39.720><c> being</c><00:04:40.440><c> good</c><00:04:40.600><c> and</c><00:04:40.720><c> kind,</c><00:04:41.200><c> if</c><00:04:41.280><c> I</c>', '', '', '<span>happen?</span> <span>I<00:04:38.960><c></span> <span>do</c><00:04:39.200><c></span> <span>think</c><00:04:39.440><c></span> <span>me</c><00:04:39.720><c></span> <span>being</c><00:04:40.440><c></span> <span>good</c><00:04:40.600><c></span> <span>and</c><00:04:40.720><c></span> <span>kind,</c><00:04:41.200><c></span> <span>if</c><00:04:41.280><c></span> <span>I</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 274, 281.31, 0.0, 'I do think me being good and kind, if I', '', '', '<span>I</span> <span>do</span> <span>think</span> <span>me</span> <span>being</span> <span>good</span> <span>and</span> <span>kind,</span> <span>if</span> <span>I</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 275, 281.32, 0.0, 'I do think me being good and kind, if I can<00:04:41.400><c> say</c><00:04:41.520><c> so</c><00:04:41.600><c> myself,</c>', '', '', '<span>I</span> <span>do</span> <span>think</span> <span>me</span> <span>being</span> <span>good</span> <span>and</span> <span>kind,</span> <span>if</span> <span>I</span> <span>can<00:04:41.400><c></span> <span>say</c><00:04:41.520><c></span> <span>so</c><00:04:41.600><c></span> <span>myself,</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 276, 283.43, 0.0, 'can say so myself,', '', '', '<span>can</span> <span>say</span> <span>so</span> <span>myself,</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 277, 283.44, 0.0, 'can say so myself, are<00:04:43.600><c> a</c><00:04:43.640><c> result</c><00:04:43.960><c> of</c><00:04:44.400><c> good</c><00:04:44.600><c> parenting.</c><00:04:45.680><c> My</c>', '', '', '<span>can</span> <span>say</span> <span>so</span> <span>myself,</span> <span>are<00:04:43.600><c></span> <span>a</c><00:04:43.640><c></span> <span>result</c><00:04:43.960><c></span> <span>of</c><00:04:44.400><c></span> <span>good</c><00:04:44.600><c></span> <span>parenting.</c><00:04:45.680><c></span> <span>My</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 278, 285.79, 0.0, 'are a result of good parenting. My', '', '', '<span>are</span> <span>a</span> <span>result</span> <span>of</span> <span>good</span> <span>parenting.</span> <span>My</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 279, 285.8, 0.0, 'are a result of good parenting. My parents<00:04:46.320><c> are</c><00:04:46.960><c> always</c><00:04:47.320><c> there</c><00:04:47.560><c> for</c><00:04:47.720><c> me.</c><00:04:47.960><c> Like,</c>', '', '', '<span>are</span> <span>a</span> <span>result</span> <span>of</span> <span>good</span> <span>parenting.</span> <span>My</span> <span>parents<00:04:46.320><c></span> <span>are</c><00:04:46.960><c></span> <span>always</c><00:04:47.320><c></span> <span>there</c><00:04:47.560><c></span> <span>for</c><00:04:47.720><c></span> <span>me.</c><00:04:47.960><c></span> <span>Like,</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 280, 288.31, 0.0, 'parents are always there for me. Like,', '', '', '<span>parents</span> <span>are</span> <span>always</span> <span>there</span> <span>for</span> <span>me.</span> <span>Like,</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 281, 288.32, 0.0, 'parents are always there for me. Like, they<00:04:48.560><c> would</c><00:04:48.840><c> be</c><00:04:49.400><c> They</c><00:04:49.480><c> would</c><00:04:49.600><c> be</c><00:04:49.680><c> home</c><00:04:50.040><c> every</c>', '', '', '<span>parents</span> <span>are</span> <span>always</span> <span>there</span> <span>for</span> <span>me.</span> <span>Like,</span> <span>they<00:04:48.560><c></span> <span>would</c><00:04:48.840><c></span> <span>be</c><00:04:49.400><c></span> <span>They</c><00:04:49.480><c></span> <span>would</c><00:04:49.600><c></span> <span>be</c><00:04:49.680><c></span> <span>home</c><00:04:50.040><c></span> <span>every</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 282, 290.27, 0.0, 'they would be They would be home every', '', '', '<span>they</span> <span>would</span> <span>be</span> <span>They</span> <span>would</span> <span>be</span> <span>home</span> <span>every</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 283, 290.28, 0.0, 'they would be They would be home every day<00:04:50.480><c> for</c><00:04:50.640><c> dinner.</c><00:04:51.320><c> And</c><00:04:51.600><c> um</c>', '', '', '<span>they</span> <span>would</span> <span>be</span> <span>They</span> <span>would</span> <span>be</span> <span>home</span> <span>every</span> <span>day<00:04:50.480><c></span> <span>for</c><00:04:50.640><c></span> <span>dinner.</c><00:04:51.320><c></span> <span>And</c><00:04:51.600><c></span> <span>um</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 284, 291.83, 0.0, 'day for dinner. And um', '', '', '<span>day</span> <span>for</span> <span>dinner.</span> <span>And</span> <span>um</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 285, 291.84, 0.0, 'day for dinner. And um That''s<00:04:52.000><c> nice.</c>', '', '', '<span>day</span> <span>for</span> <span>dinner.</span> <span>And</span> <span>um</span> <span>That''s<00:04:52.000><c></span> <span>nice.</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 286, 292.39, 0.0, 'That''s nice.', '', '', '<span>That''s</span> <span>nice.</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 287, 292.4, 0.0, 'That''s nice. Yeah.', '', '', '<span>That''s</span> <span>nice.</span> <span>Yeah.</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 288, 293.43, 0.0, 'Yeah.', '', '', '<span>Yeah.</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 289, 293.44, 0.0, 'Yeah. I<00:04:53.560><c> remember</c><00:04:53.960><c> that</c><00:04:54.440><c> that</c><00:04:54.640><c> very</c><00:04:54.840><c> distinctly.</c>', '', '', '<span>Yeah.</span> <span>I<00:04:53.560><c></span> <span>remember</c><00:04:53.960><c></span> <span>that</c><00:04:54.440><c></span> <span>that</c><00:04:54.640><c></span> <span>very</c><00:04:54.840><c></span> <span>distinctly.</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 290, 296.15, 0.0, 'I remember that that very distinctly.', '', '', '<span>I</span> <span>remember</span> <span>that</span> <span>that</span> <span>very</span> <span>distinctly.</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 291, 296.16, 0.0, 'I remember that that very distinctly. Um<00:04:56.360><c> but</c><00:04:56.840><c> I</c><00:04:57.080><c> I</c><00:04:57.160><c> try</c><00:04:57.400><c> to</c><00:04:57.560><c> do</c><00:04:57.680><c> that</c><00:04:58.280><c> as</c><00:04:58.480><c> much</c><00:04:58.720><c> as</c><00:04:58.880><c> I</c>', '', '', '<span>I</span> <span>remember</span> <span>that</span> <span>that</span> <span>very</span> <span>distinctly.</span> <span>Um<00:04:56.360><c></span> <span>but</c><00:04:56.840><c></span> <span>I</c><00:04:57.080><c></span> <span>I</c><00:04:57.160><c></span> <span>try</c><00:04:57.400><c></span> <span>to</c><00:04:57.560><c></span> <span>do</c><00:04:57.680><c></span> <span>that</c><00:04:58.280><c></span> <span>as</c><00:04:58.480><c></span> <span>much</c><00:04:58.720><c></span> <span>as</c><00:04:58.880><c></span> <span>I</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 292, 298.95, 0.0, 'Um but I I try to do that as much as I', '', '', '<span>Um</span> <span>but</span> <span>I</span> <span>I</span> <span>try</span> <span>to</span> <span>do</span> <span>that</span> <span>as</span> <span>much</span> <span>as</span> <span>I</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 293, 298.96, 0.0, 'Um but I I try to do that as much as I can.<00:04:59.640><c> Hoping</c><00:05:00.000><c> that,</c><00:05:00.240><c> you</c><00:05:00.360><c> know,</c><00:05:00.919><c> being</c><00:05:01.120><c> around</c>', '', '', '<span>Um</span> <span>but</span> <span>I</span> <span>I</span> <span>try</span> <span>to</span> <span>do</span> <span>that</span> <span>as</span> <span>much</span> <span>as</span> <span>I</span> <span>can.<00:04:59.640><c></span> <span>Hoping</c><00:05:00.000><c></span> <span>that,</c><00:05:00.240><c></span> <span>you</c><00:05:00.360><c></span> <span>know,</c><00:05:00.919><c></span> <span>being</c><00:05:01.120><c></span> <span>around</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 294, 301.55, 0.0, 'can. Hoping that, you know, being around', '', '', '<span>can.</span> <span>Hoping</span> <span>that,</span> <span>you</span> <span>know,</span> <span>being</span> <span>around</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 295, 301.56, 0.0, 'can. Hoping that, you know, being around can<00:05:01.760><c> shape</c><00:05:02.280><c> a</c><00:05:02.360><c> person.</c><00:05:03.040><c> You</c><00:05:03.160><c> are</c><00:05:03.280><c> who</c><00:05:03.560><c> you</c><00:05:03.680><c> mix</c>', '', '', '<span>can.</span> <span>Hoping</span> <span>that,</span> <span>you</span> <span>know,</span> <span>being</span> <span>around</span> <span>can<00:05:01.760><c></span> <span>shape</c><00:05:02.280><c></span> <span>a</c><00:05:02.360><c></span> <span>person.</c><00:05:03.040><c></span> <span>You</c><00:05:03.160><c></span> <span>are</c><00:05:03.280><c></span> <span>who</c><00:05:03.560><c></span> <span>you</c><00:05:03.680><c></span> <span>mix</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 296, 303.909, 0.0, 'can shape a person. You are who you mix', '', '', '<span>can</span> <span>shape</span> <span>a</span> <span>person.</span> <span>You</span> <span>are</span> <span>who</span> <span>you</span> <span>mix</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 297, 303.919, 0.0, 'can shape a person. You are who you mix around<00:05:04.200><c> with.</c>', '', '', '<span>can</span> <span>shape</span> <span>a</span> <span>person.</span> <span>You</span> <span>are</span> <span>who</span> <span>you</span> <span>mix</span> <span>around<00:05:04.200><c></span> <span>with.</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 298, 305.55, 0.0, 'around with.', '', '', '<span>around</span> <span>with.</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 299, 305.56, 0.0, 'around with. You''re<00:05:05.880><c> the</c><00:05:06.120><c> average</c><00:05:06.480><c> of</c><00:05:06.600><c> the</c><00:05:06.720><c> five</c><00:05:06.919><c> people</c>', '', '', '<span>around</span> <span>with.</span> <span>You''re<00:05:05.880><c></span> <span>the</c><00:05:06.120><c></span> <span>average</c><00:05:06.480><c></span> <span>of</c><00:05:06.600><c></span> <span>the</c><00:05:06.720><c></span> <span>five</c><00:05:06.919><c></span> <span>people</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 300, 307.19, 0.0, 'You''re the average of the five people', '', '', '<span>You''re</span> <span>the</span> <span>average</span> <span>of</span> <span>the</span> <span>five</span> <span>people</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 301, 307.2, 0.0, 'You''re the average of the five people you<00:05:07.440><c> hang</c><00:05:07.640><c> around</c><00:05:08.040><c> with.</c><00:05:08.240><c> So,</c><00:05:08.880><c> I</c><00:05:09.040><c> I</c><00:05:09.120><c> hope</c><00:05:09.320><c> to</c><00:05:09.440><c> be</c>', '', '', '<span>You''re</span> <span>the</span> <span>average</span> <span>of</span> <span>the</span> <span>five</span> <span>people</span> <span>you<00:05:07.440><c></span> <span>hang</c><00:05:07.640><c></span> <span>around</c><00:05:08.040><c></span> <span>with.</c><00:05:08.240><c></span> <span>So,</c><00:05:08.880><c></span> <span>I</c><00:05:09.040><c></span> <span>I</c><00:05:09.120><c></span> <span>hope</c><00:05:09.320><c></span> <span>to</c><00:05:09.440><c></span> <span>be</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 302, 309.55, 0.0, 'you hang around with. So, I I hope to be', '', '', '<span>you</span> <span>hang</span> <span>around</span> <span>with.</span> <span>So,</span> <span>I</span> <span>I</span> <span>hope</span> <span>to</span> <span>be</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 303, 309.56, 0.0, 'you hang around with. So, I I hope to be one<00:05:09.720><c> of</c><00:05:09.800><c> the</c><00:05:09.880><c> five</c><00:05:10.240><c> for</c><00:05:10.520><c> as</c><00:05:10.720><c> long</c><00:05:10.919><c> as</c><00:05:11.080><c> I</c><00:05:11.160><c> can.</c>', '', '', '<span>you</span> <span>hang</span> <span>around</span> <span>with.</span> <span>So,</span> <span>I</span> <span>I</span> <span>hope</span> <span>to</span> <span>be</span> <span>one<00:05:09.720><c></span> <span>of</c><00:05:09.800><c></span> <span>the</c><00:05:09.880><c></span> <span>five</c><00:05:10.240><c></span> <span>for</c><00:05:10.520><c></span> <span>as</c><00:05:10.720><c></span> <span>long</c><00:05:10.919><c></span> <span>as</c><00:05:11.080><c></span> <span>I</c><00:05:11.160><c></span> <span>can.</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 304, 312.07, 0.0, 'one of the five for as long as I can.', '', '', '<span>one</span> <span>of</span> <span>the</span> <span>five</span> <span>for</span> <span>as</span> <span>long</span> <span>as</span> <span>I</span> <span>can.</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 305, 312.08, 0.0, 'one of the five for as long as I can. Do<00:05:12.320><c> you</c><00:05:12.440><c> think</c><00:05:12.720><c> spending</c><00:05:13.200><c> lots</c><00:05:13.480><c> of</c><00:05:13.600><c> time</c><00:05:13.840><c> with</c>', '', '', '<span>one</span> <span>of</span> <span>the</span> <span>five</span> <span>for</span> <span>as</span> <span>long</span> <span>as</span> <span>I</span> <span>can.</span> <span>Do<00:05:12.320><c></span> <span>you</c><00:05:12.440><c></span> <span>think</c><00:05:12.720><c></span> <span>spending</c><00:05:13.200><c></span> <span>lots</c><00:05:13.480><c></span> <span>of</c><00:05:13.600><c></span> <span>time</c><00:05:13.840><c></span> <span>with</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 306, 313.95, 0.0, 'Do you think spending lots of time with', '', '', '<span>Do</span> <span>you</span> <span>think</span> <span>spending</span> <span>lots</span> <span>of</span> <span>time</span> <span>with</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 307, 313.96, 0.0, 'Do you think spending lots of time with him<00:05:14.480><c> is</c><00:05:14.640><c> a</c><00:05:14.760><c> good</c><00:05:15.000><c> way</c><00:05:15.200><c> to</c><00:05:15.360><c> teach</c><00:05:15.680><c> him</c><00:05:15.880><c> good</c>', '', '', '<span>Do</span> <span>you</span> <span>think</span> <span>spending</span> <span>lots</span> <span>of</span> <span>time</span> <span>with</span> <span>him<00:05:14.480><c></span> <span>is</c><00:05:14.640><c></span> <span>a</c><00:05:14.760><c></span> <span>good</c><00:05:15.000><c></span> <span>way</c><00:05:15.200><c></span> <span>to</c><00:05:15.360><c></span> <span>teach</c><00:05:15.680><c></span> <span>him</c><00:05:15.880><c></span> <span>good</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 308, 316.11, 0.0, 'him is a good way to teach him good', '', '', '<span>him</span> <span>is</span> <span>a</span> <span>good</span> <span>way</span> <span>to</span> <span>teach</span> <span>him</span> <span>good</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 309, 316.12, 0.0, 'him is a good way to teach him good values?', '', '', '<span>him</span> <span>is</span> <span>a</span> <span>good</span> <span>way</span> <span>to</span> <span>teach</span> <span>him</span> <span>good</span> <span>values?</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 310, 316.87, 0.0, 'values?', '', '', '<span>values?</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 311, 316.88, 0.0, 'values? Yes,<00:05:17.480><c> I</c><00:05:17.600><c> do.</c><00:05:18.440><c> Um</c><00:05:18.800><c> the</c><00:05:18.880><c> other</c><00:05:19.040><c> day</c><00:05:19.240><c> we</c><00:05:19.320><c> were</c><00:05:19.400><c> just</c>', '', '', '<span>values?</span> <span>Yes,<00:05:17.480><c></span> <span>I</c><00:05:17.600><c></span> <span>do.</c><00:05:18.440><c></span> <span>Um</c><00:05:18.800><c></span> <span>the</c><00:05:18.880><c></span> <span>other</c><00:05:19.040><c></span> <span>day</c><00:05:19.240><c></span> <span>we</c><00:05:19.320><c></span> <span>were</c><00:05:19.400><c></span> <span>just</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 312, 319.63, 0.0, 'Yes, I do. Um the other day we were just', '', '', '<span>Yes,</span> <span>I</span> <span>do.</span> <span>Um</span> <span>the</span> <span>other</span> <span>day</span> <span>we</span> <span>were</span> <span>just</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 313, 319.64, 0.0, 'Yes, I do. Um the other day we were just walking<00:05:20.560><c> and</c><00:05:20.720><c> he</c><00:05:20.840><c> said,</c><00:05:21.480><c> "Hey,</c><00:05:21.760><c> Mama,</c><00:05:22.120><c> look.</c>', '', '', '<span>Yes,</span> <span>I</span> <span>do.</span> <span>Um</span> <span>the</span> <span>other</span> <span>day</span> <span>we</span> <span>were</span> <span>just</span> <span>walking<00:05:20.560><c></span> <span>and</c><00:05:20.720><c></span> <span>he</c><00:05:20.840><c></span> <span>said,</c><00:05:21.480><c></span> <span>"Hey,</c><00:05:21.760><c></span> <span>Mama,</c><00:05:22.120><c></span> <span>look.</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 314, 322.55, 0.0, 'walking and he said, "Hey, Mama, look.', '', '', '<span>walking</span> <span>and</span> <span>he</span> <span>said,</span> <span>"Hey,</span> <span>Mama,</span> <span>look.</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 315, 322.56, 0.0, 'walking and he said, "Hey, Mama, look. Uh', '', '', '<span>walking</span> <span>and</span> <span>he</span> <span>said,</span> <span>"Hey,</span> <span>Mama,</span> <span>look.</span> <span>Uh</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 316, 323.23, 0.0, 'Uh', '', '', '<span>Uh</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 317, 323.24, 0.0, 'Uh there<00:05:23.360><c> was</c><00:05:23.520><c> like</c><00:05:23.680><c> a</c><00:05:23.720><c> piece</c><00:05:24.080><c> of</c><00:05:24.240><c> ribbon</c><00:05:24.600><c> on</c><00:05:24.720><c> the</c>', '', '', '<span>Uh</span> <span>there<00:05:23.360><c></span> <span>was</c><00:05:23.520><c></span> <span>like</c><00:05:23.680><c></span> <span>a</c><00:05:23.720><c></span> <span>piece</c><00:05:24.080><c></span> <span>of</c><00:05:24.240><c></span> <span>ribbon</c><00:05:24.600><c></span> <span>on</c><00:05:24.720><c></span> <span>the</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 318, 324.79, 0.0, 'there was like a piece of ribbon on the', '', '', '<span>there</span> <span>was</span> <span>like</span> <span>a</span> <span>piece</span> <span>of</span> <span>ribbon</span> <span>on</span> <span>the</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 319, 324.8, 0.0, 'there was like a piece of ribbon on the floor."<00:05:25.200><c> And</c><00:05:25.320><c> he</c><00:05:25.400><c> said,</c><00:05:25.640><c> "Somebody</c><00:05:26.040><c> threw</c><00:05:26.600><c> the</c>', '', '', '<span>there</span> <span>was</span> <span>like</span> <span>a</span> <span>piece</span> <span>of</span> <span>ribbon</span> <span>on</span> <span>the</span> <span>floor."<00:05:25.200><c></span> <span>And</c><00:05:25.320><c></span> <span>he</c><00:05:25.400><c></span> <span>said,</c><00:05:25.640><c></span> <span>"Somebody</c><00:05:26.040><c></span> <span>threw</c><00:05:26.600><c></span> <span>the</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 320, 326.75, 0.0, 'floor." And he said, "Somebody threw the', '', '', '<span>floor."</span> <span>And</span> <span>he</span> <span>said,</span> <span>"Somebody</span> <span>threw</span> <span>the</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 321, 326.76, 0.0, 'floor." And he said, "Somebody threw the rubbish<00:05:27.160><c> here."</c><00:05:27.720><c> It</c><00:05:27.880><c> probably</c><00:05:28.160><c> flew</c><00:05:28.440><c> down</c>', '', '', '<span>floor."</span> <span>And</span> <span>he</span> <span>said,</span> <span>"Somebody</span> <span>threw</span> <span>the</span> <span>rubbish<00:05:27.160><c></span> <span>here."</c><00:05:27.720><c></span> <span>It</c><00:05:27.880><c></span> <span>probably</c><00:05:28.160><c></span> <span>flew</c><00:05:28.440><c></span> <span>down</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 322, 328.63, 0.0, 'rubbish here." It probably flew down', '', '', '<span>rubbish</span> <span>here."</span> <span>It</span> <span>probably</span> <span>flew</span> <span>down</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 323, 328.64, 0.0, 'rubbish here." It probably flew down from<00:05:28.800><c> somewhere,</c><00:05:29.200><c> okay?</c>', '', '', '<span>rubbish</span> <span>here."</span> <span>It</span> <span>probably</span> <span>flew</span> <span>down</span> <span>from<00:05:28.800><c></span> <span>somewhere,</c><00:05:29.200><c></span> <span>okay?</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 324, 330.23, 0.0, 'from somewhere, okay?', '', '', '<span>from</span> <span>somewhere,</span> <span>okay?</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 325, 330.24, 0.0, 'from somewhere, okay? I<00:05:30.400><c> was</c><00:05:30.480><c> like,</c><00:05:30.640><c> "Yeah,</c><00:05:31.320><c> shall</c><00:05:31.480><c> we</c><00:05:31.600><c> pick</c><00:05:31.840><c> it</c><00:05:32.040><c> up?"</c>', '', '', '<span>from</span> <span>somewhere,</span> <span>okay?</span> <span>I<00:05:30.400><c></span> <span>was</c><00:05:30.480><c></span> <span>like,</c><00:05:30.640><c></span> <span>"Yeah,</c><00:05:31.320><c></span> <span>shall</c><00:05:31.480><c></span> <span>we</c><00:05:31.600><c></span> <span>pick</c><00:05:31.840><c></span> <span>it</c><00:05:32.040><c></span> <span>up?"</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 326, 332.51, 0.0, 'I was like, "Yeah, shall we pick it up?"', '', '', '<span>I</span> <span>was</span> <span>like,</span> <span>"Yeah,</span> <span>shall</span> <span>we</span> <span>pick</span> <span>it</span> <span>up?"</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 327, 332.52, 0.0, 'I was like, "Yeah, shall we pick it up?" He<00:05:32.600><c> said,</c><00:05:32.800><c> "Yeah,</c><00:05:33.200><c> you</c><00:05:33.400><c> pick</c><00:05:33.600><c> it</c><00:05:33.720><c> up."</c>', '', '', '<span>I</span> <span>was</span> <span>like,</span> <span>"Yeah,</span> <span>shall</span> <span>we</span> <span>pick</span> <span>it</span> <span>up?"</span> <span>He<00:05:32.600><c></span> <span>said,</c><00:05:32.800><c></span> <span>"Yeah,</c><00:05:33.200><c></span> <span>you</c><00:05:33.400><c></span> <span>pick</c><00:05:33.600><c></span> <span>it</c><00:05:33.720><c></span> <span>up."</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 328, 335.11, 0.0, 'He said, "Yeah, you pick it up."', '', '', '<span>He</span> <span>said,</span> <span>"Yeah,</span> <span>you</span> <span>pick</span> <span>it</span> <span>up."</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 329, 335.12, 0.0, 'He said, "Yeah, you pick it up." So,<00:05:35.320><c> I</c><00:05:35.360><c> had</c><00:05:35.520><c> to</c><00:05:35.560><c> pick</c><00:05:35.720><c> it</c><00:05:35.840><c> up</c><00:05:35.919><c> and</c><00:05:36.000><c> throw</c><00:05:36.160><c> it</c>', '', '', '<span>He</span> <span>said,</span> <span>"Yeah,</span> <span>you</span> <span>pick</span> <span>it</span> <span>up."</span> <span>So,<00:05:35.320><c></span> <span>I</c><00:05:35.360><c></span> <span>had</c><00:05:35.520><c></span> <span>to</c><00:05:35.560><c></span> <span>pick</c><00:05:35.720><c></span> <span>it</c><00:05:35.840><c></span> <span>up</c><00:05:35.919><c></span> <span>and</c><00:05:36.000><c></span> <span>throw</c><00:05:36.160><c></span> <span>it</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 330, 336.23, 0.0, 'So, I had to pick it up and throw it', '', '', '<span>So,</span> <span>I</span> <span>had</span> <span>to</span> <span>pick</span> <span>it</span> <span>up</span> <span>and</span> <span>throw</span> <span>it</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 331, 336.24, 0.0, 'So, I had to pick it up and throw it away.<00:05:36.640><c> Um</c><00:05:37.000><c> so,</c><00:05:37.800><c> yeah,</c><00:05:37.960><c> it''s</c><00:05:38.080><c> not</c><00:05:38.200><c> the</c><00:05:38.320><c> nicest</c>', '', '', '<span>So,</span> <span>I</span> <span>had</span> <span>to</span> <span>pick</span> <span>it</span> <span>up</span> <span>and</span> <span>throw</span> <span>it</span> <span>away.<00:05:36.640><c></span> <span>Um</c><00:05:37.000><c></span> <span>so,</c><00:05:37.800><c></span> <span>yeah,</c><00:05:37.960><c></span> <span>it''s</c><00:05:38.080><c></span> <span>not</c><00:05:38.200><c></span> <span>the</c><00:05:38.320><c></span> <span>nicest</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 332, 338.67, 0.0, 'away. Um so, yeah, it''s not the nicest', '', '', '<span>away.</span> <span>Um</span> <span>so,</span> <span>yeah,</span> <span>it''s</span> <span>not</span> <span>the</span> <span>nicest</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 333, 338.68, 0.0, 'away. Um so, yeah, it''s not the nicest thing,<00:05:38.960><c> but</c><00:05:39.360><c> if</c><00:05:39.640><c> he''s</c><00:05:39.960><c> watching</c><00:05:40.480><c> Yeah,</c>', '', '', '<span>away.</span> <span>Um</span> <span>so,</span> <span>yeah,</span> <span>it''s</span> <span>not</span> <span>the</span> <span>nicest</span> <span>thing,<00:05:38.960><c></span> <span>but</c><00:05:39.360><c></span> <span>if</c><00:05:39.640><c></span> <span>he''s</c><00:05:39.960><c></span> <span>watching</c><00:05:40.480><c></span> <span>Yeah,</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 334, 341.15, 0.0, 'thing, but if he''s watching Yeah,', '', '', '<span>thing,</span> <span>but</span> <span>if</span> <span>he''s</span> <span>watching</span> <span>Yeah,</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 335, 341.16, 0.0, 'thing, but if he''s watching Yeah, he''s<00:05:41.400><c> getting</c><00:05:41.760><c> there</c><00:05:42.080><c> and</c><00:05:42.240><c> he''s</c><00:05:42.520><c> watching</c><00:05:43.040><c> and</c>', '', '', '<span>thing,</span> <span>but</span> <span>if</span> <span>he''s</span> <span>watching</span> <span>Yeah,</span> <span>he''s<00:05:41.400><c></span> <span>getting</c><00:05:41.760><c></span> <span>there</c><00:05:42.080><c></span> <span>and</c><00:05:42.240><c></span> <span>he''s</c><00:05:42.520><c></span> <span>watching</c><00:05:43.040><c></span> <span>and</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 336, 343.19, 0.0, 'he''s getting there and he''s watching and', '', '', '<span>he''s</span> <span>getting</span> <span>there</span> <span>and</span> <span>he''s</span> <span>watching</span> <span>and</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 337, 343.2, 0.0, 'he''s getting there and he''s watching and he''s<00:05:43.400><c> seeing</c><00:05:43.680><c> if</c><00:05:43.919><c> I''m</c><00:05:44.240><c> walking</c><00:05:44.520><c> the</c><00:05:44.640><c> talk.</c><00:05:45.040><c> So,</c>', '', '', '<span>he''s</span> <span>getting</span> <span>there</span> <span>and</span> <span>he''s</span> <span>watching</span> <span>and</span> <span>he''s<00:05:43.400><c></span> <span>seeing</c><00:05:43.680><c></span> <span>if</c><00:05:43.919><c></span> <span>I''m</c><00:05:44.240><c></span> <span>walking</c><00:05:44.520><c></span> <span>the</c><00:05:44.640><c></span> <span>talk.</c><00:05:45.040><c></span> <span>So,</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 338, 345.63, 0.0, 'he''s seeing if I''m walking the talk. So,', '', '', '<span>he''s</span> <span>seeing</span> <span>if</span> <span>I''m</span> <span>walking</span> <span>the</span> <span>talk.</span> <span>So,</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 339, 345.64, 0.0, 'he''s seeing if I''m walking the talk. So, yes,<00:05:46.320><c> it</c><00:05:46.640><c> it</c><00:05:46.760><c> does</c><00:05:47.040><c> start</c><00:05:47.320><c> from</c><00:05:47.560><c> home,</c><00:05:48.120><c> I</c>', '', '', '<span>he''s</span> <span>seeing</span> <span>if</span> <span>I''m</span> <span>walking</span> <span>the</span> <span>talk.</span> <span>So,</span> <span>yes,<00:05:46.320><c></span> <span>it</c><00:05:46.640><c></span> <span>it</c><00:05:46.760><c></span> <span>does</c><00:05:47.040><c></span> <span>start</c><00:05:47.320><c></span> <span>from</c><00:05:47.560><c></span> <span>home,</c><00:05:48.120><c></span> <span>I</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 340, 348.19, 0.0, 'yes, it it does start from home, I', '', '', '<span>yes,</span> <span>it</span> <span>it</span> <span>does</span> <span>start</span> <span>from</span> <span>home,</span> <span>I</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 341, 348.2, 0.0, 'yes, it it does start from home, I think.', '', '', '<span>yes,</span> <span>it</span> <span>it</span> <span>does</span> <span>start</span> <span>from</span> <span>home,</span> <span>I</span> <span>think.</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 342, 348.99, 0.0, 'think.', '', '', '<span>think.</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 343, 349.0, 0.0, 'think. What<00:05:49.320><c> is</c><00:05:49.560><c> your</c><00:05:49.760><c> secret</c><00:05:50.240><c> to</c><00:05:50.360><c> happiness?</c>', '', '', '<span>think.</span> <span>What<00:05:49.320><c></span> <span>is</c><00:05:49.560><c></span> <span>your</c><00:05:49.760><c></span> <span>secret</c><00:05:50.240><c></span> <span>to</c><00:05:50.360><c></span> <span>happiness?</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 344, 351.55, 0.0, 'What is your secret to happiness?', '', '', '<span>What</span> <span>is</span> <span>your</span> <span>secret</span> <span>to</span> <span>happiness?</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 345, 351.56, 0.0, 'What is your secret to happiness? I<00:05:51.640><c> think</c><00:05:51.840><c> the</c><00:05:51.960><c> secret</c><00:05:53.040><c> is</c>', '', '', '<span>What</span> <span>is</span> <span>your</span> <span>secret</span> <span>to</span> <span>happiness?</span> <span>I<00:05:51.640><c></span> <span>think</c><00:05:51.840><c></span> <span>the</c><00:05:51.960><c></span> <span>secret</c><00:05:53.040><c></span> <span>is</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 346, 354.55, 0.0, 'I think the secret is', '', '', '<span>I</span> <span>think</span> <span>the</span> <span>secret</span> <span>is</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 347, 354.56, 0.0, 'I think the secret is to<00:05:54.720><c> not</c><00:05:55.320><c> measure</c><00:05:55.840><c> it,</c><00:05:56.280><c> to</c><00:05:56.400><c> not</c>', '', '', '<span>I</span> <span>think</span> <span>the</span> <span>secret</span> <span>is</span> <span>to<00:05:54.720><c></span> <span>not</c><00:05:55.320><c></span> <span>measure</c><00:05:55.840><c></span> <span>it,</c><00:05:56.280><c></span> <span>to</c><00:05:56.400><c></span> <span>not</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 348, 357.59, 0.0, 'to not measure it, to not', '', '', '<span>to</span> <span>not</span> <span>measure</span> <span>it,</span> <span>to</span> <span>not</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 349, 357.6, 0.0, 'to not measure it, to not obsess<00:05:58.240><c> about</c><00:05:58.640><c> it.</c>', '', '', '<span>to</span> <span>not</span> <span>measure</span> <span>it,</span> <span>to</span> <span>not</span> <span>obsess<00:05:58.240><c></span> <span>about</c><00:05:58.640><c></span> <span>it.</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 350, 359.63, 0.0, 'obsess about it.', '', '', '<span>obsess</span> <span>about</span> <span>it.</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 351, 359.64, 0.0, 'obsess about it. Because', '', '', '<span>obsess</span> <span>about</span> <span>it.</span> <span>Because</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 352, 360.55, 0.0, 'Because', '', '', '<span>Because</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 353, 360.56, 0.0, 'Because being<00:06:00.880><c> unhappy</c><00:06:01.280><c> is</c><00:06:01.400><c> a</c><00:06:01.480><c> very</c><00:06:01.880><c> natural</c><00:06:02.200><c> way</c><00:06:02.320><c> of</c>', '', '', '<span>Because</span> <span>being<00:06:00.880><c></span> <span>unhappy</c><00:06:01.280><c></span> <span>is</c><00:06:01.400><c></span> <span>a</c><00:06:01.480><c></span> <span>very</c><00:06:01.880><c></span> <span>natural</c><00:06:02.200><c></span> <span>way</c><00:06:02.320><c></span> <span>of</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 354, 362.47, 0.0, 'being unhappy is a very natural way of', '', '', '<span>being</span> <span>unhappy</span> <span>is</span> <span>a</span> <span>very</span> <span>natural</span> <span>way</span> <span>of</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 355, 362.48, 0.0, 'being unhappy is a very natural way of life.<00:06:03.120><c> There</c><00:06:03.440><c> always</c><00:06:03.840><c> things</c><00:06:04.200><c> that</c><00:06:04.600><c> doesn''t</c>', '', '', '<span>being</span> <span>unhappy</span> <span>is</span> <span>a</span> <span>very</span> <span>natural</span> <span>way</span> <span>of</span> <span>life.<00:06:03.120><c></span> <span>There</c><00:06:03.440><c></span> <span>always</c><00:06:03.840><c></span> <span>things</c><00:06:04.200><c></span> <span>that</c><00:06:04.600><c></span> <span>doesn''t</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 356, 364.87, 0.0, 'life. There always things that doesn''t', '', '', '<span>life.</span> <span>There</span> <span>always</span> <span>things</span> <span>that</span> <span>doesn''t</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 357, 364.88, 0.0, 'life. There always things that doesn''t go<00:06:05.040><c> your</c><00:06:05.240><c> way</c><00:06:05.640><c> or</c><00:06:05.760><c> you</c><00:06:05.840><c> think</c><00:06:06.000><c> it''s</c><00:06:06.120><c> not</c><00:06:06.360><c> good</c>', '', '', '<span>life.</span> <span>There</span> <span>always</span> <span>things</span> <span>that</span> <span>doesn''t</span> <span>go<00:06:05.040><c></span> <span>your</c><00:06:05.240><c></span> <span>way</c><00:06:05.640><c></span> <span>or</c><00:06:05.760><c></span> <span>you</c><00:06:05.840><c></span> <span>think</c><00:06:06.000><c></span> <span>it''s</c><00:06:06.120><c></span> <span>not</c><00:06:06.360><c></span> <span>good</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 358, 366.55, 0.0, 'go your way or you think it''s not good', '', '', '<span>go</span> <span>your</span> <span>way</span> <span>or</span> <span>you</span> <span>think</span> <span>it''s</span> <span>not</span> <span>good</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 359, 366.56, 0.0, 'go your way or you think it''s not good enough<00:06:07.200><c> or</c><00:06:07.560><c> just</c><00:06:07.960><c> things</c><00:06:08.320><c> that</c><00:06:08.680><c> you</c><00:06:08.880><c> wish</c><00:06:09.200><c> were</c>', '', '', '<span>go</span> <span>your</span> <span>way</span> <span>or</span> <span>you</span> <span>think</span> <span>it''s</span> <span>not</span> <span>good</span> <span>enough<00:06:07.200><c></span> <span>or</c><00:06:07.560><c></span> <span>just</c><00:06:07.960><c></span> <span>things</c><00:06:08.320><c></span> <span>that</c><00:06:08.680><c></span> <span>you</c><00:06:08.880><c></span> <span>wish</c><00:06:09.200><c></span> <span>were</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 360, 369.35, 0.0, 'enough or just things that you wish were', '', '', '<span>enough</span> <span>or</span> <span>just</span> <span>things</span> <span>that</span> <span>you</span> <span>wish</span> <span>were</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 361, 369.36, 0.0, 'enough or just things that you wish were different.<00:06:10.440><c> So,</c><00:06:10.680><c> if</c><00:06:10.880><c> you</c><00:06:11.360><c> I</c><00:06:11.440><c> think</c><00:06:11.960><c> the</c><00:06:12.080><c> secret</c>', '', '', '<span>enough</span> <span>or</span> <span>just</span> <span>things</span> <span>that</span> <span>you</span> <span>wish</span> <span>were</span> <span>different.<00:06:10.440><c></span> <span>So,</c><00:06:10.680><c></span> <span>if</c><00:06:10.880><c></span> <span>you</c><00:06:11.360><c></span> <span>I</c><00:06:11.440><c></span> <span>think</c><00:06:11.960><c></span> <span>the</c><00:06:12.080><c></span> <span>secret</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 362, 372.55, 0.0, 'different. So, if you I think the secret', '', '', '<span>different.</span> <span>So,</span> <span>if</span> <span>you</span> <span>I</span> <span>think</span> <span>the</span> <span>secret</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 363, 372.56, 0.0, 'different. So, if you I think the secret to<00:06:13.200><c> being</c><00:06:13.480><c> happy</c><00:06:13.920><c> is</c><00:06:14.440><c> is</c><00:06:14.640><c> really</c><00:06:15.040><c> to</c><00:06:15.400><c> just</c><00:06:15.760><c> do</c>', '', '', '<span>different.</span> <span>So,</span> <span>if</span> <span>you</span> <span>I</span> <span>think</span> <span>the</span> <span>secret</span> <span>to<00:06:13.200><c></span> <span>being</c><00:06:13.480><c></span> <span>happy</c><00:06:13.920><c></span> <span>is</c><00:06:14.440><c></span> <span>is</c><00:06:14.640><c></span> <span>really</c><00:06:15.040><c></span> <span>to</c><00:06:15.400><c></span> <span>just</c><00:06:15.760><c></span> <span>do</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 364, 375.95, 0.0, 'to being happy is is really to just do', '', '', '<span>to</span> <span>being</span> <span>happy</span> <span>is</span> <span>is</span> <span>really</span> <span>to</span> <span>just</span> <span>do</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 365, 375.96, 0.0, 'to being happy is is really to just do what<00:06:16.120><c> makes</c><00:06:16.280><c> sense</c><00:06:16.640><c> to</c><00:06:16.840><c> you</c><00:06:17.080><c> and</c><00:06:17.200><c> then</c><00:06:17.360><c> if</c><00:06:17.880><c> if</c>', '', '', '<span>to</span> <span>being</span> <span>happy</span> <span>is</span> <span>is</span> <span>really</span> <span>to</span> <span>just</span> <span>do</span> <span>what<00:06:16.120><c></span> <span>makes</c><00:06:16.280><c></span> <span>sense</c><00:06:16.640><c></span> <span>to</c><00:06:16.840><c></span> <span>you</c><00:06:17.080><c></span> <span>and</c><00:06:17.200><c></span> <span>then</c><00:06:17.360><c></span> <span>if</c><00:06:17.880><c></span> <span>if</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 366, 378.03, 0.0, 'what makes sense to you and then if if', '', '', '<span>what</span> <span>makes</span> <span>sense</span> <span>to</span> <span>you</span> <span>and</span> <span>then</span> <span>if</span> <span>if</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 367, 378.04, 0.0, 'what makes sense to you and then if if you<00:06:18.160><c> can</c><00:06:18.360><c> change</c><00:06:18.680><c> something,</c><00:06:19.160><c> change</c><00:06:19.520><c> it.</c><00:06:19.720><c> If</c>', '', '', '<span>what</span> <span>makes</span> <span>sense</span> <span>to</span> <span>you</span> <span>and</span> <span>then</span> <span>if</span> <span>if</span> <span>you<00:06:18.160><c></span> <span>can</c><00:06:18.360><c></span> <span>change</c><00:06:18.680><c></span> <span>something,</c><00:06:19.160><c></span> <span>change</c><00:06:19.520><c></span> <span>it.</c><00:06:19.720><c></span> <span>If</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 368, 379.83, 0.0, 'you can change something, change it. If', '', '', '<span>you</span> <span>can</span> <span>change</span> <span>something,</span> <span>change</span> <span>it.</span> <span>If</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 369, 379.84, 0.0, 'you can change something, change it. If you<00:06:19.960><c> can''t,</c><00:06:20.480><c> then</c><00:06:20.720><c> there''s</c><00:06:21.080><c> no</c><00:06:21.240><c> point</c><00:06:21.680><c> being</c>', '', '', '<span>you</span> <span>can</span> <span>change</span> <span>something,</span> <span>change</span> <span>it.</span> <span>If</span> <span>you<00:06:19.960><c></span> <span>can''t,</c><00:06:20.480><c></span> <span>then</c><00:06:20.720><c></span> <span>there''s</c><00:06:21.080><c></span> <span>no</c><00:06:21.240><c></span> <span>point</c><00:06:21.680><c></span> <span>being</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 370, 381.909, 0.0, 'you can''t, then there''s no point being', '', '', '<span>you</span> <span>can''t,</span> <span>then</span> <span>there''s</span> <span>no</span> <span>point</span> <span>being</span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 371, 381.919, 0.0, 'you can''t, then there''s no point being unhappy<00:06:22.400><c> about</c><00:06:22.800><c> it.</c>', '', '', '<span>you</span> <span>can''t,</span> <span>then</span> <span>there''s</span> <span>no</span> <span>point</span> <span>being</span> <span>unhappy<00:06:22.400><c></span> <span>about</c><00:06:22.800><c></span> <span>it.</c></span>'
FROM episodes e WHERE e.video_id = 'pgdzTec-K5LxriI';

-- episode 192: 1ZOWIuMJ1FHBY7w
INSERT INTO episodes (
  index, video_id, short_title, summary, remark, stars, voca_size,
  subtitle_count, clip_length, cover, video_url, audio_url, thumbnail_url,
  original_video_url, author_id, submitted_by_user_id, rejection_reason,
  created_at, is_demo, status, published_at
) VALUES (
  192, '1ZOWIuMJ1FHBY7w', '吉米·坎摩尔采访NCAA冠军UCLA女篮',
  '来自NCAA冠军UCLA女子篮球队的Lauren Betts、Kiki Rice、Gabriela Jaquez、Angela Dugalić和教练Cori Close谈论了夺冠后的庆祝、征战疯狂三月锦标赛的经历、Lauren被评为MOP（最杰出球员）、WNBA选秀、奥巴马总统的祝贺，以及如果受邀前往白宫并决定前往……吉米送给他们一个假奖杯，以便他们可以送给唐纳德·特朗普，这样他就不会试图拿走真奖杯了。', '',
  3, 0, 448,
  0.0, 'http://oss.sxakgs.com/en/u_v_TyLkQJg/cover.webp',
  'http://oss.sxakgs.com/en/u_v_TyLkQJg/video.mp4', 'http://oss.sxakgs.com/en/u_v_TyLkQJg/audio.mp3',
  'http://oss.sxakgs.com/en/u_v_TyLkQJg/cover.webp', 'https://www.youtube.com/watch?v=u_v_TyLkQJg',
  (SELECT id FROM authors WHERE name = 'Jimmy Kimmel Live' AND accent = '美国' LIMIT 1),
  NULL, NULL,
  '2026-07-02 15:39:49'::timestamp,
  FALSE, 'published',
  '2026-07-02 15:39:49'::timestamp
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
  SELECT s.id FROM subtitles s JOIN episodes e ON s.episode_id = e.id WHERE e.video_id = '1ZOWIuMJ1FHBY7w'
);
DELETE FROM subtitles WHERE episode_id = (SELECT id FROM episodes WHERE video_id = '1ZOWIuMJ1FHBY7w');
DELETE FROM episode_tags WHERE episode_id = (SELECT id FROM episodes WHERE video_id = '1ZOWIuMJ1FHBY7w');

INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 0, 1.91, 0.0, 'Now, our next guest won the national', '', '', '<span>Now</span><span>,</span><span>our</span><span>next</span><span tid="50001" class="highlight highlight-a">guest</span><span>won</span><span>the</span><span tid="50002" class="highlight highlight-a">national</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 1, 1.92, 0.0, 'Now, our next guest won the national women''s<00:00:02.320><c> basketball</c><00:00:03.000><c> title</c><00:00:03.440><c> for</c><00:00:03.680><c> UCLA.</c><00:00:04.920><c> They</c>', '', '', '<span>Now,</span><span>our</span><span>next</span><span>guest</span><span>won</span><span>the</span><span>national</span><span>women''s<00:00:02.320><c></span><span>basketball</c><00:00:03.000><c></span><span>title</c><00:00:03.440><c></span><span>for</c><00:00:03.680><c></span><span>UCLA.</c><00:00:04.920><c></span><span>They</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 2, 5.07, 0.0, 'women''s basketball title for UCLA. They', '', '', '<span>women''s</span><span tid="50003" class="highlight highlight-a">basketball</span><span tid="50004" class="highlight highlight-a">title</span><span>for</span><span>UCLA.</span><span>They</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 3, 5.08, 0.0, 'women''s basketball title for UCLA. They have<00:00:05.200><c> been</c><00:00:05.440><c> celebrating</c><00:00:06.200><c> for</c><00:00:06.400><c> 3</c><00:00:06.760><c> days</c>', '', '', '<span>women''s</span><span>basketball</span><span>title</span><span>for</span><span>UCLA.</span><span>They</span><span>have<00:00:05.200><c></span><span>been</c><00:00:05.440><c></span><span>celebrating</c><00:00:06.200><c></span><span>for</c><00:00:06.400><c></span><span>3</c><00:00:06.760><c></span><span>days</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 4, 7.15, 0.0, 'have been celebrating for 3 days', '', '', '<span>have</span><span>been</span><span tid="50005" class="highlight highlight-a">celebrating</span><span>for</span><span>3</span><span>days</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 5, 7.16, 0.0, 'have been celebrating for 3 days straight<00:00:07.600><c> and</c><00:00:07.720><c> it</c><00:00:07.840><c> continues</c><00:00:08.560><c> right</c><00:00:08.840><c> now.</c>', '', '', '<span>have</span><span>been</span><span>celebrating</span><span>for</span><span>3</span><span>days</span><span>straight<00:00:07.600><c></span><span>and</c><00:00:07.720><c></span><span>it</c><00:00:07.840><c></span><span>continues</c><00:00:08.560><c></span><span>right</c><00:00:08.840><c></span><span>now.</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 6, 9.63, 0.0, 'straight and it continues right now.', '', '', '<span tid="50006" class="highlight highlight-a">straight</span><span>and</span><span>it</span><span tid="50007" class="highlight highlight-a">continues</span><span>right</span><span>now.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 7, 9.64, 0.0, 'straight and it continues right now. From<00:00:09.920><c> the</c><00:00:10.040><c> Bruins,</c><00:00:10.520><c> please</c><00:00:10.800><c> welcome</c><00:00:11.320><c> Angela</c>', '', '', '<span>straight</span><span>and</span><span>it</span><span>continues</span><span>right</span><span>now.</span><span>From<00:00:09.920><c></span><span>the</c><00:00:10.040><c></span><span>Bruins,</c><00:00:10.520><c></span><span>please</c><00:00:10.800><c></span><span>welcome</c><00:00:11.320><c></span><span>Angela</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 8, 11.79, 0.0, 'From the Bruins, please welcome Angela', '', '', '<span>From</span><span>the</span><span>Bruins</span><span>,</span><span>please</span><span tid="50008" class="highlight highlight-a">welcome</span><span>Angela</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 9, 11.8, 0.0, 'From the Bruins, please welcome Angela Dugalić,<00:00:12.560><c> Gabriela</c><00:00:13.280><c> Jaquez,</c><00:00:14.240><c> Kiki</c><00:00:14.640><c> Rice,</c><00:00:15.520><c> the</c>', '', '', '<span>From</span><span>the</span><span>Bruins,</span><span>please</span><span>welcome</span><span>Angela</span><span>Dugalić,<00:00:12.560><c></span><span>Gabriela</c><00:00:13.280><c></span><span>Jaquez,</c><00:00:14.240><c></span><span>Kiki</c><00:00:14.640><c></span><span>Rice,</c><00:00:15.520><c></span><span>the</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 10, 15.75, 0.0, 'Dugalić, Gabriela Jaquez, Kiki Rice, the', '', '', '<span>Dugalić</span><span>,</span><span>Gabriela</span><span>Jaquez</span><span>,</span><span>Kiki</span><span>Rice</span><span>,</span><span>the</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 11, 15.76, 0.0, 'Dugalić, Gabriela Jaquez, Kiki Rice, the MOP<00:00:16.320><c> Lauren</c><00:00:16.680><c> Betts,</c><00:00:17.040><c> and</c><00:00:17.200><c> coach</c><00:00:17.600><c> Cori</c><00:00:18.040><c> Close.</c>', '', '', '<span>Dugalić,</span><span>Gabriela</span><span>Jaquez,</span><span>Kiki</span><span>Rice,</span><span>the</span><span>MOP<00:00:16.320><c></span><span>Lauren</c><00:00:16.680><c></span><span>Betts,</c><00:00:17.040><c></span><span>and</c><00:00:17.200><c></span><span>coach</c><00:00:17.600><c></span><span>Cori</c><00:00:18.040><c></span><span>Close.</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 12, 38.99, 0.0, 'Oh my god, I thought I''d put this right', '', '', '<span>Oh</span><span>my</span><span tid="50009" class="highlight highlight-i">god</span><span>,</span><span>I</span><span>thought</span><span>I''d</span><span tid="50010" class="highlight highlight-d">put</span><span>this</span><span>right</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 13, 39.0, 0.0, 'Oh my god, I thought I''d put this right on<00:00:39.120><c> you.</c>', '', '', '<span>Oh</span><span>my</span><span>god,</span><span>I</span><span>thought</span><span>I''d</span><span>put</span><span>this</span><span>right</span><span>on<00:00:39.120><c></span><span>you.</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 14, 39.19, 0.0, 'on you.', '', '', '<span>on</span><span>you</span><span>.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 15, 39.2, 0.0, 'on you. &gt;&gt; Yeah,<00:00:39.400><c> I''ll</c><00:00:39.560><c> take</c><00:00:39.800><c> that.</c><00:00:40.160><c> Thank</c><00:00:40.560><c> you</c><00:00:40.720><c> so</c><00:00:40.920><c> much.</c>', '', '', '<span>on</span><span>you.</span><span>&gt;&gt;</span><span>Yeah,<00:00:39.400><c></span><span>I''ll</c><00:00:39.560><c></span><span>take</c><00:00:39.800><c></span><span>that.</c><00:00:40.160><c></span><span>Thank</c><00:00:40.560><c></span><span>you</c><00:00:40.720><c></span><span>so</c><00:00:40.920><c></span><span>much.</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 16, 41.15, 0.0, '&gt;&gt; Yeah, I''ll take that. Thank you so much.', '', '', '<span>&gt;&gt;</span><span>Yeah,</span><span>I''ll</span><span>take</span><span>that.</span><span>Thank</span><span>you</span><span>so</span><span>much.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 17, 41.16, 0.0, '&gt;&gt; Yeah, I''ll take that. Thank you so much. &gt;&gt; Hey, you''re<00:00:41.280><c> welcome.</c>', '', '', '<span>&gt;&gt;</span><span>Yeah,</span><span>I''ll</span><span>take</span><span>that.</span><span>Thank</span><span>you</span><span>so</span><span>much.</span><span>&gt;&gt;</span><span>Hey,</span><span>you''re<00:00:41.280><c></span><span>welcome.</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 18, 41.91, 0.0, '&gt;&gt; Hey, you''re welcome.', '', '', '<span>&gt;&gt;</span><span>Hey,</span><span>you''re</span><span>welcome.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 19, 41.92, 0.0, '&gt;&gt; Hey, you''re welcome. &gt;&gt; Wow,<00:00:42.160><c> that''s</c><00:00:42.480><c> pretty</c><00:00:42.760><c> impressive.</c>', '', '', '<span>&gt;&gt;</span><span>Hey,</span><span>you''re</span><span>welcome.</span><span>&gt;&gt;</span><span>Wow,<00:00:42.160><c></span><span>that''s</c><00:00:42.480><c></span><span>pretty</c><00:00:42.760><c></span><span>impressive.</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 20, 43.75, 0.0, '&gt;&gt; Wow, that''s pretty impressive.', '', '', '<span>&gt;&gt;</span><span>Wow,</span><span>that''s</span><span>pretty</span><span>impressive.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 21, 43.76, 0.0, '&gt;&gt; Wow, that''s pretty impressive. Congratulations.<00:00:44.840><c> I''m</c><00:00:44.960><c> excited</c><00:00:45.360><c> to</c><00:00:45.440><c> have</c><00:00:45.600><c> you</c>', '', '', '<span>&gt;&gt;</span><span>Wow,</span><span>that''s</span><span>pretty</span><span>impressive.</span><span>Congratulations.<00:00:44.840><c></span><span>I''m</c><00:00:44.960><c></span><span>excited</c><00:00:45.360><c></span><span>to</c><00:00:45.440><c></span><span>have</c><00:00:45.600><c></span><span>you</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 22, 45.67, 0.0, 'Congratulations. I''m excited to have you', '', '', '<span tid="50011" class="highlight highlight-a">Congratulations.</span><span>I''m</span><span tid="50012" class="highlight highlight-a">excited</span><span>to</span><span>have</span><span>you</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 23, 45.68, 0.0, 'Congratulations. I''m excited to have you guys<00:00:45.880><c> here.</c><00:00:46.320><c> There''s</c><00:00:46.560><c> a</c><00:00:47.120><c> a</c><00:00:47.160><c> lot</c><00:00:47.400><c> of</c><00:00:47.480><c> excitement</c>', '', '', '<span>Congratulations.</span><span>I''m</span><span>excited</span><span>to</span><span>have</span><span>you</span><span>guys<00:00:45.880><c></span><span>here.</c><00:00:46.320><c></span><span>There''s</c><00:00:46.560><c></span><span>a</c><00:00:47.120><c></span><span>a</c><00:00:47.160><c></span><span>lot</c><00:00:47.400><c></span><span>of</c><00:00:47.480><c></span><span>excitement</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 24, 48.07, 0.0, 'guys here. There''s a a lot of excitement', '', '', '<span>guys</span><span>here.</span><span>There''s</span><span>a</span><span>a</span><span>lot</span><span>of</span><span tid="50013" class="highlight highlight-a">excitement</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 25, 48.08, 0.0, 'guys here. There''s a a lot of excitement to<00:00:48.160><c> have</c><00:00:48.400><c> you</c><00:00:48.520><c> guys</c><00:00:48.840><c> here</c><00:00:49.120><c> tonight.</c><00:00:49.560><c> Are</c><00:00:49.680><c> you</c>', '', '', '<span>guys</span><span>here.</span><span>There''s</span><span>a</span><span>a</span><span>lot</span><span>of</span><span>excitement</span><span>to<00:00:48.160><c></span><span>have</c><00:00:48.400><c></span><span>you</c><00:00:48.520><c></span><span>guys</c><00:00:48.840><c></span><span>here</c><00:00:49.120><c></span><span>tonight.</c><00:00:49.560><c></span><span>Are</c><00:00:49.680><c></span><span>you</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 26, 49.75, 0.0, 'to have you guys here tonight. Are you', '', '', '<span>to</span><span>have</span><span>you</span><span>guys</span><span>here</span><span>tonight.</span><span>Are</span><span>you</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 27, 49.76, 0.0, 'to have you guys here tonight. Are you excited<00:00:50.120><c> to</c><00:00:50.200><c> be</c><00:00:50.360><c> here?</c>', '', '', '<span>to</span><span>have</span><span>you</span><span>guys</span><span>here</span><span>tonight.</span><span>Are</span><span>you</span><span>excited<00:00:50.120><c></span><span>to</c><00:00:50.200><c></span><span>be</c><00:00:50.360><c></span><span>here?</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 28, 50.67, 0.0, 'excited to be here?', '', '', '<span tid="50014" class="highlight highlight-a">excited</span><span>to</span><span>be</span><span>here?</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 29, 50.68, 0.0, 'excited to be here? &gt;&gt; Absolutely.<00:00:51.640><c> Yes.</c>', '', '', '<span>excited</span><span>to</span><span>be</span><span>here?</span><span>&gt;&gt;</span><span>Absolutely.<00:00:51.640><c></span><span>Yes.</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 30, 51.83, 0.0, '&gt;&gt; Absolutely. Yes.', '', '', '<span>&gt;&gt;</span><span>Absolutely.</span><span>Yes.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 31, 51.84, 0.0, '&gt;&gt; Absolutely. Yes. &gt;&gt; What<00:00:51.960><c> have</c><00:00:52.080><c> you</c><00:00:52.160><c> been</c><00:00:52.320><c> up</c><00:00:52.440><c> to</c><00:00:52.600><c> since</c><00:00:52.880><c> Sunday?</c>', '', '', '<span>&gt;&gt;</span><span>Absolutely.</span><span>Yes.</span><span>&gt;&gt;</span><span>What<00:00:51.960><c></span><span>have</c><00:00:52.080><c></span><span>you</c><00:00:52.160><c></span><span>been</c><00:00:52.320><c></span><span>up</c><00:00:52.440><c></span><span>to</c><00:00:52.600><c></span><span>since</c><00:00:52.880><c></span><span>Sunday?</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 32, 53.31, 0.0, '&gt;&gt; What have you been up to since Sunday?', '', '', '<span>&gt;&gt;</span><span>What</span><span>have</span><span>you</span><span>been</span><span>up</span><span>to</span><span>since</span><span>Sunday?</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 33, 53.32, 0.0, '&gt;&gt; What have you been up to since Sunday? What''s<00:00:53.560><c> been</c><00:00:53.680><c> going</c><00:00:54.040><c> on?</c>', '', '', '<span>&gt;&gt;</span><span>What</span><span>have</span><span>you</span><span>been</span><span>up</span><span>to</span><span>since</span><span>Sunday?</span><span>What''s<00:00:53.560><c></span><span>been</c><00:00:53.680><c></span><span>going</c><00:00:54.040><c></span><span>on?</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 34, 54.43, 0.0, 'What''s been going on?', '', '', '<span>What''s</span><span>been</span><span>going</span><span>on?</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 35, 54.44, 0.0, 'What''s been going on? &gt;&gt; Man.', '', '', '<span>What''s</span><span>been</span><span>going</span><span>on?</span><span>&gt;&gt;</span><span>Man.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 36, 55.31, 0.0, '&gt;&gt; Man.', '', '', '<span>&gt;&gt;</span><span>Man.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 37, 55.32, 0.0, '&gt;&gt; Man. &gt;&gt; What<00:00:55.360><c> hasn''t</c><00:00:55.680><c> been</c><00:00:55.800><c> happening?</c>', '', '', '<span>&gt;&gt;</span><span>Man.</span><span>&gt;&gt;</span><span>What<00:00:55.360><c></span><span>hasn''t</c><00:00:55.680><c></span><span>been</c><00:00:55.800><c></span><span>happening?</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 38, 55.99, 0.0, '&gt;&gt; What hasn''t been happening?', '', '', '<span>&gt;&gt;</span><span>What</span><span>hasn''t</span><span>been</span><span>happening?</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 39, 56.0, 0.0, '&gt;&gt; What hasn''t been happening? &gt;&gt; Partying.<00:00:56.320><c> Celebrating.</c>', '', '', '<span>&gt;&gt;</span><span>What</span><span>hasn''t</span><span>been</span><span>happening?</span><span>&gt;&gt;</span><span>Partying.<00:00:56.320><c></span><span>Celebrating.</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 40, 57.71, 0.0, '&gt;&gt; Partying. Celebrating.', '', '', '<span>&gt;&gt;</span><span>Partying.</span><span>Celebrating.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 41, 57.72, 0.0, '&gt;&gt; Partying. Celebrating. &gt;&gt; What<00:00:57.920><c> is</c><00:00:58.000><c> this?</c><00:00:58.240><c> This</c><00:00:58.360><c> is</c><00:00:58.440><c> when</c><00:00:58.600><c> I</c><00:00:58.680><c> go</c><00:00:58.800><c> like</c>', '', '', '<span>&gt;&gt;</span><span>Partying.</span><span>Celebrating.</span><span>&gt;&gt;</span><span>What<00:00:57.920><c></span><span>is</c><00:00:58.000><c></span><span>this?</c><00:00:58.240><c></span><span>This</c><00:00:58.360><c></span><span>is</c><00:00:58.440><c></span><span>when</c><00:00:58.600><c></span><span>I</c><00:00:58.680><c></span><span>go</c><00:00:58.800><c></span><span>like</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 42, 58.99, 0.0, '&gt;&gt; What is this? This is when I go like', '', '', '<span>&gt;&gt;</span><span>What</span><span>is</span><span>this?</span><span>This</span><span>is</span><span>when</span><span>I</span><span>go</span><span>like</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 43, 59.0, 0.0, '&gt;&gt; What is this? This is when I go like this.', '', '', '<span>&gt;&gt;</span><span>What</span><span>is</span><span>this?</span><span>This</span><span>is</span><span>when</span><span>I</span><span>go</span><span>like</span><span>this.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 44, 60.03, 0.0, 'this.', '', '', '<span>this.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 45, 60.04, 0.0, 'this. &gt;&gt; So,<00:01:00.640><c> you</c><00:01:00.760><c> have</c><00:01:00.960><c> not</c><00:01:01.240><c> been</c><00:01:01.440><c> partying?</c>', '', '', '<span>this.</span><span>&gt;&gt;</span><span>So,<00:01:00.640><c></span><span>you</c><00:01:00.760><c></span><span>have</c><00:01:00.960><c></span><span>not</c><00:01:01.240><c></span><span>been</c><00:01:01.440><c></span><span>partying?</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 46, 62.03, 0.0, '&gt;&gt; So, you have not been partying?', '', '', '<span>&gt;&gt;</span><span>So,</span><span>you</span><span>have</span><span>not</span><span>been</span><span>partying?</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 47, 62.04, 0.0, '&gt;&gt; So, you have not been partying? &gt;&gt; No,<00:01:02.400><c> they</c><00:01:02.520><c> don''t</c><00:01:02.880><c> they</c><00:01:02.960><c> don''t</c><00:01:03.120><c> exactly</c><00:01:03.560><c> want</c>', '', '', '<span>&gt;&gt;</span><span>So,</span><span>you</span><span>have</span><span>not</span><span>been</span><span>partying?</span><span>&gt;&gt;</span><span>No,<00:01:02.400><c></span><span>they</c><00:01:02.520><c></span><span>don''t</c><00:01:02.880><c></span><span>they</c><00:01:02.960><c></span><span>don''t</c><00:01:03.120><c></span><span>exactly</c><00:01:03.560><c></span><span>want</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 48, 63.71, 0.0, '&gt;&gt; No, they don''t they don''t exactly want', '', '', '<span>&gt;&gt;</span><span>No,</span><span>they</span><span>don''t</span><span>they</span><span>don''t</span><span>exactly</span><span>want</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 49, 63.72, 0.0, '&gt;&gt; No, they don''t they don''t exactly want me<00:01:03.800><c> around</c><00:01:04.120><c> for</c><00:01:04.199><c> that.</c>', '', '', '<span>&gt;&gt;</span><span>No,</span><span>they</span><span>don''t</span><span>they</span><span>don''t</span><span>exactly</span><span>want</span><span>me<00:01:03.800><c></span><span>around</c><00:01:04.120><c></span><span>for</c><00:01:04.199><c></span><span>that.</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 50, 65.31, 0.0, 'me around for that.', '', '', '<span>me</span><span tid="50015" class="highlight highlight-a">around</span><span>for</span><span>that.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 51, 65.32, 0.0, 'me around for that. &gt;&gt; Is<00:01:05.560><c> that</c><00:01:05.800><c> a</c><00:01:05.880><c> weird</c><00:01:06.200><c> thing</c><00:01:06.440><c> because</c><00:01:07.200><c> like</c><00:01:07.360><c> in</c>', '', '', '<span>me</span><span>around</span><span>for</span><span>that.</span><span>&gt;&gt;</span><span>Is<00:01:05.560><c></span><span>that</c><00:01:05.800><c></span><span>a</c><00:01:05.880><c></span><span>weird</c><00:01:06.200><c></span><span>thing</c><00:01:06.440><c></span><span>because</c><00:01:07.200><c></span><span>like</c><00:01:07.360><c></span><span>in</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 52, 67.43, 0.0, '&gt;&gt; Is that a weird thing because like in', '', '', '<span>&gt;&gt;</span><span>Is</span><span>that</span><span>a</span><span>weird</span><span>thing</span><span>because</span><span>like</span><span>in</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 53, 67.44, 0.0, '&gt;&gt; Is that a weird thing because like in professional<00:01:08.080><c> sports,</c><00:01:08.520><c> you''ll</c><00:01:08.640><c> hear</c><00:01:08.800><c> the</c>', '', '', '<span>&gt;&gt;</span><span>Is</span><span>that</span><span>a</span><span>weird</span><span>thing</span><span>because</span><span>like</span><span>in</span><span>professional<00:01:08.080><c></span><span>sports,</c><00:01:08.520><c></span><span>you''ll</c><00:01:08.640><c></span><span>hear</c><00:01:08.800><c></span><span>the</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 54, 68.91, 0.0, 'professional sports, you''ll hear the', '', '', '<span tid="50016" class="highlight highlight-a">professional</span><span>sports,</span><span>you''ll</span><span>hear</span><span>the</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 55, 68.92, 0.0, 'professional sports, you''ll hear the coach<00:01:09.240><c> will</c><00:01:09.480><c> party</c><00:01:09.800><c> with</c><00:01:09.960><c> the</c><00:01:10.040><c> team.</c><00:01:10.560><c> But,</c>', '', '', '<span>professional</span><span>sports,</span><span>you''ll</span><span>hear</span><span>the</span><span>coach<00:01:09.240><c></span><span>will</c><00:01:09.480><c></span><span>party</c><00:01:09.800><c></span><span>with</c><00:01:09.960><c></span><span>the</c><00:01:10.040><c></span><span>team.</c><00:01:10.560><c></span><span>But,</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 56, 70.71, 0.0, 'coach will party with the team. But,', '', '', '<span tid="50017" class="highlight highlight-a">coach</span><span>will</span><span tid="50018" class="highlight highlight-a">party</span><span>with</span><span>the</span><span>team.</span><span>But,</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 57, 70.72, 0.0, 'coach will party with the team. But, you''re<00:01:10.920><c> in</c><00:01:11.040><c> a</c><00:01:11.120><c> way</c><00:01:11.480><c> like</c><00:01:11.720><c> a</c><00:01:11.800><c> teacher,</c><00:01:12.280><c> right?</c>', '', '', '<span>coach</span><span>will</span><span>party</span><span>with</span><span>the</span><span>team.</span><span>But,</span><span>you''re<00:01:10.920><c></span><span>in</c><00:01:11.040><c></span><span>a</c><00:01:11.120><c></span><span>way</c><00:01:11.480><c></span><span>like</c><00:01:11.720><c></span><span>a</c><00:01:11.800><c></span><span>teacher,</c><00:01:12.280><c></span><span>right?</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 58, 72.63, 0.0, 'you''re in a way like a teacher, right?', '', '', '<span>you''re</span><span pid="501" class="highlight highlight-i">in a way</span><span>like</span><span>a</span><span tid="50019" class="highlight highlight-a">teacher,</span><span>right?</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 59, 72.64, 0.0, 'you''re in a way like a teacher, right? And<00:01:12.720><c> technically</c>', '', '', '<span>you''re</span><span>in</span><span>a</span><span>way</span><span>like</span><span>a</span><span>teacher,</span><span>right?</span><span>And<00:01:12.720><c></span><span>technically</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 60, 73.71, 0.0, 'And technically', '', '', '<span>And</span><span tid="50020" class="highlight highlight-a">technically</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 61, 73.72, 0.0, 'And technically &gt;&gt; all<00:01:13.960><c> I</c><00:01:14.040><c> know</c><00:01:14.200><c> is</c><00:01:14.320><c> I</c><00:01:14.400><c> didn''t</c><00:01:14.560><c> get</c><00:01:14.640><c> invited.</c>', '', '', '<span>And</span><span>technically</span><span>&gt;&gt;</span><span>all<00:01:13.960><c></span><span>I</c><00:01:14.040><c></span><span>know</c><00:01:14.200><c></span><span>is</c><00:01:14.320><c></span><span>I</c><00:01:14.400><c></span><span>didn''t</c><00:01:14.560><c></span><span>get</c><00:01:14.640><c></span><span>invited.</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 62, 75.31, 0.0, '&gt;&gt; all I know is I didn''t get invited.', '', '', '<span>&gt;&gt;</span><span>all</span><span>I</span><span>know</span><span>is</span><span>I</span><span>didn''t</span><span>get</span><span>invited.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 63, 75.32, 0.0, '&gt;&gt; all I know is I didn''t get invited. &gt;&gt; You<00:01:15.440><c> didn''t</c><00:01:15.640><c> get</c><00:01:15.720><c> invited?</c>', '', '', '<span>&gt;&gt;</span><span>all</span><span>I</span><span>know</span><span>is</span><span>I</span><span>didn''t</span><span>get</span><span>invited.</span><span>&gt;&gt;</span><span>You<00:01:15.440><c></span><span>didn''t</c><00:01:15.640><c></span><span>get</c><00:01:15.720><c></span><span>invited?</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 64, 75.99, 0.0, '&gt;&gt; You didn''t get invited?', '', '', '<span>&gt;&gt;</span><span>You</span><span>didn''t</span><span>get</span><span>invited?</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 65, 76.0, 0.0, '&gt;&gt; You didn''t get invited? &gt;&gt; That''s<00:01:16.240><c> false.</c><00:01:16.800><c> That</c><00:01:16.920><c> is</c><00:01:17.400><c> so</c><00:01:17.600><c> false.</c><00:01:17.920><c> It</c><00:01:18.000><c> was</c>', '', '', '<span>&gt;&gt;</span><span>You</span><span>didn''t</span><span>get</span><span>invited?</span><span>&gt;&gt;</span><span>That''s<00:01:16.240><c></span><span>false.</c><00:01:16.800><c></span><span>That</c><00:01:16.920><c></span><span>is</c><00:01:17.400><c></span><span>so</c><00:01:17.600><c></span><span>false.</c><00:01:17.920><c></span><span>It</c><00:01:18.000><c></span><span>was</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 66, 78.15, 0.0, '&gt;&gt; That''s false. That is so false. It was', '', '', '<span>&gt;&gt;</span><span>That''s</span><span>false.</span><span>That</span><span>is</span><span>so</span><span>false.</span><span>It</span><span>was</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 67, 78.16, 0.0, '&gt;&gt; That''s false. That is so false. It was open<00:01:18.480><c> invite.</c>', '', '', '<span>&gt;&gt;</span><span>That''s</span><span>false.</span><span>That</span><span>is</span><span>so</span><span>false.</span><span>It</span><span>was</span><span>open<00:01:18.480><c></span><span>invite.</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 68, 78.71, 0.0, 'open invite.', '', '', '<span tid="50021" class="highlight highlight-a">open</span><span tid="50022" class="highlight highlight-a">invite.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 69, 78.72, 0.0, 'open invite. &gt;&gt; Where<00:01:18.920><c> does</c><00:01:19.120><c> the</c><00:01:19.240><c> trophy</c><00:01:19.600><c> go?</c><00:01:19.760><c> Does</c><00:01:19.960><c> that</c><00:01:20.200><c> go</c>', '', '', '<span>open</span><span>invite.</span><span>&gt;&gt;</span><span>Where<00:01:18.920><c></span><span>does</c><00:01:19.120><c></span><span>the</c><00:01:19.240><c></span><span>trophy</c><00:01:19.600><c></span><span>go?</c><00:01:19.760><c></span><span>Does</c><00:01:19.960><c></span><span>that</c><00:01:20.200><c></span><span>go</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 70, 80.31, 0.0, '&gt;&gt; Where does the trophy go? Does that go', '', '', '<span>&gt;&gt;</span><span>Where</span><span>does</span><span>the</span><span>trophy</span><span>go?</span><span>Does</span><span>that</span><span>go</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 71, 80.32, 0.0, '&gt;&gt; Where does the trophy go? Does that go to<00:01:20.400><c> the</c><00:01:20.480><c> school</c><00:01:20.760><c> or</c><00:01:20.800><c> you</c><00:01:20.920><c> get</c><00:01:21.040><c> to</c><00:01:21.160><c> each</c><00:01:21.320><c> take</c><00:01:21.520><c> it</c>', '', '', '<span>&gt;&gt;</span><span>Where</span><span>does</span><span>the</span><span>trophy</span><span>go?</span><span>Does</span><span>that</span><span>go</span><span>to<00:01:20.400><c></span><span>the</c><00:01:20.480><c></span><span>school</c><00:01:20.760><c></span><span>or</c><00:01:20.800><c></span><span>you</c><00:01:20.920><c></span><span>get</c><00:01:21.040><c></span><span>to</c><00:01:21.160><c></span><span>each</c><00:01:21.320><c></span><span>take</c><00:01:21.520><c></span><span>it</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 72, 81.59, 0.0, 'to the school or you get to each take it', '', '', '<span>to</span><span>the</span><span>school</span><span>or</span><span>you</span><span>get</span><span>to</span><span>each</span><span>take</span><span>it</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 73, 81.6, 0.0, 'to the school or you get to each take it home<00:01:21.840><c> for</c><00:01:21.960><c> a</c><00:01:22.000><c> couple</c><00:01:22.320><c> of</c><00:01:22.400><c> nights?</c>', '', '', '<span>to</span><span>the</span><span>school</span><span>or</span><span>you</span><span>get</span><span>to</span><span>each</span><span>take</span><span>it</span><span>home<00:01:21.840><c></span><span>for</c><00:01:21.960><c></span><span>a</c><00:01:22.000><c></span><span>couple</c><00:01:22.320><c></span><span>of</c><00:01:22.400><c></span><span>nights?</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 74, 84.03, 0.0, 'home for a couple of nights?', '', '', '<span>home</span><span>for</span><span>a</span><span tid="50023" class="highlight highlight-a">couple</span><span>of</span><span>nights?</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 75, 84.04, 0.0, 'home for a couple of nights? &gt;&gt; Probably<00:01:24.320><c> the</c><00:01:24.440><c> trophy</c><00:01:24.800><c> room.</c>', '', '', '<span>home</span><span>for</span><span>a</span><span>couple</span><span>of</span><span>nights?</span><span>&gt;&gt;</span><span>Probably<00:01:24.320><c></span><span>the</c><00:01:24.440><c></span><span>trophy</c><00:01:24.800><c></span><span>room.</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 76, 85.31, 0.0, '&gt;&gt; Probably the trophy room.', '', '', '<span>&gt;&gt;</span><span>Probably</span><span>the</span><span>trophy</span><span>room.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 77, 85.32, 0.0, '&gt;&gt; Probably the trophy room. &gt;&gt; The<00:01:25.400><c> trophy</c><00:01:25.800><c> room.</c>', '', '', '<span>&gt;&gt;</span><span>Probably</span><span>the</span><span>trophy</span><span>room.</span><span>&gt;&gt;</span><span>The<00:01:25.400><c></span><span>trophy</c><00:01:25.800><c></span><span>room.</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 78, 86.07, 0.0, '&gt;&gt; The trophy room.', '', '', '<span>&gt;&gt;</span><span>The</span><span>trophy</span><span>room.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 79, 86.08, 0.0, '&gt;&gt; The trophy room. &gt;&gt; Yes.', '', '', '<span>&gt;&gt;</span><span>The</span><span>trophy</span><span>room.</span><span>&gt;&gt;</span><span>Yes.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 80, 86.71, 0.0, '&gt;&gt; Yes.', '', '', '<span>&gt;&gt;</span><span>Yes.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 81, 86.72, 0.0, '&gt;&gt; Yes. &gt;&gt; Yeah.', '', '', '<span>&gt;&gt;</span><span>Yes.</span><span>&gt;&gt;</span><span>Yeah.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 82, 87.03, 0.0, '&gt;&gt; Yeah.', '', '', '<span>&gt;&gt;</span><span>Yeah.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 83, 87.04, 0.0, '&gt;&gt; Yeah. &gt;&gt; So,<00:01:27.560><c> since</c><00:01:27.960><c> Sunday,</c><00:01:28.640><c> has</c><00:01:28.920><c> it</c><00:01:29.040><c> been</c><00:01:29.400><c> a</c><00:01:29.520><c> party</c>', '', '', '<span>&gt;&gt;</span><span>Yeah.</span><span>&gt;&gt;</span><span>So,<00:01:27.560><c></span><span>since</c><00:01:27.960><c></span><span>Sunday,</c><00:01:28.640><c></span><span>has</c><00:01:28.920><c></span><span>it</c><00:01:29.040><c></span><span>been</c><00:01:29.400><c></span><span>a</c><00:01:29.520><c></span><span>party</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 84, 89.99, 0.0, '&gt;&gt; So, since Sunday, has it been a party', '', '', '<span>&gt;&gt;</span><span>So,</span><span>since</span><span>Sunday,</span><span>has</span><span>it</span><span>been</span><span>a</span><span>party</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 85, 90.0, 0.0, '&gt;&gt; So, since Sunday, has it been a party every<00:01:30.280><c> night</c><00:01:30.640><c> or</c><00:01:30.800><c> have</c><00:01:30.960><c> you</c><00:01:31.080><c> had</c><00:01:31.240><c> to</c><00:01:31.320><c> go</c><00:01:31.440><c> back</c>', '', '', '<span>&gt;&gt;</span><span>So,</span><span>since</span><span>Sunday,</span><span>has</span><span>it</span><span>been</span><span>a</span><span>party</span><span>every<00:01:30.280><c></span><span>night</c><00:01:30.640><c></span><span>or</c><00:01:30.800><c></span><span>have</c><00:01:30.960><c></span><span>you</c><00:01:31.080><c></span><span>had</c><00:01:31.240><c></span><span>to</c><00:01:31.320><c></span><span>go</c><00:01:31.440><c></span><span>back</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 86, 91.67, 0.0, 'every night or have you had to go back', '', '', '<span>every</span><span>night</span><span>or</span><span>have</span><span>you</span><span>had</span><span>to</span><span>go</span><span>back</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 87, 91.68, 0.0, 'every night or have you had to go back to<00:01:31.800><c> class</c><00:01:32.400><c> or</c><00:01:32.600><c> what</c><00:01:32.840><c> has</c><00:01:33.160><c> been</c><00:01:33.320><c> going</c><00:01:33.680><c> on?</c>', '', '', '<span>every</span><span>night</span><span>or</span><span>have</span><span>you</span><span>had</span><span>to</span><span>go</span><span>back</span><span>to<00:01:31.800><c></span><span>class</c><00:01:32.400><c></span><span>or</c><00:01:32.600><c></span><span>what</c><00:01:32.840><c></span><span>has</c><00:01:33.160><c></span><span>been</c><00:01:33.320><c></span><span>going</c><00:01:33.680><c></span><span>on?</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 88, 94.03, 0.0, 'to class or what has been going on?', '', '', '<span>to</span><span>class</span><span>or</span><span>what</span><span>has</span><span>been</span><span tid="50024" class="highlight highlight-d">going</span><span>on?</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 89, 94.04, 0.0, 'to class or what has been going on? &gt;&gt; So,<00:01:34.440><c> thank</c><00:01:34.760><c> God</c><00:01:35.080><c> all</c><00:01:35.280><c> of</c><00:01:35.400><c> us</c><00:01:35.520><c> have</c><00:01:35.680><c> graduated</c>', '', '', '<span>to</span><span>class</span><span>or</span><span>what</span><span>has</span><span>been</span><span>going</span><span>on?</span><span>&gt;&gt;</span><span>So,<00:01:34.440><c></span><span>thank</c><00:01:34.760><c></span><span>God</c><00:01:35.080><c></span><span>all</c><00:01:35.280><c></span><span>of</c><00:01:35.400><c></span><span>us</c><00:01:35.520><c></span><span>have</c><00:01:35.680><c></span><span>graduated</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 90, 96.35, 0.0, '&gt;&gt; So, thank God all of us have graduated', '', '', '<span>&gt;&gt;</span><span>So,</span><span>thank</span><span>God</span><span>all</span><span>of</span><span>us</span><span>have</span><span>graduated</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 91, 96.36, 0.0, '&gt;&gt; So, thank God all of us have graduated here.<00:01:36.800><c> So,</c><00:01:36.960><c> we''re</c><00:01:37.160><c> all</c><00:01:37.400><c> good</c><00:01:37.600><c> to</c><00:01:37.720><c> go.</c>', '', '', '<span>&gt;&gt;</span><span>So,</span><span>thank</span><span>God</span><span>all</span><span>of</span><span>us</span><span>have</span><span>graduated</span><span>here.<00:01:36.800><c></span><span>So,</c><00:01:36.960><c></span><span>we''re</c><00:01:37.160><c></span><span>all</c><00:01:37.400><c></span><span>good</c><00:01:37.600><c></span><span>to</c><00:01:37.720><c></span><span>go.</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 92, 98.19, 0.0, 'here. So, we''re all good to go.', '', '', '<span>here.</span><span>So,</span><span>we''re</span><span>all</span><span>good</span><span>to</span><span>go.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 93, 98.2, 0.0, 'here. So, we''re all good to go. &gt;&gt; You''re<00:01:38.240><c> all</c><00:01:38.600><c> good</c><00:01:38.680><c> to</c><00:01:38.760><c> go</c><00:01:38.840><c> back</c><00:01:39.000><c> TO</c><00:01:39.080><c> CLASS.</c>', '', '', '<span>here.</span><span>So,</span><span>we''re</span><span>all</span><span>good</span><span>to</span><span>go.</span><span>&gt;&gt;</span><span>You''re<00:01:38.240><c></span><span>all</c><00:01:38.600><c></span><span>good</c><00:01:38.680><c></span><span>to</c><00:01:38.760><c></span><span>go</c><00:01:38.840><c></span><span>back</c><00:01:39.000><c></span><span>TO</c><00:01:39.080><c></span><span>CLASS.</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 94, 103.19, 0.0, '&gt;&gt; BUT,', '', '', '<span>&gt;&gt;</span><span>BUT,</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 95, 103.2, 0.0, '&gt;&gt; BUT, SO<00:01:43.440><c> RIGHT</c><00:01:43.720><c> AFTER</c><00:01:44.000><c> WE</c><00:01:44.120><c> GOT</c><00:01:44.320><c> OFF</c><00:01:44.480><c> THE</c><00:01:44.600><c> FLIGHT,</c><00:01:45.000><c> we</c>', '', '', '<span>&gt;&gt;</span><span>BUT,</span><span>SO<00:01:43.440><c></span><span>RIGHT</c><00:01:43.720><c></span><span>AFTER</c><00:01:44.000><c></span><span>WE</c><00:01:44.120><c></span><span>GOT</c><00:01:44.320><c></span><span>OFF</c><00:01:44.480><c></span><span>THE</c><00:01:44.600><c></span><span>FLIGHT,</c><00:01:45.000><c></span><span>we</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 96, 105.07, 0.0, 'SO RIGHT AFTER WE GOT OFF THE FLIGHT, we', '', '', '<span>SO</span> <span>RIGHT</span> <span>AFTER</span> <span>WE</span> <span>GOT</span> <span>OFF</span> <span>THE</span> <span>FLIGHT,</span> <span>we</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 97, 105.08, 0.0, 'SO RIGHT AFTER WE GOT OFF THE FLIGHT, we dropped<00:01:45.440><c> all</c><00:01:45.520><c> of</c><00:01:45.600><c> our</c><00:01:45.680><c> stuff</c><00:01:45.960><c> off</c><00:01:46.120><c> at</c><00:01:46.200><c> our</c>', '', '', '<span>SO</span> <span>RIGHT</span> <span>AFTER</span> <span>WE</span> <span>GOT</span> <span>OFF</span> <span>THE</span> <span>FLIGHT,</span> <span>we</span> <span>dropped<00:01:45.440><c></span> <span>all</c><00:01:45.520><c></span> <span>of</c><00:01:45.600><c></span> <span>our</c><00:01:45.680><c></span> <span>stuff</c><00:01:45.960><c></span> <span>off</c><00:01:46.120><c></span> <span>at</c><00:01:46.200><c></span> <span>our</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 98, 106.23, 0.0, 'dropped all of our stuff off at our', '', '', '<span>dropped</span> <span>all</span> <span>of</span> <span>our</span> <span>stuff</span> <span>off</span> <span>at</span> <span>our</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 99, 106.24, 0.0, 'dropped all of our stuff off at our practice<00:01:46.600><c> facility,</c><00:01:46.920><c> went</c><00:01:47.120><c> straight</c><00:01:47.440><c> to</c><00:01:47.560><c> our</c>', '', '', '<span>dropped</span> <span>all</span> <span>of</span> <span>our</span> <span>stuff</span> <span>off</span> <span>at</span> <span>our</span> <span>practice<00:01:46.600><c></span> <span>facility,</c><00:01:46.920><c></span> <span>went</c><00:01:47.120><c></span> <span>straight</c><00:01:47.440><c></span> <span>to</c><00:01:47.560><c></span> <span>our</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 100, 107.75, 0.0, 'practice facility, went straight to our', '', '', '<span>practice</span> <span>facility,</span> <span>went</span> <span>straight</span> <span>to</span> <span>our</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 101, 107.76, 0.0, 'practice facility, went straight to our local<00:01:48.120><c> bar,</c><00:01:48.480><c> Rocco''s</c><00:01:49.080><c> in</c><00:01:49.240><c> Westwood.</c><00:01:49.840><c> I''M</c><00:01:49.920><c> NOT</c>', '', '', '<span>practice</span> <span>facility,</span> <span>went</span> <span>straight</span> <span>to</span> <span>our</span> <span>local<00:01:48.120><c></span> <span>bar,</c><00:01:48.480><c></span> <span>Rocco''s</c><00:01:49.080><c></span> <span>in</c><00:01:49.240><c></span> <span>Westwood.</c><00:01:49.840><c></span> <span>I''M</c><00:01:49.920><c></span> <span>NOT</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 102, 114.03, 0.0, 'YEAH, SO WE had a lot', '', '', '<span>YEAH,</span> <span>SO</span> <span>WE</span> <span>had</span> <span>a</span> <span>lot</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 103, 114.04, 0.0, 'YEAH, SO WE had a lot &gt;&gt; You''re<00:01:54.240><c> all</c><00:01:54.440><c> of</c><00:01:54.640><c> age.</c><00:01:55.000><c> This</c><00:01:55.200><c> is</c><00:01:55.360><c> all</c><00:01:55.560><c> legal.</c>', '', '', '<span>YEAH,</span> <span>SO</span> <span>WE</span> <span>had</span> <span>a</span> <span>lot</span> <span>&gt;&gt;</span> <span>You''re<00:01:54.240><c></span> <span>all</c><00:01:54.440><c></span> <span>of</c><00:01:54.640><c></span> <span>age.</c><00:01:55.000><c></span> <span>This</c><00:01:55.200><c></span> <span>is</c><00:01:55.360><c></span> <span>all</c><00:01:55.560><c></span> <span>legal.</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 104, 115.75, 0.0, '&gt;&gt; You''re all of age. This is all legal.', '', '', '<span>&gt;&gt;</span> <span>You''re</span> <span>all</span> <span>of</span> <span>age.</span> <span>This</span> <span>is</span> <span>all</span> <span>legal.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 105, 115.76, 0.0, '&gt;&gt; You''re all of age. This is all legal. &gt;&gt; Yes.<00:01:56.600><c> Yes.</c>', '', '', '<span>&gt;&gt;</span> <span>You''re</span> <span>all</span> <span>of</span> <span>age.</span> <span>This</span> <span>is</span> <span>all</span> <span>legal.</span> <span>&gt;&gt;</span> <span>Yes.<00:01:56.600><c></span> <span>Yes.</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 106, 116.87, 0.0, '&gt;&gt; Yes. Yes.', '', '', '<span>&gt;&gt;</span> <span>Yes.</span> <span>Yes.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 107, 116.88, 0.0, '&gt;&gt; Yes. Yes. &gt;&gt; Did<00:01:57.040><c> you</c><00:01:57.160><c> walk</c><00:01:57.440><c> around</c><00:01:57.760><c> campus</c><00:01:58.240><c> for</c><00:01:58.400><c> everybody</c>', '', '', '<span>&gt;&gt;</span> <span>Yes.</span> <span>Yes.</span> <span>&gt;&gt;</span> <span>Did<00:01:57.040><c></span> <span>you</c><00:01:57.160><c></span> <span>walk</c><00:01:57.440><c></span> <span>around</c><00:01:57.760><c></span> <span>campus</c><00:01:58.240><c></span> <span>for</c><00:01:58.400><c></span> <span>everybody</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 108, 118.83, 0.0, '&gt;&gt; Did you walk around campus for everybody', '', '', '<span>&gt;&gt;</span> <span>Did</span> <span>you</span> <span>walk</span> <span>around</span> <span>campus</span> <span>for</span> <span>everybody</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 109, 118.84, 0.0, '&gt;&gt; Did you walk around campus for everybody to<00:01:58.920><c> go</c><00:01:59.080><c> nuts?</c>', '', '', '<span>&gt;&gt;</span> <span>Did</span> <span>you</span> <span>walk</span> <span>around</span> <span>campus</span> <span>for</span> <span>everybody</span> <span>to<00:01:58.920><c></span> <span>go</c><00:01:59.080><c></span> <span>nuts?</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 110, 120.23, 0.0, 'to go nuts?', '', '', '<span>to</span> <span>go</span> <span>nuts?</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 111, 120.24, 0.0, 'to go nuts? &gt;&gt; They<00:02:00.360><c> came</c><00:02:00.600><c> to</c><00:02:00.720><c> us.</c>', '', '', '<span>to</span> <span>go</span> <span>nuts?</span> <span>&gt;&gt;</span> <span>They<00:02:00.360><c></span> <span>came</c><00:02:00.600><c></span> <span>to</c><00:02:00.720><c></span> <span>us.</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 112, 125.15, 0.0, '&gt;&gt; So, you guys had and correct me if I', '', '', '<span>&gt;&gt;</span> <span>So,</span> <span>you</span> <span>guys</span> <span>had</span> <span>and</span> <span>correct</span> <span>me</span> <span>if</span> <span>I</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 113, 125.16, 0.0, '&gt;&gt; So, you guys had and correct me if I have<00:02:05.240><c> any</c><00:02:05.360><c> strong</c><00:02:05.680><c> errors,</c><00:02:05.880><c> 31</c><00:02:06.600><c> game</c><00:02:06.920><c> win</c>', '', '', '<span>&gt;&gt;</span> <span>So,</span> <span>you</span> <span>guys</span> <span>had</span> <span>and</span> <span>correct</span> <span>me</span> <span>if</span> <span>I</span> <span>have<00:02:05.240><c></span> <span>any</c><00:02:05.360><c></span> <span>strong</c><00:02:05.680><c></span> <span>errors,</c><00:02:05.880><c></span> <span>31</c><00:02:06.600><c></span> <span>game</c><00:02:06.920><c></span> <span>win</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 114, 127.11, 0.0, 'have any strong errors, 31 game win', '', '', '<span>have</span> <span>any</span> <span>strong</span> <span>errors,</span> <span>31</span> <span>game</span> <span>win</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 115, 127.12, 0.0, 'have any strong errors, 31 game win streak<00:02:07.479><c> this</c><00:02:07.720><c> season,</c><00:02:08.200><c> right?</c>', '', '', '<span>have</span> <span>any</span> <span>strong</span> <span>errors,</span> <span>31</span> <span>game</span> <span>win</span> <span>streak<00:02:07.479><c></span> <span>this</c><00:02:07.720><c></span> <span>season,</c><00:02:08.200><c></span> <span>right?</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 116, 133.15, 0.0, 'You went 37 and 1. When you''ve won, when', '', '', '<span>You</span> <span>went</span> <span>37</span> <span>and</span> <span>1.</span> <span>When</span> <span>you''ve</span> <span>won,</span> <span>when</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 117, 133.16, 0.0, 'You went 37 and 1. When you''ve won, when you''re<00:02:13.280><c> in</c><00:02:13.360><c> the</c><00:02:13.440><c> middle</c><00:02:13.800><c> of</c><00:02:13.959><c> winning</c><00:02:14.280><c> 31</c><00:02:14.880><c> games</c>', '', '', '<span>You</span> <span>went</span> <span>37</span> <span>and</span> <span>1.</span> <span>When</span> <span>you''ve</span> <span>won,</span> <span>when</span> <span>you''re<00:02:13.280><c></span> <span>in</c><00:02:13.360><c></span> <span>the</c><00:02:13.440><c></span> <span>middle</c><00:02:13.800><c></span> <span>of</c><00:02:13.959><c></span> <span>winning</c><00:02:14.280><c></span> <span>31</c><00:02:14.880><c></span> <span>games</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 118, 135.23, 0.0, 'you''re in the middle of winning 31 games', '', '', '<span>you''re</span> <span>in</span> <span>the</span> <span>middle</span> <span>of</span> <span>winning</span> <span>31</span> <span>games</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 119, 135.24, 0.0, 'you''re in the middle of winning 31 games in<00:02:15.360><c> a</c><00:02:15.400><c> row,</c><00:02:15.680><c> do</c><00:02:15.800><c> you</c><00:02:15.920><c> are</c><00:02:16.040><c> you</c><00:02:16.160><c> superstitious?</c>', '', '', '<span>you''re</span> <span>in</span> <span>the</span> <span>middle</span> <span>of</span> <span>winning</span> <span>31</span> <span>games</span> <span>in<00:02:15.360><c></span> <span>a</c><00:02:15.400><c></span> <span>row,</c><00:02:15.680><c></span> <span>do</c><00:02:15.800><c></span> <span>you</c><00:02:15.920><c></span> <span>are</c><00:02:16.040><c></span> <span>you</c><00:02:16.160><c></span> <span>superstitious?</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 120, 137.07, 0.0, 'in a row, do you are you superstitious?', '', '', '<span>in</span> <span>a</span> <span>row,</span> <span>do</span> <span>you</span> <span>are</span> <span>you</span> <span>superstitious?</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 121, 137.08, 0.0, 'in a row, do you are you superstitious? Are<00:02:17.240><c> there</c><00:02:17.400><c> things</c><00:02:17.720><c> that</c><00:02:17.959><c> you</c><00:02:18.080><c> do</c><00:02:18.400><c> or</c><00:02:19.000><c> or</c><00:02:19.040><c> make</c>', '', '', '<span>in</span> <span>a</span> <span>row,</span> <span>do</span> <span>you</span> <span>are</span> <span>you</span> <span>superstitious?</span> <span>Are<00:02:17.240><c></span> <span>there</c><00:02:17.400><c></span> <span>things</c><00:02:17.720><c></span> <span>that</c><00:02:17.959><c></span> <span>you</c><00:02:18.080><c></span> <span>do</c><00:02:18.400><c></span> <span>or</c><00:02:19.000><c></span> <span>or</c><00:02:19.040><c></span> <span>make</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 122, 139.23, 0.0, 'Are there things that you do or or make', '', '', '<span>Are</span> <span>there</span> <span>things</span> <span>that</span> <span>you</span> <span>do</span> <span>or</span> <span>or</span> <span>make</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 123, 139.24, 0.0, 'Are there things that you do or or make sure<00:02:19.400><c> not</c><00:02:19.720><c> to</c><00:02:19.840><c> do?</c>', '', '', '<span>Are</span> <span>there</span> <span>things</span> <span>that</span> <span>you</span> <span>do</span> <span>or</span> <span>or</span> <span>make</span> <span>sure<00:02:19.400><c></span> <span>not</c><00:02:19.720><c></span> <span>to</c><00:02:19.840><c></span> <span>do?</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 124, 141.55, 0.0, 'sure not to do?', '', '', '<span>sure</span> <span>not</span> <span>to</span> <span>do?</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 125, 141.56, 0.0, 'sure not to do? &gt;&gt; Honestly,<00:02:22.600><c> I''m</c><00:02:22.800><c> not</c><00:02:23.000><c> pretty</c><00:02:23.280><c> superstitious.</c>', '', '', '<span>sure</span> <span>not</span> <span>to</span> <span>do?</span> <span>&gt;&gt;</span> <span>Honestly,<00:02:22.600><c></span> <span>I''m</c><00:02:22.800><c></span> <span>not</c><00:02:23.000><c></span> <span>pretty</c><00:02:23.280><c></span> <span>superstitious.</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 126, 144.51, 0.0, '&gt;&gt; Honestly, I''m not pretty superstitious.', '', '', '<span>&gt;&gt;</span> <span>Honestly,</span> <span>I''m</span> <span>not</span> <span>pretty</span> <span>superstitious.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 127, 144.52, 0.0, '&gt;&gt; Honestly, I''m not pretty superstitious. I''m<00:02:24.760><c> just</c><00:02:24.959><c> a</c><00:02:25.000><c> little</c><00:02:25.240><c> stitious,</c><00:02:25.880><c> but</c>', '', '', '<span>&gt;&gt;</span> <span>Honestly,</span> <span>I''m</span> <span>not</span> <span>pretty</span> <span>superstitious.</span> <span>I''m<00:02:24.760><c></span> <span>just</c><00:02:24.959><c></span> <span>a</c><00:02:25.000><c></span> <span>little</c><00:02:25.240><c></span> <span>stitious,</c><00:02:25.880><c></span> <span>but</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 128, 147.75, 0.0, 'I''m just a little stitious, but', '', '', '<span>I''m</span> <span>just</span> <span>a</span> <span>little</span> <span>stitious,</span> <span>but</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 129, 147.76, 0.0, 'I''m just a little stitious, but but<00:02:28.120><c> you</c><00:02:28.200><c> know,</c><00:02:28.520><c> we</c><00:02:28.640><c> just</c><00:02:28.800><c> have</c><00:02:29.000><c> our</c><00:02:29.200><c> each</c><00:02:29.400><c> of</c>', '', '', '<span>I''m</span> <span>just</span> <span>a</span> <span>little</span> <span>stitious,</span> <span>but</span> <span>but<00:02:28.120><c></span> <span>you</c><00:02:28.200><c></span> <span>know,</c><00:02:28.520><c></span> <span>we</c><00:02:28.640><c></span> <span>just</c><00:02:28.800><c></span> <span>have</c><00:02:29.000><c></span> <span>our</c><00:02:29.200><c></span> <span>each</c><00:02:29.400><c></span> <span>of</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 130, 149.55, 0.0, 'but you know, we just have our each of', '', '', '<span>but</span> <span>you</span> <span>know,</span> <span>we</span> <span>just</span> <span>have</span> <span>our</span> <span>each</span> <span>of</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 131, 149.56, 0.0, 'but you know, we just have our each of us<00:02:29.760><c> have</c><00:02:29.920><c> our</c><00:02:30.160><c> different</c><00:02:30.640><c> game</c><00:02:30.840><c> day</c><00:02:31.040><c> routines,</c>', '', '', '<span>but</span> <span>you</span> <span>know,</span> <span>we</span> <span>just</span> <span>have</span> <span>our</span> <span>each</span> <span>of</span> <span>us<00:02:29.760><c></span> <span>have</c><00:02:29.920><c></span> <span>our</c><00:02:30.160><c></span> <span>different</c><00:02:30.640><c></span> <span>game</c><00:02:30.840><c></span> <span>day</c><00:02:31.040><c></span> <span>routines,</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 132, 151.75, 0.0, 'us have our different game day routines,', '', '', '<span>us</span> <span>have</span> <span>our</span> <span>different</span> <span>game</span> <span>day</span> <span>routines,</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 133, 151.76, 0.0, 'us have our different game day routines, but<00:02:32.160><c> yeah.</c>', '', '', '<span>us</span> <span>have</span> <span>our</span> <span>different</span> <span>game</span> <span>day</span> <span>routines,</span> <span>but<00:02:32.160><c></span> <span>yeah.</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 134, 152.51, 0.0, 'but yeah.', '', '', '<span>but</span> <span>yeah.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 135, 152.52, 0.0, 'but yeah. &gt;&gt; Okay.<00:02:33.280><c> And</c><00:02:33.560><c> coach,</c><00:02:33.920><c> how</c><00:02:34.080><c> do</c><00:02:34.240><c> you</c><00:02:34.680><c> when</c><00:02:34.920><c> your</c>', '', '', '<span>but</span> <span>yeah.</span> <span>&gt;&gt;</span> <span>Okay.<00:02:33.280><c></span> <span>And</c><00:02:33.560><c></span> <span>coach,</c><00:02:33.920><c></span> <span>how</c><00:02:34.080><c></span> <span>do</c><00:02:34.240><c></span> <span>you</c><00:02:34.680><c></span> <span>when</c><00:02:34.920><c></span> <span>your</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 136, 155.07, 0.0, '&gt;&gt; Okay. And coach, how do you when your', '', '', '<span>&gt;&gt;</span> <span>Okay.</span> <span>And</span> <span>coach,</span> <span>how</span> <span>do</span> <span>you</span> <span>when</span> <span>your</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 137, 155.08, 0.0, '&gt;&gt; Okay. And coach, how do you when your team<00:02:35.440><c> has</c><00:02:35.720><c> won</c><00:02:36.040><c> 31</c><00:02:36.680><c> games</c><00:02:36.959><c> in</c><00:02:37.040><c> a</c><00:02:37.080><c> row,</c><00:02:37.480><c> what</c><00:02:37.640><c> do</c>', '', '', '<span>&gt;&gt;</span> <span>Okay.</span> <span>And</span> <span>coach,</span> <span>how</span> <span>do</span> <span>you</span> <span>when</span> <span>your</span> <span>team<00:02:35.440><c></span> <span>has</c><00:02:35.720><c></span> <span>won</c><00:02:36.040><c></span> <span>31</c><00:02:36.680><c></span> <span>games</c><00:02:36.959><c></span> <span>in</c><00:02:37.040><c></span> <span>a</c><00:02:37.080><c></span> <span>row,</c><00:02:37.480><c></span> <span>what</c><00:02:37.640><c></span> <span>do</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 138, 157.71, 0.0, 'team has won 31 games in a row, what do', '', '', '<span>team</span> <span>has</span> <span>won</span> <span>31</span> <span>games</span> <span>in</span> <span>a</span> <span>row,</span> <span>what</span> <span>do</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 139, 157.72, 0.0, 'team has won 31 games in a row, what do you<00:02:37.840><c> even</c><00:02:38.080><c> say</c><00:02:38.400><c> to</c><00:02:38.520><c> them</c><00:02:38.720><c> before</c><00:02:39.040><c> game?</c><00:02:39.280><c> Like,</c>', '', '', '<span>team</span> <span>has</span> <span>won</span> <span>31</span> <span>games</span> <span>in</span> <span>a</span> <span>row,</span> <span>what</span> <span>do</span> <span>you<00:02:37.840><c></span> <span>even</c><00:02:38.080><c></span> <span>say</c><00:02:38.400><c></span> <span>to</c><00:02:38.520><c></span> <span>them</c><00:02:38.720><c></span> <span>before</c><00:02:39.040><c></span> <span>game?</c><00:02:39.280><c></span> <span>Like,</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 140, 159.51, 0.0, 'you even say to them before game? Like,', '', '', '<span>you</span> <span>even</span> <span>say</span> <span>to</span> <span>them</span> <span>before</span> <span>game?</span> <span>Like,</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 141, 159.52, 0.0, 'you even say to them before game? Like, all<00:02:39.640><c> right</c><00:02:39.959><c> guys,</c><00:02:40.400><c> let''s</c><00:02:41.120><c> just</c><00:02:41.360><c> do</c><00:02:41.440><c> that</c>', '', '', '<span>you</span> <span>even</span> <span>say</span> <span>to</span> <span>them</span> <span>before</span> <span>game?</span> <span>Like,</span> <span>all<00:02:39.640><c></span> <span>right</c><00:02:39.959><c></span> <span>guys,</c><00:02:40.400><c></span> <span>let''s</c><00:02:41.120><c></span> <span>just</c><00:02:41.360><c></span> <span>do</c><00:02:41.440><c></span> <span>that</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 142, 161.63, 0.0, 'all right guys, let''s just do that', '', '', '<span>all</span> <span>right</span> <span>guys,</span> <span>let''s</span> <span>just</span> <span>do</span> <span>that</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 143, 161.64, 0.0, 'all right guys, let''s just do that again.', '', '', '<span>all</span> <span>right</span> <span>guys,</span> <span>let''s</span> <span>just</span> <span>do</span> <span>that</span> <span>again.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 144, 161.949, 0.0, 'again.', '', '', '<span>again.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 145, 161.959, 0.0, 'again. &gt;&gt; Figure<00:02:42.280><c> out</c><00:02:42.440><c> another</c><00:02:42.760><c> one</c><00:02:43.120><c> and</c><00:02:43.600><c> you</c><00:02:43.720><c> know,</c><00:02:43.840><c> I</c>', '', '', '<span>again.</span> <span>&gt;&gt;</span> <span>Figure<00:02:42.280><c></span> <span>out</c><00:02:42.440><c></span> <span>another</c><00:02:42.760><c></span> <span>one</c><00:02:43.120><c></span> <span>and</c><00:02:43.600><c></span> <span>you</c><00:02:43.720><c></span> <span>know,</c><00:02:43.840><c></span> <span>I</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 146, 163.91, 0.0, '&gt;&gt; Figure out another one and you know, I', '', '', '<span>&gt;&gt;</span> <span>Figure</span> <span>out</span> <span>another</span> <span>one</span> <span>and</span> <span>you</span> <span>know,</span> <span>I</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 147, 163.92, 0.0, '&gt;&gt; Figure out another one and you know, I think<00:02:44.120><c> the</c><00:02:44.200><c> reality</c><00:02:44.680><c> is</c><00:02:44.880><c> is</c><00:02:45.000><c> that</c><00:02:45.280><c> I</c><00:02:45.360><c> had</c><00:02:45.560><c> a</c>', '', '', '<span>&gt;&gt;</span> <span>Figure</span> <span>out</span> <span>another</span> <span>one</span> <span>and</span> <span>you</span> <span>know,</span> <span>I</span> <span>think<00:02:44.120><c></span> <span>the</c><00:02:44.200><c></span> <span>reality</c><00:02:44.680><c></span> <span>is</c><00:02:44.880><c></span> <span>is</c><00:02:45.000><c></span> <span>that</c><00:02:45.280><c></span> <span>I</c><00:02:45.360><c></span> <span>had</c><00:02:45.560><c></span> <span>a</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 148, 165.59, 0.0, 'think the reality is is that I had a', '', '', '<span>think</span> <span>the</span> <span>reality</span> <span>is</span> <span>is</span> <span>that</span> <span>I</span> <span>had</span> <span>a</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 149, 165.6, 0.0, 'think the reality is is that I had a really<00:02:45.959><c> mature</c><00:02:46.320><c> group.</c><00:02:46.920><c> See,</c><00:02:47.360><c> now</c><00:02:47.560><c> they''re</c>', '', '', '<span>think</span> <span>the</span> <span>reality</span> <span>is</span> <span>is</span> <span>that</span> <span>I</span> <span>had</span> <span>a</span> <span>really<00:02:45.959><c></span> <span>mature</c><00:02:46.320><c></span> <span>group.</c><00:02:46.920><c></span> <span>See,</c><00:02:47.360><c></span> <span>now</c><00:02:47.560><c></span> <span>they''re</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 150, 167.71, 0.0, 'really mature group. See, now they''re', '', '', '<span>really</span> <span>mature</span> <span>group.</span> <span>See,</span> <span>now</span> <span>they''re</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 151, 167.72, 0.0, 'really mature group. See, now they''re teasing<00:02:48.080><c> me</c><00:02:48.160><c> again</c><00:02:48.520><c> because</c><00:02:48.800><c> I</c><00:02:48.880><c> have</c><00:02:49.080><c> this</c>', '', '', '<span>really</span> <span>mature</span> <span>group.</span> <span>See,</span> <span>now</span> <span>they''re</span> <span>teasing<00:02:48.080><c></span> <span>me</c><00:02:48.160><c></span> <span>again</c><00:02:48.520><c></span> <span>because</c><00:02:48.800><c></span> <span>I</c><00:02:48.880><c></span> <span>have</c><00:02:49.080><c></span> <span>this</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 152, 169.31, 0.0, 'teasing me again because I have this', '', '', '<span>teasing</span> <span>me</span> <span>again</span> <span>because</span> <span>I</span> <span>have</span> <span>this</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 153, 169.32, 0.0, 'teasing me again because I have this they<00:02:49.600><c> count</c><00:02:50.000><c> how</c><00:02:50.120><c> many</c><00:02:50.320><c> times</c><00:02:50.680><c> I</c><00:02:50.760><c> say</c><00:02:51.320><c> the</c>', '', '', '<span>teasing</span> <span>me</span> <span>again</span> <span>because</span> <span>I</span> <span>have</span> <span>this</span> <span>they<00:02:49.600><c></span> <span>count</c><00:02:50.000><c></span> <span>how</c><00:02:50.120><c></span> <span>many</c><00:02:50.320><c></span> <span>times</c><00:02:50.680><c></span> <span>I</c><00:02:50.760><c></span> <span>say</c><00:02:51.320><c></span> <span>the</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 154, 171.43, 0.0, 'they count how many times I say the', '', '', '<span>they</span> <span>count</span> <span>how</span> <span>many</span> <span>times</span> <span>I</span> <span>say</span> <span>the</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 155, 171.44, 0.0, 'they count how many times I say the reality<00:02:51.920><c> is.</c>', '', '', '<span>they</span> <span>count</span> <span>how</span> <span>many</span> <span>times</span> <span>I</span> <span>say</span> <span>the</span> <span>reality<00:02:51.920><c></span> <span>is.</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 156, 173.15, 0.0, 'reality is.', '', '', '<span>reality</span> <span>is.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 157, 173.16, 0.0, 'reality is. I<00:02:53.400><c> guess</c><00:02:53.560><c> the</c><00:02:53.640><c> bottom</c><00:02:53.840><c> line.</c><00:02:54.280><c> That''s</c>', '', '', '<span>reality</span> <span>is.</span> <span>I<00:02:53.400><c></span> <span>guess</c><00:02:53.560><c></span> <span>the</c><00:02:53.640><c></span> <span>bottom</c><00:02:53.840><c></span> <span>line.</c><00:02:54.280><c></span> <span>That''s</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 158, 175.07, 0.0, 'I guess the bottom line. That''s', '', '', '<span>I</span> <span>guess</span> <span>the</span> <span>bottom</span> <span>line.</span> <span>That''s</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 159, 175.08, 0.0, 'I guess the bottom line. That''s That''s<00:02:55.320><c> how</c><00:02:55.440><c> we</c><00:02:55.560><c> won.</c>', '', '', '<span>I</span> <span>guess</span> <span>the</span> <span>bottom</span> <span>line.</span> <span>That''s</span> <span>That''s<00:02:55.320><c></span> <span>how</c><00:02:55.440><c></span> <span>we</c><00:02:55.560><c></span> <span>won.</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 160, 176.31, 0.0, 'That''s how we won.', '', '', '<span>That''s</span> <span>how</span> <span>we</span> <span>won.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 161, 176.32, 0.0, 'That''s how we won. I<00:02:56.400><c> guess</c><00:02:56.640><c> those</c><00:02:56.800><c> are</c><00:02:56.880><c> my</c><00:02:57.040><c> phrases</c><00:02:57.640><c> I</c><00:02:57.760><c> say</c><00:02:58.040><c> far</c>', '', '', '<span>That''s</span> <span>how</span> <span>we</span> <span>won.</span> <span>I<00:02:56.400><c></span> <span>guess</c><00:02:56.640><c></span> <span>those</c><00:02:56.800><c></span> <span>are</c><00:02:56.880><c></span> <span>my</c><00:02:57.040><c></span> <span>phrases</c><00:02:57.640><c></span> <span>I</c><00:02:57.760><c></span> <span>say</c><00:02:58.040><c></span> <span>far</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 162, 178.27, 0.0, 'I guess those are my phrases I say far', '', '', '<span>I</span> <span>guess</span> <span>those</span> <span>are</span> <span>my</span> <span>phrases</span> <span>I</span> <span>say</span> <span>far</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 163, 178.28, 0.0, 'I guess those are my phrases I say far too<00:02:58.440><c> often,</c>', '', '', '<span>I</span> <span>guess</span> <span>those</span> <span>are</span> <span>my</span> <span>phrases</span> <span>I</span> <span>say</span> <span>far</span> <span>too<00:02:58.440><c></span> <span>often,</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 164, 179.55, 0.0, 'too often,', '', '', '<span>too</span> <span>often,</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 165, 179.56, 0.0, 'too often, but<00:02:59.800><c> in</c><00:02:59.959><c> this</c><00:03:00.239><c> case,</c>', '', '', '<span>too</span> <span>often,</span> <span>but<00:02:59.800><c></span> <span>in</c><00:02:59.959><c></span> <span>this</c><00:03:00.239><c></span> <span>case,</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 166, 181.35, 0.0, 'but in this case,', '', '', '<span>but</span> <span>in</span> <span>this</span> <span>case,</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 167, 181.36, 0.0, 'but in this case, we<00:03:01.560><c> all</c><00:03:01.840><c> really</c><00:03:02.120><c> cared</c><00:03:02.480><c> all</c><00:03:02.640><c> season</c><00:03:03.000><c> long</c>', '', '', '<span>but</span> <span>in</span> <span>this</span> <span>case,</span> <span>we<00:03:01.560><c></span> <span>all</c><00:03:01.840><c></span> <span>really</c><00:03:02.120><c></span> <span>cared</c><00:03:02.480><c></span> <span>all</c><00:03:02.640><c></span> <span>season</c><00:03:03.000><c></span> <span>long</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 168, 183.71, 0.0, 'we all really cared all season long', '', '', '<span>we</span> <span>all</span> <span>really</span> <span>cared</span> <span>all</span> <span>season</span> <span>long</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 169, 183.72, 0.0, 'we all really cared all season long about<00:03:04.000><c> the</c><00:03:04.080><c> one</c><00:03:04.280><c> we</c><00:03:04.400><c> just</c><00:03:04.600><c> had.</c>', '', '', '<span>we</span> <span>all</span> <span>really</span> <span>cared</span> <span>all</span> <span>season</span> <span>long</span> <span>about<00:03:04.000><c></span> <span>the</c><00:03:04.080><c></span> <span>one</c><00:03:04.280><c></span> <span>we</c><00:03:04.400><c></span> <span>just</c><00:03:04.600><c></span> <span>had.</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 170, 185.35, 0.0, 'about the one we just had.', '', '', '<span>about</span> <span>the</span> <span>one</span> <span>we</span> <span>just</span> <span>had.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 171, 185.36, 0.0, 'about the one we just had. &gt;&gt; So,<00:03:05.760><c> the</c><00:03:06.120><c> first</c><00:03:06.560><c> game</c><00:03:06.800><c> you</c><00:03:06.920><c> guys</c><00:03:07.200><c> won</c><00:03:07.600><c> in</c><00:03:07.840><c> the</c>', '', '', '<span>about</span> <span>the</span> <span>one</span> <span>we</span> <span>just</span> <span>had.</span> <span>&gt;&gt;</span> <span>So,<00:03:05.760><c></span> <span>the</c><00:03:06.120><c></span> <span>first</c><00:03:06.560><c></span> <span>game</c><00:03:06.800><c></span> <span>you</c><00:03:06.920><c></span> <span>guys</c><00:03:07.200><c></span> <span>won</c><00:03:07.600><c></span> <span>in</c><00:03:07.840><c></span> <span>the</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 172, 188.11, 0.0, '&gt;&gt; So, the first game you guys won in the', '', '', '<span>&gt;&gt;</span> <span>So,</span> <span>the</span> <span>first</span> <span>game</span> <span>you</span> <span>guys</span> <span>won</span> <span>in</span> <span>the</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 173, 188.12, 0.0, '&gt;&gt; So, the first game you guys won in the NCAA<00:03:08.800><c> tournament</c><00:03:09.239><c> was</c><00:03:09.440><c> against</c><00:03:09.760><c> Cal</c><00:03:10.040><c> Baptist</c>', '', '', '<span>&gt;&gt;</span> <span>So,</span> <span>the</span> <span>first</span> <span>game</span> <span>you</span> <span>guys</span> <span>won</span> <span>in</span> <span>the</span> <span>NCAA<00:03:08.800><c></span> <span>tournament</c><00:03:09.239><c></span> <span>was</c><00:03:09.440><c></span> <span>against</c><00:03:09.760><c></span> <span>Cal</c><00:03:10.040><c></span> <span>Baptist</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 174, 190.71, 0.0, 'NCAA tournament was against Cal Baptist', '', '', '<span>NCAA</span> <span>tournament</span> <span>was</span> <span>against</span> <span>Cal</span> <span>Baptist</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 175, 190.72, 0.0, 'NCAA tournament was against Cal Baptist and<00:03:10.880><c> you</c><00:03:11.000><c> beat</c><00:03:11.239><c> them</c><00:03:11.440><c> by</c><00:03:11.600><c> how</c><00:03:11.760><c> many</c><00:03:12.000><c> points?</c>', '', '', '<span>NCAA</span> <span>tournament</span> <span>was</span> <span>against</span> <span>Cal</span> <span>Baptist</span> <span>and<00:03:10.880><c></span> <span>you</c><00:03:11.000><c></span> <span>beat</c><00:03:11.239><c></span> <span>them</c><00:03:11.440><c></span> <span>by</c><00:03:11.600><c></span> <span>how</c><00:03:11.760><c></span> <span>many</c><00:03:12.000><c></span> <span>points?</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 176, 193.91, 0.0, 'and you beat them by how many points?', '', '', '<span>and</span> <span>you</span> <span>beat</span> <span>them</span> <span>by</span> <span>how</span> <span>many</span> <span>points?</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 177, 193.92, 0.0, 'and you beat them by how many points? The<00:03:14.200><c> answer</c><00:03:14.519><c> is</c><00:03:14.640><c> 53.</c>', '', '', '<span>and</span> <span>you</span> <span>beat</span> <span>them</span> <span>by</span> <span>how</span> <span>many</span> <span>points?</span> <span>The<00:03:14.200><c></span> <span>answer</c><00:03:14.519><c></span> <span>is</c><00:03:14.640><c></span> <span>53.</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 178, 197.35, 0.0, 'The answer is 53.', '', '', '<span>The</span> <span>answer</span> <span>is</span> <span>53.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 179, 197.36, 0.0, 'The answer is 53. Do<00:03:17.480><c> you</c><00:03:17.720><c> at</c><00:03:17.880><c> any</c><00:03:18.120><c> point</c><00:03:18.519><c> feel</c><00:03:18.800><c> bad</c><00:03:19.320><c> when</c><00:03:19.519><c> you''re</c>', '', '', '<span>The</span> <span>answer</span> <span>is</span> <span>53.</span> <span>Do<00:03:17.480><c></span> <span>you</c><00:03:17.720><c></span> <span>at</c><00:03:17.880><c></span> <span>any</c><00:03:18.120><c></span> <span>point</c><00:03:18.519><c></span> <span>feel</c><00:03:18.800><c></span> <span>bad</c><00:03:19.320><c></span> <span>when</c><00:03:19.519><c></span> <span>you''re</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 180, 199.67, 0.0, 'Do you at any point feel bad when you''re', '', '', '<span>Do</span> <span>you</span> <span>at</span> <span>any</span> <span>point</span> <span>feel</span> <span>bad</span> <span>when</span> <span>you''re</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 181, 199.68, 0.0, 'Do you at any point feel bad when you''re beating<00:03:20.040><c> a</c><00:03:20.120><c> team?</c>', '', '', '<span>Do</span> <span>you</span> <span>at</span> <span>any</span> <span>point</span> <span>feel</span> <span>bad</span> <span>when</span> <span>you''re</span> <span>beating<00:03:20.040><c></span> <span>a</c><00:03:20.120><c></span> <span>team?</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 182, 201.31, 0.0, 'beating a team?', '', '', '<span>beating</span> <span>a</span> <span>team?</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 183, 201.32, 0.0, 'beating a team? &gt;&gt; No,<00:03:21.600><c> not</c><00:03:21.800><c> when</c><00:03:21.920><c> your</c><00:03:22.040><c> season''s</c><00:03:22.480><c> ON</c><00:03:22.600><c> THE</c><00:03:22.680><c> LINE.</c>', '', '', '<span>beating</span> <span>a</span> <span>team?</span> <span>&gt;&gt;</span> <span>No,<00:03:21.600><c></span> <span>not</c><00:03:21.800><c></span> <span>when</c><00:03:21.920><c></span> <span>your</c><00:03:22.040><c></span> <span>season''s</c><00:03:22.480><c></span> <span>ON</c><00:03:22.600><c></span> <span>THE</c><00:03:22.680><c></span> <span>LINE.</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 184, 209.229, 0.0, '&gt;&gt; ON SUNDAY,', '', '', '<span>&gt;&gt;</span> <span>ON</span> <span>SUNDAY,</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 185, 209.239, 0.0, '&gt;&gt; ON SUNDAY, YOU<00:03:29.360><c> DESTROYED</c><00:03:29.880><c> SOUTH</c><00:03:30.160><c> CAROLINA.</c><00:03:30.640><c> It</c><00:03:30.720><c> wasn''t</c>', '', '', '<span>&gt;&gt;</span> <span>ON</span> <span>SUNDAY,</span> <span>YOU<00:03:29.360><c></span> <span>DESTROYED</c><00:03:29.880><c></span> <span>SOUTH</c><00:03:30.160><c></span> <span>CAROLINA.</c><00:03:30.640><c></span> <span>It</c><00:03:30.720><c></span> <span>wasn''t</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 186, 211.03, 0.0, 'YOU DESTROYED SOUTH CAROLINA. It wasn''t', '', '', '<span>YOU</span> <span>DESTROYED</span> <span>SOUTH</span> <span>CAROLINA.</span> <span>It</span> <span>wasn''t</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 187, 211.04, 0.0, 'YOU DESTROYED SOUTH CAROLINA. It wasn''t even<00:03:31.239><c> close.</c><00:03:31.519><c> Do</c><00:03:31.640><c> you</c><00:03:31.760><c> feel</c><00:03:31.959><c> bad</c><00:03:32.239><c> for</c><00:03:32.360><c> them</c><00:03:32.600><c> at</c>', '', '', '<span>YOU</span> <span>DESTROYED</span> <span>SOUTH</span> <span>CAROLINA.</span> <span>It</span> <span>wasn''t</span> <span>even<00:03:31.239><c></span> <span>close.</c><00:03:31.519><c></span> <span>Do</c><00:03:31.640><c></span> <span>you</c><00:03:31.760><c></span> <span>feel</c><00:03:31.959><c></span> <span>bad</c><00:03:32.239><c></span> <span>for</c><00:03:32.360><c></span> <span>them</c><00:03:32.600><c></span> <span>at</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 188, 212.71, 0.0, 'even close. Do you feel bad for them at', '', '', '<span>even</span> <span>close.</span> <span>Do</span> <span>you</span> <span>feel</span> <span>bad</span> <span>for</span> <span>them</span> <span>at</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 189, 212.72, 0.0, 'even close. Do you feel bad for them at all?<00:03:32.880><c> Do</c><00:03:32.959><c> you</c><00:03:33.040><c> have</c><00:03:33.200><c> any</c>', '', '', '<span>even</span> <span>close.</span> <span>Do</span> <span>you</span> <span>feel</span> <span>bad</span> <span>for</span> <span>them</span> <span>at</span> <span>all?<00:03:32.880><c></span> <span>Do</c><00:03:32.959><c></span> <span>you</c><00:03:33.040><c></span> <span>have</c><00:03:33.200><c></span> <span>any</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 190, 214.67, 0.0, 'all? Do you have any', '', '', '<span>all?</span> <span>Do</span> <span>you</span> <span>have</span> <span>any</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 191, 214.68, 0.0, 'all? Do you have any &gt;&gt; We''re<00:03:34.800><c> just</c><00:03:35.040><c> happy</c><00:03:35.360><c> that</c><00:03:35.519><c> we</c><00:03:35.720><c> won.</c><00:03:36.480><c> We</c>', '', '', '<span>all?</span> <span>Do</span> <span>you</span> <span>have</span> <span>any</span> <span>&gt;&gt;</span> <span>We''re<00:03:34.800><c></span> <span>just</c><00:03:35.040><c></span> <span>happy</c><00:03:35.360><c></span> <span>that</c><00:03:35.519><c></span> <span>we</c><00:03:35.720><c></span> <span>won.</c><00:03:36.480><c></span> <span>We</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 192, 217.31, 0.0, '&gt;&gt; We''re just happy that we won. We', '', '', '<span>&gt;&gt;</span> <span>We''re</span> <span>just</span> <span>happy</span> <span>that</span> <span>we</span> <span>won.</span> <span>We</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 193, 217.32, 0.0, '&gt;&gt; We''re just happy that we won. We are<00:03:37.720><c> so</c><00:03:38.040><c> proud</c><00:03:38.519><c> as</c><00:03:38.680><c> a</c><00:03:38.720><c> team</c><00:03:40.000><c> and</c><00:03:40.120><c> we''re</c><00:03:40.239><c> all</c>', '', '', '<span>&gt;&gt;</span> <span>We''re</span> <span>just</span> <span>happy</span> <span>that</span> <span>we</span> <span>won.</span> <span>We</span> <span>are<00:03:37.720><c></span> <span>so</c><00:03:38.040><c></span> <span>proud</c><00:03:38.519><c></span> <span>as</c><00:03:38.680><c></span> <span>a</c><00:03:38.720><c></span> <span>team</c><00:03:40.000><c></span> <span>and</c><00:03:40.120><c></span> <span>we''re</c><00:03:40.239><c></span> <span>all</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 194, 220.31, 0.0, 'are so proud as a team and we''re all', '', '', '<span>are</span> <span>so</span> <span>proud</span> <span>as</span> <span>a</span> <span>team</span> <span>and</span> <span>we''re</span> <span>all</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 195, 220.32, 0.0, 'are so proud as a team and we''re all competitors.', '', '', '<span>are</span> <span>so</span> <span>proud</span> <span>as</span> <span>a</span> <span>team</span> <span>and</span> <span>we''re</span> <span>all</span> <span>competitors.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 196, 221.19, 0.0, 'competitors.', '', '', '<span>competitors.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 197, 221.2, 0.0, 'competitors. &gt;&gt; Lauren,<00:03:41.519><c> you''re</c><00:03:41.720><c> the</c><00:03:41.880><c> MOP,</c><00:03:42.560><c> the</c><00:03:42.680><c> most</c>', '', '', '<span>competitors.</span> <span>&gt;&gt;</span> <span>Lauren,<00:03:41.519><c></span> <span>you''re</c><00:03:41.720><c></span> <span>the</c><00:03:41.880><c></span> <span>MOP,</c><00:03:42.560><c></span> <span>the</c><00:03:42.680><c></span> <span>most</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 198, 222.949, 0.0, '&gt;&gt; Lauren, you''re the MOP, the most', '', '', '<span>&gt;&gt;</span> <span>Lauren,</span> <span>you''re</span> <span>the</span> <span>MOP,</span> <span>the</span> <span>most</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 199, 222.959, 0.0, '&gt;&gt; Lauren, you''re the MOP, the most outstanding<00:03:43.640><c> player.</c><00:03:44.040><c> Do</c><00:03:44.160><c> you</c><00:03:44.280><c> wish</c><00:03:44.480><c> it</c><00:03:44.600><c> was</c>', '', '', '<span>&gt;&gt;</span> <span>Lauren,</span> <span>you''re</span> <span>the</span> <span>MOP,</span> <span>the</span> <span>most</span> <span>outstanding<00:03:43.640><c></span> <span>player.</c><00:03:44.040><c></span> <span>Do</c><00:03:44.160><c></span> <span>you</c><00:03:44.280><c></span> <span>wish</c><00:03:44.480><c></span> <span>it</c><00:03:44.600><c></span> <span>was</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 200, 224.79, 0.0, 'outstanding player. Do you wish it was', '', '', '<span>outstanding</span> <span>player.</span> <span>Do</span> <span>you</span> <span>wish</span> <span>it</span> <span>was</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 201, 224.8, 0.0, 'outstanding player. Do you wish it was MVP<00:03:45.440><c> because</c><00:03:46.120><c> a</c><00:03:46.200><c> mop</c><00:03:46.560><c> is</c><00:03:46.720><c> a</c><00:03:46.760><c> weird</c><00:03:47.000><c> word.</c>', '', '', '<span>outstanding</span> <span>player.</span> <span>Do</span> <span>you</span> <span>wish</span> <span>it</span> <span>was</span> <span>MVP<00:03:45.440><c></span> <span>because</c><00:03:46.120><c></span> <span>a</c><00:03:46.200><c></span> <span>mop</c><00:03:46.560><c></span> <span>is</c><00:03:46.720><c></span> <span>a</c><00:03:46.760><c></span> <span>weird</c><00:03:47.000><c></span> <span>word.</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 202, 228.27, 0.0, 'MVP because a mop is a weird word.', '', '', '<span>MVP</span> <span>because</span> <span>a</span> <span>mop</span> <span>is</span> <span>a</span> <span>weird</span> <span>word.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 203, 228.28, 0.0, 'MVP because a mop is a weird word. &gt;&gt; I<00:03:48.400><c> like</c><00:03:48.600><c> the</c><00:03:48.680><c> word</c><00:03:48.880><c> mop.</c><00:03:49.239><c> I</c><00:03:49.280><c> think</c><00:03:49.440><c> it''s</c><00:03:49.519><c> cool.</c>', '', '', '<span>MVP</span> <span>because</span> <span>a</span> <span>mop</span> <span>is</span> <span>a</span> <span>weird</span> <span>word.</span> <span>&gt;&gt;</span> <span>I<00:03:48.400><c></span> <span>like</c><00:03:48.600><c></span> <span>the</c><00:03:48.680><c></span> <span>word</c><00:03:48.880><c></span> <span>mop.</c><00:03:49.239><c></span> <span>I</c><00:03:49.280><c></span> <span>think</c><00:03:49.440><c></span> <span>it''s</c><00:03:49.519><c></span> <span>cool.</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 204, 230.03, 0.0, '&gt;&gt; I like the word mop. I think it''s cool.', '', '', '<span>&gt;&gt;</span> <span>I</span> <span>like</span> <span>the</span> <span>word</span> <span>mop.</span> <span>I</span> <span>think</span> <span>it''s</span> <span>cool.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 205, 230.04, 0.0, '&gt;&gt; I like the word mop. I think it''s cool. Yeah,<00:03:50.160><c> the</c><00:03:50.280><c> mop</c><00:03:50.519><c> is</c><00:03:50.640><c> cool.</c>', '', '', '<span>&gt;&gt;</span> <span>I</span> <span>like</span> <span>the</span> <span>word</span> <span>mop.</span> <span>I</span> <span>think</span> <span>it''s</span> <span>cool.</span> <span>Yeah,<00:03:50.160><c></span> <span>the</c><00:03:50.280><c></span> <span>mop</c><00:03:50.519><c></span> <span>is</c><00:03:50.640><c></span> <span>cool.</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 206, 230.949, 0.0, 'Yeah, the mop is cool.', '', '', '<span>Yeah,</span> <span>the</span> <span>mop</span> <span>is</span> <span>cool.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 207, 230.959, 0.0, 'Yeah, the mop is cool. &gt;&gt; Okay.<00:03:51.640><c> All</c><00:03:51.760><c> right,</c><00:03:52.120><c> you''re</c><00:03:52.320><c> okay</c><00:03:52.640><c> with</c><00:03:52.840><c> the</c>', '', '', '<span>Yeah,</span> <span>the</span> <span>mop</span> <span>is</span> <span>cool.</span> <span>&gt;&gt;</span> <span>Okay.<00:03:51.640><c></span> <span>All</c><00:03:51.760><c></span> <span>right,</c><00:03:52.120><c></span> <span>you''re</c><00:03:52.320><c></span> <span>okay</c><00:03:52.640><c></span> <span>with</c><00:03:52.840><c></span> <span>the</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 208, 232.91, 0.0, '&gt;&gt; Okay. All right, you''re okay with the', '', '', '<span>&gt;&gt;</span> <span>Okay.</span> <span>All</span> <span>right,</span> <span>you''re</span> <span>okay</span> <span>with</span> <span>the</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 209, 232.92, 0.0, '&gt;&gt; Okay. All right, you''re okay with the mob?', '', '', '<span>&gt;&gt;</span> <span>Okay.</span> <span>All</span> <span>right,</span> <span>you''re</span> <span>okay</span> <span>with</span> <span>the</span> <span>mob?</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 210, 233.19, 0.0, 'mob?', '', '', '<span>mob?</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 211, 233.2, 0.0, 'mob? &gt;&gt; Oh,<00:03:53.440><c> I''m</c><00:03:53.680><c> fine</c><00:03:53.960><c> with</c><00:03:54.200><c> it.</c><00:03:54.480><c> I''m</c><00:03:54.560><c> fine.</c>', '', '', '<span>mob?</span> <span>&gt;&gt;</span> <span>Oh,<00:03:53.440><c></span> <span>I''m</c><00:03:53.680><c></span> <span>fine</c><00:03:53.960><c></span> <span>with</c><00:03:54.200><c></span> <span>it.</c><00:03:54.480><c></span> <span>I''m</c><00:03:54.560><c></span> <span>fine.</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 212, 235.59, 0.0, '&gt;&gt; Oh, I''m fine with it. I''m fine.', '', '', '<span>&gt;&gt;</span> <span>Oh,</span> <span>I''m</span> <span>fine</span> <span>with</span> <span>it.</span> <span>I''m</span> <span>fine.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 213, 235.6, 0.0, '&gt;&gt; Oh, I''m fine with it. I''m fine. &gt;&gt; It<00:03:55.760><c> feels</c><00:03:56.040><c> like</c><00:03:56.200><c> it''s</c><00:03:56.360><c> like</c><00:03:56.560><c> a</c><00:03:56.600><c> big</c><00:03:57.040><c> time</c><00:03:57.440><c> for</c>', '', '', '<span>&gt;&gt;</span> <span>Oh,</span> <span>I''m</span> <span>fine</span> <span>with</span> <span>it.</span> <span>I''m</span> <span>fine.</span> <span>&gt;&gt;</span> <span>It<00:03:55.760><c></span> <span>feels</c><00:03:56.040><c></span> <span>like</c><00:03:56.200><c></span> <span>it''s</c><00:03:56.360><c></span> <span>like</c><00:03:56.560><c></span> <span>a</c><00:03:56.600><c></span> <span>big</c><00:03:57.040><c></span> <span>time</c><00:03:57.440><c></span> <span>for</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 214, 237.59, 0.0, '&gt;&gt; It feels like it''s like a big time for', '', '', '<span>&gt;&gt;</span> <span>It</span> <span>feels</span> <span>like</span> <span>it''s</span> <span>like</span> <span>a</span> <span>big</span> <span>time</span> <span>for</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 215, 237.6, 0.0, '&gt;&gt; It feels like it''s like a big time for women''s<00:03:57.960><c> sports</c><00:03:58.400><c> right</c><00:03:58.600><c> now.</c><00:03:58.720><c> Do</c><00:03:58.800><c> you</c><00:03:58.880><c> guys</c>', '', '', '<span>&gt;&gt;</span> <span>It</span> <span>feels</span> <span>like</span> <span>it''s</span> <span>like</span> <span>a</span> <span>big</span> <span>time</span> <span>for</span> <span>women''s<00:03:57.960><c></span> <span>sports</c><00:03:58.400><c></span> <span>right</c><00:03:58.600><c></span> <span>now.</c><00:03:58.720><c></span> <span>Do</c><00:03:58.800><c></span> <span>you</c><00:03:58.880><c></span> <span>guys</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 216, 239.15, 0.0, 'women''s sports right now. Do you guys', '', '', '<span>women''s</span> <span>sports</span> <span>right</span> <span>now.</span> <span>Do</span> <span>you</span> <span>guys</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 217, 239.16, 0.0, 'women''s sports right now. Do you guys sense<00:03:59.480><c> that?</c><00:03:59.760><c> Do</c><00:03:59.840><c> you</c><00:03:59.920><c> feel</c><00:04:00.160><c> that</c><00:04:00.400><c> from</c><00:04:00.560><c> the</c>', '', '', '<span>women''s</span> <span>sports</span> <span>right</span> <span>now.</span> <span>Do</span> <span>you</span> <span>guys</span> <span>sense<00:03:59.480><c></span> <span>that?</c><00:03:59.760><c></span> <span>Do</c><00:03:59.840><c></span> <span>you</c><00:03:59.920><c></span> <span>feel</c><00:04:00.160><c></span> <span>that</c><00:04:00.400><c></span> <span>from</c><00:04:00.560><c></span> <span>the</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 218, 240.63, 0.0, 'sense that? Do you feel that from the', '', '', '<span>sense</span> <span>that?</span> <span>Do</span> <span>you</span> <span>feel</span> <span>that</span> <span>from</span> <span>the</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 219, 240.64, 0.0, 'sense that? Do you feel that from the fans<00:04:01.200><c> and</c><00:04:01.360><c> from</c><00:04:01.600><c> the</c><00:04:01.680><c> reaction</c><00:04:02.240><c> that</c><00:04:02.760><c> that</c><00:04:02.960><c> you</c>', '', '', '<span>sense</span> <span>that?</span> <span>Do</span> <span>you</span> <span>feel</span> <span>that</span> <span>from</span> <span>the</span> <span>fans<00:04:01.200><c></span> <span>and</c><00:04:01.360><c></span> <span>from</c><00:04:01.600><c></span> <span>the</c><00:04:01.680><c></span> <span>reaction</c><00:04:02.240><c></span> <span>that</c><00:04:02.760><c></span> <span>that</c><00:04:02.960><c></span> <span>you</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 220, 243.07, 0.0, 'fans and from the reaction that that you', '', '', '<span>fans</span> <span>and</span> <span>from</span> <span>the</span> <span>reaction</span> <span>that</span> <span>that</span> <span>you</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 221, 243.08, 0.0, 'fans and from the reaction that that you get?', '', '', '<span>fans</span> <span>and</span> <span>from</span> <span>the</span> <span>reaction</span> <span>that</span> <span>that</span> <span>you</span> <span>get?</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 222, 243.79, 0.0, 'get?', '', '', '<span>get?</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 223, 243.8, 0.0, 'get? &gt;&gt; Totally.<00:04:04.120><c> I</c><00:04:04.200><c> mean,</c><00:04:04.680><c> I</c><00:04:04.760><c> just</c><00:04:04.960><c> remember</c><00:04:05.640><c> the</c>', '', '', '<span>get?</span> <span>&gt;&gt;</span> <span>Totally.<00:04:04.120><c></span> <span>I</c><00:04:04.200><c></span> <span>mean,</c><00:04:04.680><c></span> <span>I</c><00:04:04.760><c></span> <span>just</c><00:04:04.960><c></span> <span>remember</c><00:04:05.640><c></span> <span>the</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 224, 245.91, 0.0, '&gt;&gt; Totally. I mean, I just remember the', '', '', '<span>&gt;&gt;</span> <span>Totally.</span> <span>I</span> <span>mean,</span> <span>I</span> <span>just</span> <span>remember</span> <span>the</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 225, 245.92, 0.0, '&gt;&gt; Totally. I mean, I just remember the attendance<00:04:06.360><c> at</c><00:04:06.440><c> our</c><00:04:06.520><c> games</c><00:04:06.800><c> from</c><00:04:06.959><c> freshman</c>', '', '', '<span>&gt;&gt;</span> <span>Totally.</span> <span>I</span> <span>mean,</span> <span>I</span> <span>just</span> <span>remember</span> <span>the</span> <span>attendance<00:04:06.360><c></span> <span>at</c><00:04:06.440><c></span> <span>our</c><00:04:06.520><c></span> <span>games</c><00:04:06.800><c></span> <span>from</c><00:04:06.959><c></span> <span>freshman</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 226, 247.35, 0.0, 'attendance at our games from freshman', '', '', '<span>attendance</span> <span>at</span> <span>our</span> <span>games</span> <span>from</span> <span>freshman</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 227, 247.36, 0.0, 'attendance at our games from freshman year<00:04:07.480><c> to</c><00:04:07.600><c> now</c><00:04:07.959><c> just</c><00:04:08.160><c> in</c><00:04:08.240><c> the</c><00:04:08.320><c> last</c><00:04:08.600><c> 4</c><00:04:08.800><c> years</c><00:04:09.080><c> has</c>', '', '', '<span>attendance</span> <span>at</span> <span>our</span> <span>games</span> <span>from</span> <span>freshman</span> <span>year<00:04:07.480><c></span> <span>to</c><00:04:07.600><c></span> <span>now</c><00:04:07.959><c></span> <span>just</c><00:04:08.160><c></span> <span>in</c><00:04:08.240><c></span> <span>the</c><00:04:08.320><c></span> <span>last</c><00:04:08.600><c></span> <span>4</c><00:04:08.800><c></span> <span>years</c><00:04:09.080><c></span> <span>has</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 228, 249.19, 0.0, 'year to now just in the last 4 years has', '', '', '<span>year</span> <span>to</span> <span>now</span> <span>just</span> <span>in</span> <span>the</span> <span>last</span> <span>4</span> <span>years</span> <span>has</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 229, 249.2, 0.0, 'year to now just in the last 4 years has like<00:04:09.440><c> totally</c><00:04:09.920><c> skyrocketed.</c><00:04:10.880><c> And</c><00:04:11.000><c> to</c><00:04:11.120><c> see</c><00:04:11.280><c> the</c>', '', '', '<span>year</span> <span>to</span> <span>now</span> <span>just</span> <span>in</span> <span>the</span> <span>last</span> <span>4</span> <span>years</span> <span>has</span> <span>like<00:04:09.440><c></span> <span>totally</c><00:04:09.920><c></span> <span>skyrocketed.</c><00:04:10.880><c></span> <span>And</c><00:04:11.000><c></span> <span>to</c><00:04:11.120><c></span> <span>see</c><00:04:11.280><c></span> <span>the</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 230, 251.99, 0.0, 'like totally skyrocketed. And to see the', '', '', '<span>like</span> <span>totally</span> <span>skyrocketed.</span> <span>And</span> <span>to</span> <span>see</span> <span>the</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 231, 252.0, 0.0, 'like totally skyrocketed. And to see the attention<00:04:12.640><c> and</c><00:04:12.800><c> so</c><00:04:12.920><c> many</c><00:04:13.080><c> people</c><00:04:13.280><c> that</c><00:04:13.400><c> are</c><00:04:13.480><c> so</c>', '', '', '<span>like</span> <span>totally</span> <span>skyrocketed.</span> <span>And</span> <span>to</span> <span>see</span> <span>the</span> <span>attention<00:04:12.640><c></span> <span>and</c><00:04:12.800><c></span> <span>so</c><00:04:12.920><c></span> <span>many</c><00:04:13.080><c></span> <span>people</c><00:04:13.280><c></span> <span>that</c><00:04:13.400><c></span> <span>are</c><00:04:13.480><c></span> <span>so</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 232, 253.67, 0.0, 'attention and so many people that are so', '', '', '<span>attention</span> <span>and</span> <span>so</span> <span>many</span> <span>people</span> <span>that</span> <span>are</span> <span>so</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 233, 253.68, 0.0, 'attention and so many people that are so excited<00:04:14.040><c> for</c><00:04:14.160><c> us,</c><00:04:14.280><c> it</c><00:04:14.680><c> it</c><00:04:14.800><c> really</c><00:04:15.000><c> means</c><00:04:15.240><c> a</c><00:04:15.280><c> lot</c>', '', '', '<span>attention</span> <span>and</span> <span>so</span> <span>many</span> <span>people</span> <span>that</span> <span>are</span> <span>so</span> <span>excited<00:04:14.040><c></span> <span>for</c><00:04:14.160><c></span> <span>us,</c><00:04:14.280><c></span> <span>it</c><00:04:14.680><c></span> <span>it</c><00:04:14.800><c></span> <span>really</c><00:04:15.000><c></span> <span>means</c><00:04:15.240><c></span> <span>a</c><00:04:15.280><c></span> <span>lot</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 234, 255.47, 0.0, 'excited for us, it it really means a lot', '', '', '<span>excited</span> <span>for</span> <span>us,</span> <span>it</span> <span>it</span> <span>really</span> <span>means</span> <span>a</span> <span>lot</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 235, 255.48, 0.0, 'excited for us, it it really means a lot cuz<00:04:15.640><c> it''s</c><00:04:15.800><c> like</c><00:04:15.959><c> so</c><00:04:16.160><c> fun</c><00:04:16.400><c> to</c><00:04:16.480><c> be</c><00:04:16.560><c> playing</c>', '', '', '<span>excited</span> <span>for</span> <span>us,</span> <span>it</span> <span>it</span> <span>really</span> <span>means</span> <span>a</span> <span>lot</span> <span>cuz<00:04:15.640><c></span> <span>it''s</c><00:04:15.800><c></span> <span>like</c><00:04:15.959><c></span> <span>so</c><00:04:16.160><c></span> <span>fun</c><00:04:16.400><c></span> <span>to</c><00:04:16.480><c></span> <span>be</c><00:04:16.560><c></span> <span>playing</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 236, 256.99, 0.0, 'cuz it''s like so fun to be playing', '', '', '<span>cuz</span> <span>it''s</span> <span>like</span> <span>so</span> <span>fun</span> <span>to</span> <span>be</span> <span>playing</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 237, 257.0, 0.0, 'cuz it''s like so fun to be playing &gt;&gt; To<00:04:17.160><c> what</c><00:04:17.400><c> do</c><00:04:17.480><c> you</c><00:04:17.600><c> attribute</c><00:04:18.079><c> that</c><00:04:18.320><c> to?</c><00:04:18.440><c> Is</c><00:04:18.600><c> it</c>', '', '', '<span>cuz</span> <span>it''s</span> <span>like</span> <span>so</span> <span>fun</span> <span>to</span> <span>be</span> <span>playing</span> <span>&gt;&gt;</span> <span>To<00:04:17.160><c></span> <span>what</c><00:04:17.400><c></span> <span>do</c><00:04:17.480><c></span> <span>you</c><00:04:17.600><c></span> <span>attribute</c><00:04:18.079><c></span> <span>that</c><00:04:18.320><c></span> <span>to?</c><00:04:18.440><c></span> <span>Is</c><00:04:18.600><c></span> <span>it</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 238, 258.789, 0.0, '&gt;&gt; To what do you attribute that to? Is it', '', '', '<span>&gt;&gt;</span> <span>To</span> <span>what</span> <span>do</span> <span>you</span> <span>attribute</span> <span>that</span> <span>to?</span> <span>Is</span> <span>it</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 239, 258.799, 0.0, '&gt;&gt; To what do you attribute that to? Is it the<00:04:19.000><c> success</c><00:04:19.560><c> of</c><00:04:19.799><c> your</c><00:04:20.000><c> team?</c><00:04:20.480><c> Is</c><00:04:20.760><c> it</c><00:04:20.920><c> the</c>', '', '', '<span>&gt;&gt;</span> <span>To</span> <span>what</span> <span>do</span> <span>you</span> <span>attribute</span> <span>that</span> <span>to?</span> <span>Is</span> <span>it</span> <span>the<00:04:19.000><c></span> <span>success</c><00:04:19.560><c></span> <span>of</c><00:04:19.799><c></span> <span>your</c><00:04:20.000><c></span> <span>team?</c><00:04:20.480><c></span> <span>Is</c><00:04:20.760><c></span> <span>it</c><00:04:20.920><c></span> <span>the</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 240, 260.99, 0.0, 'the success of your team? Is it the', '', '', '<span>the</span> <span>success</span> <span>of</span> <span>your</span> <span>team?</span> <span>Is</span> <span>it</span> <span>the</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 241, 261.0, 0.0, 'the success of your team? Is it the success<00:04:21.640><c> of</c><00:04:22.040><c> women''s</c><00:04:22.400><c> sports</c><00:04:22.840><c> in</c><00:04:22.960><c> general</c><00:04:23.480><c> or</c>', '', '', '<span>the</span> <span>success</span> <span>of</span> <span>your</span> <span>team?</span> <span>Is</span> <span>it</span> <span>the</span> <span>success<00:04:21.640><c></span> <span>of</c><00:04:22.040><c></span> <span>women''s</c><00:04:22.400><c></span> <span>sports</c><00:04:22.840><c></span> <span>in</c><00:04:22.960><c></span> <span>general</c><00:04:23.480><c></span> <span>or</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 242, 263.75, 0.0, 'success of women''s sports in general or', '', '', '<span>success</span> <span>of</span> <span>women''s</span> <span>sports</span> <span>in</span> <span>general</span> <span>or</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 243, 263.76, 0.0, 'success of women''s sports in general or some<00:04:24.000><c> combination</c><00:04:24.640><c> of</c><00:04:24.720><c> both</c><00:04:25.000><c> of</c><00:04:25.080><c> those</c>', '', '', '<span>success</span> <span>of</span> <span>women''s</span> <span>sports</span> <span>in</span> <span>general</span> <span>or</span> <span>some<00:04:24.000><c></span> <span>combination</c><00:04:24.640><c></span> <span>of</c><00:04:24.720><c></span> <span>both</c><00:04:25.000><c></span> <span>of</c><00:04:25.080><c></span> <span>those</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 244, 265.31, 0.0, 'some combination of both of those', '', '', '<span>some</span> <span>combination</span> <span>of</span> <span>both</span> <span>of</span> <span>those</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 245, 265.32, 0.0, 'some combination of both of those things?', '', '', '<span>some</span> <span>combination</span> <span>of</span> <span>both</span> <span>of</span> <span>those</span> <span>things?</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 246, 266.11, 0.0, 'things?', '', '', '<span>things?</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 247, 266.12, 0.0, 'things? &gt;&gt; I<00:04:26.240><c> think</c><00:04:26.440><c> it''s</c><00:04:26.560><c> a</c><00:04:26.600><c> mix</c><00:04:26.840><c> of</c><00:04:26.960><c> both.</c><00:04:27.280><c> I</c><00:04:27.320><c> definitely</c>', '', '', '<span>things?</span> <span>&gt;&gt;</span> <span>I<00:04:26.240><c></span> <span>think</c><00:04:26.440><c></span> <span>it''s</c><00:04:26.560><c></span> <span>a</c><00:04:26.600><c></span> <span>mix</c><00:04:26.840><c></span> <span>of</c><00:04:26.960><c></span> <span>both.</c><00:04:27.280><c></span> <span>I</c><00:04:27.320><c></span> <span>definitely</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 248, 267.63, 0.0, '&gt;&gt; I think it''s a mix of both. I definitely', '', '', '<span>&gt;&gt;</span> <span>I</span> <span>think</span> <span>it''s</span> <span>a</span> <span>mix</span> <span>of</span> <span>both.</span> <span>I</span> <span>definitely</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 249, 267.64, 0.0, '&gt;&gt; I think it''s a mix of both. I definitely think<00:04:27.919><c> when</c><00:04:28.640><c> Kiki</c><00:04:28.919><c> and</c><00:04:29.040><c> Gabby</c><00:04:29.400><c> and</c><00:04:29.520><c> their</c>', '', '', '<span>&gt;&gt;</span> <span>I</span> <span>think</span> <span>it''s</span> <span>a</span> <span>mix</span> <span>of</span> <span>both.</span> <span>I</span> <span>definitely</span> <span>think<00:04:27.919><c></span> <span>when</c><00:04:28.640><c></span> <span>Kiki</c><00:04:28.919><c></span> <span>and</c><00:04:29.040><c></span> <span>Gabby</c><00:04:29.400><c></span> <span>and</c><00:04:29.520><c></span> <span>their</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 250, 269.71, 0.0, 'think when Kiki and Gabby and their', '', '', '<span>think</span> <span>when</span> <span>Kiki</span> <span>and</span> <span>Gabby</span> <span>and</span> <span>their</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 251, 269.72, 0.0, 'think when Kiki and Gabby and their class<00:04:30.040><c> came</c><00:04:30.280><c> in</c><00:04:30.400><c> it</c><00:04:30.600><c> really</c><00:04:30.840><c> skyrocketed</c><00:04:31.680><c> and</c>', '', '', '<span>think</span> <span>when</span> <span>Kiki</span> <span>and</span> <span>Gabby</span> <span>and</span> <span>their</span> <span>class<00:04:30.040><c></span> <span>came</c><00:04:30.280><c></span> <span>in</c><00:04:30.400><c></span> <span>it</c><00:04:30.600><c></span> <span>really</c><00:04:30.840><c></span> <span>skyrocketed</c><00:04:31.680><c></span> <span>and</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 252, 271.79, 0.0, 'class came in it really skyrocketed and', '', '', '<span>class</span> <span>came</span> <span>in</span> <span>it</span> <span>really</span> <span>skyrocketed</span> <span>and</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 253, 271.8, 0.0, 'class came in it really skyrocketed and then<00:04:31.960><c> just</c><00:04:32.160><c> throughout</c><00:04:32.400><c> the</c><00:04:32.520><c> years</c><00:04:32.760><c> we''ve</c>', '', '', '<span>class</span> <span>came</span> <span>in</span> <span>it</span> <span>really</span> <span>skyrocketed</span> <span>and</span> <span>then<00:04:31.960><c></span> <span>just</c><00:04:32.160><c></span> <span>throughout</c><00:04:32.400><c></span> <span>the</c><00:04:32.520><c></span> <span>years</c><00:04:32.760><c></span> <span>we''ve</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 254, 272.87, 0.0, 'then just throughout the years we''ve', '', '', '<span>then</span> <span>just</span> <span>throughout</span> <span>the</span> <span>years</span> <span>we''ve</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 255, 272.88, 0.0, 'then just throughout the years we''ve gotten<00:04:33.160><c> better</c><00:04:33.520><c> so</c><00:04:33.640><c> then</c><00:04:33.800><c> that''s</c><00:04:34.040><c> how</c><00:04:34.120><c> we</c><00:04:34.240><c> get</c>', '', '', '<span>then</span> <span>just</span> <span>throughout</span> <span>the</span> <span>years</span> <span>we''ve</span> <span>gotten<00:04:33.160><c></span> <span>better</c><00:04:33.520><c></span> <span>so</c><00:04:33.640><c></span> <span>then</c><00:04:33.800><c></span> <span>that''s</c><00:04:34.040><c></span> <span>how</c><00:04:34.120><c></span> <span>we</c><00:04:34.240><c></span> <span>get</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 256, 274.43, 0.0, 'gotten better so then that''s how we get', '', '', '<span>gotten</span> <span>better</span> <span>so</span> <span>then</span> <span>that''s</span> <span>how</span> <span>we</span> <span>get</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 257, 274.44, 0.0, 'gotten better so then that''s how we get more<00:04:34.640><c> viewers.</c>', '', '', '<span>gotten</span> <span>better</span> <span>so</span> <span>then</span> <span>that''s</span> <span>how</span> <span>we</span> <span>get</span> <span>more<00:04:34.640><c></span> <span>viewers.</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 258, 275.35, 0.0, 'more viewers.', '', '', '<span>more</span> <span>viewers.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 259, 275.36, 0.0, 'more viewers. &gt;&gt; Yeah,<00:04:35.520><c> I</c><00:04:35.600><c> think</c><00:04:35.800><c> it''s</c><00:04:35.919><c> just</c><00:04:36.120><c> that</c><00:04:36.200><c> globally</c>', '', '', '<span>more</span> <span>viewers.</span> <span>&gt;&gt;</span> <span>Yeah,<00:04:35.520><c></span> <span>I</c><00:04:35.600><c></span> <span>think</c><00:04:35.800><c></span> <span>it''s</c><00:04:35.919><c></span> <span>just</c><00:04:36.120><c></span> <span>that</c><00:04:36.200><c></span> <span>globally</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 260, 276.67, 0.0, '&gt;&gt; Yeah, I think it''s just that globally', '', '', '<span>&gt;&gt;</span> <span>Yeah,</span> <span>I</span> <span>think</span> <span>it''s</span> <span>just</span> <span>that</span> <span>globally</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 261, 276.68, 0.0, '&gt;&gt; Yeah, I think it''s just that globally people<00:04:37.040><c> are</c><00:04:37.280><c> I</c><00:04:37.320><c> think</c><00:04:37.520><c> there''s</c><00:04:37.720><c> a</c><00:04:37.760><c> lot</c><00:04:38.080><c> of</c>', '', '', '<span>&gt;&gt;</span> <span>Yeah,</span> <span>I</span> <span>think</span> <span>it''s</span> <span>just</span> <span>that</span> <span>globally</span> <span>people<00:04:37.040><c></span> <span>are</c><00:04:37.280><c></span> <span>I</c><00:04:37.320><c></span> <span>think</c><00:04:37.520><c></span> <span>there''s</c><00:04:37.720><c></span> <span>a</c><00:04:37.760><c></span> <span>lot</c><00:04:38.080><c></span> <span>of</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 262, 278.23, 0.0, 'people are I think there''s a lot of', '', '', '<span>people</span> <span>are</span> <span>I</span> <span>think</span> <span>there''s</span> <span>a</span> <span>lot</span> <span>of</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 263, 278.24, 0.0, 'people are I think there''s a lot of things<00:04:38.520><c> that</c><00:04:38.640><c> factor</c><00:04:39.000><c> in.</c><00:04:39.120><c> It''s</c><00:04:39.320><c> corporate</c>', '', '', '<span>people</span> <span>are</span> <span>I</span> <span>think</span> <span>there''s</span> <span>a</span> <span>lot</span> <span>of</span> <span>things<00:04:38.520><c></span> <span>that</c><00:04:38.640><c></span> <span>factor</c><00:04:39.000><c></span> <span>in.</c><00:04:39.120><c></span> <span>It''s</c><00:04:39.320><c></span> <span>corporate</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 264, 279.67, 0.0, 'things that factor in. It''s corporate', '', '', '<span>things</span> <span>that</span> <span>factor</span> <span>in.</span> <span>It''s</span> <span>corporate</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 265, 279.68, 0.0, 'things that factor in. It''s corporate sponsorship,<00:04:40.760><c> it''s</c><00:04:41.000><c> viewership</c><00:04:41.640><c> on</c><00:04:41.919><c> TV</c><00:04:42.280><c> and</c>', '', '', '<span>things</span> <span>that</span> <span>factor</span> <span>in.</span> <span>It''s</span> <span>corporate</span> <span>sponsorship,<00:04:40.760><c></span> <span>it''s</c><00:04:41.000><c></span> <span>viewership</c><00:04:41.640><c></span> <span>on</c><00:04:41.919><c></span> <span>TV</c><00:04:42.280><c></span> <span>and</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 266, 282.39, 0.0, 'sponsorship, it''s viewership on TV and', '', '', '<span>sponsorship,</span> <span>it''s</span> <span>viewership</span> <span>on</span> <span>TV</span> <span>and</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 267, 282.4, 0.0, 'sponsorship, it''s viewership on TV and exposure.<00:04:43.200><c> You</c><00:04:43.280><c> know,</c><00:04:43.440><c> the</c><00:04:43.560><c> more</c><00:04:44.120><c> people</c><00:04:44.440><c> feel</c>', '', '', '<span>sponsorship,</span> <span>it''s</span> <span>viewership</span> <span>on</span> <span>TV</span> <span>and</span> <span>exposure.<00:04:43.200><c></span> <span>You</c><00:04:43.280><c></span> <span>know,</c><00:04:43.440><c></span> <span>the</c><00:04:43.560><c></span> <span>more</c><00:04:44.120><c></span> <span>people</c><00:04:44.440><c></span> <span>feel</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 268, 284.59, 0.0, 'exposure. You know, the more people feel', '', '', '<span>exposure.</span> <span>You</span> <span>know,</span> <span>the</span> <span>more</span> <span>people</span> <span>feel</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 269, 284.6, 0.0, 'exposure. You know, the more people feel like<00:04:44.840><c> they''ve</c><00:04:45.200><c> are</c><00:04:45.360><c> tied</c><00:04:45.720><c> to</c><00:04:45.840><c> their</c><00:04:46.000><c> journey,</c>', '', '', '<span>exposure.</span> <span>You</span> <span>know,</span> <span>the</span> <span>more</span> <span>people</span> <span>feel</span> <span>like<00:04:44.840><c></span> <span>they''ve</c><00:04:45.200><c></span> <span>are</c><00:04:45.360><c></span> <span>tied</c><00:04:45.720><c></span> <span>to</c><00:04:45.840><c></span> <span>their</c><00:04:46.000><c></span> <span>journey,</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 270, 286.35, 0.0, 'like they''ve are tied to their journey,', '', '', '<span>like</span> <span>they''ve</span> <span>are</span> <span>tied</span> <span>to</span> <span>their</span> <span>journey,</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 271, 286.36, 0.0, 'like they''ve are tied to their journey, the<00:04:46.480><c> more</c><00:04:46.640><c> they</c><00:04:46.760><c> want</c><00:04:46.919><c> to</c><00:04:47.000><c> go</c><00:04:47.200><c> and</c><00:04:47.320><c> show</c><00:04:47.520><c> up</c><00:04:47.640><c> for</c>', '', '', '<span>like</span> <span>they''ve</span> <span>are</span> <span>tied</span> <span>to</span> <span>their</span> <span>journey,</span> <span>the<00:04:46.480><c></span> <span>more</c><00:04:46.640><c></span> <span>they</c><00:04:46.760><c></span> <span>want</c><00:04:46.919><c></span> <span>to</c><00:04:47.000><c></span> <span>go</c><00:04:47.200><c></span> <span>and</c><00:04:47.320><c></span> <span>show</c><00:04:47.520><c></span> <span>up</c><00:04:47.640><c></span> <span>for</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 272, 287.75, 0.0, 'the more they want to go and show up for', '', '', '<span>the</span> <span>more</span> <span>they</span> <span>want</span> <span>to</span> <span>go</span> <span>and</span> <span>show</span> <span>up</span> <span>for</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 273, 287.76, 0.0, 'the more they want to go and show up for them<00:04:48.040><c> and</c><00:04:48.120><c> then</c><00:04:48.240><c> the</c><00:04:48.360><c> whole</c><00:04:48.480><c> byproduct</c><00:04:49.080><c> of</c>', '', '', '<span>the</span> <span>more</span> <span>they</span> <span>want</span> <span>to</span> <span>go</span> <span>and</span> <span>show</span> <span>up</span> <span>for</span> <span>them<00:04:48.040><c></span> <span>and</c><00:04:48.120><c></span> <span>then</c><00:04:48.240><c></span> <span>the</c><00:04:48.360><c></span> <span>whole</c><00:04:48.480><c></span> <span>byproduct</c><00:04:49.080><c></span> <span>of</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 274, 289.15, 0.0, 'them and then the whole byproduct of', '', '', '<span>them</span> <span>and</span> <span>then</span> <span>the</span> <span>whole</span> <span>byproduct</span> <span>of</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 275, 289.16, 0.0, 'them and then the whole byproduct of that<00:04:49.320><c> is</c><00:04:49.440><c> attendance</c><00:04:50.000><c> I</c><00:04:50.080><c> think.</c><00:04:50.400><c> But,</c><00:04:50.919><c> you</c>', '', '', '<span>them</span> <span>and</span> <span>then</span> <span>the</span> <span>whole</span> <span>byproduct</span> <span>of</span> <span>that<00:04:49.320><c></span> <span>is</c><00:04:49.440><c></span> <span>attendance</c><00:04:50.000><c></span> <span>I</c><00:04:50.080><c></span> <span>think.</c><00:04:50.400><c></span> <span>But,</c><00:04:50.919><c></span> <span>you</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 276, 291.03, 0.0, 'that is attendance I think. But, you', '', '', '<span>that</span> <span>is</span> <span>attendance</span> <span>I</span> <span>think.</span> <span>But,</span> <span>you</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 277, 291.04, 0.0, 'that is attendance I think. But, you know,<00:04:51.160><c> we</c><00:04:51.280><c> got</c><00:04:51.440><c> to</c><00:04:51.520><c> keep</c><00:04:51.760><c> our</c><00:04:52.040><c> the</c><00:04:52.160><c> pedal</c><00:04:52.440><c> to</c>', '', '', '<span>that</span> <span>is</span> <span>attendance</span> <span>I</span> <span>think.</span> <span>But,</span> <span>you</span> <span>know,<00:04:51.160><c></span> <span>we</c><00:04:51.280><c></span> <span>got</c><00:04:51.440><c></span> <span>to</c><00:04:51.520><c></span> <span>keep</c><00:04:51.760><c></span> <span>our</c><00:04:52.040><c></span> <span>the</c><00:04:52.160><c></span> <span>pedal</c><00:04:52.440><c></span> <span>to</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 278, 292.51, 0.0, 'know, we got to keep our the pedal to', '', '', '<span>know,</span> <span>we</span> <span>got</span> <span>to</span> <span>keep</span> <span>our</span> <span>the</span> <span>pedal</span> <span>to</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 279, 292.52, 0.0, 'know, we got to keep our the pedal to the<00:04:52.600><c> metal</c><00:04:52.880><c> because</c><00:04:53.880><c> you</c><00:04:54.000><c> know,</c><00:04:54.120><c> I</c><00:04:54.160><c> think</c>', '', '', '<span>know,</span> <span>we</span> <span>got</span> <span>to</span> <span>keep</span> <span>our</span> <span>the</span> <span>pedal</span> <span>to</span> <span>the<00:04:52.600><c></span> <span>metal</c><00:04:52.880><c></span> <span>because</c><00:04:53.880><c></span> <span>you</c><00:04:54.000><c></span> <span>know,</c><00:04:54.120><c></span> <span>I</c><00:04:54.160><c></span> <span>think</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 280, 294.35, 0.0, 'the metal because you know, I think', '', '', '<span>the</span> <span>metal</span> <span>because</span> <span>you</span> <span>know,</span> <span>I</span> <span>think</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 281, 294.36, 0.0, 'the metal because you know, I think there', '', '', '<span>the</span> <span>metal</span> <span>because</span> <span>you</span> <span>know,</span> <span>I</span> <span>think</span> <span>there</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 282, 295.03, 0.0, 'there', '', '', '<span>there</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 283, 295.04, 0.0, 'there I<00:04:55.120><c> almost</c><00:04:55.400><c> said</c><00:04:55.520><c> it</c><00:04:55.600><c> again.</c>', '', '', '<span>there</span> <span>I<00:04:55.120><c></span> <span>almost</c><00:04:55.400><c></span> <span>said</c><00:04:55.520><c></span> <span>it</c><00:04:55.600><c></span> <span>again.</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 284, 296.67, 0.0, 'I almost said it again.', '', '', '<span>I</span> <span>almost</span> <span>said</span> <span>it</span> <span>again.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 285, 296.68, 0.0, 'I almost said it again. You<00:04:56.800><c> know,</c><00:04:57.000><c> I</c><00:04:57.080><c> think</c><00:04:57.360><c> that</c><00:04:57.600><c> we</c><00:04:57.840><c> are</c><00:04:58.000><c> just</c><00:04:58.600><c> as</c>', '', '', '<span>I</span> <span>almost</span> <span>said</span> <span>it</span> <span>again.</span> <span>You<00:04:56.800><c></span> <span>know,</c><00:04:57.000><c></span> <span>I</c><00:04:57.080><c></span> <span>think</c><00:04:57.360><c></span> <span>that</c><00:04:57.600><c></span> <span>we</c><00:04:57.840><c></span> <span>are</c><00:04:58.000><c></span> <span>just</c><00:04:58.600><c></span> <span>as</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 286, 298.75, 0.0, 'You know, I think that we are just as', '', '', '<span>You</span> <span>know,</span> <span>I</span> <span>think</span> <span>that</span> <span>we</span> <span>are</span> <span>just</span> <span>as</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 287, 298.76, 0.0, 'You know, I think that we are just as much<00:04:59.000><c> as</c><00:04:59.120><c> we''ve</c><00:04:59.280><c> experienced</c><00:04:59.919><c> in</c><00:05:00.000><c> the</c><00:05:00.080><c> last</c><00:05:00.360><c> 4</c>', '', '', '<span>You</span> <span>know,</span> <span>I</span> <span>think</span> <span>that</span> <span>we</span> <span>are</span> <span>just</span> <span>as</span> <span>much<00:04:59.000><c></span> <span>as</c><00:04:59.120><c></span> <span>we''ve</c><00:04:59.280><c></span> <span>experienced</c><00:04:59.919><c></span> <span>in</c><00:05:00.000><c></span> <span>the</c><00:05:00.080><c></span> <span>last</c><00:05:00.360><c></span> <span>4</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 288, 300.55, 0.0, 'much as we''ve experienced in the last 4', '', '', '<span>much</span> <span>as</span> <span>we''ve</span> <span>experienced</span> <span>in</span> <span>the</span> <span>last</span> <span>4</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 289, 300.56, 0.0, 'much as we''ve experienced in the last 4 years<00:05:00.880><c> we</c><00:05:00.960><c> still</c><00:05:01.160><c> got</c><00:05:01.280><c> a</c><00:05:01.320><c> lot</c><00:05:01.480><c> of</c><00:05:01.560><c> work</c><00:05:01.720><c> to</c><00:05:01.840><c> do.</c>', '', '', '<span>much</span> <span>as</span> <span>we''ve</span> <span>experienced</span> <span>in</span> <span>the</span> <span>last</span> <span>4</span> <span>years<00:05:00.880><c></span> <span>we</c><00:05:00.960><c></span> <span>still</c><00:05:01.160><c></span> <span>got</c><00:05:01.280><c></span> <span>a</c><00:05:01.320><c></span> <span>lot</c><00:05:01.480><c></span> <span>of</c><00:05:01.560><c></span> <span>work</c><00:05:01.720><c></span> <span>to</c><00:05:01.840><c></span> <span>do.</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 290, 302.43, 0.0, 'years we still got a lot of work to do.', '', '', '<span>years</span> <span>we</span> <span>still</span> <span>got</span> <span>a</span> <span>lot</span> <span>of</span> <span>work</span> <span>to</span> <span>do.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 291, 302.44, 0.0, 'years we still got a lot of work to do. &gt;&gt; Well,<00:05:02.640><c> you</c><00:05:02.760><c> they</c><00:05:02.960><c> don''t</c><00:05:03.280><c> cuz</c><00:05:03.480><c> they''re</c>', '', '', '<span>years</span> <span>we</span> <span>still</span> <span>got</span> <span>a</span> <span>lot</span> <span>of</span> <span>work</span> <span>to</span> <span>do.</span> <span>&gt;&gt;</span> <span>Well,<00:05:02.640><c></span> <span>you</c><00:05:02.760><c></span> <span>they</c><00:05:02.960><c></span> <span>don''t</c><00:05:03.280><c></span> <span>cuz</c><00:05:03.480><c></span> <span>they''re</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 292, 303.63, 0.0, '&gt;&gt; Well, you they don''t cuz they''re', '', '', '<span>&gt;&gt;</span> <span>Well,</span> <span>you</span> <span>they</span> <span>don''t</span> <span>cuz</span> <span>they''re</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 293, 303.64, 0.0, '&gt;&gt; Well, you they don''t cuz they''re leaving.', '', '', '<span>&gt;&gt;</span> <span>Well,</span> <span>you</span> <span>they</span> <span>don''t</span> <span>cuz</span> <span>they''re</span> <span>leaving.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 294, 304.07, 0.0, 'leaving.', '', '', '<span>leaving.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 295, 304.08, 0.0, 'leaving. &gt;&gt; Yeah,<00:05:04.280><c> I</c><00:05:04.320><c> know.</c>', '', '', '<span>leaving.</span> <span>&gt;&gt;</span> <span>Yeah,<00:05:04.280><c></span> <span>I</c><00:05:04.320><c></span> <span>know.</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 296, 305.03, 0.0, '&gt;&gt; Yeah, I know.', '', '', '<span>&gt;&gt;</span> <span>Yeah,</span> <span>I</span> <span>know.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 297, 305.04, 0.0, '&gt;&gt; Yeah, I know. Thanks<00:05:05.320><c> a</c><00:05:05.360><c> lot,</c><00:05:05.640><c> rub</c><00:05:05.880><c> it</c><00:05:05.960><c> in.</c><00:05:06.320><c> Rub</c><00:05:06.480><c> it</c><00:05:06.600><c> in.</c>', '', '', '<span>&gt;&gt;</span> <span>Yeah,</span> <span>I</span> <span>know.</span> <span>Thanks<00:05:05.320><c></span> <span>a</c><00:05:05.360><c></span> <span>lot,</c><00:05:05.640><c></span> <span>rub</c><00:05:05.880><c></span> <span>it</c><00:05:05.960><c></span> <span>in.</c><00:05:06.320><c></span> <span>Rub</c><00:05:06.480><c></span> <span>it</c><00:05:06.600><c></span> <span>in.</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 298, 307.55, 0.0, 'Thanks a lot, rub it in. Rub it in.', '', '', '<span>Thanks</span> <span>a</span> <span>lot,</span> <span>rub</span> <span>it</span> <span>in.</span> <span>Rub</span> <span>it</span> <span>in.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 299, 307.56, 0.0, 'Thanks a lot, rub it in. Rub it in. You<00:05:07.640><c> know,</c><00:05:07.720><c> there''s</c><00:05:07.960><c> six</c><00:05:08.280><c> of</c><00:05:08.400><c> them.</c>', '', '', '<span>Thanks</span> <span>a</span> <span>lot,</span> <span>rub</span> <span>it</span> <span>in.</span> <span>Rub</span> <span>it</span> <span>in.</span> <span>You<00:05:07.640><c></span> <span>know,</c><00:05:07.720><c></span> <span>there''s</c><00:05:07.960><c></span> <span>six</c><00:05:08.280><c></span> <span>of</c><00:05:08.400><c></span> <span>them.</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 300, 308.75, 0.0, 'You know, there''s six of them.', '', '', '<span>You</span> <span>know,</span> <span>there''s</span> <span>six</span> <span>of</span> <span>them.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 301, 308.76, 0.0, 'You know, there''s six of them. &gt;&gt; your<00:05:08.919><c> pedal</c><00:05:09.240><c> to</c><00:05:09.360><c> the</c><00:05:09.480><c> metal,</c><00:05:09.800><c> right?</c>', '', '', '<span>You</span> <span>know,</span> <span>there''s</span> <span>six</span> <span>of</span> <span>them.</span> <span>&gt;&gt;</span> <span>your<00:05:08.919><c></span> <span>pedal</c><00:05:09.240><c></span> <span>to</c><00:05:09.360><c></span> <span>the</c><00:05:09.480><c></span> <span>metal,</c><00:05:09.800><c></span> <span>right?</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 302, 309.87, 0.0, '&gt;&gt; your pedal to the metal, right?', '', '', '<span>&gt;&gt;</span> <span>your</span> <span>pedal</span> <span>to</span> <span>the</span> <span>metal,</span> <span>right?</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 303, 309.88, 0.0, '&gt;&gt; your pedal to the metal, right? &gt;&gt; Yeah,<00:05:10.000><c> exactly.</c><00:05:11.000><c> They''re</c><00:05:11.160><c> just</c><00:05:11.360><c> going</c><00:05:11.560><c> back</c>', '', '', '<span>&gt;&gt;</span> <span>your</span> <span>pedal</span> <span>to</span> <span>the</span> <span>metal,</span> <span>right?</span> <span>&gt;&gt;</span> <span>Yeah,<00:05:10.000><c></span> <span>exactly.</c><00:05:11.000><c></span> <span>They''re</c><00:05:11.160><c></span> <span>just</c><00:05:11.360><c></span> <span>going</c><00:05:11.560><c></span> <span>back</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 304, 311.75, 0.0, '&gt;&gt; Yeah, exactly. They''re just going back', '', '', '<span>&gt;&gt;</span> <span>Yeah,</span> <span>exactly.</span> <span>They''re</span> <span>just</span> <span>going</span> <span>back</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 305, 311.76, 0.0, '&gt;&gt; Yeah, exactly. They''re just going back to<00:05:11.880><c> Rock</c><00:05:12.080><c> Nation.</c><00:05:12.640><c> You</c><00:05:12.720><c> know.</c>', '', '', '<span>&gt;&gt;</span> <span>Yeah,</span> <span>exactly.</span> <span>They''re</span> <span>just</span> <span>going</span> <span>back</span> <span>to<00:05:11.880><c></span> <span>Rock</c><00:05:12.080><c></span> <span>Nation.</c><00:05:12.640><c></span> <span>You</c><00:05:12.720><c></span> <span>know.</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 306, 313.51, 0.0, 'to Rock Nation. You know.', '', '', '<span>to</span> <span>Rock</span> <span>Nation.</span> <span>You</span> <span>know.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 307, 313.52, 0.0, 'to Rock Nation. You know. &gt;&gt; Well,<00:05:13.840><c> all</c><00:05:14.520><c> most</c><00:05:14.840><c> likely</c><00:05:15.240><c> get</c><00:05:15.640><c> drafted</c><00:05:16.520><c> by</c><00:05:16.640><c> the</c>', '', '', '<span>to</span> <span>Rock</span> <span>Nation.</span> <span>You</span> <span>know.</span> <span>&gt;&gt;</span> <span>Well,<00:05:13.840><c></span> <span>all</c><00:05:14.520><c></span> <span>most</c><00:05:14.840><c></span> <span>likely</c><00:05:15.240><c></span> <span>get</c><00:05:15.640><c></span> <span>drafted</c><00:05:16.520><c></span> <span>by</c><00:05:16.640><c></span> <span>the</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 308, 316.79, 0.0, '&gt;&gt; Well, all most likely get drafted by the', '', '', '<span>&gt;&gt;</span> <span>Well,</span> <span>all</span> <span>most</span> <span>likely</span> <span>get</span> <span>drafted</span> <span>by</span> <span>the</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 309, 316.8, 0.0, '&gt;&gt; Well, all most likely get drafted by the WNBA<00:05:17.760><c> and</c><00:05:17.960><c> then</c><00:05:18.120><c> you</c><00:05:18.240><c> will</c><00:05:18.360><c> be</c><00:05:18.520><c> on</c><00:05:19.200><c> maybe</c>', '', '', '<span>&gt;&gt;</span> <span>Well,</span> <span>all</span> <span>most</span> <span>likely</span> <span>get</span> <span>drafted</span> <span>by</span> <span>the</span> <span>WNBA<00:05:17.760><c></span> <span>and</c><00:05:17.960><c></span> <span>then</c><00:05:18.120><c></span> <span>you</c><00:05:18.240><c></span> <span>will</c><00:05:18.360><c></span> <span>be</c><00:05:18.520><c></span> <span>on</c><00:05:19.200><c></span> <span>maybe</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 310, 319.55, 0.0, 'WNBA and then you will be on maybe', '', '', '<span>WNBA</span> <span>and</span> <span>then</span> <span>you</span> <span>will</span> <span>be</span> <span>on</span> <span>maybe</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 311, 319.56, 0.0, 'WNBA and then you will be on maybe probably<00:05:20.280><c> different</c><00:05:20.760><c> teams</c><00:05:21.160><c> playing</c><00:05:21.520><c> against</c>', '', '', '<span>WNBA</span> <span>and</span> <span>then</span> <span>you</span> <span>will</span> <span>be</span> <span>on</span> <span>maybe</span> <span>probably<00:05:20.280><c></span> <span>different</c><00:05:20.760><c></span> <span>teams</c><00:05:21.160><c></span> <span>playing</c><00:05:21.520><c></span> <span>against</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 312, 322.15, 0.0, 'probably different teams playing against', '', '', '<span>probably</span> <span>different</span> <span>teams</span> <span>playing</span> <span>against</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 313, 322.16, 0.0, 'probably different teams playing against each<00:05:22.400><c> other.</c><00:05:23.000><c> Will</c><00:05:23.160><c> that</c><00:05:23.400><c> be</c><00:05:23.640><c> hard</c><00:05:24.040><c> for</c><00:05:24.320><c> you</c>', '', '', '<span>probably</span> <span>different</span> <span>teams</span> <span>playing</span> <span>against</span> <span>each<00:05:22.400><c></span> <span>other.</c><00:05:23.000><c></span> <span>Will</c><00:05:23.160><c></span> <span>that</c><00:05:23.400><c></span> <span>be</c><00:05:23.640><c></span> <span>hard</c><00:05:24.040><c></span> <span>for</c><00:05:24.320><c></span> <span>you</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 314, 324.59, 0.0, 'each other. Will that be hard for you', '', '', '<span>each</span> <span>other.</span> <span>Will</span> <span>that</span> <span>be</span> <span>hard</span> <span>for</span> <span>you</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 315, 324.6, 0.0, 'each other. Will that be hard for you after<00:05:25.400><c> going</c><00:05:25.680><c> through</c><00:05:25.840><c> so</c><00:05:26.000><c> much</c><00:05:26.320><c> as</c><00:05:26.440><c> a</c><00:05:26.520><c> team?</c>', '', '', '<span>each</span> <span>other.</span> <span>Will</span> <span>that</span> <span>be</span> <span>hard</span> <span>for</span> <span>you</span> <span>after<00:05:25.400><c></span> <span>going</c><00:05:25.680><c></span> <span>through</c><00:05:25.840><c></span> <span>so</c><00:05:26.000><c></span> <span>much</c><00:05:26.320><c></span> <span>as</c><00:05:26.440><c></span> <span>a</c><00:05:26.520><c></span> <span>team?</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 316, 327.11, 0.0, 'after going through so much as a team?', '', '', '<span>after</span> <span>going</span> <span>through</span> <span>so</span> <span>much</span> <span>as</span> <span>a</span> <span>team?</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 317, 327.12, 0.0, 'after going through so much as a team? &gt;&gt; Nah,<00:05:27.400><c> I</c><00:05:27.440><c> think</c><00:05:27.680><c> it''ll</c><00:05:27.840><c> be</c><00:05:27.960><c> fine.</c>', '', '', '<span>after</span> <span>going</span> <span>through</span> <span>so</span> <span>much</span> <span>as</span> <span>a</span> <span>team?</span> <span>&gt;&gt;</span> <span>Nah,<00:05:27.400><c></span> <span>I</c><00:05:27.440><c></span> <span>think</c><00:05:27.680><c></span> <span>it''ll</c><00:05:27.840><c></span> <span>be</c><00:05:27.960><c></span> <span>fine.</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 318, 330.03, 0.0, '&gt;&gt; Nah, I think it''ll be fine.', '', '', '<span>&gt;&gt;</span> <span>Nah,</span> <span>I</span> <span>think</span> <span>it''ll</span> <span>be</span> <span>fine.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 319, 330.04, 0.0, '&gt;&gt; Nah, I think it''ll be fine. There''s<00:05:30.240><c> going</c><00:05:30.360><c> to</c><00:05:30.440><c> be</c><00:05:30.560><c> lots</c><00:05:31.080><c> of</c><00:05:31.200><c> talking</c><00:05:31.600><c> to</c>', '', '', '<span>&gt;&gt;</span> <span>Nah,</span> <span>I</span> <span>think</span> <span>it''ll</span> <span>be</span> <span>fine.</span> <span>There''s<00:05:30.240><c></span> <span>going</c><00:05:30.360><c></span> <span>to</c><00:05:30.440><c></span> <span>be</c><00:05:30.560><c></span> <span>lots</c><00:05:31.080><c></span> <span>of</c><00:05:31.200><c></span> <span>talking</c><00:05:31.600><c></span> <span>to</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 320, 331.71, 0.0, 'There''s going to be lots of talking to', '', '', '<span>There''s</span> <span>going</span> <span>to</span> <span>be</span> <span>lots</span> <span>of</span> <span>talking</span> <span>to</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 321, 331.72, 0.0, 'There''s going to be lots of talking to each<00:05:31.880><c> other</c><00:05:32.080><c> throughout</c><00:05:32.400><c> the</c><00:05:32.520><c> game.</c><00:05:32.840><c> It''s</c>', '', '', '<span>There''s</span> <span>going</span> <span>to</span> <span>be</span> <span>lots</span> <span>of</span> <span>talking</span> <span>to</span> <span>each<00:05:31.880><c></span> <span>other</c><00:05:32.080><c></span> <span>throughout</c><00:05:32.400><c></span> <span>the</c><00:05:32.520><c></span> <span>game.</c><00:05:32.840><c></span> <span>It''s</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 322, 332.95, 0.0, 'each other throughout the game. It''s', '', '', '<span>each</span> <span>other</span> <span>throughout</span> <span>the</span> <span>game.</span> <span>It''s</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 323, 332.96, 0.0, 'each other throughout the game. It''s going<00:05:33.080><c> to</c><00:05:33.160><c> be</c><00:05:33.240><c> really</c><00:05:33.560><c> cool.</c>', '', '', '<span>each</span> <span>other</span> <span>throughout</span> <span>the</span> <span>game.</span> <span>It''s</span> <span>going<00:05:33.080><c></span> <span>to</c><00:05:33.160><c></span> <span>be</c><00:05:33.240><c></span> <span>really</c><00:05:33.560><c></span> <span>cool.</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 324, 334.11, 0.0, 'going to be really cool.', '', '', '<span>going</span> <span>to</span> <span>be</span> <span>really</span> <span>cool.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 325, 334.12, 0.0, 'going to be really cool. &gt;&gt; Well,<00:05:34.400><c> I</c><00:05:34.480><c> have</c><00:05:34.640><c> to</c><00:05:34.760><c> brag</c><00:05:35.040><c> on</c><00:05:35.120><c> them</c><00:05:35.280><c> real</c><00:05:35.440><c> quick</c>', '', '', '<span>going</span> <span>to</span> <span>be</span> <span>really</span> <span>cool.</span> <span>&gt;&gt;</span> <span>Well,<00:05:34.400><c></span> <span>I</c><00:05:34.480><c></span> <span>have</c><00:05:34.640><c></span> <span>to</c><00:05:34.760><c></span> <span>brag</c><00:05:35.040><c></span> <span>on</c><00:05:35.120><c></span> <span>them</c><00:05:35.280><c></span> <span>real</c><00:05:35.440><c></span> <span>quick</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 326, 335.79, 0.0, '&gt;&gt; Well, I have to brag on them real quick', '', '', '<span>&gt;&gt;</span> <span>Well,</span> <span>I</span> <span>have</span> <span>to</span> <span>brag</span> <span>on</span> <span>them</span> <span>real</span> <span>quick</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 327, 335.8, 0.0, '&gt;&gt; Well, I have to brag on them real quick because', '', '', '<span>&gt;&gt;</span> <span>Well,</span> <span>I</span> <span>have</span> <span>to</span> <span>brag</span> <span>on</span> <span>them</span> <span>real</span> <span>quick</span> <span>because</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 328, 336.95, 0.0, 'because', '', '', '<span>because</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 329, 336.96, 0.0, 'because this<00:05:37.480><c> they</c><00:05:37.640><c> will</c><00:05:37.800><c> set</c><00:05:38.040><c> a</c><00:05:38.080><c> record</c><00:05:38.560><c> for</c><00:05:38.680><c> the</c><00:05:38.840><c> most</c>', '', '', '<span>because</span> <span>this<00:05:37.480><c></span> <span>they</c><00:05:37.640><c></span> <span>will</c><00:05:37.800><c></span> <span>set</c><00:05:38.040><c></span> <span>a</c><00:05:38.080><c></span> <span>record</c><00:05:38.560><c></span> <span>for</c><00:05:38.680><c></span> <span>the</c><00:05:38.840><c></span> <span>most</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 330, 339.23, 0.0, 'this they will set a record for the most', '', '', '<span>this</span> <span>they</span> <span>will</span> <span>set</span> <span>a</span> <span>record</span> <span>for</span> <span>the</span> <span>most</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 331, 339.24, 0.0, 'this they will set a record for the most players<00:05:39.800><c> ever</c><00:05:40.080><c> drafted</c><00:05:40.680><c> from</c><00:05:40.880><c> one</c><00:05:41.080><c> school</c><00:05:41.400><c> in</c>', '', '', '<span>this</span> <span>they</span> <span>will</span> <span>set</span> <span>a</span> <span>record</span> <span>for</span> <span>the</span> <span>most</span> <span>players<00:05:39.800><c></span> <span>ever</c><00:05:40.080><c></span> <span>drafted</c><00:05:40.680><c></span> <span>from</c><00:05:40.880><c></span> <span>one</c><00:05:41.080><c></span> <span>school</c><00:05:41.400><c></span> <span>in</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 332, 341.51, 0.0, 'players ever drafted from one school in', '', '', '<span>players</span> <span>ever</span> <span>drafted</span> <span>from</span> <span>one</span> <span>school</span> <span>in</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 333, 341.52, 0.0, 'players ever drafted from one school in one<00:05:41.720><c> class</c><00:05:42.240><c> ever</c><00:05:42.520><c> TO</c><00:05:42.640><c> THE</c><00:05:42.720><c> WNBA.</c>', '', '', '<span>players</span> <span>ever</span> <span>drafted</span> <span>from</span> <span>one</span> <span>school</span> <span>in</span> <span>one<00:05:41.720><c></span> <span>class</c><00:05:42.240><c></span> <span>ever</c><00:05:42.520><c></span> <span>TO</c><00:05:42.640><c></span> <span>THE</c><00:05:42.720><c></span> <span>WNBA.</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 334, 349.87, 0.0, '&gt;&gt; YEAH, THAT''S PRETTY CRAZY.', '', '', '<span>&gt;&gt;</span> <span>YEAH,</span> <span>THAT''S</span> <span>PRETTY</span> <span>CRAZY.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 335, 349.88, 0.0, '&gt;&gt; YEAH, THAT''S PRETTY CRAZY. &gt;&gt; So', '', '', '<span>&gt;&gt;</span> <span>YEAH,</span> <span>THAT''S</span> <span>PRETTY</span> <span>CRAZY.</span> <span>&gt;&gt;</span> <span>So</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 336, 350.91, 0.0, '&gt;&gt; So', '', '', '<span>&gt;&gt;</span> <span>So</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 337, 350.92, 0.0, '&gt;&gt; So you''re<00:05:51.080><c> not</c><00:05:51.240><c> allowed</c><00:05:51.680><c> to</c><00:05:52.040><c> be</c><00:05:52.240><c> in</c><00:05:52.400><c> a</c><00:05:52.680><c> like</c><00:05:52.880><c> a</c>', '', '', '<span>&gt;&gt;</span> <span>So</span> <span>you''re<00:05:51.080><c></span> <span>not</c><00:05:51.240><c></span> <span>allowed</c><00:05:51.680><c></span> <span>to</c><00:05:52.040><c></span> <span>be</c><00:05:52.240><c></span> <span>in</c><00:05:52.400><c></span> <span>a</c><00:05:52.680><c></span> <span>like</c><00:05:52.880><c></span> <span>a</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 338, 352.91, 0.0, 'you''re not allowed to be in a like a', '', '', '<span>you''re</span> <span>not</span> <span>allowed</span> <span>to</span> <span>be</span> <span>in</span> <span>a</span> <span>like</span> <span>a</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 339, 352.92, 0.0, 'you''re not allowed to be in a like a tournament<00:05:53.440><c> pool,</c><00:05:53.680><c> right?</c><00:05:53.880><c> That''s</c><00:05:54.080><c> against</c>', '', '', '<span>you''re</span> <span>not</span> <span>allowed</span> <span>to</span> <span>be</span> <span>in</span> <span>a</span> <span>like</span> <span>a</span> <span>tournament<00:05:53.440><c></span> <span>pool,</c><00:05:53.680><c></span> <span>right?</c><00:05:53.880><c></span> <span>That''s</c><00:05:54.080><c></span> <span>against</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 340, 354.39, 0.0, 'tournament pool, right? That''s against', '', '', '<span>tournament</span> <span>pool,</span> <span>right?</span> <span>That''s</span> <span>against</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 341, 354.4, 0.0, 'tournament pool, right? That''s against the<00:05:54.480><c> rules.</c><00:05:54.800><c> You''re</c><00:05:54.880><c> not</c><00:05:55.000><c> allowed</c><00:05:55.280><c> to</c><00:05:55.360><c> pick</c><00:05:55.680><c> a</c>', '', '', '<span>tournament</span> <span>pool,</span> <span>right?</span> <span>That''s</span> <span>against</span> <span>the<00:05:54.480><c></span> <span>rules.</c><00:05:54.800><c></span> <span>You''re</c><00:05:54.880><c></span> <span>not</c><00:05:55.000><c></span> <span>allowed</c><00:05:55.280><c></span> <span>to</c><00:05:55.360><c></span> <span>pick</c><00:05:55.680><c></span> <span>a</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 342, 356.39, 0.0, 'the rules. You''re not allowed to pick a', '', '', '<span>the</span> <span>rules.</span> <span>You''re</span> <span>not</span> <span>allowed</span> <span>to</span> <span>pick</span> <span>a</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 343, 356.4, 0.0, 'the rules. You''re not allowed to pick a bracket.', '', '', '<span>the</span> <span>rules.</span> <span>You''re</span> <span>not</span> <span>allowed</span> <span>to</span> <span>pick</span> <span>a</span> <span>bracket.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 344, 358.31, 0.0, 'bracket.', '', '', '<span>bracket.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 345, 358.32, 0.0, 'bracket. Can''t<00:05:58.520><c> do</c><00:05:58.600><c> that.</c>', '', '', '<span>bracket.</span> <span>Can''t<00:05:58.520><c></span> <span>do</c><00:05:58.600><c></span> <span>that.</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 346, 359.07, 0.0, 'Can''t do that.', '', '', '<span>Can''t</span> <span>do</span> <span>that.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 347, 359.08, 0.0, 'Can''t do that. &gt;&gt; Yeah.', '', '', '<span>Can''t</span> <span>do</span> <span>that.</span> <span>&gt;&gt;</span> <span>Yeah.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 348, 359.55, 0.0, '&gt;&gt; Yeah.', '', '', '<span>&gt;&gt;</span> <span>Yeah.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 349, 359.56, 0.0, '&gt;&gt; Yeah. &gt;&gt; Did<00:06:00.280><c> anyone</c><00:06:00.720><c> you</c><00:06:00.880><c> know</c><00:06:01.120><c> anyone</c><00:06:01.440><c> in</c><00:06:01.520><c> your</c><00:06:01.680><c> lives</c>', '', '', '<span>&gt;&gt;</span> <span>Yeah.</span> <span>&gt;&gt;</span> <span>Did<00:06:00.280><c></span> <span>anyone</c><00:06:00.720><c></span> <span>you</c><00:06:00.880><c></span> <span>know</c><00:06:01.120><c></span> <span>anyone</c><00:06:01.440><c></span> <span>in</c><00:06:01.520><c></span> <span>your</c><00:06:01.680><c></span> <span>lives</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 350, 362.23, 0.0, '&gt;&gt; Did anyone you know anyone in your lives', '', '', '<span>&gt;&gt;</span> <span>Did</span> <span>anyone</span> <span>you</span> <span>know</span> <span>anyone</span> <span>in</span> <span>your</span> <span>lives</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 351, 362.24, 0.0, '&gt;&gt; Did anyone you know anyone in your lives bet<00:06:02.480><c> against</c><00:06:02.920><c> you</c><00:06:03.000><c> guys</c><00:06:03.280><c> pick</c><00:06:03.520><c> somebody</c><00:06:03.920><c> else?</c>', '', '', '<span>&gt;&gt;</span> <span>Did</span> <span>anyone</span> <span>you</span> <span>know</span> <span>anyone</span> <span>in</span> <span>your</span> <span>lives</span> <span>bet<00:06:02.480><c></span> <span>against</c><00:06:02.920><c></span> <span>you</c><00:06:03.000><c></span> <span>guys</c><00:06:03.280><c></span> <span>pick</c><00:06:03.520><c></span> <span>somebody</c><00:06:03.920><c></span> <span>else?</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 352, 364.63, 0.0, 'bet against you guys pick somebody else?', '', '', '<span>bet</span> <span>against</span> <span>you</span> <span>guys</span> <span>pick</span> <span>somebody</span> <span>else?</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 353, 364.64, 0.0, 'bet against you guys pick somebody else? &gt;&gt; They<00:06:04.840><c> knew</c><00:06:05.080><c> that</c><00:06:05.280><c> would</c><00:06:05.400><c> be</c><00:06:05.520><c> bad.</c>', '', '', '<span>bet</span> <span>against</span> <span>you</span> <span>guys</span> <span>pick</span> <span>somebody</span> <span>else?</span> <span>&gt;&gt;</span> <span>They<00:06:04.840><c></span> <span>knew</c><00:06:05.080><c></span> <span>that</c><00:06:05.280><c></span> <span>would</c><00:06:05.400><c></span> <span>be</c><00:06:05.520><c></span> <span>bad.</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 354, 365.91, 0.0, '&gt;&gt; They knew that would be bad.', '', '', '<span>&gt;&gt;</span> <span>They</span> <span>knew</span> <span>that</span> <span>would</span> <span>be</span> <span>bad.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 355, 365.92, 0.0, '&gt;&gt; They knew that would be bad. &gt;&gt; All<00:06:06.240><c> of</c><00:06:06.360><c> ESPN,</c><00:06:07.080><c> all</c><00:06:07.360><c> of</c><00:06:07.480><c> ESPN</c><00:06:08.040><c> bet</c><00:06:08.200><c> against</c><00:06:08.560><c> us.</c>', '', '', '<span>&gt;&gt;</span> <span>They</span> <span>knew</span> <span>that</span> <span>would</span> <span>be</span> <span>bad.</span> <span>&gt;&gt;</span> <span>All<00:06:06.240><c></span> <span>of</c><00:06:06.360><c></span> <span>ESPN,</c><00:06:07.080><c></span> <span>all</c><00:06:07.360><c></span> <span>of</c><00:06:07.480><c></span> <span>ESPN</c><00:06:08.040><c></span> <span>bet</c><00:06:08.200><c></span> <span>against</c><00:06:08.560><c></span> <span>us.</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 356, 368.91, 0.0, '&gt;&gt; All of ESPN, all of ESPN bet against us.', '', '', '<span>&gt;&gt;</span> <span>All</span> <span>of</span> <span>ESPN,</span> <span>all</span> <span>of</span> <span>ESPN</span> <span>bet</span> <span>against</span> <span>us.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 357, 368.92, 0.0, '&gt;&gt; All of ESPN, all of ESPN bet against us. &gt;&gt; That''s<00:06:09.160><c> right.</c>', '', '', '<span>&gt;&gt;</span> <span>All</span> <span>of</span> <span>ESPN,</span> <span>all</span> <span>of</span> <span>ESPN</span> <span>bet</span> <span>against</span> <span>us.</span> <span>&gt;&gt;</span> <span>That''s<00:06:09.160><c></span> <span>right.</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 358, 369.43, 0.0, '&gt;&gt; That''s right.', '', '', '<span>&gt;&gt;</span> <span>That''s</span> <span>right.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 359, 369.44, 0.0, '&gt;&gt; That''s right. &gt;&gt; Every<00:06:09.480><c> single</c><00:06:09.800><c> one.</c><00:06:09.920><c> Does</c><00:06:10.000><c> that</c><00:06:10.160><c> fire</c><00:06:10.480><c> you</c><00:06:10.680><c> up?</c>', '', '', '<span>&gt;&gt;</span> <span>That''s</span> <span>right.</span> <span>&gt;&gt;</span> <span>Every<00:06:09.480><c></span> <span>single</c><00:06:09.800><c></span> <span>one.</c><00:06:09.920><c></span> <span>Does</c><00:06:10.000><c></span> <span>that</c><00:06:10.160><c></span> <span>fire</c><00:06:10.480><c></span> <span>you</c><00:06:10.680><c></span> <span>up?</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 360, 370.83, 0.0, '&gt;&gt; Every single one. Does that fire you up?', '', '', '<span>&gt;&gt;</span> <span>Every</span> <span>single</span> <span>one.</span> <span>Does</span> <span>that</span> <span>fire</span> <span>you</span> <span>up?</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 361, 370.84, 0.0, '&gt;&gt; Every single one. Does that fire you up? Is<00:06:10.960><c> that</c><00:06:11.120><c> something</c><00:06:11.440><c> that</c><00:06:11.600><c> got</c><00:06:11.840><c> you</c><00:06:12.040><c> going</c><00:06:12.440><c> or</c>', '', '', '<span>&gt;&gt;</span> <span>Every</span> <span>single</span> <span>one.</span> <span>Does</span> <span>that</span> <span>fire</span> <span>you</span> <span>up?</span> <span>Is<00:06:10.960><c></span> <span>that</c><00:06:11.120><c></span> <span>something</c><00:06:11.440><c></span> <span>that</c><00:06:11.600><c></span> <span>got</c><00:06:11.840><c></span> <span>you</c><00:06:12.040><c></span> <span>going</c><00:06:12.440><c></span> <span>or</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 362, 372.55, 0.0, 'Is that something that got you going or', '', '', '<span>Is</span> <span>that</span> <span>something</span> <span>that</span> <span>got</span> <span>you</span> <span>going</span> <span>or</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 363, 372.56, 0.0, 'Is that something that got you going or you<00:06:12.640><c> didn''t</c><00:06:12.880><c> care?</c>', '', '', '<span>Is</span> <span>that</span> <span>something</span> <span>that</span> <span>got</span> <span>you</span> <span>going</span> <span>or</span> <span>you<00:06:12.640><c></span> <span>didn''t</c><00:06:12.880><c></span> <span>care?</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 364, 373.71, 0.0, 'you didn''t care?', '', '', '<span>you</span> <span>didn''t</span> <span>care?</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 365, 373.72, 0.0, 'you didn''t care? &gt;&gt; To<00:06:13.840><c> be</c><00:06:14.000><c> honest,</c><00:06:14.280><c> I</c><00:06:14.360><c> didn''t</c><00:06:14.560><c> notice.</c>', '', '', '<span>you</span> <span>didn''t</span> <span>care?</span> <span>&gt;&gt;</span> <span>To<00:06:13.840><c></span> <span>be</c><00:06:14.000><c></span> <span>honest,</c><00:06:14.280><c></span> <span>I</c><00:06:14.360><c></span> <span>didn''t</c><00:06:14.560><c></span> <span>notice.</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 366, 374.99, 0.0, '&gt;&gt; To be honest, I didn''t notice.', '', '', '<span>&gt;&gt;</span> <span>To</span> <span>be</span> <span>honest,</span> <span>I</span> <span>didn''t</span> <span>notice.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 367, 375.0, 0.0, '&gt;&gt; To be honest, I didn''t notice. &gt;&gt; We<00:06:15.160><c> didn''t</c><00:06:15.360><c> notice.</c>', '', '', '<span>&gt;&gt;</span> <span>To</span> <span>be</span> <span>honest,</span> <span>I</span> <span>didn''t</span> <span>notice.</span> <span>&gt;&gt;</span> <span>We<00:06:15.160><c></span> <span>didn''t</c><00:06:15.360><c></span> <span>notice.</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 368, 383.43, 0.0, '&gt;&gt; You did get President Obama posted', '', '', '<span>&gt;&gt;</span> <span>You</span> <span>did</span> <span>get</span> <span>President</span> <span>Obama</span> <span>posted</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 369, 383.44, 0.0, '&gt;&gt; You did get President Obama posted congratulating<00:06:24.320><c> the</c><00:06:24.440><c> team,</c><00:06:24.840><c> which</c><00:06:25.040><c> is</c><00:06:25.200><c> fun,</c>', '', '', '<span>&gt;&gt;</span> <span>You</span> <span>did</span> <span>get</span> <span>President</span> <span>Obama</span> <span>posted</span> <span>congratulating<00:06:24.320><c></span> <span>the</c><00:06:24.440><c></span> <span>team,</c><00:06:24.840><c></span> <span>which</c><00:06:25.040><c></span> <span>is</c><00:06:25.200><c></span> <span>fun,</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 370, 385.55, 0.0, 'congratulating the team, which is fun,', '', '', '<span>congratulating</span> <span>the</span> <span>team,</span> <span>which</span> <span>is</span> <span>fun,</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 371, 385.56, 0.0, 'congratulating the team, which is fun, RIGHT?<00:06:25.840><c> I</c><00:06:25.919><c> MEAN</c>', '', '', '<span>congratulating</span> <span>the</span> <span>team,</span> <span>which</span> <span>is</span> <span>fun,</span> <span>RIGHT?<00:06:25.840><c></span> <span>I</c><00:06:25.919><c></span> <span>MEAN</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 372, 390.23, 0.0, '&gt;&gt; THAT ONE.', '', '', '<span>&gt;&gt;</span> <span>THAT</span> <span>ONE.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 373, 390.24, 0.0, '&gt;&gt; THAT ONE. &gt;&gt; ALTHOUGH<00:06:30.480><c> I</c><00:06:30.560><c> SHOULD</c><00:06:30.800><c> SAY</c><00:06:30.960><c> HE</c><00:06:31.160><c> PICKED</c><00:06:31.440><c> YUKON,</c><00:06:32.000><c> I</c>', '', '', '<span>&gt;&gt;</span> <span>THAT</span> <span>ONE.</span> <span>&gt;&gt;</span> <span>ALTHOUGH<00:06:30.480><c></span> <span>I</c><00:06:30.560><c></span> <span>SHOULD</c><00:06:30.800><c></span> <span>SAY</c><00:06:30.960><c></span> <span>HE</c><00:06:31.160><c></span> <span>PICKED</c><00:06:31.440><c></span> <span>YUKON,</c><00:06:32.000><c></span> <span>I</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 374, 392.07, 0.0, '&gt;&gt; ALTHOUGH I SHOULD SAY HE PICKED YUKON, I', '', '', '<span>&gt;&gt;</span> <span>ALTHOUGH</span> <span>I</span> <span>SHOULD</span> <span>SAY</span> <span>HE</span> <span>PICKED</span> <span>YUKON,</span> <span>I</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 375, 392.08, 0.0, '&gt;&gt; ALTHOUGH I SHOULD SAY HE PICKED YUKON, I think<00:06:32.320><c> to</c><00:06:32.440><c> win</c><00:06:33.120><c> uh</c><00:06:33.200><c> the</c><00:06:33.520><c> the</c><00:06:33.640><c> tournament.</c>', '', '', '<span>&gt;&gt;</span> <span>ALTHOUGH</span> <span>I</span> <span>SHOULD</span> <span>SAY</span> <span>HE</span> <span>PICKED</span> <span>YUKON,</span> <span>I</span> <span>think<00:06:32.320><c></span> <span>to</c><00:06:32.440><c></span> <span>win</c><00:06:33.120><c></span> <span>uh</c><00:06:33.200><c></span> <span>the</c><00:06:33.520><c></span> <span>the</c><00:06:33.640><c></span> <span>tournament.</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 376, 394.27, 0.0, 'think to win uh the the tournament.', '', '', '<span>think</span> <span>to</span> <span>win</span> <span>uh</span> <span>the</span> <span>the</span> <span>tournament.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 377, 394.28, 0.0, 'think to win uh the the tournament. &gt;&gt; Everybody<00:06:34.600><c> makes</c><00:06:34.840><c> mistakes.</c><00:06:35.400><c> It''s</c><00:06:35.560><c> okay.</c>', '', '', '<span>think</span> <span>to</span> <span>win</span> <span>uh</span> <span>the</span> <span>the</span> <span>tournament.</span> <span>&gt;&gt;</span> <span>Everybody<00:06:34.600><c></span> <span>makes</c><00:06:34.840><c></span> <span>mistakes.</c><00:06:35.400><c></span> <span>It''s</c><00:06:35.560><c></span> <span>okay.</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 378, 396.63, 0.0, '&gt;&gt; Everybody makes mistakes. It''s okay.', '', '', '<span>&gt;&gt;</span> <span>Everybody</span> <span>makes</span> <span>mistakes.</span> <span>It''s</span> <span>okay.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 379, 396.64, 0.0, '&gt;&gt; Everybody makes mistakes. It''s okay. &gt;&gt; Have<00:06:36.919><c> you</c><00:06:37.000><c> heard</c><00:06:37.200><c> from</c><00:06:37.400><c> our</c><00:06:37.520><c> current</c>', '', '', '<span>&gt;&gt;</span> <span>Everybody</span> <span>makes</span> <span>mistakes.</span> <span>It''s</span> <span>okay.</span> <span>&gt;&gt;</span> <span>Have<00:06:36.919><c></span> <span>you</c><00:06:37.000><c></span> <span>heard</c><00:06:37.200><c></span> <span>from</c><00:06:37.400><c></span> <span>our</c><00:06:37.520><c></span> <span>current</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 380, 397.87, 0.0, '&gt;&gt; Have you heard from our current', '', '', '<span>&gt;&gt;</span> <span>Have</span> <span>you</span> <span>heard</span> <span>from</span> <span>our</span> <span>current</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 381, 397.88, 0.0, '&gt;&gt; Have you heard from our current president?', '', '', '<span>&gt;&gt;</span> <span>Have</span> <span>you</span> <span>heard</span> <span>from</span> <span>our</span> <span>current</span> <span>president?</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 382, 399.47, 0.0, 'president?', '', '', '<span>president?</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 383, 399.48, 0.0, 'president? &gt;&gt; We<00:06:39.600><c> have</c><00:06:39.760><c> not.</c>', '', '', '<span>president?</span> <span>&gt;&gt;</span> <span>We<00:06:39.600><c></span> <span>have</c><00:06:39.760><c></span> <span>not.</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 384, 400.31, 0.0, '&gt;&gt; We have not.', '', '', '<span>&gt;&gt;</span> <span>We</span> <span>have</span> <span>not.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 385, 400.32, 0.0, '&gt;&gt; We have not. &gt;&gt; not.', '', '', '<span>&gt;&gt;</span> <span>We</span> <span>have</span> <span>not.</span> <span>&gt;&gt;</span> <span>not.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 386, 401.59, 0.0, '&gt;&gt; not.', '', '', '<span>&gt;&gt;</span> <span>not.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 387, 401.6, 0.0, '&gt;&gt; not. I''m<00:06:41.760><c> sure</c><00:06:41.919><c> you</c><00:06:42.000><c> know</c><00:06:42.120><c> he''s</c><00:06:42.360><c> busy.</c><00:06:43.280><c> Um</c>', '', '', '<span>&gt;&gt;</span> <span>not.</span> <span>I''m<00:06:41.760><c></span> <span>sure</c><00:06:41.919><c></span> <span>you</c><00:06:42.000><c></span> <span>know</c><00:06:42.120><c></span> <span>he''s</c><00:06:42.360><c></span> <span>busy.</c><00:06:43.280><c></span> <span>Um</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 388, 404.11, 0.0, 'I''m sure you know he''s busy. Um', '', '', '<span>I''m</span> <span>sure</span> <span>you</span> <span>know</span> <span>he''s</span> <span>busy.</span> <span>Um</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 389, 404.12, 0.0, 'I''m sure you know he''s busy. Um he''s<00:06:44.360><c> in</c><00:06:44.520><c> 2</c><00:06:44.680><c> weeks</c><00:06:45.000><c> you''ll</c><00:06:45.120><c> hear</c><00:06:45.280><c> from</c><00:06:45.440><c> him.</c>', '', '', '<span>I''m</span> <span>sure</span> <span>you</span> <span>know</span> <span>he''s</span> <span>busy.</span> <span>Um</span> <span>he''s<00:06:44.360><c></span> <span>in</c><00:06:44.520><c></span> <span>2</c><00:06:44.680><c></span> <span>weeks</c><00:06:45.000><c></span> <span>you''ll</c><00:06:45.120><c></span> <span>hear</c><00:06:45.280><c></span> <span>from</c><00:06:45.440><c></span> <span>him.</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 390, 407.55, 0.0, 'he''s in 2 weeks you''ll hear from him.', '', '', '<span>he''s</span> <span>in</span> <span>2</span> <span>weeks</span> <span>you''ll</span> <span>hear</span> <span>from</span> <span>him.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 391, 407.56, 0.0, 'he''s in 2 weeks you''ll hear from him. But', '', '', '<span>he''s</span> <span>in</span> <span>2</span> <span>weeks</span> <span>you''ll</span> <span>hear</span> <span>from</span> <span>him.</span> <span>But</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 392, 413.11, 0.0, 'Okay, so in the in event that you do get', '', '', '<span>Okay,</span> <span>so</span> <span>in</span> <span>the</span> <span>in</span> <span>event</span> <span>that</span> <span>you</span> <span>do</span> <span>get</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 393, 413.12, 0.0, 'Okay, so in the in event that you do get invited<00:06:53.480><c> to</c><00:06:53.520><c> the</c><00:06:53.600><c> White</c><00:06:53.800><c> House</c><00:06:53.960><c> and</c><00:06:54.040><c> you</c>', '', '', '<span>Okay,</span> <span>so</span> <span>in</span> <span>the</span> <span>in</span> <span>event</span> <span>that</span> <span>you</span> <span>do</span> <span>get</span> <span>invited<00:06:53.480><c></span> <span>to</c><00:06:53.520><c></span> <span>the</c><00:06:53.600><c></span> <span>White</c><00:06:53.800><c></span> <span>House</c><00:06:53.960><c></span> <span>and</c><00:06:54.040><c></span> <span>you</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 394, 414.11, 0.0, 'invited to the White House and you', '', '', '<span>invited</span> <span>to</span> <span>the</span> <span>White</span> <span>House</span> <span>and</span> <span>you</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 395, 414.12, 0.0, 'invited to the White House and you decide<00:06:54.400><c> to</c><00:06:54.480><c> go</c><00:06:54.640><c> to</c><00:06:54.720><c> the</c><00:06:54.840><c> White</c><00:06:55.120><c> House,</c><00:06:55.800><c> um</c><00:06:56.000><c> I</c>', '', '', '<span>invited</span> <span>to</span> <span>the</span> <span>White</span> <span>House</span> <span>and</span> <span>you</span> <span>decide<00:06:54.400><c></span> <span>to</c><00:06:54.480><c></span> <span>go</c><00:06:54.640><c></span> <span>to</c><00:06:54.720><c></span> <span>the</c><00:06:54.840><c></span> <span>White</c><00:06:55.120><c></span> <span>House,</c><00:06:55.800><c></span> <span>um</c><00:06:56.000><c></span> <span>I</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 396, 416.07, 0.0, 'decide to go to the White House, um I', '', '', '<span>decide</span> <span>to</span> <span>go</span> <span>to</span> <span>the</span> <span>White</span> <span>House,</span> <span>um</span> <span>I</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 397, 416.08, 0.0, 'decide to go to the White House, um I have<00:06:56.320><c> something</c><00:06:56.760><c> for</c><00:06:57.000><c> you,</c><00:06:57.120><c> okay?</c><00:06:58.080><c> Now,</c><00:06:58.800><c> this</c>', '', '', '<span>decide</span> <span>to</span> <span>go</span> <span>to</span> <span>the</span> <span>White</span> <span>House,</span> <span>um</span> <span>I</span> <span>have<00:06:56.320><c></span> <span>something</c><00:06:56.760><c></span> <span>for</c><00:06:57.000><c></span> <span>you,</c><00:06:57.120><c></span> <span>okay?</c><00:06:58.080><c></span> <span>Now,</c><00:06:58.800><c></span> <span>this</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 398, 419.03, 0.0, 'have something for you, okay? Now, this', '', '', '<span>have</span> <span>something</span> <span>for</span> <span>you,</span> <span>okay?</span> <span>Now,</span> <span>this</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 399, 419.04, 0.0, 'have something for you, okay? Now, this is<00:06:59.560><c> I</c><00:06:59.680><c> don''t</c><00:07:00.240><c> do</c><00:07:00.400><c> not</c><00:07:00.720><c> bring</c><00:07:01.120><c> this</c><00:07:01.440><c> to</c><00:07:01.560><c> the</c>', '', '', '<span>have</span> <span>something</span> <span>for</span> <span>you,</span> <span>okay?</span> <span>Now,</span> <span>this</span> <span>is<00:06:59.560><c></span> <span>I</c><00:06:59.680><c></span> <span>don''t</c><00:07:00.240><c></span> <span>do</c><00:07:00.400><c></span> <span>not</c><00:07:00.720><c></span> <span>bring</c><00:07:01.120><c></span> <span>this</c><00:07:01.440><c></span> <span>to</c><00:07:01.560><c></span> <span>the</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 400, 421.67, 0.0, 'is I don''t do not bring this to the', '', '', '<span>is</span> <span>I</span> <span>don''t</span> <span>do</span> <span>not</span> <span>bring</span> <span>this</span> <span>to</span> <span>the</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 401, 421.68, 0.0, 'is I don''t do not bring this to the White<00:07:01.960><c> House.</c>', '', '', '<span>is</span> <span>I</span> <span>don''t</span> <span>do</span> <span>not</span> <span>bring</span> <span>this</span> <span>to</span> <span>the</span> <span>White<00:07:01.960><c></span> <span>House.</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 402, 423.39, 0.0, 'White House.', '', '', '<span>White</span> <span>House.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 403, 423.4, 0.0, 'White House. Okay,<00:07:03.720><c> what</c><00:07:03.919><c> I</c><00:07:04.000><c> want</c><00:07:04.280><c> you</c><00:07:04.400><c> to</c><00:07:04.520><c> do</c><00:07:05.320><c> is</c><00:07:05.560><c> bring</c>', '', '', '<span>White</span> <span>House.</span> <span>Okay,<00:07:03.720><c></span> <span>what</c><00:07:03.919><c></span> <span>I</c><00:07:04.000><c></span> <span>want</c><00:07:04.280><c></span> <span>you</c><00:07:04.400><c></span> <span>to</c><00:07:04.520><c></span> <span>do</c><00:07:05.320><c></span> <span>is</c><00:07:05.560><c></span> <span>bring</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 404, 425.95, 0.0, 'Okay, what I want you to do is bring', '', '', '<span>Okay,</span> <span>what</span> <span>I</span> <span>want</span> <span>you</span> <span>to</span> <span>do</span> <span>is</span> <span>bring</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 405, 425.96, 0.0, 'Okay, what I want you to do is bring this', '', '', '<span>Okay,</span> <span>what</span> <span>I</span> <span>want</span> <span>you</span> <span>to</span> <span>do</span> <span>is</span> <span>bring</span> <span>this</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 406, 427.15, 0.0, 'this', '', '', '<span>this</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 407, 427.16, 0.0, 'this fake<00:07:07.560><c> trophy</c><00:07:07.960><c> we''ve</c><00:07:08.200><c> made</c><00:07:08.760><c> to</c><00:07:08.880><c> the</c><00:07:09.000><c> White</c>', '', '', '<span>this</span> <span>fake<00:07:07.560><c></span> <span>trophy</c><00:07:07.960><c></span> <span>we''ve</c><00:07:08.200><c></span> <span>made</c><00:07:08.760><c></span> <span>to</c><00:07:08.880><c></span> <span>the</c><00:07:09.000><c></span> <span>White</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 408, 429.15, 0.0, 'fake trophy we''ve made to the White', '', '', '<span>fake</span> <span>trophy</span> <span>we''ve</span> <span>made</span> <span>to</span> <span>the</span> <span>White</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 409, 429.16, 0.0, 'fake trophy we''ve made to the White House.', '', '', '<span>fake</span> <span>trophy</span> <span>we''ve</span> <span>made</span> <span>to</span> <span>the</span> <span>White</span> <span>House.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 410, 430.55, 0.0, 'House.', '', '', '<span>House.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 411, 430.56, 0.0, 'House. He''s<00:07:10.880><c> not</c><00:07:11.160><c> going</c><00:07:11.360><c> to</c><00:07:11.440><c> know,</c><00:07:11.800><c> but</c><00:07:12.160><c> when</c><00:07:12.360><c> you</c>', '', '', '<span>House.</span> <span>He''s<00:07:10.880><c></span> <span>not</c><00:07:11.160><c></span> <span>going</c><00:07:11.360><c></span> <span>to</c><00:07:11.440><c></span> <span>know,</c><00:07:11.800><c></span> <span>but</c><00:07:12.160><c></span> <span>when</c><00:07:12.360><c></span> <span>you</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 412, 432.43, 0.0, 'He''s not going to know, but when you', '', '', '<span>He''s</span> <span>not</span> <span>going</span> <span>to</span> <span>know,</span> <span>but</span> <span>when</span> <span>you</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 413, 432.44, 0.0, 'He''s not going to know, but when you bring<00:07:12.720><c> a</c><00:07:12.760><c> trophy</c><00:07:13.360><c> he</c><00:07:13.560><c> sometimes</c><00:07:14.120><c> takes</c><00:07:14.480><c> it</c><00:07:14.600><c> and</c>', '', '', '<span>He''s</span> <span>not</span> <span>going</span> <span>to</span> <span>know,</span> <span>but</span> <span>when</span> <span>you</span> <span>bring<00:07:12.720><c></span> <span>a</c><00:07:12.760><c></span> <span>trophy</c><00:07:13.360><c></span> <span>he</c><00:07:13.560><c></span> <span>sometimes</c><00:07:14.120><c></span> <span>takes</c><00:07:14.480><c></span> <span>it</c><00:07:14.600><c></span> <span>and</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 414, 434.71, 0.0, 'bring a trophy he sometimes takes it and', '', '', '<span>bring</span> <span>a</span> <span>trophy</span> <span>he</span> <span>sometimes</span> <span>takes</span> <span>it</span> <span>and</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 415, 434.72, 0.0, 'bring a trophy he sometimes takes it and keeps<00:07:15.000><c> it</c><00:07:15.120><c> for</c><00:07:15.240><c> himself.</c>', '', '', '<span>bring</span> <span>a</span> <span>trophy</span> <span>he</span> <span>sometimes</span> <span>takes</span> <span>it</span> <span>and</span> <span>keeps<00:07:15.000><c></span> <span>it</c><00:07:15.120><c></span> <span>for</c><00:07:15.240><c></span> <span>himself.</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 416, 436.909, 0.0, 'keeps it for himself.', '', '', '<span>keeps</span> <span>it</span> <span>for</span> <span>himself.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 417, 436.919, 0.0, 'keeps it for himself. So<00:07:17.160><c> this</c><00:07:17.400><c> is</c><00:07:17.520><c> for</c><00:07:17.720><c> you</c><00:07:17.880><c> guys</c><00:07:18.240><c> to</c><00:07:18.400><c> take</c><00:07:18.720><c> to</c><00:07:18.840><c> the</c>', '', '', '<span>keeps</span> <span>it</span> <span>for</span> <span>himself.</span> <span>So<00:07:17.160><c></span> <span>this</c><00:07:17.400><c></span> <span>is</c><00:07:17.520><c></span> <span>for</c><00:07:17.720><c></span> <span>you</c><00:07:17.880><c></span> <span>guys</c><00:07:18.240><c></span> <span>to</c><00:07:18.400><c></span> <span>take</c><00:07:18.720><c></span> <span>to</c><00:07:18.840><c></span> <span>the</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 418, 438.95, 0.0, 'So this is for you guys to take to the', '', '', '<span>So</span> <span>this</span> <span>is</span> <span>for</span> <span>you</span> <span>guys</span> <span>to</span> <span>take</span> <span>to</span> <span>the</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 419, 438.96, 0.0, 'So this is for you guys to take to the White<00:07:19.280><c> House.</c>', '', '', '<span>So</span> <span>this</span> <span>is</span> <span>for</span> <span>you</span> <span>guys</span> <span>to</span> <span>take</span> <span>to</span> <span>the</span> <span>White<00:07:19.280><c></span> <span>House.</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 420, 441.11, 0.0, 'White House.', '', '', '<span>White</span> <span>House.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 421, 441.12, 0.0, 'White House. And<00:07:21.600><c> then</c><00:07:21.800><c> you</c><00:07:21.880><c> can</c><00:07:22.080><c> say,</c><00:07:22.480><c> "President</c><00:07:22.919><c> Trump,</c>', '', '', '<span>White</span> <span>House.</span> <span>And<00:07:21.600><c></span> <span>then</c><00:07:21.800><c></span> <span>you</c><00:07:21.880><c></span> <span>can</c><00:07:22.080><c></span> <span>say,</c><00:07:22.480><c></span> <span>"President</c><00:07:22.919><c></span> <span>Trump,</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 422, 443.23, 0.0, 'And then you can say, "President Trump,', '', '', '<span>And</span> <span>then</span> <span>you</span> <span>can</span> <span>say,</span> <span>"President</span> <span>Trump,</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 423, 443.24, 0.0, 'And then you can say, "President Trump, we<00:07:23.400><c> want</c><00:07:23.680><c> you</c><00:07:23.840><c> to</c><00:07:24.000><c> have</c><00:07:24.280><c> this."</c><00:07:24.600><c> And</c><00:07:24.800><c> he''ll</c><00:07:25.000><c> be</c>', '', '', '<span>And</span> <span>then</span> <span>you</span> <span>can</span> <span>say,</span> <span>"President</span> <span>Trump,</span> <span>we<00:07:23.400><c></span> <span>want</c><00:07:23.680><c></span> <span>you</c><00:07:23.840><c></span> <span>to</c><00:07:24.000><c></span> <span>have</c><00:07:24.280><c></span> <span>this."</c><00:07:24.600><c></span> <span>And</c><00:07:24.800><c></span> <span>he''ll</c><00:07:25.000><c></span> <span>be</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 424, 445.15, 0.0, 'we want you to have this." And he''ll be', '', '', '<span>we</span> <span>want</span> <span>you</span> <span>to</span> <span>have</span> <span>this."</span> <span>And</span> <span>he''ll</span> <span>be</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 425, 445.16, 0.0, 'we want you to have this." And he''ll be so<00:07:25.560><c> happy</c><00:07:25.919><c> you''ll</c><00:07:26.080><c> probably</c><00:07:26.440><c> GET</c><00:07:26.640><c> AN</c>', '', '', '<span>we</span> <span>want</span> <span>you</span> <span>to</span> <span>have</span> <span>this."</span> <span>And</span> <span>he''ll</span> <span>be</span> <span>so<00:07:25.560><c></span> <span>happy</c><00:07:25.919><c></span> <span>you''ll</c><00:07:26.080><c></span> <span>probably</c><00:07:26.440><c></span> <span>GET</c><00:07:26.640><c></span> <span>AN</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 426, 446.75, 0.0, 'so happy you''ll probably GET AN', '', '', '<span>so</span> <span>happy</span> <span>you''ll</span> <span>probably</span> <span>GET</span> <span>AN</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 427, 446.76, 0.0, 'so happy you''ll probably GET AN ENDOWMENT.', '', '', '<span>so</span> <span>happy</span> <span>you''ll</span> <span>probably</span> <span>GET</span> <span>AN</span> <span>ENDOWMENT.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 428, 452.59, 0.0, 'AND YOU''LL BE ABLE TO KEEP the real one.', '', '', '<span>AND</span> <span>YOU''LL</span> <span>BE</span> <span>ABLE</span> <span>TO</span> <span>KEEP</span> <span>the</span> <span>real</span> <span>one.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 429, 452.6, 0.0, 'AND YOU''LL BE ABLE TO KEEP the real one. It''s<00:07:32.800><c> called</c><00:07:33.040><c> the</c><00:07:33.200><c> old</c><00:07:33.440><c> switcheroo.</c>', '', '', '<span>AND</span> <span>YOU''LL</span> <span>BE</span> <span>ABLE</span> <span>TO</span> <span>KEEP</span> <span>the</span> <span>real</span> <span>one.</span> <span>It''s<00:07:32.800><c></span> <span>called</c><00:07:33.040><c></span> <span>the</c><00:07:33.200><c></span> <span>old</c><00:07:33.440><c></span> <span>switcheroo.</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 430, 456.19, 0.0, 'It''s called the old switcheroo.', '', '', '<span>It''s</span> <span>called</span> <span>the</span> <span>old</span> <span>switcheroo.</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 431, 456.2, 0.0, 'It''s called the old switcheroo. Well,<00:07:36.440><c> congratulations.</c><00:07:37.280><c> We''re</c><00:07:37.400><c> very</c><00:07:37.680><c> proud</c>', '', '', '<span>It''s</span> <span>called</span> <span>the</span> <span>old</span> <span>switcheroo.</span> <span>Well,<00:07:36.440><c></span> <span>congratulations.</c><00:07:37.280><c></span> <span>We''re</c><00:07:37.400><c></span> <span>very</c><00:07:37.680><c></span> <span>proud</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 432, 458.43, 0.0, 'Well, congratulations. We''re very proud', '', '', '<span>Well,</span> <span>congratulations.</span> <span>We''re</span> <span>very</span> <span>proud</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 433, 458.44, 0.0, 'Well, congratulations. We''re very proud to<00:07:38.600><c> have</c><00:07:38.840><c> you</c><00:07:38.960><c> in</c><00:07:39.080><c> our</c><00:07:39.520><c> our</c><00:07:39.680><c> town</c><00:07:40.160><c> and</c><00:07:40.640><c> and</c><00:07:40.800><c> I</c>', '', '', '<span>Well,</span> <span>congratulations.</span> <span>We''re</span> <span>very</span> <span>proud</span> <span>to<00:07:38.600><c></span> <span>have</c><00:07:38.840><c></span> <span>you</c><00:07:38.960><c></span> <span>in</c><00:07:39.080><c></span> <span>our</c><00:07:39.520><c></span> <span>our</c><00:07:39.680><c></span> <span>town</c><00:07:40.160><c></span> <span>and</c><00:07:40.640><c></span> <span>and</c><00:07:40.800><c></span> <span>I</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 434, 460.87, 0.0, 'to have you in our our town and and I', '', '', '<span>to</span> <span>have</span> <span>you</span> <span>in</span> <span>our</span> <span>our</span> <span>town</span> <span>and</span> <span>and</span> <span>I</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 435, 460.88, 0.0, 'to have you in our our town and and I hope<00:07:41.080><c> you</c><00:07:41.200><c> guys</c><00:07:41.800><c> I</c><00:07:42.240><c> look</c><00:07:42.480><c> forward</c><00:07:42.720><c> to</c><00:07:42.800><c> seeing</c>', '', '', '<span>to</span> <span>have</span> <span>you</span> <span>in</span> <span>our</span> <span>our</span> <span>town</span> <span>and</span> <span>and</span> <span>I</span> <span>hope<00:07:41.080><c></span> <span>you</c><00:07:41.200><c></span> <span>guys</c><00:07:41.800><c></span> <span>I</c><00:07:42.240><c></span> <span>look</c><00:07:42.480><c></span> <span>forward</c><00:07:42.720><c></span> <span>to</c><00:07:42.800><c></span> <span>seeing</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 436, 463.03, 0.0, 'hope you guys I look forward to seeing', '', '', '<span>hope</span> <span>you</span> <span>guys</span> <span>I</span> <span>look</span> <span>forward</span> <span>to</span> <span>seeing</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 437, 463.04, 0.0, 'hope you guys I look forward to seeing you<00:07:43.200><c> in</c><00:07:43.320><c> the</c><00:07:43.400><c> WNBA</c><00:07:44.160><c> and</c><00:07:44.800><c> coach</c><00:07:45.120><c> you</c><00:07:45.520><c> keep</c><00:07:45.760><c> your</c>', '', '', '<span>hope</span> <span>you</span> <span>guys</span> <span>I</span> <span>look</span> <span>forward</span> <span>to</span> <span>seeing</span> <span>you<00:07:43.200><c></span> <span>in</c><00:07:43.320><c></span> <span>the</c><00:07:43.400><c></span> <span>WNBA</c><00:07:44.160><c></span> <span>and</c><00:07:44.800><c></span> <span>coach</c><00:07:45.120><c></span> <span>you</c><00:07:45.520><c></span> <span>keep</c><00:07:45.760><c></span> <span>your</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 438, 465.91, 0.0, 'you in the WNBA and coach you keep your', '', '', '<span>you</span> <span>in</span> <span>the</span> <span>WNBA</span> <span>and</span> <span>coach</span> <span>you</span> <span>keep</span> <span>your</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 439, 465.92, 0.0, 'you in the WNBA and coach you keep your pedal<00:07:46.200><c> to</c><00:07:46.320><c> the</c><00:07:46.400><c> metal.</c><00:07:46.680><c> You</c><00:07:46.760><c> know</c><00:07:46.880><c> what</c><00:07:47.000><c> I''m</c>', '', '', '<span>you</span> <span>in</span> <span>the</span> <span>WNBA</span> <span>and</span> <span>coach</span> <span>you</span> <span>keep</span> <span>your</span> <span>pedal<00:07:46.200><c></span> <span>to</c><00:07:46.320><c></span> <span>the</c><00:07:46.400><c></span> <span>metal.</c><00:07:46.680><c></span> <span>You</c><00:07:46.760><c></span> <span>know</c><00:07:46.880><c></span> <span>what</c><00:07:47.000><c></span> <span>I''m</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 440, 467.07, 0.0, 'pedal to the metal. You know what I''m', '', '', '<span>pedal</span> <span>to</span> <span>the</span> <span>metal.</span> <span>You</span> <span>know</span> <span>what</span> <span>I''m</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 441, 467.08, 0.0, 'pedal to the metal. You know what I''m saying?', '', '', '<span>pedal</span> <span>to</span> <span>the</span> <span>metal.</span> <span>You</span> <span>know</span> <span>what</span> <span>I''m</span> <span>saying?</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 442, 467.31, 0.0, 'saying?', '', '', '<span>saying?</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 443, 467.32, 0.0, 'saying? &gt;&gt; do<00:07:47.560><c> it.</c><00:07:47.880><c> I''m</c><00:07:48.000><c> going</c><00:07:48.120><c> to</c><00:07:48.160><c> do</c>', '', '', '<span>saying?</span> <span>&gt;&gt;</span> <span>do<00:07:47.560><c></span> <span>it.</c><00:07:47.880><c></span> <span>I''m</c><00:07:48.000><c></span> <span>going</c><00:07:48.120><c></span> <span>to</c><00:07:48.160><c></span> <span>do</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 444, 468.23, 0.0, '&gt;&gt; do it. I''m going to do', '', '', '<span>&gt;&gt;</span> <span>do</span> <span>it.</span> <span>I''m</span> <span>going</span> <span>to</span> <span>do</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 445, 468.24, 0.0, '&gt;&gt; do it. I''m going to do &gt;&gt; There<00:07:48.280><c> YOU</c><00:07:48.400><c> GO.</c><00:07:48.720><c> YOU''RE</c>', '', '', '<span>&gt;&gt;</span> <span>do</span> <span>it.</span> <span>I''m</span> <span>going</span> <span>to</span> <span>do</span> <span>&gt;&gt;</span> <span>There<00:07:48.280><c></span> <span>YOU</c><00:07:48.400><c></span> <span>GO.</c><00:07:48.720><c></span> <span>YOU''RE</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 446, 473.39, 0.0, 'WOMEN''S BASKETBALL CHAMPIONS AND WE''LL', '', '', '<span>WOMEN''S</span> <span>BASKETBALL</span> <span>CHAMPIONS</span> <span>AND</span> <span>WE''LL</span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 447, 473.4, 0.0, 'WOMEN''S BASKETBALL CHAMPIONS AND WE''LL BE<00:07:53.480><c> right</c><00:07:53.760><c> back.</c>', '', '', '<span>WOMEN''S</span> <span>BASKETBALL</span> <span>CHAMPIONS</span> <span>AND</span> <span>WE''LL</span> <span>BE<00:07:53.480><c></span> <span>right</c><00:07:53.760><c></span> <span>back.</c></span>'
FROM episodes e WHERE e.video_id = '1ZOWIuMJ1FHBY7w';

-- episode 193: BxBL4RohKg_s2a0
INSERT INTO episodes (
  index, video_id, short_title, summary, remark, stars, voca_size,
  subtitle_count, clip_length, cover, video_url, audio_url, thumbnail_url,
  original_video_url, author_id, submitted_by_user_id, rejection_reason,
  created_at, is_demo, status, published_at
) VALUES (
  193, 'BxBL4RohKg_s2a0', '闲聊',
  '一位老鳏夫从一个过于热心的烦人孩子那里学到了爱的真谛。
由加州大学洛杉矶分校的Delta Kappa Alpha Productions于2013年制作，作为全球最大的学生电影节——校园电影节的参赛作品。
《闲聊》演职员表：
Daichi Hirabayashi - 导演，执行制片人
与
Nerris Nassiri - 执行制片人，摄影指导
Andrey Misyutin - 执行制片人，直升机摄影师
Searit Huluf - 选角助理
Matthew Camello - 第二助理导演
KJ Knies - 第一助理导演，第一助理摄影师
Ryan Elkins - 编剧，导演，制片人
Stephen Spies - 作曲
----------
在Facebook上成为CMF的粉丝：http://www.facebook.com/campusmoviefest
在Twitter上关注CMF：http://www.twitter.com/campusmoviefest
在YouTube上订阅CMF：http://www.youtube.com/campusmoviefest
了解更多关于CMF的信息，请访问：http://www.campusmoviefest.com
更多信息 - CMF校园电影节电影短片电影节五分钟''5分钟''''短片''''一周''大学学院学生''电影节''''全球最大''加州大学洛杉矶分校2013年''7天''七', '',
  3, 0, 126,
  0.0, 'http://oss.sxakgs.com/en/PNTCM7cbrsc/cover.webp',
  'http://oss.sxakgs.com/en/PNTCM7cbrsc/video.mp4', 'http://oss.sxakgs.com/en/PNTCM7cbrsc/audio.mp3',
  'http://oss.sxakgs.com/en/PNTCM7cbrsc/cover.webp', 'https://www.youtube.com/watch?v=PNTCM7cbrsc',
  (SELECT id FROM authors WHERE name = 'Campus Movie Fest' AND accent = '美国' LIMIT 1),
  NULL, NULL,
  '2026-07-02 15:40:20'::timestamp,
  FALSE, 'published',
  '2026-07-02 15:40:20'::timestamp
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
  SELECT s.id FROM subtitles s JOIN episodes e ON s.episode_id = e.id WHERE e.video_id = 'BxBL4RohKg_s2a0'
);
DELETE FROM subtitles WHERE episode_id = (SELECT id FROM episodes WHERE video_id = 'BxBL4RohKg_s2a0');
DELETE FROM episode_tags WHERE episode_id = (SELECT id FROM episodes WHERE video_id = 'BxBL4RohKg_s2a0');

INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 0, 26.109, 0.0, 'excuse me', '', '', '<span pid="501" class="highlight highlight-i">excuse me</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 1, 26.119, 0.0, 'excuse me hi<00:00:27.119><c> I''m</c><00:00:27.240><c> trying</c><00:00:27.439><c> to</c><00:00:27.640><c> relax</c>', '', '', '<span>excuse</span><span>me</span><span>hi<00:00:27.119><c></span><span>I''m</c><00:00:27.240><c></span><span>trying</c><00:00:27.439><c></span><span>to</c><00:00:27.640><c></span><span>relax</c></span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 2, 30.15, 0.0, 'hi I''m trying to relax', '', '', '<span>hi</span><span>I''m</span><span tid="50001" class="highlight highlight-a">trying</span><span>to</span><span tid="50002" class="highlight highlight-a">relax</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 3, 30.16, 0.0, 'hi I''m trying to relax what<00:00:30.320><c> you</c><00:00:30.480><c> mine</c><00:00:31.480><c> oh</c><00:00:31.920><c> sorry</c>', '', '', '<span>hi</span><span>I''m</span><span>trying</span><span>to</span><span>relax</span><span>what<00:00:30.320><c></span><span>you</c><00:00:30.480><c></span><span>mine</c><00:00:31.480><c></span><span>oh</c><00:00:31.920><c></span><span>sorry</c></span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 4, 42.069, 0.0, 'Mis Hey kid kid kid just come over here', '', '', '<span>Mis</span><span>Hey</span><span tid="50003" class="highlight highlight-a">kid</span><span tid="50004" class="highlight highlight-a">kid</span><span tid="50005" class="highlight highlight-a">kid</span><span>just</span><span pid="502" class="highlight highlight-d">come over here</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 5, 42.079, 0.0, 'Mis Hey kid kid kid just come over here and<00:00:42.239><c> sit</c><00:00:42.440><c> down</c><00:00:42.800><c> would</c><00:00:43.039><c> you</c>', '', '', '<span>Mis</span><span>Hey</span><span>kid</span><span>kid</span><span>kid</span><span>just</span><span>come</span><span>over</span><span>here</span><span>and<00:00:42.239><c></span><span>sit</c><00:00:42.440><c></span><span>down</c><00:00:42.800><c></span><span>would</c><00:00:43.039><c></span><span>you</c></span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 6, 54.11, 0.0, 'okay what''s your name Mister my name is', '', '', '<span>okay</span><span>what''s</span><span>your</span><span>name</span><span>Mister</span><span>my</span><span>name</span><span>is</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 7, 54.12, 0.0, 'okay what''s your name Mister my name is Adam<00:00:55.120><c> you</c><00:00:55.280><c> look</c><00:00:55.520><c> like</c><00:00:55.680><c> my</c><00:00:55.920><c> grandpa</c><00:00:56.320><c> except</c>', '', '', '<span>okay</span><span>what''s</span><span>your</span><span>name</span><span>Mister</span><span>my</span><span>name</span><span>is</span><span>Adam<00:00:55.120><c></span><span>you</c><00:00:55.280><c></span><span>look</c><00:00:55.520><c></span><span>like</c><00:00:55.680><c></span><span>my</c><00:00:55.920><c></span><span>grandpa</c><00:00:56.320><c></span><span>except</c></span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 8, 56.79, 0.0, 'Adam you look like my grandpa except', '', '', '<span>Adam</span><span>you</span><span pid="503" class="highlight highlight-d">look like</span><span>my</span><span tid="50006" class="highlight highlight-a">grandpa</span><span tid="50007" class="highlight highlight-c">except</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 9, 56.8, 0.0, 'Adam you look like my grandpa except he''s<00:00:57.000><c> not</c><00:00:57.199><c> as</c><00:00:57.359><c> old</c><00:00:58.160><c> that''s</c><00:00:58.600><c> very</c><00:00:59.000><c> rude</c>', '', '', '<span>Adam</span><span>you</span><span>look</span><span>like</span><span>my</span><span>grandpa</span><span>except</span><span>he''s<00:00:57.000><c></span><span>not</c><00:00:57.199><c></span><span>as</c><00:00:57.359><c></span><span>old</c><00:00:58.160><c></span><span>that''s</c><00:00:58.600><c></span><span>very</c><00:00:59.000><c></span><span>rude</c></span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 10, 60.47, 0.0, 'he''s not as old that''s very rude', '', '', '<span>he''s</span><span>not</span><span>as</span><span tid="50008" class="highlight highlight-a">old</span><span>that''s</span><span>very</span><span tid="50009" class="highlight highlight-a">rude</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 11, 60.48, 0.0, 'he''s not as old that''s very rude I''m<00:01:00.760><c> Adam</c><00:01:01.199><c> who</c><00:01:01.320><c> are</c>', '', '', '<span>he''s</span><span>not</span><span>as</span><span>old</span><span>that''s</span><span>very</span><span>rude</span><span>I''m<00:01:00.760><c></span><span>Adam</c><00:01:01.199><c></span><span>who</c><00:01:01.320><c></span><span>are</c></span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 12, 65.75, 0.0, 'you', '', '', '<span>you</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 13, 65.76, 0.0, 'you Joseph<00:01:06.760><c> where''s</c><00:01:07.000><c> your</c><00:01:07.320><c> mother</c><00:01:08.320><c> she''s</c><00:01:08.600><c> with</c>', '', '', '<span>you</span><span>Joseph<00:01:06.760><c></span><span>where''s</c><00:01:07.000><c></span><span>your</c><00:01:07.320><c></span><span>mother</c><00:01:08.320><c></span><span>she''s</c><00:01:08.600><c></span><span>with</c></span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 14, 68.789, 0.0, 'Joseph where''s your mother she''s with', '', '', '<span>Joseph</span><span>where''s</span><span>your</span><span tid="50010" class="highlight highlight-a">mother</span><span>she''s</span><span>with</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 15, 68.799, 0.0, 'Joseph where''s your mother she''s with her', '', '', '<span>Joseph</span><span>where''s</span><span>your</span><span tid="50011" class="highlight highlight-a">mother</span><span>she''s</span><span>with</span><span>her</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 16, 69.67, 0.0, 'her', '', '', '<span>her</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 17, 69.68, 0.0, 'her boyfriend<00:01:10.680><c> I''m</c><00:01:10.880><c> supposed</c><00:01:11.119><c> to</c><00:01:11.280><c> wait</c><00:01:11.560><c> over</c>', '', '', '<span>her</span> <span>boyfriend<00:01:10.680><c></span> <span>I''m</c><00:01:10.880><c></span> <span>supposed</c><00:01:11.119><c></span> <span>to</c><00:01:11.280><c></span> <span>wait</c><00:01:11.560><c></span> <span>over</c></span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 18, 78.63, 0.0, 'here I''m 8 and 3/4 Mister how old are', '', '', '<span>here</span> <span>I''m</span> <span>8</span> <span>and</span> <span>3/4</span> <span>Mister</span> <span>how</span> <span>old</span> <span>are</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 19, 78.64, 0.0, 'here I''m 8 and 3/4 Mister how old are you<00:01:19.640><c> mister</c><00:01:20.040><c> you''re</c>', '', '', '<span>here</span> <span>I''m</span> <span>8</span> <span>and</span> <span>3/4</span> <span>Mister</span> <span>how</span> <span>old</span> <span>are</span> <span>you<00:01:19.640><c></span> <span>mister</c><00:01:20.040><c></span> <span>you''re</c></span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 20, 88.39, 0.0, 'boring Hey listen kid I''d like some', '', '', '<span>boring</span> <span>Hey</span> <span>listen</span> <span>kid</span> <span>I''d</span> <span>like</span> <span>some</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 21, 88.4, 0.0, 'boring Hey listen kid I''d like some peace<00:01:28.600><c> and</c><00:01:28.799><c> quiet</c><00:01:29.439><c> please</c>', '', '', '<span>boring</span> <span>Hey</span> <span>listen</span> <span>kid</span> <span>I''d</span> <span>like</span> <span>some</span> <span>peace<00:01:28.600><c></span> <span>and</c><00:01:28.799><c></span> <span>quiet</c><00:01:29.439><c></span> <span>please</c></span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 22, 91.55, 0.0, 'peace and quiet please', '', '', '<span>peace</span> <span>and</span> <span>quiet</span> <span>please</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 23, 91.56, 0.0, 'peace and quiet please you''re<00:01:31.840><c> grumpy</c><00:01:32.320><c> Mister</c><00:01:33.159><c> is</c><00:01:33.280><c> that</c><00:01:33.479><c> why</c><00:01:33.680><c> that</c>', '', '', '<span>peace</span> <span>and</span> <span>quiet</span> <span>please</span> <span>you''re<00:01:31.840><c></span> <span>grumpy</c><00:01:32.320><c></span> <span>Mister</c><00:01:33.159><c></span> <span>is</c><00:01:33.280><c></span> <span>that</c><00:01:33.479><c></span> <span>why</c><00:01:33.680><c></span> <span>that</c></span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 24, 93.87, 0.0, 'you''re grumpy Mister is that why that', '', '', '<span>you''re</span> <span>grumpy</span> <span>Mister</span> <span>is</span> <span>that</span> <span>why</span> <span>that</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 25, 93.88, 0.0, 'you''re grumpy Mister is that why that woman<00:01:34.159><c> left</c><00:01:34.399><c> you</c><00:01:34.520><c> on</c><00:01:34.680><c> the</c><00:01:34.840><c> bench</c><00:01:35.799><c> was</c><00:01:35.960><c> she</c><00:01:36.159><c> your</c>', '', '', '<span>you''re</span> <span>grumpy</span> <span>Mister</span> <span>is</span> <span>that</span> <span>why</span> <span>that</span> <span>woman<00:01:34.159><c></span> <span>left</c><00:01:34.399><c></span> <span>you</c><00:01:34.520><c></span> <span>on</c><00:01:34.680><c></span> <span>the</c><00:01:34.840><c></span> <span>bench</c><00:01:35.799><c></span> <span>was</c><00:01:35.960><c></span> <span>she</c><00:01:36.159><c></span> <span>your</c></span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 26, 97.749, 0.0, 'woman left you on the bench was she your', '', '', '<span>woman</span> <span>left</span> <span>you</span> <span>on</span> <span>the</span> <span>bench</span> <span>was</span> <span>she</span> <span>your</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 27, 97.759, 0.0, 'woman left you on the bench was she your girlfriend<00:01:39.240><c> no</c><00:01:40.240><c> no</c><00:01:40.520><c> she</c>', '', '', '<span>woman</span> <span>left</span> <span>you</span> <span>on</span> <span>the</span> <span>bench</span> <span>was</span> <span>she</span> <span>your</span> <span>girlfriend<00:01:39.240><c></span> <span>no</c><00:01:40.240><c></span> <span>no</c><00:01:40.520><c></span> <span>she</c></span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 28, 101.99, 0.0, 'girlfriend no no she', '', '', '<span>girlfriend</span> <span>no</span> <span>no</span> <span>she</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 29, 102.0, 0.0, 'girlfriend no no she wasn''t<00:01:43.000><c> listen</c><00:01:43.799><c> um</c><00:01:44.159><c> I</c><00:01:44.280><c> have</c><00:01:44.399><c> a</c><00:01:44.560><c> girlfriend</c>', '', '', '<span>girlfriend</span> <span>no</span> <span>no</span> <span>she</span> <span>wasn''t<00:01:43.000><c></span> <span>listen</c><00:01:43.799><c></span> <span>um</c><00:01:44.159><c></span> <span>I</c><00:01:44.280><c></span> <span>have</c><00:01:44.399><c></span> <span>a</c><00:01:44.560><c></span> <span>girlfriend</c></span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 30, 104.99, 0.0, 'wasn''t listen um I have a girlfriend', '', '', '<span>wasn''t</span> <span>listen</span> <span>um</span> <span>I</span> <span>have</span> <span>a</span> <span>girlfriend</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 31, 105.0, 0.0, 'wasn''t listen um I have a girlfriend this<00:01:45.280><c> year</c><00:01:46.079><c> I''m</c><00:01:46.240><c> only</c><00:01:46.479><c> in</c><00:01:46.640><c> the</c><00:01:47.000><c> second</c>', '', '', '<span>wasn''t</span> <span>listen</span> <span>um</span> <span>I</span> <span>have</span> <span>a</span> <span>girlfriend</span> <span>this<00:01:45.280><c></span> <span>year</c><00:01:46.079><c></span> <span>I''m</c><00:01:46.240><c></span> <span>only</c><00:01:46.479><c></span> <span>in</c><00:01:46.640><c></span> <span>the</c><00:01:47.000><c></span> <span>second</c></span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 32, 108.27, 0.0, 'this year I''m only in the second', '', '', '<span>this</span> <span>year</span> <span>I''m</span> <span>only</span> <span>in</span> <span>the</span> <span>second</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 33, 108.28, 0.0, 'this year I''m only in the second grade<00:01:49.280><c> where''s</c><00:01:49.520><c> your</c>', '', '', '<span>this</span> <span>year</span> <span>I''m</span> <span>only</span> <span>in</span> <span>the</span> <span>second</span> <span>grade<00:01:49.280><c></span> <span>where''s</c><00:01:49.520><c></span> <span>your</c></span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 34, 116.23, 0.0, 'girlfriend my wife', '', '', '<span>girlfriend</span> <span>my</span> <span>wife</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 35, 116.24, 0.0, 'girlfriend my wife Elizabeth<00:01:57.240><c> is</c><00:01:57.520><c> gone</c>', '', '', '<span>girlfriend</span> <span>my</span> <span>wife</span> <span>Elizabeth<00:01:57.240><c></span> <span>is</c><00:01:57.520><c></span> <span>gone</c></span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 36, 125.51, 0.0, 'well where has she gone to She''s', '', '', '<span>well</span> <span>where</span> <span>has</span> <span>she</span> <span>gone</span> <span>to</span> <span>She''s</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 37, 125.52, 0.0, 'well where has she gone to She''s Gone', '', '', '<span>well</span> <span>where</span> <span>has</span> <span>she</span> <span>gone</span> <span>to</span> <span>She''s</span> <span>Gone</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 38, 127.949, 0.0, 'Gone', '', '', '<span>Gone</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 39, 127.959, 0.0, 'Gone Gone', '', '', '<span>Gone</span> <span>Gone</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 40, 129.749, 0.0, 'Gone', '', '', '<span>Gone</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 41, 129.759, 0.0, 'Gone Dead', '', '', '<span>Gone</span> <span>Dead</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 42, 131.47, 0.0, 'Dead', '', '', '<span>Dead</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 43, 131.48, 0.0, 'Dead oh<00:02:12.480><c> that''s</c><00:02:13.319><c> sad</c><00:02:14.319><c> well</c><00:02:14.920><c> my</c><00:02:15.080><c> girlfriend</c><00:02:15.519><c> Katie</c>', '', '', '<span>Dead</span> <span>oh<00:02:12.480><c></span> <span>that''s</c><00:02:13.319><c></span> <span>sad</c><00:02:14.319><c></span> <span>well</c><00:02:14.920><c></span> <span>my</c><00:02:15.080><c></span> <span>girlfriend</c><00:02:15.519><c></span> <span>Katie</c></span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 44, 136.35, 0.0, 'oh that''s sad well my girlfriend Katie', '', '', '<span>oh</span> <span>that''s</span> <span>sad</span> <span>well</span> <span>my</span> <span>girlfriend</span> <span>Katie</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 45, 136.36, 0.0, 'oh that''s sad well my girlfriend Katie she''s<00:02:16.599><c> still</c><00:02:16.840><c> really</c>', '', '', '<span>oh</span> <span>that''s</span> <span>sad</span> <span>well</span> <span>my</span> <span>girlfriend</span> <span>Katie</span> <span>she''s<00:02:16.599><c></span> <span>still</c><00:02:16.840><c></span> <span>really</c></span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 46, 138.35, 0.0, 'she''s still really', '', '', '<span>she''s</span> <span>still</span> <span>really</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 47, 138.36, 0.0, 'she''s still really young<00:02:19.360><c> was</c><00:02:19.519><c> she</c><00:02:19.680><c> a</c><00:02:19.879><c> good</c>', '', '', '<span>she''s</span> <span>still</span> <span>really</span> <span>young<00:02:19.360><c></span> <span>was</c><00:02:19.519><c></span> <span>she</c><00:02:19.680><c></span> <span>a</c><00:02:19.879><c></span> <span>good</c></span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 48, 141.75, 0.0, 'young was she a good', '', '', '<span>young</span> <span>was</span> <span>she</span> <span>a</span> <span>good</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 49, 141.76, 0.0, 'young was she a good girlfriend<00:02:22.760><c> Katie''s</c><00:02:23.239><c> the</c><00:02:23.560><c> best</c><00:02:24.080><c> I''ve</c>', '', '', '<span>young</span> <span>was</span> <span>she</span> <span>a</span> <span>good</span> <span>girlfriend<00:02:22.760><c></span> <span>Katie''s</c><00:02:23.239><c></span> <span>the</c><00:02:23.560><c></span> <span>best</c><00:02:24.080><c></span> <span>I''ve</c></span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 50, 145.27, 0.0, 'girlfriend Katie''s the best I''ve', '', '', '<span>girlfriend</span> <span>Katie''s</span> <span>the</span> <span>best</span> <span>I''ve</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 51, 145.28, 0.0, 'girlfriend Katie''s the best I''ve had', '', '', '<span>girlfriend</span> <span>Katie''s</span> <span>the</span> <span>best</span> <span>I''ve</span> <span>had</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 52, 146.91, 0.0, 'had', '', '', '<span>had</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 53, 146.92, 0.0, 'had yes<00:02:27.920><c> Elizabeth</c><00:02:28.440><c> was</c><00:02:28.599><c> one</c><00:02:28.760><c> of</c><00:02:28.840><c> a</c><00:02:29.120><c> kind</c>', '', '', '<span>had</span> <span>yes<00:02:27.920><c></span> <span>Elizabeth</c><00:02:28.440><c></span> <span>was</c><00:02:28.599><c></span> <span>one</c><00:02:28.760><c></span> <span>of</c><00:02:28.840><c></span> <span>a</c><00:02:29.120><c></span> <span>kind</c></span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 54, 150.55, 0.0, 'yes Elizabeth was one of a kind', '', '', '<span>yes</span> <span>Elizabeth</span> <span>was</span> <span>one</span> <span>of</span> <span>a</span> <span>kind</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 55, 150.56, 0.0, 'yes Elizabeth was one of a kind why<00:02:31.560><c> have</c><00:02:31.680><c> you</c><00:02:31.800><c> ever</c><00:02:32.040><c> had</c><00:02:32.239><c> any</c><00:02:32.519><c> other</c>', '', '', '<span>yes</span> <span>Elizabeth</span> <span>was</span> <span>one</span> <span>of</span> <span>a</span> <span>kind</span> <span>why<00:02:31.560><c></span> <span>have</c><00:02:31.680><c></span> <span>you</c><00:02:31.800><c></span> <span>ever</c><00:02:32.040><c></span> <span>had</c><00:02:32.239><c></span> <span>any</c><00:02:32.519><c></span> <span>other</c></span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 56, 158.67, 0.0, 'girlfriends yesterday I brought Katie a', '', '', '<span>girlfriends</span> <span>yesterday</span> <span>I</span> <span>brought</span> <span>Katie</span> <span>a</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 57, 158.68, 0.0, 'girlfriends yesterday I brought Katie a flower<00:02:39.599><c> and</c><00:02:39.720><c> she</c><00:02:39.879><c> gave</c><00:02:40.040><c> me</c><00:02:40.200><c> a</c><00:02:40.360><c> kiss</c><00:02:40.560><c> on</c><00:02:40.680><c> the</c>', '', '', '<span>girlfriends</span> <span>yesterday</span> <span>I</span> <span>brought</span> <span>Katie</span> <span>a</span> <span>flower<00:02:39.599><c></span> <span>and</c><00:02:39.720><c></span> <span>she</c><00:02:39.879><c></span> <span>gave</c><00:02:40.040><c></span> <span>me</c><00:02:40.200><c></span> <span>a</c><00:02:40.360><c></span> <span>kiss</c><00:02:40.560><c></span> <span>on</c><00:02:40.680><c></span> <span>the</c></span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 58, 166.03, 0.0, 'cheek have you ever brought a girl', '', '', '<span>cheek</span> <span>have</span> <span>you</span> <span>ever</span> <span>brought</span> <span>a</span> <span>girl</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 59, 166.04, 0.0, 'cheek have you ever brought a girl flower<00:02:46.879><c> kid</c><00:02:47.879><c> you''ve</c><00:02:48.120><c> got</c><00:02:48.239><c> a</c><00:02:48.360><c> lot</c><00:02:48.519><c> to</c><00:02:48.640><c> learn</c>', '', '', '<span>cheek</span> <span>have</span> <span>you</span> <span>ever</span> <span>brought</span> <span>a</span> <span>girl</span> <span>flower<00:02:46.879><c></span> <span>kid</c><00:02:47.879><c></span> <span>you''ve</c><00:02:48.120><c></span> <span>got</c><00:02:48.239><c></span> <span>a</c><00:02:48.360><c></span> <span>lot</c><00:02:48.519><c></span> <span>to</c><00:02:48.640><c></span> <span>learn</c></span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 60, 168.949, 0.0, 'flower kid you''ve got a lot to learn', '', '', '<span>flower</span> <span>kid</span> <span>you''ve</span> <span>got</span> <span>a</span> <span>lot</span> <span>to</span> <span>learn</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 61, 168.959, 0.0, 'flower kid you''ve got a lot to learn about', '', '', '<span>flower</span> <span>kid</span> <span>you''ve</span> <span>got</span> <span>a</span> <span>lot</span> <span>to</span> <span>learn</span> <span>about</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 62, 170.149, 0.0, 'about', '', '', '<span>about</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 63, 170.159, 0.0, 'about relationships<00:02:51.159><c> have</c><00:02:51.280><c> you</c><00:02:51.400><c> ever</c><00:02:52.000><c> looked</c><00:02:52.239><c> into</c>', '', '', '<span>about</span> <span>relationships<00:02:51.159><c></span> <span>have</c><00:02:51.280><c></span> <span>you</c><00:02:51.400><c></span> <span>ever</c><00:02:52.000><c></span> <span>looked</c><00:02:52.239><c></span> <span>into</c></span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 64, 172.47, 0.0, 'relationships have you ever looked into', '', '', '<span>relationships</span> <span>have</span> <span>you</span> <span>ever</span> <span>looked</span> <span>into</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 65, 172.48, 0.0, 'relationships have you ever looked into someone''s<00:02:53.000><c> eyes</c><00:02:53.440><c> and</c><00:02:54.440><c> had</c><00:02:54.560><c> a</c><00:02:54.720><c> whole</c>', '', '', '<span>relationships</span> <span>have</span> <span>you</span> <span>ever</span> <span>looked</span> <span>into</span> <span>someone''s<00:02:53.000><c></span> <span>eyes</c><00:02:53.440><c></span> <span>and</c><00:02:54.440><c></span> <span>had</c><00:02:54.560><c></span> <span>a</c><00:02:54.720><c></span> <span>whole</c></span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 66, 174.949, 0.0, 'someone''s eyes and had a whole', '', '', '<span>someone''s</span> <span>eyes</span> <span>and</span> <span>had</span> <span>a</span> <span>whole</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 67, 174.959, 0.0, 'someone''s eyes and had a whole conversation<00:02:55.599><c> in</c><00:02:55.760><c> an</c>', '', '', '<span>someone''s</span> <span>eyes</span> <span>and</span> <span>had</span> <span>a</span> <span>whole</span> <span>conversation<00:02:55.599><c></span> <span>in</c><00:02:55.760><c></span> <span>an</c></span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 68, 181.47, 0.0, 'instant laughed with some someone kept', '', '', '<span>instant</span> <span>laughed</span> <span>with</span> <span>some</span> <span>someone</span> <span>kept</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 69, 181.48, 0.0, 'instant laughed with some someone kept laughing<00:03:01.840><c> until</c><00:03:02.080><c> you</c><00:03:02.200><c> even</c><00:03:02.400><c> forgot</c><00:03:02.760><c> why</c><00:03:02.840><c> you</c>', '', '', '<span>instant</span> <span>laughed</span> <span>with</span> <span>some</span> <span>someone</span> <span>kept</span> <span>laughing<00:03:01.840><c></span> <span>until</c><00:03:02.080><c></span> <span>you</c><00:03:02.200><c></span> <span>even</c><00:03:02.400><c></span> <span>forgot</c><00:03:02.760><c></span> <span>why</c><00:03:02.840><c></span> <span>you</c></span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 70, 182.949, 0.0, 'laughing until you even forgot why you', '', '', '<span>laughing</span> <span>until</span> <span>you</span> <span>even</span> <span>forgot</span> <span>why</span> <span>you</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 71, 182.959, 0.0, 'laughing until you even forgot why you were', '', '', '<span>laughing</span> <span>until</span> <span>you</span> <span>even</span> <span>forgot</span> <span>why</span> <span>you</span> <span>were</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 72, 184.949, 0.0, 'were', '', '', '<span>were</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 73, 184.959, 0.0, 'were laughing<00:03:05.959><c> have</c><00:03:06.080><c> you</c><00:03:06.200><c> ever</c><00:03:06.440><c> cried</c><00:03:06.879><c> when</c><00:03:07.120><c> I</c>', '', '', '<span>were</span> <span>laughing<00:03:05.959><c></span> <span>have</c><00:03:06.080><c></span> <span>you</c><00:03:06.200><c></span> <span>ever</c><00:03:06.440><c></span> <span>cried</c><00:03:06.879><c></span> <span>when</c><00:03:07.120><c></span> <span>I</c></span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 74, 187.229, 0.0, 'laughing have you ever cried when I', '', '', '<span>laughing</span> <span>have</span> <span>you</span> <span>ever</span> <span>cried</span> <span>when</span> <span>I</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 75, 187.239, 0.0, 'laughing have you ever cried when I cried<00:03:07.560><c> last</c><00:03:07.799><c> night</c><00:03:08.400><c> when</c><00:03:08.560><c> I</c><00:03:08.640><c> said</c><00:03:08.920><c> goodbye</c><00:03:09.239><c> to</c>', '', '', '<span>laughing</span> <span>have</span> <span>you</span> <span>ever</span> <span>cried</span> <span>when</span> <span>I</span> <span>cried<00:03:07.560><c></span> <span>last</c><00:03:07.799><c></span> <span>night</c><00:03:08.400><c></span> <span>when</c><00:03:08.560><c></span> <span>I</c><00:03:08.640><c></span> <span>said</c><00:03:08.920><c></span> <span>goodbye</c><00:03:09.239><c></span> <span>to</c></span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 76, 191.309, 0.0, 'cried last night when I said goodbye to', '', '', '<span>cried</span> <span>last</span> <span>night</span> <span>when</span> <span>I</span> <span>said</span> <span>goodbye</span> <span>to</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 77, 191.319, 0.0, 'cried last night when I said goodbye to Katie<00:03:12.319><c> but</c><00:03:12.760><c> that</c><00:03:12.879><c> was</c><00:03:13.159><c> cuz</c><00:03:13.319><c> I</c><00:03:13.440><c> had</c><00:03:13.599><c> scraped</c><00:03:14.040><c> my</c>', '', '', '<span>cried</span> <span>last</span> <span>night</span> <span>when</span> <span>I</span> <span>said</span> <span>goodbye</span> <span>to</span> <span>Katie<00:03:12.319><c></span> <span>but</c><00:03:12.760><c></span> <span>that</c><00:03:12.879><c></span> <span>was</c><00:03:13.159><c></span> <span>cuz</c><00:03:13.319><c></span> <span>I</c><00:03:13.440><c></span> <span>had</c><00:03:13.599><c></span> <span>scraped</c><00:03:14.040><c></span> <span>my</c></span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 78, 194.149, 0.0, 'Katie but that was cuz I had scraped my', '', '', '<span>Katie</span> <span>but</span> <span>that</span> <span>was</span> <span>cuz</span> <span>I</span> <span>had</span> <span>scraped</span> <span>my</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 79, 194.159, 0.0, 'Katie but that was cuz I had scraped my knee', '', '', '<span>Katie</span> <span>but</span> <span>that</span> <span>was</span> <span>cuz</span> <span>I</span> <span>had</span> <span>scraped</span> <span>my</span> <span>knee</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 80, 201.589, 0.0, 'badly Mister H', '', '', '<span>badly</span> <span>Mister</span> <span>H</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 81, 201.599, 0.0, 'badly Mister H yes<00:03:22.599><c> are</c><00:03:22.720><c> you</c><00:03:22.879><c> going</c><00:03:23.040><c> to</c><00:03:23.159><c> get</c><00:03:23.280><c> a</c><00:03:23.400><c> new</c>', '', '', '<span>badly</span> <span>Mister</span> <span>H</span> <span>yes<00:03:22.599><c></span> <span>are</c><00:03:22.720><c></span> <span>you</c><00:03:22.879><c></span> <span>going</c><00:03:23.040><c></span> <span>to</c><00:03:23.159><c></span> <span>get</c><00:03:23.280><c></span> <span>a</c><00:03:23.400><c></span> <span>new</c></span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 82, 203.55, 0.0, 'yes are you going to get a new', '', '', '<span>yes</span> <span>are</span> <span>you</span> <span>going</span> <span>to</span> <span>get</span> <span>a</span> <span>new</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 83, 203.56, 0.0, 'yes are you going to get a new girlfriend<00:03:24.000><c> for</c><00:03:24.200><c> all</c><00:03:24.480><c> those</c>', '', '', '<span>yes</span> <span>are</span> <span>you</span> <span>going</span> <span>to</span> <span>get</span> <span>a</span> <span>new</span> <span>girlfriend<00:03:24.000><c></span> <span>for</c><00:03:24.200><c></span> <span>all</c><00:03:24.480><c></span> <span>those</c></span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 84, 205.949, 0.0, 'girlfriend for all those', '', '', '<span>girlfriend</span> <span>for</span> <span>all</span> <span>those</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 85, 205.959, 0.0, 'girlfriend for all those things', '', '', '<span>girlfriend</span> <span>for</span> <span>all</span> <span>those</span> <span>things</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 86, 207.47, 0.0, 'things', '', '', '<span>things</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 87, 207.48, 0.0, 'things no<00:03:28.480><c> I''m</c><00:03:28.720><c> happy</c><00:03:28.959><c> just</c><00:03:29.200><c> by</c><00:03:29.400><c> myself</c>', '', '', '<span>things</span> <span>no<00:03:28.480><c></span> <span>I''m</c><00:03:28.720><c></span> <span>happy</c><00:03:28.959><c></span> <span>just</c><00:03:29.200><c></span> <span>by</c><00:03:29.400><c></span> <span>myself</c></span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 88, 210.91, 0.0, 'no I''m happy just by myself', '', '', '<span>no</span> <span>I''m</span> <span>happy</span> <span>just</span> <span>by</span> <span>myself</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 89, 210.92, 0.0, 'no I''m happy just by myself I<00:03:31.040><c> think</c><00:03:31.239><c> you''re</c>', '', '', '<span>no</span> <span>I''m</span> <span>happy</span> <span>just</span> <span>by</span> <span>myself</span> <span>I<00:03:31.040><c></span> <span>think</c><00:03:31.239><c></span> <span>you''re</c></span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 90, 221.63, 0.0, 'grumpy I have lots of girlfriends Mister', '', '', '<span>grumpy</span> <span>I</span> <span>have</span> <span>lots</span> <span>of</span> <span>girlfriends</span> <span>Mister</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 91, 221.64, 0.0, 'grumpy I have lots of girlfriends Mister over', '', '', '<span>grumpy</span> <span>I</span> <span>have</span> <span>lots</span> <span>of</span> <span>girlfriends</span> <span>Mister</span> <span>over</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 92, 223.19, 0.0, 'over', '', '', '<span>over</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 93, 223.2, 0.0, 'over six<00:03:44.200><c> Lizzie</c><00:03:44.560><c> was</c><00:03:44.799><c> my</c><00:03:44.959><c> one</c><00:03:45.120><c> and</c>', '', '', '<span>over</span> <span>six<00:03:44.200><c></span> <span>Lizzie</c><00:03:44.560><c></span> <span>was</c><00:03:44.799><c></span> <span>my</c><00:03:44.959><c></span> <span>one</c><00:03:45.120><c></span> <span>and</c></span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 94, 230.19, 0.0, 'only you talk about your girlfriend a', '', '', '<span>only</span> <span>you</span> <span>talk</span> <span>about</span> <span>your</span> <span>girlfriend</span> <span>a</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 95, 230.2, 0.0, 'only you talk about your girlfriend a lot<00:03:51.200><c> my</c><00:03:51.720><c> wife</c><00:03:52.720><c> I</c><00:03:52.840><c> love</c><00:03:53.079><c> getting</c><00:03:53.360><c> girlfriends</c>', '', '', '<span>only</span> <span>you</span> <span>talk</span> <span>about</span> <span>your</span> <span>girlfriend</span> <span>a</span> <span>lot<00:03:51.200><c></span> <span>my</c><00:03:51.720><c></span> <span>wife</c><00:03:52.720><c></span> <span>I</c><00:03:52.840><c></span> <span>love</c><00:03:53.079><c></span> <span>getting</c><00:03:53.360><c></span> <span>girlfriends</c></span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 96, 233.91, 0.0, 'lot my wife I love getting girlfriends', '', '', '<span>lot</span> <span>my</span> <span>wife</span> <span>I</span> <span>love</span> <span>getting</span> <span>girlfriends</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 97, 233.92, 0.0, 'lot my wife I love getting girlfriends Mister<00:03:54.640><c> you</c><00:03:54.760><c> should</c><00:03:55.000><c> try</c><00:03:55.319><c> it</c><00:03:56.560><c> uh</c><00:03:57.560><c> there''s</c><00:03:57.799><c> not</c>', '', '', '<span>lot</span> <span>my</span> <span>wife</span> <span>I</span> <span>love</span> <span>getting</span> <span>girlfriends</span> <span>Mister<00:03:54.640><c></span> <span>you</c><00:03:54.760><c></span> <span>should</c><00:03:55.000><c></span> <span>try</c><00:03:55.319><c></span> <span>it</c><00:03:56.560><c></span> <span>uh</c><00:03:57.560><c></span> <span>there''s</c><00:03:57.799><c></span> <span>not</c></span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 98, 237.99, 0.0, 'Mister you should try it uh there''s not', '', '', '<span>Mister</span> <span>you</span> <span>should</span> <span>try</span> <span>it</span> <span>uh</span> <span>there''s</span> <span>not</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 99, 238.0, 0.0, 'Mister you should try it uh there''s not enough<00:03:58.319><c> time</c><00:03:58.599><c> left</c><00:03:58.879><c> for</c><00:03:59.120><c> me</c><00:03:59.840><c> for</c><00:04:00.079><c> those</c><00:04:00.280><c> kind</c>', '', '', '<span>Mister</span> <span>you</span> <span>should</span> <span>try</span> <span>it</span> <span>uh</span> <span>there''s</span> <span>not</span> <span>enough<00:03:58.319><c></span> <span>time</c><00:03:58.599><c></span> <span>left</c><00:03:58.879><c></span> <span>for</c><00:03:59.120><c></span> <span>me</c><00:03:59.840><c></span> <span>for</c><00:04:00.079><c></span> <span>those</c><00:04:00.280><c></span> <span>kind</c></span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 100, 240.429, 0.0, 'enough time left for me for those kind', '', '', '<span>enough</span> <span>time</span> <span>left</span> <span>for</span> <span>me</span> <span>for</span> <span>those</span> <span>kind</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 101, 240.439, 0.0, 'enough time left for me for those kind of', '', '', '<span>enough</span> <span>time</span> <span>left</span> <span>for</span> <span>me</span> <span>for</span> <span>those</span> <span>kind</span> <span>of</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 102, 241.309, 0.0, 'of', '', '', '<span>of</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 103, 241.319, 0.0, 'of shenanigans<00:04:02.319><c> plus</c><00:04:03.159><c> I</c><00:04:03.280><c> thought</c><00:04:03.439><c> I</c><00:04:03.560><c> was</c><00:04:03.720><c> a</c>', '', '', '<span>of</span> <span>shenanigans<00:04:02.319><c></span> <span>plus</c><00:04:03.159><c></span> <span>I</c><00:04:03.280><c></span> <span>thought</c><00:04:03.439><c></span> <span>I</c><00:04:03.560><c></span> <span>was</c><00:04:03.720><c></span> <span>a</c></span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 104, 243.99, 0.0, 'shenanigans plus I thought I was a', '', '', '<span>shenanigans</span> <span>plus</span> <span>I</span> <span>thought</span> <span>I</span> <span>was</span> <span>a</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 105, 244.0, 0.0, 'shenanigans plus I thought I was a boring<00:04:04.640><c> grumpy</c><00:04:05.360><c> old</c>', '', '', '<span>shenanigans</span> <span>plus</span> <span>I</span> <span>thought</span> <span>I</span> <span>was</span> <span>a</span> <span>boring<00:04:04.640><c></span> <span>grumpy</c><00:04:05.360><c></span> <span>old</c></span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 106, 246.75, 0.0, 'boring grumpy old', '', '', '<span>boring</span> <span>grumpy</span> <span>old</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 107, 246.76, 0.0, 'boring grumpy old guy<00:04:07.840><c> nah</c><00:04:08.840><c> you''re</c><00:04:09.799><c> nice</c><00:04:10.799><c> well</c><00:04:11.439><c> once</c><00:04:11.680><c> you</c>', '', '', '<span>boring</span> <span>grumpy</span> <span>old</span> <span>guy<00:04:07.840><c></span> <span>nah</c><00:04:08.840><c></span> <span>you''re</c><00:04:09.799><c></span> <span>nice</c><00:04:10.799><c></span> <span>well</c><00:04:11.439><c></span> <span>once</c><00:04:11.680><c></span> <span>you</c></span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 108, 251.789, 0.0, 'guy nah you''re nice well once you', '', '', '<span>guy</span> <span>nah</span> <span>you''re</span> <span>nice</span> <span>well</span> <span>once</span> <span>you</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 109, 251.799, 0.0, 'guy nah you''re nice well once you stopped<00:04:12.319><c> reading</c><00:04:13.319><c> see</c><00:04:13.560><c> that</c><00:04:13.760><c> pretty</c><00:04:14.000><c> girl</c>', '', '', '<span>guy</span> <span>nah</span> <span>you''re</span> <span>nice</span> <span>well</span> <span>once</span> <span>you</span> <span>stopped<00:04:12.319><c></span> <span>reading</c><00:04:13.319><c></span> <span>see</c><00:04:13.560><c></span> <span>that</c><00:04:13.760><c></span> <span>pretty</c><00:04:14.000><c></span> <span>girl</c></span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 110, 254.27, 0.0, 'stopped reading see that pretty girl', '', '', '<span>stopped</span> <span>reading</span> <span>see</span> <span>that</span> <span>pretty</span> <span>girl</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 111, 254.28, 0.0, 'stopped reading see that pretty girl over', '', '', '<span>stopped</span> <span>reading</span> <span>see</span> <span>that</span> <span>pretty</span> <span>girl</span> <span>over</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 112, 256.43, 0.0, 'over', '', '', '<span>over</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 113, 256.44, 0.0, 'over there<00:04:17.440><c> I''m</c><00:04:17.600><c> about</c><00:04:17.759><c> to</c><00:04:17.880><c> get</c><00:04:18.040><c> a</c><00:04:18.160><c> new</c><00:04:18.359><c> girlfriend</c>', '', '', '<span>over</span> <span>there<00:04:17.440><c></span> <span>I''m</c><00:04:17.600><c></span> <span>about</c><00:04:17.759><c></span> <span>to</c><00:04:17.880><c></span> <span>get</c><00:04:18.040><c></span> <span>a</c><00:04:18.160><c></span> <span>new</c><00:04:18.359><c></span> <span>girlfriend</c></span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 114, 258.87, 0.0, 'there I''m about to get a new girlfriend', '', '', '<span>there</span> <span>I''m</span> <span>about</span> <span>to</span> <span>get</span> <span>a</span> <span>new</span> <span>girlfriend</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 115, 258.88, 0.0, 'there I''m about to get a new girlfriend in<00:04:19.040><c> 10</c><00:04:19.840><c> seconds</c><00:04:20.840><c> there''s</c><00:04:21.239><c> always</c>', '', '', '<span>there</span> <span>I''m</span> <span>about</span> <span>to</span> <span>get</span> <span>a</span> <span>new</span> <span>girlfriend</span> <span>in<00:04:19.040><c></span> <span>10</c><00:04:19.840><c></span> <span>seconds</c><00:04:20.840><c></span> <span>there''s</c><00:04:21.239><c></span> <span>always</c></span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 116, 263.629, 0.0, 'in 10 seconds there''s always', '', '', '<span>in</span> <span>10</span> <span>seconds</span> <span>there''s</span> <span>always</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 117, 263.639, 0.0, 'in 10 seconds there''s always time<00:04:24.639><c> got</c><00:04:24.759><c> to</c><00:04:24.919><c> go</c><00:04:25.160><c> mister</c><00:04:25.680><c> bye</c><00:04:26.400><c> bye</c>', '', '', '<span>in</span> <span>10</span> <span>seconds</span> <span>there''s</span> <span>always</span> <span>time<00:04:24.639><c></span> <span>got</c><00:04:24.759><c></span> <span>to</c><00:04:24.919><c></span> <span>go</c><00:04:25.160><c></span> <span>mister</c><00:04:25.680><c></span> <span>bye</c><00:04:26.400><c></span> <span>bye</c></span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 118, 280.83, 0.0, '[Music]', '', '', '<span>[Music]</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 119, 280.84, 0.0, '[Music] nice<00:04:41.199><c> day</c><00:04:41.479><c> isn''t</c><00:04:41.759><c> it</c>', '', '', '<span>[Music]</span> <span>nice<00:04:41.199><c></span> <span>day</c><00:04:41.479><c></span> <span>isn''t</c><00:04:41.759><c></span> <span>it</c></span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 120, 283.21, 0.0, 'nice day isn''t it', '', '', '<span>nice</span> <span>day</span> <span>isn''t</span> <span>it</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 121, 283.22, 0.0, 'nice day isn''t it [Music]', '', '', '<span>nice</span> <span>day</span> <span>isn''t</span> <span>it</span> <span>[Music]</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 122, 292.27, 0.0, '[Music]', '', '', '<span>[Music]</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 123, 292.28, 0.0, '[Music] yeah<00:04:53.280><c> it''s</c><00:04:53.840><c> beautiful</c><00:04:54.840><c> really</c><00:04:55.120><c> enjoy</c><00:04:55.479><c> the</c>', '', '', '<span>[Music]</span> <span>yeah<00:04:53.280><c></span> <span>it''s</c><00:04:53.840><c></span> <span>beautiful</c><00:04:54.840><c></span> <span>really</c><00:04:55.120><c></span> <span>enjoy</c><00:04:55.479><c></span> <span>the</c></span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 124, 295.67, 0.0, 'yeah it''s beautiful really enjoy the', '', '', '<span>yeah</span> <span>it''s</span> <span>beautiful</span> <span>really</span> <span>enjoy</span> <span>the</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 125, 295.68, 0.0, 'yeah it''s beautiful really enjoy the park', '', '', '<span>yeah</span> <span>it''s</span> <span>beautiful</span> <span>really</span> <span>enjoy</span> <span>the</span> <span>park</span>'
FROM episodes e WHERE e.video_id = 'BxBL4RohKg_s2a0';

-- episode 194: sQe2j4A_zYD1-8k
INSERT INTO episodes (
  index, video_id, short_title, summary, remark, stars, voca_size,
  subtitle_count, clip_length, cover, video_url, audio_url, thumbnail_url,
  original_video_url, author_id, submitted_by_user_id, rejection_reason,
  created_at, is_demo, status, published_at
) VALUES (
  194, 'sQe2j4A_zYD1-8k', '米娅·哈利法：我为何公开谈论*行业',
  '人类对性的关注并不新鲜——但互联网使得探索和利用每一种欲望变得更加容易。在线色情行业每年赚取数十亿美元的利润，但最大的赢家是企业玩家，而不是进行性表演的男女。斯蒂芬·萨克采访了米娅·哈利法。
她曾短暂做过色情演员，因在性爱视频中佩戴伊斯兰头巾而全球闻名。经过多年的威胁和不安全感，她终于发声。她的故事揭示了色情行业和21世纪文化的哪些方面？
请在此订阅 http://bit.ly/1rbfUog', '',
  3, 0, 328,
  0.0, 'http://oss.sxakgs.com/en/RwTAgom_VX8/cover.webp',
  'http://oss.sxakgs.com/en/RwTAgom_VX8/video.mp4', 'http://oss.sxakgs.com/en/RwTAgom_VX8/audio.mp3',
  'http://oss.sxakgs.com/en/RwTAgom_VX8/cover.webp', 'https://www.youtube.com/watch?v=RwTAgom_VX8',
  (SELECT id FROM authors WHERE name = 'News' AND accent = '美国' LIMIT 1),
  NULL, NULL,
  '2026-07-02 15:47:14'::timestamp,
  FALSE, 'published',
  '2026-07-02 15:47:14'::timestamp
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
  SELECT s.id FROM subtitles s JOIN episodes e ON s.episode_id = e.id WHERE e.video_id = 'sQe2j4A_zYD1-8k'
);
DELETE FROM subtitles WHERE episode_id = (SELECT id FROM episodes WHERE video_id = 'sQe2j4A_zYD1-8k');
DELETE FROM episode_tags WHERE episode_id = (SELECT id FROM episodes WHERE video_id = 'sQe2j4A_zYD1-8k');

INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 0, 2.119, 0.0, 'let''s go through this step-by-step how', '让我们一步一步地看看', '/lɛts goʊ θruː ðɪs stɛp baɪ stɛp haʊ/', '<span>let''s</span><span pid="501" class="highlight highlight-d">go through</span><span>this</span><span tid="50001" class="highlight highlight-a">step-by-step</span><span>how</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 1, 2.129, 0.0, 'let''s go through this step-by-step how did<00:00:02.700><c> a</c><00:00:03.000><c> girl</c><00:00:03.750><c> who</c><00:00:04.200><c> was</c><00:00:04.380><c> brought</c><00:00:04.589><c> by</c><00:00:04.799><c> her</c>', '让我们一步一步地看看一个女孩是如何被她的', '/lɛts goʊ θruː ðɪs stɛp baɪ stɛp haʊ dɪd ə gɜːrl huː wʌz brɔːt baɪ hɜːr/', '<span>let''s</span><span>go</span><span>through</span><span>this</span><span>step-by-step</span><span>how</span><span>did<00:00:02.700><c></span><span>a</c><00:00:03.000><c></span><span>girl</c><00:00:03.750><c></span><span>who</c><00:00:04.200><c></span><span>was</c><00:00:04.380><c></span><span>brought</c><00:00:04.589><c></span><span>by</c><00:00:04.799><c></span><span>her</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 2, 4.94, 0.0, 'did a girl who was brought by her', '一个女孩是如何被她的', '/dɪd ə gɜːrl huː wʌz brɔːt baɪ hɜːr/', '<span>did</span><span>a</span><span>girl</span><span>who</span><span>was</span><span tid="50002" class="highlight highlight-a">brought</span><span>by</span><span>her</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 3, 4.95, 0.0, 'did a girl who was brought by her parents<00:00:05.339><c> the</c><00:00:05.490><c> United</c><00:00:05.790><c> States</c><00:00:06.089><c> from</c><00:00:06.540><c> Lebanon</c>', '一个女孩是如何被她的父母从黎巴嫩带到美国的', '/dɪd ə gɜːrl huː wʌz brɔːt baɪ hɜːr ˈpɛrənts ðə juːˈnaɪtɪd steɪts frʌm ˈlɛbənɑːn/', '<span>did</span><span>a</span><span>girl</span><span>who</span><span>was</span><span>brought</span><span>by</span><span>her</span><span>parents<00:00:05.339><c></span><span>the</c><00:00:05.490><c></span><span>United</c><00:00:05.790><c></span><span>States</c><00:00:06.089><c></span><span>from</c><00:00:06.540><c></span><span>Lebanon</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 4, 7.43, 0.0, 'parents the United States from Lebanon', '父母从黎巴嫩带到美国', '/ˈpɛrənts ðə juːˈnaɪtɪd steɪts frʌm ˈlɛbənɑːn/', '<span>parents</span><span>the</span><span>United</span><span>States</span><span>from</span><span tid="50003" class="highlight highlight-a">Lebanon</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 5, 7.44, 0.0, 'parents the United States from Lebanon your<00:00:07.620><c> home</c><00:00:07.799><c> country</c><00:00:08.309><c> schooled</c><00:00:09.179><c> in</c><00:00:09.630><c> the</c><00:00:09.780><c> United</c>', '父母从黎巴嫩带到美国你的祖国在美国上学', '/ˈpɛrənts ðə juːˈnaɪtɪd steɪts frʌm ˈlɛbənɑːn jɔːr hoʊm ˈkʌntri skuːld ɪn ðə juːˈnaɪtɪd/', '<span>parents</span><span>the</span><span>United</span><span>States</span><span>from</span><span>Lebanon</span><span>your<00:00:07.620><c></span><span>home</c><00:00:07.799><c></span><span>country</c><00:00:08.309><c></span><span>schooled</c><00:00:09.179><c></span><span>in</c><00:00:09.630><c></span><span>the</c><00:00:09.780><c></span><span>United</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 6, 10.07, 0.0, 'your home country schooled in the United', '你的祖国在美国上学', '/jɔːr hoʊm ˈkʌntri skuːld ɪn ðə juːˈnaɪtɪd/', '<span>your</span><span>home</span><span>country</span><span tid="50004" class="highlight highlight-a">schooled</span><span>in</span><span>the</span><span>United</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 7, 10.08, 0.0, 'your home country schooled in the United States<00:00:10.349><c> clearly</c><00:00:10.920><c> smart</c><00:00:11.190><c> went</c><00:00:11.490><c> to</c><00:00:11.759><c> university</c>', '你的祖国在美国上学显然很聪明上了大学', '/jɔːr hoʊm ˈkʌntri skuːld ɪn ðə juːˈnaɪtɪd steɪts ˈklɪrli smɑːrt wɛnt tuː ˌjuːnɪˈvɜːrsɪti/', '<span>your</span><span>home</span><span>country</span><span>schooled</span><span>in</span><span>the</span><span>United</span><span>States<00:00:10.349><c></span><span>clearly</c><00:00:10.920><c></span><span>smart</c><00:00:11.190><c></span><span>went</c><00:00:11.490><c></span><span>to</c><00:00:11.759><c></span><span>university</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 8, 12.47, 0.0, 'States clearly smart went to university', '显然很聪明上了大学', '/ˈklɪrli smɑːrt wɛnt tuː ˌjuːnɪˈvɜːrsɪti/', '<span>States</span><span>clearly</span><span tid="50005" class="highlight highlight-a">smart</span><span>went</span><span>to</span><span tid="50006" class="highlight highlight-a">university</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 9, 12.48, 0.0, 'States clearly smart went to university in<00:00:12.509><c> Texas</c><00:00:12.690><c> read</c><00:00:13.110><c> history</c><00:00:13.500><c> how</c><00:00:14.190><c> did</c><00:00:14.460><c> you</c><00:00:14.690><c> get</c>', '显然很聪明在德克萨斯上大学读历史你是怎么', '/ˈklɪrli smɑːrt wɛnt tuː ˌjuːnɪˈvɜːrsɪti ɪn ˈtɛksəs riːd ˈhɪstəri haʊ dɪd juː gɛt/', '<span>States</span><span>clearly</span><span>smart</span><span>went</span><span>to</span><span>university</span><span>in<00:00:12.509><c></span><span>Texas</c><00:00:12.690><c></span><span>read</c><00:00:13.110><c></span><span>history</c><00:00:13.500><c></span><span>how</c><00:00:14.190><c></span><span>did</c><00:00:14.460><c></span><span>you</c><00:00:14.690><c></span><span>get</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 10, 15.68, 0.0, 'in Texas read history how did you get', '在德克萨斯上大学读历史你是怎么', '/ɪn ˈtɛksəs riːd ˈhɪstəri haʊ dɪd juː gɛt/', '<span>in</span><span>Texas</span><span>read</span><span tid="50007" class="highlight highlight-a">history</span><span>how</span><span>did</span><span>you</span><span>get</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 11, 15.69, 0.0, 'in Texas read history how did you get involved<00:00:16.020><c> with</c><00:00:16.940><c> the</c><00:00:17.940><c> sex</c><00:00:18.210><c> porn</c><00:00:18.570><c> industry</c>', '在德克萨斯上大学读历史你是怎么进入色情行业的', '/ɪn ˈtɛksəs riːd ˈhɪstəri haʊ dɪd juː gɛt ɪnˈvɑːlvd wɪð ðə sɛks pɔːrn ˈɪndəstri/', '<span>in</span><span>Texas</span><span>read</span><span>history</span><span>how</span><span>did</span><span>you</span><span>get</span><span>involved<00:00:16.020><c></span><span>with</c><00:00:16.940><c></span><span>the</c><00:00:17.940><c></span><span>sex</c><00:00:18.210><c></span><span>porn</c><00:00:18.570><c></span><span>industry</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 12, 19.58, 0.0, 'involved with the sex porn industry', '进入色情行业', '/ɪnˈvɑːlvd wɪð ðə sɛks pɔːrn ˈɪndəstri/', '<span tid="50008" class="highlight highlight-a">involved</span><span>with</span><span>the</span><span>sex</span><span>porn</span><span tid="50009" class="highlight highlight-a">industry</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 13, 19.59, 0.0, 'involved with the sex porn industry I<00:00:19.619><c> don''t</c><00:00:20.369><c> think</c><00:00:20.430><c> low</c><00:00:20.609><c> self-esteem</c>', '进入色情行业我不认为自卑', '/ɪnˈvɑːlvd wɪð ðə sɛks pɔːrn ˈɪndəstri aɪ doʊnt θɪŋk loʊ sɛlfˈɛstiːm/', '<span>involved</span><span>with</span><span>the</span><span>sex</span><span>porn</span><span>industry</span><span>I<00:00:19.619><c></span><span>don''t</c><00:00:20.369><c></span><span>think</c><00:00:20.430><c></span><span>low</c><00:00:20.609><c></span><span>self-esteem</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 14, 21.099, 0.0, 'I don''t think low self-esteem', '我不认为自卑', '/aɪ doʊnt θɪŋk loʊ sɛlfˈɛstiːm/', '<span>I</span><span>don''t</span><span>think</span><span>low</span><span pid="502" class="highlight highlight-a">self-esteem</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 15, 21.109, 0.0, 'I don''t think low self-esteem discriminates<00:00:22.109><c> against</c><00:00:22.439><c> anyone</c><00:00:22.769><c> it</c><00:00:22.920><c> doesn''t</c>', '我不认为自卑会歧视任何人它不会', '/aɪ doʊnt θɪŋk loʊ sɛlfˈɛstiːm dɪˈskrɪmɪneɪts əˈɡɛnst ˈɛniwʌn ɪt ˈdʌzənt/', '<span>I</span><span>don''t</span><span>think</span><span>low</span><span>self-esteem</span><span>discriminates<00:00:22.109><c></span><span>against</c><00:00:22.439><c></span><span>anyone</c><00:00:22.769><c></span><span>it</c><00:00:22.920><c></span><span>doesn''t</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 16, 23.06, 0.0, 'discriminates against anyone it doesn''t', '歧视任何人它不会', '/dɪˈskrɪmɪneɪts əˈɡɛnst ˈɛniwʌn ɪt ˈdʌzənt/', '<span tid="50010" class="highlight highlight-a">discriminates</span><span>against</span><span>anyone</span><span>it</span><span>doesn''t</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 17, 23.07, 0.0, 'discriminates against anyone it doesn''t matter<00:00:23.310><c> if</c><00:00:23.460><c> you</c><00:00:23.670><c> come</c><00:00:24.210><c> from</c><00:00:24.359><c> a</c><00:00:24.449><c> great</c><00:00:24.660><c> family</c>', '歧视任何人它不在乎你来自一个很好的家庭', '/dɪˈskrɪmɪneɪts əˈɡɛnst ˈɛniwʌn ɪt ˈdʌzənt ˈmætər ɪf juː kʌm frʌm ə greɪt ˈfæmɪli/', '<span>discriminates</span><span>against</span><span>anyone</span><span>it</span><span>doesn''t</span><span>matter<00:00:23.310><c></span><span>if</c><00:00:23.460><c></span><span>you</c><00:00:23.670><c></span><span>come</c><00:00:24.210><c></span><span>from</c><00:00:24.359><c></span><span>a</c><00:00:24.449><c></span><span>great</c><00:00:24.660><c></span><span>family</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 18, 24.71, 0.0, 'matter if you come from a great family', '不在乎你来自一个很好的家庭', '/ˈmætər ɪf juː kʌm frʌm ə greɪt ˈfæmɪli/', '<span tid="50011" class="highlight highlight-a">matter</span><span>if</span><span>you</span><span>come</span><span>from</span><span>a</span><span>great</span><span>family</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 19, 24.72, 0.0, 'matter if you come from a great family or<00:00:25.199><c> if</c><00:00:25.289><c> you</c><00:00:25.410><c> come</c><00:00:25.560><c> from</c><00:00:25.920><c> a</c><00:00:26.930><c> not-so-great</c>', '不在乎你来自一个很好的家庭还是不太好的', '/ˈmætər ɪf juː kʌm frʌm ə greɪt ˈfæmɪli ɔːr ɪf juː kʌm frʌm ə nɑːt soʊ greɪt/', '<span>matter</span><span>if</span><span>you</span><span>come</span><span>from</span><span>a</span><span>great</span><span>family</span><span>or<00:00:25.199><c></span><span>if</c><00:00:25.289><c></span><span>you</c><00:00:25.410><c></span><span>come</c><00:00:25.560><c></span><span>from</c><00:00:25.920><c></span><span>a</c><00:00:26.930><c></span><span>not-so-great</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 20, 27.92, 0.0, 'or if you come from a not-so-great', '还是来自不太好的', '/ɔːr ɪf juː kʌm frʌm ə nɑːt soʊ greɪt/', '<span>or</span><span>if</span><span>you</span><span>come</span><span>from</span><span>a</span><span tid="50012" class="highlight highlight-a">not-so-great</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 21, 27.93, 0.0, 'or if you come from a not-so-great background<00:00:28.470><c> I</c><00:00:28.920><c> struggled</c><00:00:29.820><c> my</c><00:00:30.420><c> entire</c>', '还是来自不太好的背景我挣扎了整个', '/ɔːr ɪf juː kʌm frʌm ə nɑːt soʊ greɪt ˈbækɡraʊnd aɪ ˈstrʌɡəld maɪ ɪnˈtaɪər/', '<span>or</span><span>if</span><span>you</span><span>come</span><span>from</span><span>a</span><span>not-so-great</span><span>background<00:00:28.470><c></span><span>I</c><00:00:28.920><c></span><span>struggled</c><00:00:29.820><c></span><span>my</c><00:00:30.420><c></span><span>entire</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 22, 30.62, 0.0, 'background I struggled my entire', '背景我挣扎了整个', '/ˈbækɡraʊnd aɪ ˈstrʌɡəld maɪ ɪnˈtaɪər/', '<span tid="50013" class="highlight highlight-a">background</span><span>I</span><span tid="50014" class="highlight highlight-a">struggled</span><span>my</span><span>entire</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 23, 30.63, 0.0, 'background I struggled my entire childhood<00:00:31.019><c> with</c><00:00:31.260><c> weight</c><00:00:31.679><c> and</c><00:00:31.949><c> I</c><00:00:32.790><c> never</c><00:00:33.030><c> felt</c>', '背景我挣扎了整个童年与体重我从未感到', '/ˈbækɡraʊnd aɪ ˈstrʌɡəld maɪ ɪnˈtaɪər ˈtʃaɪldhʊd wɪð weɪt ænd aɪ ˈnɛvər fɛlt/', '<span>background</span><span>I</span><span>struggled</span><span>my</span><span>entire</span><span>childhood<00:00:31.019><c></span><span>with</c><00:00:31.260><c></span><span>weight</c><00:00:31.679><c></span><span>and</c><00:00:31.949><c></span><span>I</c><00:00:32.790><c></span><span>never</c><00:00:33.030><c></span><span>felt</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 24, 33.43, 0.0, 'childhood with weight and I never felt', '童年与体重我从未感到', '/ˈtʃaɪldhʊd wɪð weɪt ænd aɪ ˈnɛvər fɛlt/', '<span tid="50015" class="highlight highlight-a">childhood</span><span>with</span><span tid="50016" class="highlight highlight-a">weight</span><span>and</span><span>I</span><span>never</span><span>felt</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 25, 33.44, 0.0, 'childhood with weight and I never felt attractive<00:00:34.440><c> or</c><00:00:34.739><c> worthy</c><00:00:35.640><c> of</c><00:00:35.790><c> male</c><00:00:36.000><c> attention</c>', '童年与体重我从未感到有吸引力或值得男性关注', '/ˈtʃaɪldhʊd wɪð weɪt ænd aɪ ˈnɛvər fɛlt əˈtræktɪv ɔːr ˈwɜːrði ʌv meɪl əˈtɛnʃən/', '<span>childhood</span><span>with</span><span>weight</span><span>and</span><span>I</span><span>never</span><span>felt</span><span>attractive<00:00:34.440><c></span><span>or</c><00:00:34.739><c></span><span>worthy</c><00:00:35.640><c></span><span>of</c><00:00:35.790><c></span><span>male</c><00:00:36.000><c></span><span>attention</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 26, 36.319, 0.0, 'attractive or worthy of male attention', '有吸引力或值得男性关注', '/əˈtræktɪv ɔːr ˈwɜːrði ʌv meɪl əˈtɛnʃən/', '<span tid="50017" class="highlight highlight-a">attractive</span><span>or</span><span tid="50018" class="highlight highlight-a">worthy</span><span>of</span><span tid="50019" class="highlight highlight-a">male</span><span tid="50020" class="highlight highlight-a">attention</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 27, 36.329, 0.0, 'attractive or worthy of male attention and<00:00:37.070><c> suddenly</c><00:00:38.070><c> my</c><00:00:38.370><c> first</c><00:00:39.300><c> year</c><00:00:39.450><c> of</c><00:00:39.510><c> college</c><00:00:39.719><c> I</c>', '有吸引力或值得男性关注然后突然我大学第一年', '/əˈtræktɪv ɔːr ˈwɜːrði ʌv meɪl əˈtɛnʃən ænd ˈsʌdənli maɪ fɜːrst jɪr ʌv ˈkɑːlɪdʒ aɪ/', '<span>attractive</span><span>or</span><span>worthy</span><span>of</span><span>male</span><span>attention</span><span>and<00:00:37.070><c></span><span>suddenly</c><00:00:38.070><c></span><span>my</c><00:00:38.370><c></span><span>first</c><00:00:39.300><c></span><span>year</c><00:00:39.450><c></span><span>of</c><00:00:39.510><c></span><span>college</c><00:00:39.719><c></span><span>I</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 28, 39.979, 0.0, 'and suddenly my first year of college I', '然后突然我大学第一年', '/ænd ˈsʌdənli maɪ fɜːrst jɪr ʌv ˈkɑːlɪdʒ aɪ/', '<span>and</span><span tid="50021" class="highlight highlight-a">suddenly</span><span>my</span><span>first</span><span>year</span><span>of</span><span tid="50022" class="highlight highlight-a">college</span><span>I</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 29, 39.989, 0.0, 'and suddenly my first year of college I start<00:00:40.260><c> losing</c><00:00:40.379><c> all</c><00:00:41.129><c> this</c><00:00:41.370><c> weight</c><00:00:41.430><c> from</c><00:00:41.910><c> making</c>', '然后突然我大学第一年开始减掉所有这些体重通过', '/ænd ˈsʌdənli maɪ fɜːrst jɪr ʌv ˈkɑːlɪdʒ aɪ stɑːrt ˈluːzɪŋ ɔːl ðɪs weɪt frʌm ˈmeɪkɪŋ/', '<span>and</span><span>suddenly</span><span>my</span><span>first</span><span>year</span><span>of</span><span>college</span><span>I</span><span>start<00:00:40.260><c></span><span>losing</c><00:00:40.379><c></span><span>all</c><00:00:41.129><c></span><span>this</c><00:00:41.370><c></span><span>weight</c><00:00:41.430><c></span><span>from</c><00:00:41.910><c></span><span>making</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 30, 42.17, 0.0, 'start losing all this weight from making', '开始减掉所有这些体重，通过做出', '/stɑːrt ˈluːzɪŋ ɔːl ðɪs weɪt frəm ˈmeɪkɪŋ/', '<span>start</span><span tid="50023" class="highlight highlight-a">losing</span><span>all</span><span>this</span><span tid="50024" class="highlight highlight-a">weight</span><span>from</span><span>making</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 31, 42.18, 0.0, 'start losing all this weight from making small<00:00:42.480><c> changes</c><00:00:42.510><c> and</c><00:00:43.200><c> by</c><00:00:43.649><c> the</c><00:00:43.710><c> time</c><00:00:43.950><c> I</c>', '开始减掉所有这些体重，通过做出小的改变，到那时我', '/stɑːrt ˈluːzɪŋ ɔːl ðɪs weɪt frəm ˈmeɪkɪŋ smɔːl ˈtʃeɪndʒɪz ænd baɪ ðə taɪm aɪ/', '<span>start</span><span>losing</span><span>all</span><span>this</span><span>weight</span><span>from</span><span>making</span><span>small<00:00:42.480><c></span><span>changes</c><00:00:42.510><c></span><span>and</c><00:00:43.200><c></span><span>by</c><00:00:43.649><c></span><span>the</c><00:00:43.710><c></span><span>time</c><00:00:43.950><c></span><span>I</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 32, 43.97, 0.0, 'small changes and by the time I', '小的改变，到那时我', '/smɔːl ˈtʃeɪndʒɪz ænd baɪ ðə taɪm aɪ/', '<span tid="50025" class="highlight highlight-a">small</span><span tid="50026" class="highlight highlight-a">changes</span><span>and</span><span>by</span><span>the</span><span>time</span><span>I</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 33, 43.98, 0.0, 'small changes and by the time I graduated<00:00:44.610><c> I</c><00:00:45.020><c> was</c><00:00:46.020><c> ready</c><00:00:46.200><c> to</c><00:00:46.379><c> make</c><00:00:46.530><c> a</c><00:00:46.770><c> bigger</c>', '小的改变，到那时我毕业时，我已经准备好做出更大的', '/smɔːl ˈtʃeɪndʒɪz ænd baɪ ðə taɪm aɪ ˈɡrædʒuˌeɪtɪd aɪ wʌz ˈrɛdi tu meɪk ə ˈbɪɡər/', '<span>small</span><span>changes</span><span>and</span><span>by</span><span>the</span><span>time</span><span>I</span><span>graduated<00:00:44.610><c></span><span>I</c><00:00:45.020><c></span><span>was</c><00:00:46.020><c></span><span>ready</c><00:00:46.200><c></span><span>to</c><00:00:46.379><c></span><span>make</c><00:00:46.530><c></span><span>a</c><00:00:46.770><c></span><span>bigger</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 34, 47.09, 0.0, 'graduated I was ready to make a bigger', '毕业时，我已经准备好做出更大的', '/ˈɡrædʒuˌeɪtɪd aɪ wʌz ˈrɛdi tu meɪk ə ˈbɪɡər/', '<span tid="50027" class="highlight highlight-a">graduated</span><span>I</span><span>was</span><span tid="50028" class="highlight highlight-a">ready</span><span>to</span><span>make</span><span>a</span><span tid="50029" class="highlight highlight-a">bigger</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 35, 47.1, 0.0, 'graduated I was ready to make a bigger difference<00:00:47.280><c> I</c><00:00:47.700><c> felt</c><00:00:47.940><c> extremely</c>', '毕业时，我已经准备好做出更大的改变。我感到非常', '/ˈɡrædʒuˌeɪtɪd aɪ wʌz ˈrɛdi tu meɪk ə ˈbɪɡər ˈdɪfərəns aɪ fɛlt ɪkˈstriːmli/', '<span>graduated</span><span>I</span><span>was</span><span>ready</span><span>to</span><span>make</span><span>a</span><span>bigger</span><span>difference<00:00:47.280><c></span><span>I</c><00:00:47.700><c></span><span>felt</c><00:00:47.940><c></span><span>extremely</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 36, 48.319, 0.0, 'difference I felt extremely', '改变。我感到非常', '/ˈdɪfərəns aɪ fɛlt ɪkˈstriːmli/', '<span tid="50030" class="highlight highlight-a">difference</span><span>I</span><span>felt</span><span tid="50031" class="highlight highlight-a">extremely</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 37, 48.329, 0.0, 'difference I felt extremely self-conscious<00:00:49.140><c> about</c><00:00:49.469><c> my</c><00:00:49.559><c> breasts</c><00:00:50.100><c> because</c>', '改变。我感到非常在意自己的胸部，因为', '/ˈdɪfərəns aɪ fɛlt ɪkˈstriːmli ˌsɛlfˈkɑːnʃəs əˈbaʊt maɪ brɛsts bɪˈkɔːz/', '<span>difference</span><span>I</span><span>felt</span><span>extremely</span><span>self-conscious<00:00:49.140><c></span><span>about</c><00:00:49.469><c></span><span>my</c><00:00:49.559><c></span><span>breasts</c><00:00:50.100><c></span><span>because</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 38, 50.36, 0.0, 'self-conscious about my breasts because', '在意自己的胸部，因为', '/ˌsɛlfˈkɑːnʃəs əˈbaʊt maɪ brɛsts bɪˈkɔːz/', '<span tid="50032" class="highlight highlight-a">self-conscious</span><span>about</span><span>my</span><span tid="50033" class="highlight highlight-a">breasts</span><span>because</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 39, 50.37, 0.0, 'self-conscious about my breasts because that<00:00:50.520><c> was</c><00:00:50.640><c> the</c><00:00:50.760><c> first</c><00:00:50.789><c> thing</c><00:00:51.180><c> to</c><00:00:51.300><c> go</c><00:00:51.420><c> when</c><00:00:51.600><c> I</c>', '在意自己的胸部，因为那是我最先失去的，当我', '/ˌsɛlfˈkɑːnʃəs əˈbaʊt maɪ brɛsts bɪˈkɔːz ðæt wʌz ðə fɜːrst θɪŋ tu ɡoʊ wɛn aɪ/', '<span>self-conscious</span><span>about</span><span>my</span><span>breasts</span><span>because</span><span>that<00:00:50.520><c></span><span>was</c><00:00:50.640><c></span><span>the</c><00:00:50.760><c></span><span>first</c><00:00:50.789><c></span><span>thing</c><00:00:51.180><c></span><span>to</c><00:00:51.300><c></span><span>go</c><00:00:51.420><c></span><span>when</c><00:00:51.600><c></span><span>I</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 40, 51.619, 0.0, 'that was the first thing to go when I', '那是我最先失去的，当我', '/ðæt wʌz ðə fɜːrst θɪŋ tu ɡoʊ wɛn aɪ/', '<span>that</span><span>was</span><span>the</span><span>first</span><span>thing</span><span>to</span><span tid="50034" class="highlight highlight-a">go</span><span>when</span><span>I</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 41, 51.629, 0.0, 'that was the first thing to go when I lost<00:00:51.840><c> all</c><00:00:52.020><c> the</c><00:00:52.079><c> weight</c><00:00:52.260><c> I</c><00:00:52.440><c> lost</c><00:00:52.680><c> about</c><00:00:52.800><c> 50</c>', '那是我最先失去的，当我减掉所有体重时，我减掉了大约50', '/ðæt wʌz ðə fɜːrst θɪŋ tu ɡoʊ wɛn aɪ lɔːst ɔːl ðə weɪt aɪ lɔːst əˈbaʊt ˈfɪfti/', '<span>that</span><span>was</span><span>the</span><span>first</span><span>thing</span><span>to</span><span>go</span><span>when</span><span>I</span><span>lost<00:00:51.840><c></span><span>all</c><00:00:52.020><c></span><span>the</c><00:00:52.079><c></span><span>weight</c><00:00:52.260><c></span><span>I</c><00:00:52.440><c></span><span>lost</c><00:00:52.680><c></span><span>about</c><00:00:52.800><c></span><span>50</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 42, 53.779, 0.0, 'lost all the weight I lost about 50', '减掉所有体重时，我减掉了大约50', '/lɔːst ɔːl ðə weɪt aɪ lɔːst əˈbaʊt ˈfɪfti/', '<span tid="50035" class="highlight highlight-a">lost</span><span>all</span><span>the</span><span>weight</span><span>I</span><span tid="50036" class="highlight highlight-a">lost</span><span>about</span><span>50</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 43, 53.789, 0.0, 'lost all the weight I lost about 50 pounds<00:00:54.149><c> I</c><00:00:54.210><c> don''t</c><00:00:54.360><c> know</c><00:00:54.449><c> how</c><00:00:54.570><c> many</c><00:00:54.750><c> kilos</c><00:00:54.960><c> that</c>', '减掉所有体重时，我减掉了大约50磅。我不知道那是多少公斤', '/lɔːst ɔːl ðə weɪt aɪ lɔːst əˈbaʊt ˈfɪfti paʊndz aɪ doʊnt noʊ haʊ ˈmɛni ˈkɪloʊz ðæt/', '<span>lost</span><span>all</span><span>the</span><span>weight</span><span>I</span><span>lost</span><span>about</span><span>50</span><span>pounds<00:00:54.149><c></span><span>I</c><00:00:54.210><c></span><span>don''t</c><00:00:54.360><c></span><span>know</c><00:00:54.449><c></span><span>how</c><00:00:54.570><c></span><span>many</c><00:00:54.750><c></span><span>kilos</c><00:00:54.960><c></span><span>that</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 44, 55.13, 0.0, 'pounds I don''t know how many kilos that', '磅。我不知道那是多少公斤', '/paʊndz aɪ doʊnt noʊ haʊ ˈmɛni ˈkɪloʊz ðæt/', '<span>pounds</span><span>I</span><span>don''t</span><span>know</span><span>how</span><span>many</span><span tid="50037" class="highlight highlight-a">kilos</span><span>that</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 45, 55.14, 0.0, 'pounds I don''t know how many kilos that is<00:00:55.440><c> or</c><00:00:55.800><c> stones</c><00:00:56.660><c> well</c><00:00:57.660><c> it''s</c><00:00:58.109><c> a</c><00:00:58.199><c> considerable</c>', '磅。我不知道那是多少公斤或英石，嗯，那是相当可观的', '/paʊndz aɪ doʊnt noʊ haʊ ˈmɛni ˈkɪloʊz ðæt ɪz ɔːr stoʊnz wɛl ɪts ə kənˈsɪdərəbəl/', '<span>pounds</span><span>I</span><span>don''t</span><span>know</span><span>how</span><span>many</span><span>kilos</span><span>that</span><span>is<00:00:55.440><c></span><span>or</c><00:00:55.800><c></span><span>stones</c><00:00:56.660><c></span><span>well</c><00:00:57.660><c></span><span>it''s</c><00:00:58.109><c></span><span>a</c><00:00:58.199><c></span><span>considerable</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 46, 58.819, 0.0, 'is or stones well it''s a considerable', '是或英石，嗯，那是相当可观的', '/ɪz ɔːr stoʊnz wɛl ɪts ə kənˈsɪdərəbəl/', '<span>is</span><span>or</span><span tid="50038" class="highlight highlight-a">stones</span><span>well</span><span>it''s</span><span>a</span><span tid="50039" class="highlight highlight-a">considerable</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 47, 58.829, 0.0, 'is or stones well it''s a considerable amount<00:00:59.070><c> of</c><00:00:59.160><c> weight</c><00:00:59.280><c> yeah</c><00:00:59.520><c> changed</c><00:01:00.300><c> yeah</c>', '是或英石，嗯，那是相当可观的体重。是的，改变了，是的', '/ɪz ɔːr stoʊnz wɛl ɪts ə kənˈsɪdərəbəl əˈmaʊnt ʌv weɪt jɛs tʃeɪndʒd jɛs/', '<span>is</span><span>or</span><span>stones</span><span>well</span><span>it''s</span><span>a</span><span>considerable</span><span>amount<00:00:59.070><c></span><span>of</c><00:00:59.160><c></span><span>weight</c><00:00:59.280><c></span><span>yeah</c><00:00:59.520><c></span><span>changed</c><00:01:00.300><c></span><span>yeah</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 48, 60.65, 0.0, 'amount of weight yeah changed yeah', '体重。是的，改变了，是的', '/əˈmaʊnt ʌv weɪt jɛs tʃeɪndʒd jɛs/', '<span tid="50040" class="highlight highlight-a">amount</span><span>of</span><span tid="50041" class="highlight highlight-a">weight</span><span>yeah</span><span tid="50042" class="highlight highlight-a">changed</span><span>yeah</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 49, 60.66, 0.0, 'amount of weight yeah changed yeah changed<00:01:01.079><c> your</c><00:01:01.170><c> physic</c><00:01:01.440><c> completely</c><00:01:01.949><c> so</c><00:01:02.219><c> my</c>', '体重。是的，改变了，是的，完全改变了你的体型。所以我的', '/əˈmaʊnt ʌv weɪt jɛs tʃeɪndʒd jɛs tʃeɪndʒd jʊər ˈfɪzɪk kəmˈpliːtli soʊ maɪ/', '<span>amount</span><span>of</span><span>weight</span><span>yeah</span><span>changed</span><span>yeah</span><span>changed<00:01:01.079><c></span><span>your</c><00:01:01.170><c></span><span>physic</c><00:01:01.440><c></span><span>completely</c><00:01:01.949><c></span><span>so</c><00:01:02.219><c></span><span>my</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 50, 62.63, 0.0, 'changed your physic completely so my', '改变了你的体型。所以我的', '/tʃeɪndʒd jʊər ˈfɪzɪk kəmˈpliːtli soʊ maɪ/', '<span tid="50043" class="highlight highlight-a">changed</span><span>your</span><span tid="50044" class="highlight highlight-a">physic</span><span tid="50045" class="highlight highlight-a">completely</span><span>so</span><span>my</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 51, 62.64, 0.0, 'changed your physic completely so my biggest<00:01:02.910><c> insecurity</c><00:01:03.300><c> was</c><00:01:03.719><c> my</c><00:01:03.899><c> breast</c><00:01:04.199><c> so</c><00:01:04.530><c> I</c>', '改变了你的体型。所以我最大的不安全感是我的胸部，所以我', '/tʃeɪndʒd jʊər ˈfɪzɪk kəmˈpliːtli soʊ maɪ ˈbɪɡɪst ˌɪnsɪˈkjʊrəti wʌz maɪ brɛst soʊ aɪ/', '<span>changed</span><span>your</span><span>physic</span><span>completely</span><span>so</span><span>my</span><span>biggest<00:01:02.910><c></span><span>insecurity</c><00:01:03.300><c></span><span>was</c><00:01:03.719><c></span><span>my</c><00:01:03.899><c></span><span>breast</c><00:01:04.199><c></span><span>so</c><00:01:04.530><c></span><span>I</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 52, 64.549, 0.0, 'biggest insecurity was my breast so I', '最大的不安全感是我的胸部，所以我', '/ˈbɪɡɪst ˌɪnsɪˈkjʊrəti wʌz maɪ brɛst soʊ aɪ/', '<span tid="50046" class="highlight highlight-a">biggest</span><span tid="50047" class="highlight highlight-a">insecurity</span><span>was</span><span>my</span><span tid="50048" class="highlight highlight-a">breast</span><span>so</span><span>I</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 53, 64.559, 0.0, 'biggest insecurity was my breast so I wanted<00:01:05.070><c> to</c><00:01:05.369><c> more</c><00:01:06.330><c> or</c><00:01:06.420><c> less</c><00:01:06.450><c> go</c><00:01:06.689><c> back</c><00:01:06.840><c> to</c><00:01:07.020><c> what</c>', '最大的不安全感是我的胸部，所以我想或多或少回到它们', '/ˈbɪɡɪst ˌɪnsɪˈkjʊrəti wʌz maɪ brɛst soʊ aɪ ˈwɑːntɪd tu mɔːr ɔːr lɛs ɡoʊ bæk tu wʌt/', '<span>biggest</span><span>insecurity</span><span>was</span><span>my</span><span>breast</span><span>so</span><span>I</span><span>wanted<00:01:05.070><c></span><span>to</c><00:01:05.369><c></span><span>more</c><00:01:06.330><c></span><span>or</c><00:01:06.420><c></span><span>less</c><00:01:06.450><c></span><span>go</c><00:01:06.689><c></span><span>back</c><00:01:06.840><c></span><span>to</c><00:01:07.020><c></span><span>what</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 54, 67.16, 0.0, 'wanted to more or less go back to what', '想或多或少回到它们', '/ˈwɑːntɪd tu mɔːr ɔːr lɛs ɡoʊ bæk tu wʌt/', '<span tid="50049" class="highlight highlight-a">wanted</span><span>to</span><span pid="503" class="highlight highlight-i">more or less</span><span pid="504" class="highlight highlight-d">go back to</span><span>what</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 55, 67.17, 0.0, 'wanted to more or less go back to what they<00:01:07.290><c> normally</c><00:01:07.439><c> were</c><00:01:07.830><c> and</c><00:01:08.270><c> once</c><00:01:09.270><c> I</c><00:01:09.390><c> did</c><00:01:09.600><c> that</c><00:01:09.630><c> I</c>', '想或多或少回到它们原来的样子，一旦我那样做了，我', '/ˈwɑːntɪd tu mɔːr ɔːr lɛs ɡoʊ bæk tu wʌt ðeɪ ˈnɔːrməli wɜːr ænd wʌns aɪ dɪd ðæt aɪ/', '<span>wanted</span><span>to</span><span>more</span><span>or</span><span>less</span><span>go</span><span>back</span><span>to</span><span>what</span><span>they<00:01:07.290><c></span><span>normally</c><00:01:07.439><c></span><span>were</c><00:01:07.830><c></span><span>and</c><00:01:08.270><c></span><span>once</c><00:01:09.270><c></span><span>I</c><00:01:09.390><c></span><span>did</c><00:01:09.600><c></span><span>that</c><00:01:09.630><c></span><span>I</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 56, 70.01, 0.0, 'they normally were and once I did that I', '它们原来的样子，一旦我那样做了，我', '/ðeɪ ˈnɔːrməli wɜːr ænd wʌns aɪ dɪd ðæt aɪ/', '<span>they</span><span tid="50050" class="highlight highlight-a">normally</span><span>were</span><span>and</span><span>once</span><span>I</span><span>did</span><span>that</span><span>I</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 57, 70.02, 0.0, 'they normally were and once I did that I started<00:01:10.170><c> garnering</c><00:01:10.830><c> all</c><00:01:11.040><c> of</c><00:01:11.130><c> this</c><00:01:11.220><c> attention</c>', '它们原来的样子，一旦我那样做了，我开始获得所有这些关注', '/ðeɪ ˈnɔːrməli wɜːr ænd wʌns aɪ dɪd ðæt aɪ ˈstɑːrtɪd ˈɡɑːrnərɪŋ ɔːl ʌv ðɪs əˈtɛnʃən/', '<span>they</span><span>normally</span><span>were</span><span>and</span><span>once</span><span>I</span><span>did</span><span>that</span><span>I</span><span>started<00:01:10.170><c></span><span>garnering</c><00:01:10.830><c></span><span>all</c><00:01:11.040><c></span><span>of</c><00:01:11.130><c></span><span>this</c><00:01:11.220><c></span><span>attention</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 58, 71.48, 0.0, 'started garnering all of this attention', '开始获得所有这些关注', '/ˈstɑːrtɪd ˈɡɑːrnərɪŋ ɔːl ʌv ðɪs əˈtɛnʃən/', '<span>started</span><span tid="50051" class="highlight highlight-a">garnering</span><span>all</span><span>of</span><span>this</span><span tid="50052" class="highlight highlight-a">attention</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 59, 71.49, 0.0, 'started garnering all of this attention from<00:01:11.909><c> men</c><00:01:12.780><c> and</c><00:01:13.140><c> I</c><00:01:13.590><c> was</c><00:01:13.799><c> never</c><00:01:14.010><c> used</c><00:01:14.280><c> to</c><00:01:14.460><c> it</c><00:01:14.610><c> and</c>', '开始获得所有这些来自男性的关注，我从未习惯过，而且', '/ˈstɑːrtɪd ˈɡɑːrnərɪŋ ɔːl ʌv ðɪs əˈtɛnʃən frʌm mɛn ænd aɪ wʌz ˈnɛvər juːzd tu ɪt ænd/', '<span>started</span><span>garnering</span><span>all</span><span>of</span><span>this</span><span>attention</span><span>from<00:01:11.909><c></span><span>men</c><00:01:12.780><c></span><span>and</c><00:01:13.140><c></span><span>I</c><00:01:13.590><c></span><span>was</c><00:01:13.799><c></span><span>never</c><00:01:14.010><c></span><span>used</c><00:01:14.280><c></span><span>to</c><00:01:14.460><c></span><span>it</c><00:01:14.610><c></span><span>and</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 60, 74.75, 0.0, 'from men and I was never used to it and', '来自男人，我从未习惯过，而且', '/frʌm mɛn ænd aɪ wʌz ˈnɛvər juzd tu ɪt ænd/', '<span>from</span><span>men</span><span>and</span><span>I</span><span>was</span><span>never</span><span>used</span><span>to</span><span>it</span><span>and</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 61, 74.76, 0.0, 'from men and I was never used to it and I<00:01:14.939><c> felt</c><00:01:15.210><c> like</c><00:01:15.390><c> unless</c><00:01:16.229><c> I</c><00:01:16.850><c> held</c><00:01:17.850><c> onto</c><00:01:18.030><c> it</c><00:01:18.240><c> and</c>', '来自男人，我从未习惯过，而且我觉得除非我紧紧抓住它，并且', '/frʌm mɛn ænd aɪ wʌz ˈnɛvər juzd tu ɪt ænd aɪ fɛlt laɪk ənˈlɛs aɪ hɛld ˈɑntu ɪt ænd/', '<span>from</span><span>men</span><span>and</span><span>I</span><span>was</span><span>never</span><span>used</span><span>to</span><span>it</span><span>and</span><span>I<00:01:14.939><c></span><span>felt</c><00:01:15.210><c></span><span>like</c><00:01:15.390><c></span><span>unless</c><00:01:16.229><c></span><span>I</c><00:01:16.850><c></span><span>held</c><00:01:17.850><c></span><span>onto</c><00:01:18.030><c></span><span>it</c><00:01:18.240><c></span><span>and</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 62, 78.59, 0.0, 'I felt like unless I held onto it and', '我觉得除非我紧紧抓住它，并且', '/aɪ fɛlt laɪk ənˈlɛs aɪ hɛld ˈɑntu ɪt ænd/', '<span>I</span><span>felt</span><span>like</span><span>unless</span><span>I</span><span>held</span><span>onto</span><span>it</span><span>and</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 63, 78.6, 0.0, 'I felt like unless I held onto it and kind<00:01:19.170><c> of</c><00:01:19.759><c> did</c><00:01:20.759><c> what</c><00:01:20.970><c> was</c><00:01:21.090><c> asked</c><00:01:21.450><c> of</c><00:01:21.540><c> me</c><00:01:21.689><c> or</c><00:01:21.840><c> what</c>', '我觉得除非我紧紧抓住它，并且有点按照要求去做，或者按照', '/aɪ fɛlt laɪk ənˈlɛs aɪ hɛld ˈɑntu ɪt ænd kaɪnd əv dɪd wʌt wʌz æskt əv mi ɔr wʌt/', '<span>I</span><span>felt</span><span>like</span><span>unless</span><span>I</span><span>held</span><span>onto</span><span>it</span><span>and</span><span>kind<00:01:19.170><c></span><span>of</c><00:01:19.759><c></span><span>did</c><00:01:20.759><c></span><span>what</c><00:01:20.970><c></span><span>was</c><00:01:21.090><c></span><span>asked</c><00:01:21.450><c></span><span>of</c><00:01:21.540><c></span><span>me</c><00:01:21.689><c></span><span>or</c><00:01:21.840><c></span><span>what</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 64, 81.95, 0.0, 'kind of did what was asked of me or what', '有点按照要求去做，或者按照', '/kaɪnd əv dɪd wʌt wʌz æskt əv mi ɔr wʌt/', '<span pid="505" class="highlight highlight-i">kind of</span><span>did</span><span>what</span><span>was</span><span tid="50053" class="highlight highlight-a">asked</span><span>of</span><span>me</span><span>or</span><span>what</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 65, 81.96, 0.0, 'kind of did what was asked of me or what was<00:01:22.080><c> expected</c><00:01:22.439><c> of</c><00:01:22.680><c> me</c><00:01:22.740><c> it</c><00:01:22.979><c> would</c><00:01:23.100><c> go</c><00:01:23.220><c> away</c><00:01:23.369><c> and</c>', '有点按照要求去做，或者按照对我的期望去做，它就会消失，而且', '/kaɪnd əv dɪd wʌt wʌz æskt əv mi ɔr wʌt wʌz ɪkˈspɛktɪd əv mi ɪt wʊd goʊ əˈweɪ ænd/', '<span>kind</span><span>of</span><span>did</span><span>what</span><span>was</span><span>asked</span><span>of</span><span>me</span><span>or</span><span>what</span><span>was<00:01:22.080><c></span><span>expected</c><00:01:22.439><c></span><span>of</c><00:01:22.680><c></span><span>me</c><00:01:22.740><c></span><span>it</c><00:01:22.979><c></span><span>would</c><00:01:23.100><c></span><span>go</c><00:01:23.220><c></span><span>away</c><00:01:23.369><c></span><span>and</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 66, 84.28, 0.0, 'was expected of me it would go away and', '按照对我的期望去做，它就会消失，而且', '/wʌz ɪkˈspɛktɪd əv mi ɪt wʊd goʊ əˈweɪ ænd/', '<span>was</span><span tid="50054" class="highlight highlight-a">expected</span><span>of</span><span>me</span><span>it</span><span>would</span><span pid="506" class="highlight highlight-d">go away</span><span>and</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 67, 84.29, 0.0, 'was expected of me it would go away and after<00:01:25.290><c> feeling</c><00:01:25.770><c> what</c><00:01:25.890><c> it</c><00:01:25.979><c> was</c><00:01:26.100><c> like</c><00:01:26.340><c> that</c>', '按照对我的期望去做，它就会消失，而且在感受了那种感觉之后', '/wʌz ɪkˈspɛktɪd əv mi ɪt wʊd goʊ əˈweɪ ænd ˈæftər ˈfilɪŋ wʌt ɪt wʌz laɪk ðæt/', '<span>was</span><span>expected</span><span>of</span><span>me</span><span>it</span><span>would</span><span>go</span><span>away</span><span>and</span><span>after<00:01:25.290><c></span><span>feeling</c><00:01:25.770><c></span><span>what</c><00:01:25.890><c></span><span>it</c><00:01:25.979><c></span><span>was</c><00:01:26.100><c></span><span>like</c><00:01:26.340><c></span><span>that</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 68, 86.57, 0.0, 'after feeling what it was like that', '在感受了那种感觉之后', '/ˈæftər ˈfilɪŋ wʌt ɪt wʌz laɪk ðæt/', '<span>after</span><span tid="50055" class="highlight highlight-a">feeling</span><span>what</span><span>it</span><span>was</span><span>like</span><span>that</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 69, 86.58, 0.0, 'after feeling what it was like that validation<00:01:27.270><c> and</c><00:01:27.509><c> you</c><00:01:27.930><c> know</c><00:01:28.020><c> the</c><00:01:28.520><c> compliments</c>', '在感受了那种认可和你知道的赞美之后', '/ˈæftər ˈfilɪŋ wʌt ɪt wʌz laɪk ðæt ˌvælɪˈdeɪʃən ænd ju noʊ ðə ˈkɑmplɪmənts/', '<span>after</span><span>feeling</span><span>what</span><span>it</span><span>was</span><span>like</span><span>that</span><span>validation<00:01:27.270><c></span><span>and</c><00:01:27.509><c></span><span>you</c><00:01:27.930><c></span><span>know</c><00:01:28.020><c></span><span>the</c><00:01:28.520><c></span><span>compliments</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 70, 89.51, 0.0, 'validation and you know the compliments', '认可和你知道的赞美', '/ˌvælɪˈdeɪʃən ænd ju noʊ ðə ˈkɑmplɪmənts/', '<span tid="50056" class="highlight highlight-a">validation</span><span>and</span><span pid="507" class="highlight highlight-i">you know</span><span>the</span><span tid="50057" class="highlight highlight-a">compliments</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 71, 89.52, 0.0, 'validation and you know the compliments for<00:01:29.670><c> the</c><00:01:29.759><c> first</c><00:01:30.000><c> time</c><00:01:30.270><c> I</c><00:01:30.600><c> did</c><00:01:30.960><c> not</c><00:01:31.110><c> want</c><00:01:31.320><c> that</c>', '认可和你知道的赞美，第一次我不想要那种', '/ˌvælɪˈdeɪʃən ænd ju noʊ ðə ˈkɑmplɪmənts fɔr ðə fɜrst taɪm aɪ dɪd nɑt wɑnt ðæt/', '<span>validation</span><span>and</span><span>you</span><span>know</span><span>the</span><span>compliments</span><span>for<00:01:29.670><c></span><span>the</c><00:01:29.759><c></span><span>first</c><00:01:30.000><c></span><span>time</c><00:01:30.270><c></span><span>I</c><00:01:30.600><c></span><span>did</c><00:01:30.960><c></span><span>not</c><00:01:31.110><c></span><span>want</c><00:01:31.320><c></span><span>that</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 72, 91.37, 0.0, 'for the first time I did not want that', '第一次我不想要那种', '/fɔr ðə fɜrst taɪm aɪ dɪd nɑt wɑnt ðæt/', '<span pid="508" class="highlight highlight-i">for the first time</span><span>I</span><span>did not</span><span tid="50058" class="highlight highlight-a">want</span><span>that</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 73, 91.38, 0.0, 'for the first time I did not want that to<00:01:31.500><c> go</c><00:01:31.710><c> away</c><00:01:31.740><c> hmm</c><00:01:32.840><c> you</c><00:01:33.840><c> were</c><00:01:33.869><c> spotted</c>', '第一次我不想要那种感觉消失。嗯，你被发现了。', '/fɔr ðə fɜrst taɪm aɪ dɪd nɑt wɑnt ðæt tu goʊ əˈweɪ hʌm ju wɜr ˈspɑtɪd/', '<span>for</span><span>the</span><span>first</span><span>time</span><span>I</span><span>did</span><span>not</span><span>want</span><span>that</span><span>to<00:01:31.500><c></span><span>go</c><00:01:31.710><c></span><span>away</c><00:01:31.740><c></span><span>hmm</c><00:01:32.840><c></span><span>you</c><00:01:33.840><c></span><span>were</c><00:01:33.869><c></span><span>spotted</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 74, 94.999, 0.0, 'to go away hmm you were spotted', '消失。嗯，你被发现了。', '/tu goʊ əˈweɪ hʌm ju wɜr ˈspɑtɪd/', '<span pid="509" class="highlight highlight-d">to go away</span><span>hmm</span><span>you</span><span>were</span><span tid="50059" class="highlight highlight-a">spotted</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 75, 95.009, 0.0, 'to go away hmm you were spotted I<00:01:35.040><c> think</c><00:01:35.520><c> honest</c><00:01:35.880><c> Rittman</c><00:01:36.180><c> there</c><00:01:36.329><c> you</c><00:01:36.450><c> were</c>', '消失。嗯，你被发现了。我想诚实的里特曼，你就在那里。', '/tu goʊ əˈweɪ hʌm ju wɜr ˈspɑtɪd aɪ θɪŋk ˈɑnɪst ˈrɪtmən ðɛr ju wɜr/', '<span>to</span><span>go</span><span>away</span><span>hmm</span><span>you</span><span>were</span><span>spotted</span><span>I<00:01:35.040><c></span><span>think</c><00:01:35.520><c></span><span>honest</c><00:01:35.880><c></span><span>Rittman</c><00:01:36.180><c></span><span>there</c><00:01:36.329><c></span><span>you</c><00:01:36.450><c></span><span>were</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 76, 96.59, 0.0, 'I think honest Rittman there you were', '我想诚实的里特曼，你就在那里。', '/aɪ θɪŋk ˈɑnɪst ˈrɪtmən ðɛr ju wɜr/', '<span>I</span><span>think</span><span tid="50060" class="highlight highlight-a">honest</span><span>Rittman</span><span>there</span><span>you</span><span>were</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 77, 96.6, 0.0, 'I think honest Rittman there you were you<00:01:36.810><c> were</c><00:01:36.990><c> a</c><00:01:37.259><c> young</c><00:01:37.470><c> graduate</c><00:01:37.710><c> wanting</c><00:01:38.400><c> to</c>', '我想诚实的里特曼，你就在那里。你是一个年轻的毕业生，想要', '/aɪ θɪŋk ˈɑnɪst ˈrɪtmən ðɛr ju wɜr ju wɜr ə jʌŋ ˈɡrædʒuət ˈwɑntɪŋ tu/', '<span>I</span><span>think</span><span>honest</span><span>Rittman</span><span>there</span><span>you</span><span>were</span><span>you<00:01:36.810><c></span><span>were</c><00:01:36.990><c></span><span>a</c><00:01:37.259><c></span><span>young</c><00:01:37.470><c></span><span>graduate</c><00:01:37.710><c></span><span>wanting</c><00:01:38.400><c></span><span>to</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 78, 98.539, 0.0, 'you were a young graduate wanting to', '你是一个年轻的毕业生，想要', '/ju wɜr ə jʌŋ ˈɡrædʒuət ˈwɑntɪŋ tu/', '<span>you</span><span>were</span><span>a</span><span tid="50061" class="highlight highlight-a">young</span><span tid="50062" class="highlight highlight-a">graduate</span><span>wanting</span><span>to</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 79, 98.549, 0.0, 'you were a young graduate wanting to sort<00:01:39.000><c> of</c><00:01:39.060><c> find</c><00:01:39.420><c> a</c><00:01:39.570><c> job</c><00:01:39.780><c> and</c><00:01:40.140><c> and</c><00:01:40.590><c> you</c><00:01:40.710><c> were</c>', '你是一个年轻的毕业生，想要找份工作，而且你', '/ju wɜr ə jʌŋ ˈɡrædʒuət ˈwɑntɪŋ tu sɔrt əv faɪnd ə dʒɑb ænd ænd ju wɜr/', '<span>you</span><span>were</span><span>a</span><span>young</span><span>graduate</span><span>wanting</span><span>to</span><span>sort<00:01:39.000><c></span><span>of</c><00:01:39.060><c></span><span>find</c><00:01:39.420><c></span><span>a</c><00:01:39.570><c></span><span>job</c><00:01:39.780><c></span><span>and</c><00:01:40.140><c></span><span>and</c><00:01:40.590><c></span><span>you</c><00:01:40.710><c></span><span>were</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 80, 100.819, 0.0, 'sort of find a job and and you were', '找份工作，而且你', '/sɔrt əv faɪnd ə dʒɑb ænd ænd ju wɜr/', '<span pid="510" class="highlight highlight-i">sort of</span><span>find</span><span>a</span><span>job</span><span>and</span><span>and</span><span>you</span><span>were</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 81, 100.829, 0.0, 'sort of find a job and and you were spotted<00:01:41.130><c> on</c><00:01:41.280><c> the</c><00:01:41.340><c> street</c><00:01:41.670><c> by</c><00:01:42.000><c> a</c><00:01:42.030><c> guy</c><00:01:42.299><c> who</c><00:01:42.360><c> said</c>', '找份工作，而且你在街上被一个家伙发现，他说', '/sɔrt əv faɪnd ə dʒɑb ænd ænd ju wɜr ˈspɑtɪd ɑn ðə strit baɪ ə ɡaɪ hu sɛd/', '<span>sort</span><span>of</span><span>find</span><span>a</span><span>job</span><span>and</span><span>and</span><span>you</span><span>were</span><span>spotted<00:01:41.130><c></span><span>on</c><00:01:41.280><c></span><span>the</c><00:01:41.340><c></span><span>street</c><00:01:41.670><c></span><span>by</c><00:01:42.000><c></span><span>a</c><00:01:42.030><c></span><span>guy</c><00:01:42.299><c></span><span>who</c><00:01:42.360><c></span><span>said</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 82, 102.679, 0.0, 'spotted on the street by a guy who said', '在街上被一个家伙发现，他说', '/ˈspɑtɪd ɑn ðə strit baɪ ə ɡaɪ hu sɛd/', '<span tid="50063" class="highlight highlight-a">spotted</span><span>on</span><span>the</span><span>street</span><span>by</span><span>a</span><span>guy</span><span>who</span><span>said</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 83, 102.689, 0.0, 'spotted on the street by a guy who said I<00:01:42.810><c> I</c><00:01:42.840><c> can</c><00:01:43.640><c> work</c><00:01:44.640><c> with</c><00:01:44.880><c> you</c><00:01:45.090><c> and</c><00:01:45.500><c> clearly</c><00:01:46.500><c> he</c>', '在街上被一个家伙发现，他说：“我，我可以和你合作。”显然他', '/ˈspɑtɪd ɑn ðə strit baɪ ə ɡaɪ hu sɛd aɪ aɪ kæn wɜrk wɪð ju ænd ˈklɪrli hi/', '<span>spotted</span><span>on</span><span>the</span><span>street</span><span>by</span><span>a</span><span>guy</span><span>who</span><span>said</span><span>I<00:01:42.810><c></span><span>I</c><00:01:42.840><c></span><span>can</c><00:01:43.640><c></span><span>work</c><00:01:44.640><c></span><span>with</c><00:01:44.880><c></span><span>you</c><00:01:45.090><c></span><span>and</c><00:01:45.500><c></span><span>clearly</c><00:01:46.500><c></span><span>he</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 84, 106.96, 0.0, 'I I can work with you and clearly he', '我，我可以和你合作。显然他', '/aɪ aɪ kæn wɜrk wɪð ju ænd ˈklɪrli hi/', '<span>I</span><span>I</span><span>can</span><span>work</span><span>with</span><span>you</span><span>and</span><span tid="50064" class="highlight highlight-a">clearly</span><span>he</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 85, 106.97, 0.0, 'I I can work with you and clearly he opened<00:01:47.970><c> up</c><00:01:48.060><c> and</c><00:01:48.240><c> said</c><00:01:48.360><c> it''s</c><00:01:48.869><c> the</c><00:01:49.020><c> porn</c>', '我，我可以和你合作。显然他坦白说这是色情', '/aɪ aɪ kæn wɜrk wɪð ju ænd ˈklɪrli hi ˈoʊpənd ʌp ænd sɛd ɪts ðə pɔrn/', '<span>I</span><span>I</span><span>can</span><span>work</span><span>with</span><span>you</span><span>and</span><span>clearly</span><span>he</span><span>opened<00:01:47.970><c></span><span>up</c><00:01:48.060><c></span><span>and</c><00:01:48.240><c></span><span>said</c><00:01:48.360><c></span><span>it''s</c><00:01:48.869><c></span><span>the</c><00:01:49.020><c></span><span>porn</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 86, 109.219, 0.0, 'opened up and said it''s the porn', '坦白说这是色情', '/ˈoʊpənd ʌp ænd sɛd ɪts ðə pɔrn/', '<span>opened</span><span>up</span><span>and</span><span>said</span><span>it''s</span><span>the</span><span tid="50065" class="highlight highlight-a">porn</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 87, 109.229, 0.0, 'opened up and said it''s the porn business', '坦白说这是色情行业', '/ˈoʊpənd ʌp ænd sɛd ɪts ðə pɔrn ˈbɪznəs/', '<span>opened</span><span>up</span><span>and</span><span>said</span><span>it''s</span><span>the</span><span tid="50066" class="highlight highlight-a">porn</span><span>business</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 88, 110.08, 0.0, 'business', '行业', '/ˈbɪznəs/', '<span tid="50067" class="highlight highlight-a">business</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 89, 110.09, 0.0, 'business what<00:01:51.090><c> was</c><00:01:51.329><c> it</c><00:01:51.479><c> in</c><00:01:51.600><c> you</c><00:01:51.810><c> that</c>', '行业。你内心是什么？', '/ˈbɪznəs wʌt wʌz ɪt ɪn ju ðæt/', '<span>business</span><span>what<00:01:51.090><c></span><span>was</c><00:01:51.329><c></span><span>it</c><00:01:51.479><c></span><span>in</c><00:01:51.600><c></span><span>you</c><00:01:51.810><c></span><span>that</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 90, 113.01, 0.0, 'what was it in you that', '你身上有什么东西', '/wʌt wʌz ɪt ɪn juː ðæt/', '<span>what</span><span>was</span><span>it</span><span>in</span><span>you</span><span>that</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 91, 113.02, 0.0, 'what was it in you that from<00:01:53.680><c> far</c><00:01:53.920><c> from</c><00:01:54.130><c> running</c><00:01:54.430><c> away</c><00:01:54.520><c> we</c><00:01:54.880><c> was</c><00:01:55.180><c> drawn</c>', '你身上有什么东西，从远处，从逃跑中，我们被吸引', '/wʌt wʌz ɪt ɪn juː ðæt frʌm fɑːr frʌm ˈrʌnɪŋ əˈweɪ wiː wʌz drɔːn/', '<span>what</span><span>was</span><span>it</span><span>in</span><span>you</span><span>that</span><span>from<00:01:53.680><c></span><span>far</c><00:01:53.920><c></span><span>from</c><00:01:54.130><c></span><span>running</c><00:01:54.430><c></span><span>away</c><00:01:54.520><c></span><span>we</c><00:01:54.880><c></span><span>was</c><00:01:55.180><c></span><span>drawn</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 92, 115.44, 0.0, 'from far from running away we was drawn', '从远处，从逃跑中，我们被吸引', '/frʌm fɑːr frʌm ˈrʌnɪŋ əˈweɪ wiː wʌz drɔːn/', '<span>from</span><span tid="50068" class="highlight highlight-a">far</span><span>from</span><span tid="50069" class="highlight highlight-a">running</span><span>away</span><span>we</span><span>was</span><span tid="50070" class="highlight highlight-a">drawn</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 93, 115.45, 0.0, 'from far from running away we was drawn into<00:01:55.659><c> it</c><00:01:55.899><c> I</c><00:01:56.340><c> it</c><00:01:57.340><c> wasn''t</c><00:01:57.899><c> that''s</c><00:01:58.899><c> not</c><00:01:59.049><c> how</c><00:01:59.170><c> it</c>', '从远处，从逃跑中，我们被吸引进去，我，它，不是那样，不是那样', '/frʌm fɑːr frʌm ˈrʌnɪŋ əˈweɪ wiː wʌz drɔːn ˈɪntuː ɪt aɪ ɪt ˈwʌzənt ðæts nɑːt haʊ ɪt/', '<span>from</span><span>far</span><span>from</span><span>running</span><span>away</span><span>we</span><span>was</span><span>drawn</span><span>into<00:01:55.659><c></span><span>it</c><00:01:55.899><c></span><span>I</c><00:01:56.340><c></span><span>it</c><00:01:57.340><c></span><span>wasn''t</c><00:01:57.899><c></span><span>that''s</c><00:01:58.899><c></span><span>not</c><00:01:59.049><c></span><span>how</c><00:01:59.170><c></span><span>it</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 94, 119.28, 0.0, 'into it I it wasn''t that''s not how it', '进去，我，它，不是那样，不是那样', '/ˈɪntuː ɪt aɪ ɪt ˈwʌzənt ðæts nɑːt haʊ ɪt/', '<span>into</span><span>it</span><span>I</span><span>it</span><span>wasn''t</span><span>that''s</span><span>not</span><span>how</span><span>it</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 95, 119.29, 0.0, 'into it I it wasn''t that''s not how it was<00:01:59.439><c> it</c><00:01:59.619><c> wasn''t</c><00:01:59.740><c> just</c><00:01:59.890><c> hey</c><00:02:00.189><c> do</c><00:02:00.399><c> you</c><00:02:00.460><c> want</c><00:02:00.610><c> to</c>', '进去，我，它，不是那样，不是那样，它不只是，嘿，你想', '/ˈɪntuː ɪt aɪ ɪt ˈwʌzənt ðæts nɑːt haʊ ɪt wʌz ɪt ˈwʌzənt dʒʌst heɪ duː juː wɑːnt tuː/', '<span>into</span><span>it</span><span>I</span><span>it</span><span>wasn''t</span><span>that''s</span><span>not</span><span>how</span><span>it</span><span>was<00:01:59.439><c></span><span>it</c><00:01:59.619><c></span><span>wasn''t</c><00:01:59.740><c></span><span>just</c><00:01:59.890><c></span><span>hey</c><00:02:00.189><c></span><span>do</c><00:02:00.399><c></span><span>you</c><00:02:00.460><c></span><span>want</c><00:02:00.610><c></span><span>to</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 96, 120.66, 0.0, 'was it wasn''t just hey do you want to', '它不只是，嘿，你想', '/wʌz ɪt ˈwʌzənt dʒʌst heɪ duː juː wɑːnt tuː/', '<span>was</span><span>it</span><span>wasn''t</span><span>just</span><span>hey</span><span>do</span><span>you</span><span>want</span><span>to</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 97, 120.67, 0.0, 'was it wasn''t just hey do you want to come<00:02:00.790><c> to</c><00:02:00.939><c> porn</c><00:02:01.240><c> it</c><00:02:01.420><c> was</c><00:02:01.540><c> more</c><00:02:01.750><c> so</c><00:02:02.020><c> oh</c><00:02:02.290><c> you''re</c>', '它不只是，嘿，你想来拍色情片，它更像是，哦，你', '/wʌz ɪt ˈwʌzənt dʒʌst heɪ duː juː wɑːnt tuː kʌm tuː pɔːrn ɪt wʌz mɔːr soʊ oʊ jʊr/', '<span>was</span><span>it</span><span>wasn''t</span><span>just</span><span>hey</span><span>do</span><span>you</span><span>want</span><span>to</span><span>come<00:02:00.790><c></span><span>to</c><00:02:00.939><c></span><span>porn</c><00:02:01.240><c></span><span>it</c><00:02:01.420><c></span><span>was</c><00:02:01.540><c></span><span>more</c><00:02:01.750><c></span><span>so</c><00:02:02.020><c></span><span>oh</c><00:02:02.290><c></span><span>you''re</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 98, 122.85, 0.0, 'come to porn it was more so oh you''re', '来拍色情片，它更像是，哦，你', '/kʌm tuː pɔːrn ɪt wʌz mɔːr soʊ oʊ jʊr/', '<span tid="50071" class="highlight highlight-a">come</span><span>to</span><span tid="50072" class="highlight highlight-a">porn</span><span>it</span><span>was</span><span>more</span><span>so</span><span>oh</span><span>you''re</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 99, 122.86, 0.0, 'come to porn it was more so oh you''re beautiful<00:02:03.070><c> like</c><00:02:03.700><c> would</c><00:02:03.939><c> you</c><00:02:04.030><c> like</c><00:02:04.090><c> to</c><00:02:04.299><c> do</c><00:02:04.390><c> some</c>', '来拍色情片，它更像是，哦，你很漂亮，比如，你想做一些', '/kʌm tuː pɔːrn ɪt wʌz mɔːr soʊ oʊ jʊr ˈbjuːtɪfəl laɪk wʊd juː laɪk tuː duː sʌm/', '<span>come</span><span>to</span><span>porn</span><span>it</span><span>was</span><span>more</span><span>so</span><span>oh</span><span>you''re</span><span>beautiful<00:02:03.070><c></span><span>like</c><00:02:03.700><c></span><span>would</c><00:02:03.939><c></span><span>you</c><00:02:04.030><c></span><span>like</c><00:02:04.090><c></span><span>to</c><00:02:04.299><c></span><span>do</c><00:02:04.390><c></span><span>some</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 100, 124.56, 0.0, 'beautiful like would you like to do some', '漂亮，比如，你想做一些', '/ˈbjuːtɪfəl laɪk wʊd juː laɪk tuː duː sʌm/', '<span tid="50073" class="highlight highlight-a">beautiful</span><span>like</span><span>would</span><span>you</span><span>like</span><span>to</span><span>do</span><span>some</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 101, 124.57, 0.0, 'beautiful like would you like to do some modeling<00:02:05.080><c> oh</c><00:02:05.380><c> you</c><00:02:06.340><c> know</c><00:02:06.430><c> you</c><00:02:06.520><c> have</c><00:02:06.640><c> a</c><00:02:06.670><c> great</c>', '漂亮，比如，你想做一些模特工作，哦，你知道，你有一个很棒', '/ˈbjuːtɪfəl laɪk wʊd juː laɪk tuː duː sʌm ˈmɑːdəlɪŋ oʊ juː noʊ juː hæv ə greɪt/', '<span>beautiful</span><span>like</span><span>would</span><span>you</span><span>like</span><span>to</span><span>do</span><span>some</span><span>modeling<00:02:05.080><c></span><span>oh</c><00:02:05.380><c></span><span>you</c><00:02:06.340><c></span><span>know</c><00:02:06.430><c></span><span>you</c><00:02:06.520><c></span><span>have</c><00:02:06.640><c></span><span>a</c><00:02:06.670><c></span><span>great</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 102, 126.96, 0.0, 'modeling oh you know you have a great', '模特工作，哦，你知道，你有一个很棒', '/ˈmɑːdəlɪŋ oʊ juː noʊ juː hæv ə greɪt/', '<span tid="50074" class="highlight highlight-a">modeling</span><span>oh</span><span>you</span><span>know</span><span>you</span><span>have</span><span>a</span><span tid="50075" class="highlight highlight-a">great</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 103, 126.97, 0.0, 'modeling oh you know you have a great body<00:02:07.119><c> like</c><00:02:07.420><c> I</c><00:02:07.509><c> think</c><00:02:07.570><c> you''d</c><00:02:07.780><c> be</c><00:02:07.869><c> great</c><00:02:07.990><c> nude</c>', '模特工作，哦，你知道，你有一个很棒的身材，比如，我觉得你会很适合裸体', '/ˈmɑːdəlɪŋ oʊ juː noʊ juː hæv ə greɪt ˈbɑːdi laɪk aɪ θɪŋk jud biː greɪt nuːd/', '<span>modeling</span><span>oh</span><span>you</span><span>know</span><span>you</span><span>have</span><span>a</span><span>great</span><span>body<00:02:07.119><c></span><span>like</c><00:02:07.420><c></span><span>I</c><00:02:07.509><c></span><span>think</c><00:02:07.570><c></span><span>you''d</c><00:02:07.780><c></span><span>be</c><00:02:07.869><c></span><span>great</c><00:02:07.990><c></span><span>nude</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 104, 128.339, 0.0, 'body like I think you''d be great nude', '身材，比如，我觉得你会很适合裸体', '/ˈbɑːdi laɪk aɪ θɪŋk jud biː greɪt nuːd/', '<span>body</span><span>like</span><span>I</span><span>think</span><span>you''d</span><span>be</span><span tid="50076" class="highlight highlight-a">great</span><span tid="50077" class="highlight highlight-a">nude</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 105, 128.349, 0.0, 'body like I think you''d be great nude modeling<00:02:08.890><c> things</c><00:02:09.640><c> like</c><00:02:09.819><c> that</c><00:02:10.000><c> and</c><00:02:10.300><c> after</c><00:02:10.840><c> I</c>', '身材，比如，我觉得你会很适合裸体模特之类的事情，之后我', '/ˈbɑːdi laɪk aɪ θɪŋk jud biː greɪt nuːd ˈmɑːdəlɪŋ θɪŋz laɪk ðæt ænd ˈæftər aɪ/', '<span>body</span><span>like</span><span>I</span><span>think</span><span>you''d</span><span>be</span><span>great</span><span>nude</span><span>modeling<00:02:08.890><c></span><span>things</c><00:02:09.640><c></span><span>like</c><00:02:09.819><c></span><span>that</c><00:02:10.000><c></span><span>and</c><00:02:10.300><c></span><span>after</c><00:02:10.840><c></span><span>I</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 106, 130.859, 0.0, 'modeling things like that and after I', '模特之类的事情，之后我', '/ˈmɑːdəlɪŋ θɪŋz laɪk ðæt ænd ˈæftər aɪ/', '<span tid="50078" class="highlight highlight-a">modeling</span><span>things</span><span>like</span><span>that</span><span>and</span><span>after</span><span>I</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 107, 130.869, 0.0, 'modeling things like that and after I came<00:02:10.959><c> in</c><00:02:11.230><c> toward</c><00:02:11.500><c> the</c><00:02:11.800><c> studio</c><00:02:12.430><c> you</c><00:02:12.580><c> know</c><00:02:12.819><c> it</c>', '模特之类的事情，之后我走进工作室，你知道，它', '/ˈmɑːdəlɪŋ θɪŋz laɪk ðæt ænd ˈæftər aɪ keɪm ɪn tɔːrd ðə ˈstuːdioʊ juː noʊ ɪt/', '<span>modeling</span><span>things</span><span>like</span><span>that</span><span>and</span><span>after</span><span>I</span><span>came<00:02:10.959><c></span><span>in</c><00:02:11.230><c></span><span>toward</c><00:02:11.500><c></span><span>the</c><00:02:11.800><c></span><span>studio</c><00:02:12.430><c></span><span>you</c><00:02:12.580><c></span><span>know</c><00:02:12.819><c></span><span>it</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 108, 132.87, 0.0, 'came in toward the studio you know it', '走进工作室，你知道，它', '/keɪm ɪn tɔːrd ðə ˈstuːdioʊ juː noʊ ɪt/', '<span tid="50079" class="highlight highlight-d">came</span><span>in</span><span>toward</span><span>the</span><span tid="50080" class="highlight highlight-a">studio</span><span>you</span><span>know</span><span>it</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 109, 132.88, 0.0, 'came in toward the studio you know it was<00:02:13.000><c> very</c><00:02:13.720><c> respectable</c><00:02:14.200><c> it</c><00:02:14.349><c> was</c><00:02:14.440><c> a</c><00:02:14.470><c> gorgeous</c>', '走进工作室，你知道，它非常体面，它是一个华丽的', '/keɪm ɪn tɔːrd ðə ˈstuːdioʊ juː noʊ ɪt wʌz ˈveri rɪˈspɛktəbəl ɪt wʌz ə ˈɡɔːrdʒəs/', '<span>came</span><span>in</span><span>toward</span><span>the</span><span>studio</span><span>you</span><span>know</span><span>it</span><span>was<00:02:13.000><c></span><span>very</c><00:02:13.720><c></span><span>respectable</c><00:02:14.200><c></span><span>it</c><00:02:14.349><c></span><span>was</c><00:02:14.440><c></span><span>a</c><00:02:14.470><c></span><span>gorgeous</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 110, 134.97, 0.0, 'was very respectable it was a gorgeous', '非常体面，它是一个华丽的', '/wʌz ˈveri rɪˈspɛktəbəl ɪt wʌz ə ˈɡɔːrdʒəs/', '<span>was</span><span>very</span><span tid="50081" class="highlight highlight-a">respectable</span><span>it</span><span>was</span><span>a</span><span tid="50082" class="highlight highlight-a">gorgeous</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 111, 134.98, 0.0, 'was very respectable it was a gorgeous location<00:02:15.310><c> it</c><00:02:15.880><c> was</c><00:02:16.019><c> in</c><00:02:17.019><c> Miami</c><00:02:17.470><c> in</c><00:02:17.739><c> Doral</c>', '非常体面，它是一个华丽的地点，它在迈阿密，在多拉', '/wʌz ˈveri rɪˈspɛktəbəl ɪt wʌz ə ˈɡɔːrdʒəs loʊˈkeɪʃən ɪt wʌz ɪn maɪˈæmi ɪn ˈdɔːrəl/', '<span>was</span><span>very</span><span>respectable</span><span>it</span><span>was</span><span>a</span><span>gorgeous</span><span>location<00:02:15.310><c></span><span>it</c><00:02:15.880><c></span><span>was</c><00:02:16.019><c></span><span>in</c><00:02:17.019><c></span><span>Miami</c><00:02:17.470><c></span><span>in</c><00:02:17.739><c></span><span>Doral</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 112, 138.0, 0.0, 'location it was in Miami in Doral', '地点，它在迈阿密，在多拉', '/loʊˈkeɪʃən ɪt wʌz ɪn maɪˈæmi ɪn ˈdɔːrəl/', '<span tid="50083" class="highlight highlight-a">location</span><span>it</span><span>was</span><span>in</span><span>Miami</span><span>in</span><span>Doral</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 113, 138.01, 0.0, 'location it was in Miami in Doral Florida<00:02:18.870><c> it</c><00:02:19.870><c> was</c><00:02:20.170><c> clean</c><00:02:21.010><c> everyone</c><00:02:21.550><c> who</c><00:02:21.670><c> worked</c>', '地点，它在迈阿密，在多拉佛罗里达，它很干净，每个工作', '/loʊˈkeɪʃən ɪt wʌz ɪn maɪˈæmi ɪn ˈdɔːrəl ˈflɔːrɪdə ɪt wʌz kliːn ˈevriwʌn huː wɜːrkt/', '<span>location</span><span>it</span><span>was</span><span>in</span><span>Miami</span><span>in</span><span>Doral</span><span>Florida<00:02:18.870><c></span><span>it</c><00:02:19.870><c></span><span>was</c><00:02:20.170><c></span><span>clean</c><00:02:21.010><c></span><span>everyone</c><00:02:21.550><c></span><span>who</c><00:02:21.670><c></span><span>worked</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 114, 141.96, 0.0, 'Florida it was clean everyone who worked', '佛罗里达，它很干净，每个工作', '/ˈflɔːrɪdə ɪt wʌz kliːn ˈevriwʌn huː wɜːrkt/', '<span>Florida</span><span>it</span><span>was</span><span tid="50084" class="highlight highlight-a">clean</span><span>everyone</span><span>who</span><span>worked</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 115, 141.97, 0.0, 'Florida it was clean everyone who worked there<00:02:22.239><c> was</c><00:02:22.450><c> nice</c><00:02:22.750><c> all</c><00:02:23.080><c> of</c><00:02:23.170><c> their</c><00:02:23.290><c> cubicles</c>', '佛罗里达，它很干净，每个在那里工作的人都很友好，他们所有的隔间', '/ˈflɔːrɪdə ɪt wʌz kliːn ˈevriwʌn huː wɜːrkt ðɛr wʌz naɪs ɔːl ʌv ðɛr ˈkjuːbɪkəlz/', '<span>Florida</span><span>it</span><span>was</span><span>clean</span><span>everyone</span><span>who</span><span>worked</span><span>there<00:02:22.239><c></span><span>was</c><00:02:22.450><c></span><span>nice</c><00:02:22.750><c></span><span>all</c><00:02:23.080><c></span><span>of</c><00:02:23.170><c></span><span>their</c><00:02:23.290><c></span><span>cubicles</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 116, 143.759, 0.0, 'there was nice all of their cubicles', '那里的人都很友好，他们所有的隔间', '/ðɛr wʌz naɪs ɔːl ʌv ðɛr ˈkjuːbɪkəlz/', '<span>there</span><span>was</span><span tid="50085" class="highlight highlight-a">nice</span><span>all</span><span>of</span><span>their</span><span tid="50086" class="highlight highlight-a">cubicles</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 117, 143.769, 0.0, 'there was nice all of their cubicles were<00:02:24.010><c> decorated</c><00:02:24.940><c> with</c><00:02:24.970><c> family</c><00:02:25.420><c> photos</c><00:02:25.600><c> like</c>', '那里的人都很友好，他们所有的隔间都装饰着家庭照片，就像', '/ðɛr wʌz naɪs ɔːl ʌv ðɛr ˈkjuːbɪkəlz wɜːr ˈdɛkəreɪtɪd wɪð ˈfæməli ˈfoʊtoʊz laɪk/', '<span>there</span><span>was</span><span>nice</span><span>all</span><span>of</span><span>their</span><span>cubicles</span><span>were<00:02:24.010><c></span><span>decorated</c><00:02:24.940><c></span><span>with</c><00:02:24.970><c></span><span>family</c><00:02:25.420><c></span><span>photos</c><00:02:25.600><c></span><span>like</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 118, 146.009, 0.0, 'were decorated with family photos like', '都装饰着家庭照片，就像', '/wɜːr ˈdɛkəreɪtɪd wɪð ˈfæməli ˈfoʊtoʊz laɪk/', '<span>were</span><span tid="50087" class="highlight highlight-a">decorated</span><span>with</span><span>family</span><span tid="50088" class="highlight highlight-a">photos</span><span>like</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 119, 146.019, 0.0, 'were decorated with family photos like it<00:02:26.110><c> was</c><00:02:26.200><c> nothing</c><00:02:26.500><c> dodgy</c><00:02:27.430><c> or</c><00:02:27.730><c> mid</c><00:02:28.600><c> that</c><00:02:28.720><c> made</c><00:02:28.870><c> me</c>', '都装饰着家庭照片，就像它一点也不可疑或中间，那让我', '/wɜːr ˈdɛkəreɪtɪd wɪð ˈfæməli ˈfoʊtoʊz laɪk ɪt wʌz ˈnʌθɪŋ ˈdɑːdʒi ɔːr mɪd ðæt meɪd miː/', '<span>were</span><span>decorated</span><span>with</span><span>family</span><span>photos</span><span>like</span><span>it<00:02:26.110><c></span><span>was</c><00:02:26.200><c></span><span>nothing</c><00:02:26.500><c></span><span>dodgy</c><00:02:27.430><c></span><span>or</c><00:02:27.730><c></span><span>mid</c><00:02:28.600><c></span><span>that</c><00:02:28.720><c></span><span>made</c><00:02:28.870><c></span><span>me</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 120, 149.009, 0.0, 'it was nothing dodgy or mid that made me', '', '', '<span>it</span> <span>was</span> <span>nothing</span> <span>dodgy</span> <span>or</span> <span>mid</span> <span>that</span> <span>made</span> <span>me</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 121, 149.019, 0.0, 'it was nothing dodgy or mid that made me uncomfortable<00:02:29.170><c> and</c><00:02:29.950><c> after</c><00:02:30.819><c> do</c><00:02:31.299><c> I</c><00:02:31.330><c> get</c><00:02:31.630><c> the</c>', '', '', '<span>it</span> <span>was</span> <span>nothing</span> <span>dodgy</span> <span>or</span> <span>mid</span> <span>that</span> <span>made</span> <span>me</span> <span>uncomfortable<00:02:29.170><c></span> <span>and</c><00:02:29.950><c></span> <span>after</c><00:02:30.819><c></span> <span>do</c><00:02:31.299><c></span> <span>I</c><00:02:31.330><c></span> <span>get</c><00:02:31.630><c></span> <span>the</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 122, 152.25, 0.0, 'uncomfortable and after do I get the', '', '', '<span>uncomfortable</span> <span>and</span> <span>after</span> <span>do</span> <span>I</span> <span>get</span> <span>the</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 123, 152.26, 0.0, 'uncomfortable and after do I get the first<00:02:32.410><c> time</c><00:02:32.590><c> I</c><00:02:32.680><c> went</c><00:02:32.799><c> in</c><00:02:32.950><c> wasn''t</c><00:02:33.220><c> the</c><00:02:33.340><c> first</c>', '', '', '<span>uncomfortable</span> <span>and</span> <span>after</span> <span>do</span> <span>I</span> <span>get</span> <span>the</span> <span>first<00:02:32.410><c></span> <span>time</c><00:02:32.590><c></span> <span>I</c><00:02:32.680><c></span> <span>went</c><00:02:32.799><c></span> <span>in</c><00:02:32.950><c></span> <span>wasn''t</c><00:02:33.220><c></span> <span>the</c><00:02:33.340><c></span> <span>first</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 124, 153.479, 0.0, 'first time I went in wasn''t the first', '', '', '<span>first</span> <span>time</span> <span>I</span> <span>went</span> <span>in</span> <span>wasn''t</span> <span>the</span> <span>first</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 125, 153.489, 0.0, 'first time I went in wasn''t the first time<00:02:33.760><c> I</c><00:02:34.090><c> I</c><00:02:34.840><c> filmed</c><00:02:35.350><c> a</c><00:02:35.500><c> porn</c><00:02:36.100><c> movie</c><00:02:38.160><c> it</c><00:02:39.160><c> was</c><00:02:39.670><c> the</c>', '', '', '<span>first</span> <span>time</span> <span>I</span> <span>went</span> <span>in</span> <span>wasn''t</span> <span>the</span> <span>first</span> <span>time<00:02:33.760><c></span> <span>I</c><00:02:34.090><c></span> <span>I</c><00:02:34.840><c></span> <span>filmed</c><00:02:35.350><c></span> <span>a</c><00:02:35.500><c></span> <span>porn</c><00:02:36.100><c></span> <span>movie</c><00:02:38.160><c></span> <span>it</c><00:02:39.160><c></span> <span>was</c><00:02:39.670><c></span> <span>the</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 126, 160.11, 0.0, 'time I I filmed a porn movie it was the', '', '', '<span>time</span> <span>I</span> <span>I</span> <span>filmed</span> <span>a</span> <span>porn</span> <span>movie</span> <span>it</span> <span>was</span> <span>the</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 127, 160.12, 0.0, 'time I I filmed a porn movie it was the second<00:02:40.480><c> time</c><00:02:40.510><c> the</c><00:02:40.959><c> first</c><00:02:41.319><c> time</c><00:02:41.680><c> was</c><00:02:41.890><c> more</c><00:02:42.040><c> so</c>', '', '', '<span>time</span> <span>I</span> <span>I</span> <span>filmed</span> <span>a</span> <span>porn</span> <span>movie</span> <span>it</span> <span>was</span> <span>the</span> <span>second<00:02:40.480><c></span> <span>time</c><00:02:40.510><c></span> <span>the</c><00:02:40.959><c></span> <span>first</c><00:02:41.319><c></span> <span>time</c><00:02:41.680><c></span> <span>was</c><00:02:41.890><c></span> <span>more</c><00:02:42.040><c></span> <span>so</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 128, 162.3, 0.0, 'second time the first time was more so', '', '', '<span>second</span> <span>time</span> <span>the</span> <span>first</span> <span>time</span> <span>was</span> <span>more</span> <span>so</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 129, 162.31, 0.0, 'second time the first time was more so do<00:02:43.209><c> you</c><00:02:43.299><c> want</c><00:02:43.450><c> to</c><00:02:43.510><c> do</c><00:02:43.660><c> this</c><00:02:43.840><c> like</c><00:02:44.170><c> sign</c><00:02:44.650><c> the</c>', '', '', '<span>second</span> <span>time</span> <span>the</span> <span>first</span> <span>time</span> <span>was</span> <span>more</span> <span>so</span> <span>do<00:02:43.209><c></span> <span>you</c><00:02:43.299><c></span> <span>want</c><00:02:43.450><c></span> <span>to</c><00:02:43.510><c></span> <span>do</c><00:02:43.660><c></span> <span>this</c><00:02:43.840><c></span> <span>like</c><00:02:44.170><c></span> <span>sign</c><00:02:44.650><c></span> <span>the</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 130, 164.789, 0.0, 'do you want to do this like sign the', '', '', '<span>do</span> <span>you</span> <span>want</span> <span>to</span> <span>do</span> <span>this</span> <span>like</span> <span>sign</span> <span>the</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 131, 164.799, 0.0, 'do you want to do this like sign the paperwork<00:02:45.160><c> etc</c><00:02:45.819><c> etc</c><00:02:45.880><c> so</c><00:02:46.480><c> these</c><00:02:46.900><c> guys</c><00:02:47.140><c> they</c>', '', '', '<span>do</span> <span>you</span> <span>want</span> <span>to</span> <span>do</span> <span>this</span> <span>like</span> <span>sign</span> <span>the</span> <span>paperwork<00:02:45.160><c></span> <span>etc</c><00:02:45.819><c></span> <span>etc</c><00:02:45.880><c></span> <span>so</c><00:02:46.480><c></span> <span>these</c><00:02:46.900><c></span> <span>guys</c><00:02:47.140><c></span> <span>they</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 132, 167.49, 0.0, 'paperwork etc etc so these guys they', '', '', '<span>paperwork</span> <span>etc</span> <span>etc</span> <span>so</span> <span>these</span> <span>guys</span> <span>they</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 133, 167.5, 0.0, 'paperwork etc etc so these guys they just<00:02:47.530><c> saw</c><00:02:48.130><c> you</c><00:02:48.190><c> frankly</c><00:02:49.120><c> as</c><00:02:49.390><c> a</c><00:02:49.450><c> money</c><00:02:49.750><c> machine</c>', '', '', '<span>paperwork</span> <span>etc</span> <span>etc</span> <span>so</span> <span>these</span> <span>guys</span> <span>they</span> <span>just<00:02:47.530><c></span> <span>saw</c><00:02:48.130><c></span> <span>you</c><00:02:48.190><c></span> <span>frankly</c><00:02:49.120><c></span> <span>as</c><00:02:49.390><c></span> <span>a</c><00:02:49.450><c></span> <span>money</c><00:02:49.750><c></span> <span>machine</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 134, 169.92, 0.0, 'just saw you frankly as a money machine', '', '', '<span>just</span> <span>saw</span> <span>you</span> <span>frankly</span> <span>as</span> <span>a</span> <span>money</span> <span>machine</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 135, 169.93, 0.0, 'just saw you frankly as a money machine absolutely<00:02:51.390><c> but</c><00:02:52.390><c> you</c><00:02:52.420><c> still</c><00:02:52.780><c> had</c><00:02:52.930><c> no</c><00:02:53.080><c> advisors</c>', '', '', '<span>just</span> <span>saw</span> <span>you</span> <span>frankly</span> <span>as</span> <span>a</span> <span>money</span> <span>machine</span> <span>absolutely<00:02:51.390><c></span> <span>but</c><00:02:52.390><c></span> <span>you</c><00:02:52.420><c></span> <span>still</c><00:02:52.780><c></span> <span>had</c><00:02:52.930><c></span> <span>no</c><00:02:53.080><c></span> <span>advisors</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 136, 173.58, 0.0, 'absolutely but you still had no advisors', '', '', '<span>absolutely</span> <span>but</span> <span>you</span> <span>still</span> <span>had</span> <span>no</span> <span>advisors</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 137, 173.59, 0.0, 'absolutely but you still had no advisors you<00:02:53.769><c> had</c><00:02:53.920><c> no</c><00:02:54.069><c> lawyer</c>', '', '', '<span>absolutely</span> <span>but</span> <span>you</span> <span>still</span> <span>had</span> <span>no</span> <span>advisors</span> <span>you<00:02:53.769><c></span> <span>had</c><00:02:53.920><c></span> <span>no</c><00:02:54.069><c></span> <span>lawyer</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 138, 174.479, 0.0, 'you had no lawyer', '', '', '<span>you</span> <span>had</span> <span>no</span> <span>lawyer</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 139, 174.489, 0.0, 'you had no lawyer you<00:02:54.640><c> had</c><00:02:54.790><c> no</c><00:02:54.970><c> nothing</c><00:02:55.360><c> so</c><00:02:55.630><c> I</c><00:02:55.660><c> was</c><00:02:55.900><c> what</c><00:02:56.349><c> 21</c><00:02:56.680><c> year</c>', '', '', '<span>you</span> <span>had</span> <span>no</span> <span>lawyer</span> <span>you<00:02:54.640><c></span> <span>had</c><00:02:54.790><c></span> <span>no</c><00:02:54.970><c></span> <span>nothing</c><00:02:55.360><c></span> <span>so</c><00:02:55.630><c></span> <span>I</c><00:02:55.660><c></span> <span>was</c><00:02:55.900><c></span> <span>what</c><00:02:56.349><c></span> <span>21</c><00:02:56.680><c></span> <span>year</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 140, 176.82, 0.0, 'you had no nothing so I was what 21 year', '', '', '<span>you</span> <span>had</span> <span>no</span> <span>nothing</span> <span>so</span> <span>I</span> <span>was</span> <span>what</span> <span>21</span> <span>year</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 141, 176.83, 0.0, 'you had no nothing so I was what 21 year old<00:02:56.950><c> has</c><00:02:57.160><c> a</c><00:02:57.190><c> lawyer</c><00:02:57.489><c> on</c><00:02:57.700><c> retainer</c><00:02:59.010><c> I''m</c><00:03:00.010><c> just</c>', '', '', '<span>you</span> <span>had</span> <span>no</span> <span>nothing</span> <span>so</span> <span>I</span> <span>was</span> <span>what</span> <span>21</span> <span>year</span> <span>old<00:02:56.950><c></span> <span>has</c><00:02:57.160><c></span> <span>a</c><00:02:57.190><c></span> <span>lawyer</c><00:02:57.489><c></span> <span>on</c><00:02:57.700><c></span> <span>retainer</c><00:02:59.010><c></span> <span>I''m</c><00:03:00.010><c></span> <span>just</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 142, 180.24, 0.0, 'old has a lawyer on retainer I''m just', '', '', '<span>old</span> <span>has</span> <span>a</span> <span>lawyer</span> <span>on</span> <span>retainer</span> <span>I''m</span> <span>just</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 143, 180.25, 0.0, 'old has a lawyer on retainer I''m just trying<00:03:00.430><c> to</c><00:03:00.459><c> get</c><00:03:00.579><c> my</c><00:03:00.760><c> head</c><00:03:00.940><c> around</c><00:03:01.109><c> how</c>', '', '', '<span>old</span> <span>has</span> <span>a</span> <span>lawyer</span> <span>on</span> <span>retainer</span> <span>I''m</span> <span>just</span> <span>trying<00:03:00.430><c></span> <span>to</c><00:03:00.459><c></span> <span>get</c><00:03:00.579><c></span> <span>my</c><00:03:00.760><c></span> <span>head</c><00:03:00.940><c></span> <span>around</c><00:03:01.109><c></span> <span>how</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 144, 182.18, 0.0, 'trying to get my head around how', '', '', '<span>trying</span> <span>to</span> <span>get</span> <span>my</span> <span>head</span> <span>around</span> <span>how</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 145, 182.19, 0.0, 'trying to get my head around how stressful<00:03:03.190><c> this</c><00:03:04.180><c> must</c><00:03:04.450><c> have</c><00:03:04.570><c> been</c><00:03:04.660><c> and</c>', '', '', '<span>trying</span> <span>to</span> <span>get</span> <span>my</span> <span>head</span> <span>around</span> <span>how</span> <span>stressful<00:03:03.190><c></span> <span>this</c><00:03:04.180><c></span> <span>must</c><00:03:04.450><c></span> <span>have</c><00:03:04.570><c></span> <span>been</c><00:03:04.660><c></span> <span>and</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 146, 184.83, 0.0, 'stressful this must have been and', '', '', '<span>stressful</span> <span>this</span> <span>must</span> <span>have</span> <span>been</span> <span>and</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 147, 184.84, 0.0, 'stressful this must have been and whether<00:03:04.930><c> even</c><00:03:05.260><c> now</c><00:03:05.680><c> because</c><00:03:05.890><c> you</c><00:03:06.010><c> sit</c><00:03:06.250><c> here</c><00:03:06.430><c> so</c>', '', '', '<span>stressful</span> <span>this</span> <span>must</span> <span>have</span> <span>been</span> <span>and</span> <span>whether<00:03:04.930><c></span> <span>even</c><00:03:05.260><c></span> <span>now</c><00:03:05.680><c></span> <span>because</c><00:03:05.890><c></span> <span>you</c><00:03:06.010><c></span> <span>sit</c><00:03:06.250><c></span> <span>here</c><00:03:06.430><c></span> <span>so</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 148, 186.66, 0.0, 'whether even now because you sit here so', '', '', '<span>whether</span> <span>even</span> <span>now</span> <span>because</span> <span>you</span> <span>sit</span> <span>here</span> <span>so</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 149, 186.67, 0.0, 'whether even now because you sit here so poised<00:03:07.000><c> and</c><00:03:07.329><c> obviously</c><00:03:07.780><c> a</c><00:03:07.870><c> lot</c><00:03:07.930><c> of</c><00:03:08.109><c> time</c><00:03:08.380><c> has</c>', '', '', '<span>whether</span> <span>even</span> <span>now</span> <span>because</span> <span>you</span> <span>sit</span> <span>here</span> <span>so</span> <span>poised<00:03:07.000><c></span> <span>and</c><00:03:07.329><c></span> <span>obviously</c><00:03:07.780><c></span> <span>a</c><00:03:07.870><c></span> <span>lot</c><00:03:07.930><c></span> <span>of</c><00:03:08.109><c></span> <span>time</c><00:03:08.380><c></span> <span>has</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 150, 188.52, 0.0, 'poised and obviously a lot of time has', '', '', '<span>poised</span> <span>and</span> <span>obviously</span> <span>a</span> <span>lot</span> <span>of</span> <span>time</span> <span>has</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 151, 188.53, 0.0, 'poised and obviously a lot of time has passed<00:03:08.560><c> and</c><00:03:09.070><c> you''ve</c><00:03:09.160><c> moved</c><00:03:09.430><c> on</c><00:03:09.730><c> but</c><00:03:09.970><c> do</c><00:03:10.480><c> you</c>', '', '', '<span>poised</span> <span>and</span> <span>obviously</span> <span>a</span> <span>lot</span> <span>of</span> <span>time</span> <span>has</span> <span>passed<00:03:08.560><c></span> <span>and</c><00:03:09.070><c></span> <span>you''ve</c><00:03:09.160><c></span> <span>moved</c><00:03:09.430><c></span> <span>on</c><00:03:09.730><c></span> <span>but</c><00:03:09.970><c></span> <span>do</c><00:03:10.480><c></span> <span>you</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 152, 190.56, 0.0, 'passed and you''ve moved on but do you', '', '', '<span>passed</span> <span>and</span> <span>you''ve</span> <span>moved</span> <span>on</span> <span>but</span> <span>do</span> <span>you</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 153, 190.57, 0.0, 'passed and you''ve moved on but do you think<00:03:10.840><c> there</c><00:03:11.079><c> is</c><00:03:11.260><c> some</c><00:03:11.590><c> sort</c><00:03:12.010><c> of</c>', '', '', '<span>passed</span> <span>and</span> <span>you''ve</span> <span>moved</span> <span>on</span> <span>but</span> <span>do</span> <span>you</span> <span>think<00:03:10.840><c></span> <span>there</c><00:03:11.079><c></span> <span>is</c><00:03:11.260><c></span> <span>some</c><00:03:11.590><c></span> <span>sort</c><00:03:12.010><c></span> <span>of</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 154, 192.65, 0.0, 'think there is some sort of', '', '', '<span>think</span> <span>there</span> <span>is</span> <span>some</span> <span>sort</span> <span>of</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 155, 192.66, 0.0, 'think there is some sort of post-traumatic<00:03:13.660><c> stress</c><00:03:13.799><c> that</c><00:03:14.799><c> is</c><00:03:15.010><c> in</c><00:03:15.190><c> you</c>', '', '', '<span>think</span> <span>there</span> <span>is</span> <span>some</span> <span>sort</span> <span>of</span> <span>post-traumatic<00:03:13.660><c></span> <span>stress</c><00:03:13.799><c></span> <span>that</c><00:03:14.799><c></span> <span>is</c><00:03:15.010><c></span> <span>in</c><00:03:15.190><c></span> <span>you</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 156, 195.449, 0.0, 'post-traumatic stress that is in you', '', '', '<span>post-traumatic</span> <span>stress</span> <span>that</span> <span>is</span> <span>in</span> <span>you</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 157, 195.459, 0.0, 'post-traumatic stress that is in you from<00:03:15.850><c> this</c><00:03:16.000><c> experience</c><00:03:16.480><c> yes</c><00:03:17.109><c> and</c><00:03:17.560><c> I</c><00:03:18.250><c> think</c><00:03:18.940><c> it</c>', '', '', '<span>post-traumatic</span> <span>stress</span> <span>that</span> <span>is</span> <span>in</span> <span>you</span> <span>from<00:03:15.850><c></span> <span>this</c><00:03:16.000><c></span> <span>experience</c><00:03:16.480><c></span> <span>yes</c><00:03:17.109><c></span> <span>and</c><00:03:17.560><c></span> <span>I</c><00:03:18.250><c></span> <span>think</c><00:03:18.940><c></span> <span>it</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 158, 199.02, 0.0, 'from this experience yes and I think it', '', '', '<span>from</span> <span>this</span> <span>experience</span> <span>yes</span> <span>and</span> <span>I</span> <span>think</span> <span>it</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 159, 199.03, 0.0, 'from this experience yes and I think it kicks<00:03:19.239><c> in</c>', '', '', '<span>from</span> <span>this</span> <span>experience</span> <span>yes</span> <span>and</span> <span>I</span> <span>think</span> <span>it</span> <span>kicks<00:03:19.239><c></span> <span>in</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 160, 199.65, 0.0, 'kicks in', '', '', '<span>kicks</span> <span>in</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 161, 199.66, 0.0, 'kicks in mostly<00:03:20.140><c> when</c><00:03:20.350><c> I</c><00:03:20.380><c> go</c><00:03:20.560><c> out</c><00:03:20.680><c> in</c><00:03:20.769><c> public</c><00:03:20.890><c> because</c>', '', '', '<span>kicks</span> <span>in</span> <span>mostly<00:03:20.140><c></span> <span>when</c><00:03:20.350><c></span> <span>I</c><00:03:20.380><c></span> <span>go</c><00:03:20.560><c></span> <span>out</c><00:03:20.680><c></span> <span>in</c><00:03:20.769><c></span> <span>public</c><00:03:20.890><c></span> <span>because</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 162, 202.58, 0.0, 'mostly when I go out in public because', '', '', '<span>mostly</span> <span>when</span> <span>I</span> <span>go</span> <span>out</span> <span>in</span> <span>public</span> <span>because</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 163, 202.59, 0.0, 'mostly when I go out in public because the<00:03:23.590><c> stairs</c><00:03:23.920><c> I</c><00:03:24.130><c> get</c><00:03:24.310><c> I</c><00:03:24.340><c> feel</c><00:03:24.489><c> like</c><00:03:24.760><c> people</c><00:03:24.940><c> can</c>', '', '', '<span>mostly</span> <span>when</span> <span>I</span> <span>go</span> <span>out</span> <span>in</span> <span>public</span> <span>because</span> <span>the<00:03:23.590><c></span> <span>stairs</c><00:03:23.920><c></span> <span>I</c><00:03:24.130><c></span> <span>get</c><00:03:24.310><c></span> <span>I</c><00:03:24.340><c></span> <span>feel</c><00:03:24.489><c></span> <span>like</c><00:03:24.760><c></span> <span>people</c><00:03:24.940><c></span> <span>can</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 164, 205.229, 0.0, 'the stairs I get I feel like people can', '', '', '<span>the</span> <span>stairs</span> <span>I</span> <span>get</span> <span>I</span> <span>feel</span> <span>like</span> <span>people</span> <span>can</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 165, 205.239, 0.0, 'the stairs I get I feel like people can see<00:03:25.450><c> through</c><00:03:25.600><c> my</c><00:03:25.750><c> clothes</c><00:03:26.019><c> and</c><00:03:26.380><c> it</c><00:03:26.859><c> brings</c><00:03:27.069><c> me</c>', '', '', '<span>the</span> <span>stairs</span> <span>I</span> <span>get</span> <span>I</span> <span>feel</span> <span>like</span> <span>people</span> <span>can</span> <span>see<00:03:25.450><c></span> <span>through</c><00:03:25.600><c></span> <span>my</c><00:03:25.750><c></span> <span>clothes</c><00:03:26.019><c></span> <span>and</c><00:03:26.380><c></span> <span>it</c><00:03:26.859><c></span> <span>brings</c><00:03:27.069><c></span> <span>me</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 166, 207.18, 0.0, 'see through my clothes and it brings me', '', '', '<span>see</span> <span>through</span> <span>my</span> <span>clothes</span> <span>and</span> <span>it</span> <span>brings</span> <span>me</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 167, 207.19, 0.0, 'see through my clothes and it brings me deep<00:03:27.459><c> shame</c><00:03:27.730><c> it</c><00:03:28.030><c> makes</c><00:03:28.720><c> me</c><00:03:28.870><c> feel</c><00:03:29.049><c> like</c><00:03:29.290><c> it</c>', '', '', '<span>see</span> <span>through</span> <span>my</span> <span>clothes</span> <span>and</span> <span>it</span> <span>brings</span> <span>me</span> <span>deep<00:03:27.459><c></span> <span>shame</c><00:03:27.730><c></span> <span>it</c><00:03:28.030><c></span> <span>makes</c><00:03:28.720><c></span> <span>me</c><00:03:28.870><c></span> <span>feel</c><00:03:29.049><c></span> <span>like</c><00:03:29.290><c></span> <span>it</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 168, 210.24, 0.0, 'deep shame it makes me feel like it', '', '', '<span>deep</span> <span>shame</span> <span>it</span> <span>makes</span> <span>me</span> <span>feel</span> <span>like</span> <span>it</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 169, 210.25, 0.0, 'deep shame it makes me feel like it makes<00:03:30.459><c> me</c><00:03:30.519><c> feel</c><00:03:30.700><c> like</c><00:03:30.910><c> I</c><00:03:32.459><c> lost</c><00:03:33.459><c> all</c><00:03:33.760><c> right</c><00:03:33.970><c> to</c>', '', '', '<span>deep</span> <span>shame</span> <span>it</span> <span>makes</span> <span>me</span> <span>feel</span> <span>like</span> <span>it</span> <span>makes<00:03:30.459><c></span> <span>me</c><00:03:30.519><c></span> <span>feel</c><00:03:30.700><c></span> <span>like</c><00:03:30.910><c></span> <span>I</c><00:03:32.459><c></span> <span>lost</c><00:03:33.459><c></span> <span>all</c><00:03:33.760><c></span> <span>right</c><00:03:33.970><c></span> <span>to</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 170, 214.14, 0.0, 'makes me feel like I lost all right to', '', '', '<span>makes</span> <span>me</span> <span>feel</span> <span>like</span> <span>I</span> <span>lost</span> <span>all</span> <span>right</span> <span>to</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 171, 214.15, 0.0, 'makes me feel like I lost all right to my<00:03:34.239><c> privacy</c><00:03:34.290><c> which</c><00:03:35.290><c> I</c><00:03:35.380><c> did</c><00:03:35.530><c> because</c><00:03:35.799><c> then</c><00:03:35.980><c> I''m</c>', '', '', '<span>makes</span> <span>me</span> <span>feel</span> <span>like</span> <span>I</span> <span>lost</span> <span>all</span> <span>right</span> <span>to</span> <span>my<00:03:34.239><c></span> <span>privacy</c><00:03:34.290><c></span> <span>which</c><00:03:35.290><c></span> <span>I</c><00:03:35.380><c></span> <span>did</c><00:03:35.530><c></span> <span>because</c><00:03:35.799><c></span> <span>then</c><00:03:35.980><c></span> <span>I''m</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 172, 216.36, 0.0, 'my privacy which I did because then I''m', '', '', '<span>my</span> <span>privacy</span> <span>which</span> <span>I</span> <span>did</span> <span>because</span> <span>then</span> <span>I''m</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 173, 216.37, 0.0, 'my privacy which I did because then I''m one<00:03:36.609><c> Google</c><00:03:36.910><c> search</c><00:03:36.940><c> away</c><00:03:37.269><c> yeah</c><00:03:37.750><c> and</c><00:03:39.150><c> those</c>', '', '', '<span>my</span> <span>privacy</span> <span>which</span> <span>I</span> <span>did</span> <span>because</span> <span>then</span> <span>I''m</span> <span>one<00:03:36.609><c></span> <span>Google</c><00:03:36.910><c></span> <span>search</c><00:03:36.940><c></span> <span>away</c><00:03:37.269><c></span> <span>yeah</c><00:03:37.750><c></span> <span>and</c><00:03:39.150><c></span> <span>those</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 174, 220.14, 0.0, 'one Google search away yeah and those', '', '', '<span>one</span> <span>Google</span> <span>search</span> <span>away</span> <span>yeah</span> <span>and</span> <span>those</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 175, 220.15, 0.0, 'one Google search away yeah and those images', '', '', '<span>one</span> <span>Google</span> <span>search</span> <span>away</span> <span>yeah</span> <span>and</span> <span>those</span> <span>images</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 176, 220.83, 0.0, 'images', '', '', '<span>images</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 177, 220.84, 0.0, 'images you<00:03:41.049><c> cannot</c><00:03:41.440><c> expunge</c><00:03:42.090><c> you</c><00:03:43.090><c> have</c><00:03:43.299><c> no</c><00:03:43.510><c> right</c>', '', '', '<span>images</span> <span>you<00:03:41.049><c></span> <span>cannot</c><00:03:41.440><c></span> <span>expunge</c><00:03:42.090><c></span> <span>you</c><00:03:43.090><c></span> <span>have</c><00:03:43.299><c></span> <span>no</c><00:03:43.510><c></span> <span>right</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 178, 223.83, 0.0, 'you cannot expunge you have no right', '', '', '<span>you</span> <span>cannot</span> <span>expunge</span> <span>you</span> <span>have</span> <span>no</span> <span>right</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 179, 223.84, 0.0, 'you cannot expunge you have no right even<00:03:44.350><c> though</c><00:03:44.530><c> it</c><00:03:44.680><c> is</c><00:03:44.799><c> deeply</c><00:03:45.160><c> personal</c><00:03:45.609><c> to</c><00:03:45.639><c> you</c>', '', '', '<span>you</span> <span>cannot</span> <span>expunge</span> <span>you</span> <span>have</span> <span>no</span> <span>right</span> <span>even<00:03:44.350><c></span> <span>though</c><00:03:44.530><c></span> <span>it</c><00:03:44.680><c></span> <span>is</c><00:03:44.799><c></span> <span>deeply</c><00:03:45.160><c></span> <span>personal</c><00:03:45.609><c></span> <span>to</c><00:03:45.639><c></span> <span>you</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 180, 225.9, 0.0, 'even though it is deeply personal to you', '', '', '<span>even</span> <span>though</span> <span>it</span> <span>is</span> <span>deeply</span> <span>personal</span> <span>to</span> <span>you</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 181, 225.91, 0.0, 'even though it is deeply personal to you you<00:03:46.150><c> have</c><00:03:46.269><c> no</c><00:03:46.480><c> right</c><00:03:46.690><c> to</c><00:03:46.920><c> remove</c><00:03:47.920><c> them</c><00:03:48.280><c> from</c>', '', '', '<span>even</span> <span>though</span> <span>it</span> <span>is</span> <span>deeply</span> <span>personal</span> <span>to</span> <span>you</span> <span>you<00:03:46.150><c></span> <span>have</c><00:03:46.269><c></span> <span>no</c><00:03:46.480><c></span> <span>right</c><00:03:46.690><c></span> <span>to</c><00:03:46.920><c></span> <span>remove</c><00:03:47.920><c></span> <span>them</c><00:03:48.280><c></span> <span>from</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 182, 229.009, 0.0, 'you have no right to remove them from', '', '', '<span>you</span> <span>have</span> <span>no</span> <span>right</span> <span>to</span> <span>remove</span> <span>them</span> <span>from</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 183, 229.019, 0.0, 'you have no right to remove them from anybody''s<00:03:50.019><c> view</c><00:03:50.290><c> around</c><00:03:50.620><c> the</c><00:03:50.739><c> world</c><00:03:53.940><c> it</c><00:03:54.940><c> is</c>', '', '', '<span>you</span> <span>have</span> <span>no</span> <span>right</span> <span>to</span> <span>remove</span> <span>them</span> <span>from</span> <span>anybody''s<00:03:50.019><c></span> <span>view</c><00:03:50.290><c></span> <span>around</c><00:03:50.620><c></span> <span>the</c><00:03:50.739><c></span> <span>world</c><00:03:53.940><c></span> <span>it</c><00:03:54.940><c></span> <span>is</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 184, 235.14, 0.0, 'anybody''s view around the world it is', '', '', '<span>anybody''s</span> <span>view</span> <span>around</span> <span>the</span> <span>world</span> <span>it</span> <span>is</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 185, 235.15, 0.0, 'anybody''s view around the world it is very<00:03:55.389><c> hard</c><00:03:55.660><c> and</c><00:03:56.440><c> I''m</c><00:03:56.590><c> just</c><00:03:56.769><c> thinking</c><00:03:56.950><c> this</c>', '', '', '<span>anybody''s</span> <span>view</span> <span>around</span> <span>the</span> <span>world</span> <span>it</span> <span>is</span> <span>very<00:03:55.389><c></span> <span>hard</c><00:03:55.660><c></span> <span>and</c><00:03:56.440><c></span> <span>I''m</c><00:03:56.590><c></span> <span>just</c><00:03:56.769><c></span> <span>thinking</c><00:03:56.950><c></span> <span>this</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 186, 237.69, 0.0, 'very hard and I''m just thinking this', '', '', '<span>very</span> <span>hard</span> <span>and</span> <span>I''m</span> <span>just</span> <span>thinking</span> <span>this</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 187, 237.7, 0.0, 'very hard and I''m just thinking this isn''t<00:03:58.060><c> I</c><00:03:58.359><c> mean</c><00:03:58.540><c> this</c><00:03:58.750><c> story</c><00:03:59.079><c> is</c><00:03:59.290><c> your</c><00:03:59.709><c> story</c>', '', '', '<span>very</span> <span>hard</span> <span>and</span> <span>I''m</span> <span>just</span> <span>thinking</span> <span>this</span> <span>isn''t<00:03:58.060><c></span> <span>I</c><00:03:58.359><c></span> <span>mean</c><00:03:58.540><c></span> <span>this</c><00:03:58.750><c></span> <span>story</c><00:03:59.079><c></span> <span>is</c><00:03:59.290><c></span> <span>your</c><00:03:59.709><c></span> <span>story</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 188, 239.729, 0.0, 'isn''t I mean this story is your story', '', '', '<span>isn''t</span> <span>I</span> <span>mean</span> <span>this</span> <span>story</span> <span>is</span> <span>your</span> <span>story</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 189, 239.739, 0.0, 'isn''t I mean this story is your story but<00:04:00.430><c> frankly</c><00:04:01.389><c> it''s</c><00:04:01.750><c> also</c><00:04:01.959><c> the</c><00:04:02.260><c> story</c><00:04:02.560><c> of</c><00:04:02.650><c> other</c>', '', '', '<span>isn''t</span> <span>I</span> <span>mean</span> <span>this</span> <span>story</span> <span>is</span> <span>your</span> <span>story</span> <span>but<00:04:00.430><c></span> <span>frankly</c><00:04:01.389><c></span> <span>it''s</c><00:04:01.750><c></span> <span>also</c><00:04:01.959><c></span> <span>the</c><00:04:02.260><c></span> <span>story</c><00:04:02.560><c></span> <span>of</c><00:04:02.650><c></span> <span>other</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 190, 243.809, 0.0, 'but frankly it''s also the story of other', '', '', '<span>but</span> <span>frankly</span> <span>it''s</span> <span>also</span> <span>the</span> <span>story</span> <span>of</span> <span>other</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 191, 243.819, 0.0, 'but frankly it''s also the story of other porn<00:04:04.349><c> actors</c><00:04:05.349><c> and</c><00:04:05.530><c> actresses</c><00:04:06.340><c> I</c><00:04:06.370><c> honestly</c>', '', '', '<span>but</span> <span>frankly</span> <span>it''s</span> <span>also</span> <span>the</span> <span>story</span> <span>of</span> <span>other</span> <span>porn<00:04:04.349><c></span> <span>actors</c><00:04:05.349><c></span> <span>and</c><00:04:05.530><c></span> <span>actresses</c><00:04:06.340><c></span> <span>I</c><00:04:06.370><c></span> <span>honestly</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 192, 247.08, 0.0, 'porn actors and actresses I honestly', '', '', '<span>porn</span> <span>actors</span> <span>and</span> <span>actresses</span> <span>I</span> <span>honestly</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 193, 247.09, 0.0, 'porn actors and actresses I honestly started<00:04:07.629><c> seeing</c><00:04:07.989><c> that</c><00:04:08.200><c> recently</c><00:04:09.189><c> after</c><00:04:09.370><c> the</c>', '', '', '<span>porn</span> <span>actors</span> <span>and</span> <span>actresses</span> <span>I</span> <span>honestly</span> <span>started<00:04:07.629><c></span> <span>seeing</c><00:04:07.989><c></span> <span>that</c><00:04:08.200><c></span> <span>recently</c><00:04:09.189><c></span> <span>after</c><00:04:09.370><c></span> <span>the</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 194, 249.569, 0.0, 'started seeing that recently after the', '', '', '<span>started</span> <span>seeing</span> <span>that</span> <span>recently</span> <span>after</span> <span>the</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 195, 249.579, 0.0, 'started seeing that recently after the interview<00:04:09.939><c> came</c><00:04:10.090><c> out</c><00:04:10.269><c> and</c><00:04:10.510><c> people</c><00:04:11.140><c> started</c>', '', '', '<span>started</span> <span>seeing</span> <span>that</span> <span>recently</span> <span>after</span> <span>the</span> <span>interview<00:04:09.939><c></span> <span>came</c><00:04:10.090><c></span> <span>out</c><00:04:10.269><c></span> <span>and</c><00:04:10.510><c></span> <span>people</c><00:04:11.140><c></span> <span>started</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 196, 251.55, 0.0, 'interview came out and people started', '', '', '<span>interview</span> <span>came</span> <span>out</span> <span>and</span> <span>people</span> <span>started</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 197, 251.56, 0.0, 'interview came out and people started reaching<00:04:11.739><c> out</c><00:04:12.010><c> and</c><00:04:12.359><c> all</c><00:04:13.359><c> of</c><00:04:13.569><c> the</c><00:04:13.659><c> emails</c><00:04:13.959><c> go</c>', '', '', '<span>interview</span> <span>came</span> <span>out</span> <span>and</span> <span>people</span> <span>started</span> <span>reaching<00:04:11.739><c></span> <span>out</c><00:04:12.010><c></span> <span>and</c><00:04:12.359><c></span> <span>all</c><00:04:13.359><c></span> <span>of</c><00:04:13.569><c></span> <span>the</c><00:04:13.659><c></span> <span>emails</c><00:04:13.959><c></span> <span>go</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 198, 254.25, 0.0, 'reaching out and all of the emails go', '', '', '<span>reaching</span> <span>out</span> <span>and</span> <span>all</span> <span>of</span> <span>the</span> <span>emails</span> <span>go</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 199, 254.26, 0.0, 'reaching out and all of the emails go my<00:04:14.680><c> manager</c><00:04:15.340><c> checks</c><00:04:15.609><c> them</c><00:04:15.849><c> and</c><00:04:16.289><c> when</c><00:04:17.289><c> he</c><00:04:17.470><c> gets</c>', '', '', '<span>reaching</span> <span>out</span> <span>and</span> <span>all</span> <span>of</span> <span>the</span> <span>emails</span> <span>go</span> <span>my<00:04:14.680><c></span> <span>manager</c><00:04:15.340><c></span> <span>checks</c><00:04:15.609><c></span> <span>them</c><00:04:15.849><c></span> <span>and</c><00:04:16.289><c></span> <span>when</c><00:04:17.289><c></span> <span>he</c><00:04:17.470><c></span> <span>gets</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 200, 257.64, 0.0, 'my manager checks them and when he gets', '', '', '<span>my</span> <span>manager</span> <span>checks</span> <span>them</span> <span>and</span> <span>when</span> <span>he</span> <span>gets</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 201, 257.65, 0.0, 'my manager checks them and when he gets stuff<00:04:17.859><c> like</c><00:04:18.009><c> that</c><00:04:18.190><c> he</c><00:04:18.459><c> filters</c><00:04:18.820><c> them</c><00:04:19.030><c> and</c>', '', '', '<span>my</span> <span>manager</span> <span>checks</span> <span>them</span> <span>and</span> <span>when</span> <span>he</span> <span>gets</span> <span>stuff<00:04:17.859><c></span> <span>like</c><00:04:18.009><c></span> <span>that</c><00:04:18.190><c></span> <span>he</c><00:04:18.459><c></span> <span>filters</c><00:04:18.820><c></span> <span>them</c><00:04:19.030><c></span> <span>and</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 202, 259.14, 0.0, 'stuff like that he filters them and', '', '', '<span>stuff</span> <span>like</span> <span>that</span> <span>he</span> <span>filters</span> <span>them</span> <span>and</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 203, 259.15, 0.0, 'stuff like that he filters them and sends<00:04:19.359><c> them</c><00:04:19.509><c> to</c><00:04:19.660><c> me</c><00:04:19.690><c> and</c><00:04:20.400><c> reading</c><00:04:21.400><c> the</c><00:04:21.609><c> words</c>', '', '', '<span>stuff</span> <span>like</span> <span>that</span> <span>he</span> <span>filters</span> <span>them</span> <span>and</span> <span>sends<00:04:19.359><c></span> <span>them</c><00:04:19.509><c></span> <span>to</c><00:04:19.660><c></span> <span>me</c><00:04:19.690><c></span> <span>and</c><00:04:20.400><c></span> <span>reading</c><00:04:21.400><c></span> <span>the</c><00:04:21.609><c></span> <span>words</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 204, 261.87, 0.0, 'sends them to me and reading the words', '', '', '<span>sends</span> <span>them</span> <span>to</span> <span>me</span> <span>and</span> <span>reading</span> <span>the</span> <span>words</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 205, 261.88, 0.0, 'sends them to me and reading the words of<00:04:22.120><c> some</c><00:04:22.240><c> of</c><00:04:22.360><c> these</c><00:04:22.449><c> girls</c><00:04:22.720><c> who</c><00:04:23.020><c> have</c><00:04:23.169><c> been</c><00:04:23.320><c> sex</c>', '', '', '<span>sends</span> <span>them</span> <span>to</span> <span>me</span> <span>and</span> <span>reading</span> <span>the</span> <span>words</span> <span>of<00:04:22.120><c></span> <span>some</c><00:04:22.240><c></span> <span>of</c><00:04:22.360><c></span> <span>these</c><00:04:22.449><c></span> <span>girls</c><00:04:22.720><c></span> <span>who</c><00:04:23.020><c></span> <span>have</c><00:04:23.169><c></span> <span>been</c><00:04:23.320><c></span> <span>sex</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 206, 264.12, 0.0, 'of some of these girls who have been sex', '', '', '<span>of</span> <span>some</span> <span>of</span> <span>these</span> <span>girls</span> <span>who</span> <span>have</span> <span>been</span> <span>sex</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 207, 264.13, 0.0, 'of some of these girls who have been sex trafficked<00:04:24.610><c> and</c><00:04:24.789><c> forced</c><00:04:25.630><c> into</c><00:04:25.870><c> porn</c><00:04:26.139><c> and</c><00:04:26.380><c> then</c>', '', '', '<span>of</span> <span>some</span> <span>of</span> <span>these</span> <span>girls</span> <span>who</span> <span>have</span> <span>been</span> <span>sex</span> <span>trafficked<00:04:24.610><c></span> <span>and</c><00:04:24.789><c></span> <span>forced</c><00:04:25.630><c></span> <span>into</c><00:04:25.870><c></span> <span>porn</c><00:04:26.139><c></span> <span>and</c><00:04:26.380><c></span> <span>then</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 208, 266.46, 0.0, 'trafficked and forced into porn and then', '', '', '<span>trafficked</span> <span>and</span> <span>forced</span> <span>into</span> <span>porn</span> <span>and</span> <span>then</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 209, 266.47, 0.0, 'trafficked and forced into porn and then all<00:04:26.770><c> of</c><00:04:26.919><c> these</c><00:04:27.070><c> stories</c><00:04:27.400><c> of</c><00:04:27.520><c> girls</c><00:04:28.360><c> whose</c>', '', '', '<span>trafficked</span> <span>and</span> <span>forced</span> <span>into</span> <span>porn</span> <span>and</span> <span>then</span> <span>all<00:04:26.770><c></span> <span>of</c><00:04:26.919><c></span> <span>these</c><00:04:27.070><c></span> <span>stories</c><00:04:27.400><c></span> <span>of</c><00:04:27.520><c></span> <span>girls</c><00:04:28.360><c></span> <span>whose</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 210, 268.65, 0.0, 'all of these stories of girls whose', '', '', '<span>all</span> <span>of</span> <span>these</span> <span>stories</span> <span>of</span> <span>girls</span> <span>whose</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 211, 268.66, 0.0, 'all of these stories of girls whose lives<00:04:28.690><c> have</c><00:04:29.169><c> been</c><00:04:29.199><c> ruined</c><00:04:29.380><c> by</c><00:04:29.889><c> owed</c><00:04:30.100><c> and</c><00:04:30.520><c> by</c>', '', '', '<span>all</span> <span>of</span> <span>these</span> <span>stories</span> <span>of</span> <span>girls</span> <span>whose</span> <span>lives<00:04:28.690><c></span> <span>have</c><00:04:29.169><c></span> <span>been</c><00:04:29.199><c></span> <span>ruined</c><00:04:29.380><c></span> <span>by</c><00:04:29.889><c></span> <span>owed</c><00:04:30.100><c></span> <span>and</c><00:04:30.520><c></span> <span>by</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 212, 270.659, 0.0, 'lives have been ruined by owed and by', '', '', '<span>lives</span> <span>have</span> <span>been</span> <span>ruined</span> <span>by</span> <span>owed</span> <span>and</span> <span>by</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 213, 270.669, 0.0, 'lives have been ruined by owed and by men<00:04:30.910><c> who</c><00:04:31.060><c> have</c><00:04:31.240><c> taken</c><00:04:31.389><c> advantage</c><00:04:31.630><c> of</c><00:04:32.080><c> them</c><00:04:32.259><c> and</c>', '', '', '<span>lives</span> <span>have</span> <span>been</span> <span>ruined</span> <span>by</span> <span>owed</span> <span>and</span> <span>by</span> <span>men<00:04:30.910><c></span> <span>who</c><00:04:31.060><c></span> <span>have</c><00:04:31.240><c></span> <span>taken</c><00:04:31.389><c></span> <span>advantage</c><00:04:31.630><c></span> <span>of</c><00:04:32.080><c></span> <span>them</c><00:04:32.259><c></span> <span>and</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 214, 272.279, 0.0, 'men who have taken advantage of them and', '', '', '<span>men</span> <span>who</span> <span>have</span> <span>taken</span> <span>advantage</span> <span>of</span> <span>them</span> <span>and</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 215, 272.289, 0.0, 'men who have taken advantage of them and by<00:04:32.880><c> contracts</c><00:04:33.880><c> that</c><00:04:34.030><c> they</c><00:04:34.090><c> didn''t</c><00:04:34.330><c> even</c>', '', '', '<span>men</span> <span>who</span> <span>have</span> <span>taken</span> <span>advantage</span> <span>of</span> <span>them</span> <span>and</span> <span>by<00:04:32.880><c></span> <span>contracts</c><00:04:33.880><c></span> <span>that</c><00:04:34.030><c></span> <span>they</c><00:04:34.090><c></span> <span>didn''t</c><00:04:34.330><c></span> <span>even</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 216, 274.409, 0.0, 'by contracts that they didn''t even', '', '', '<span>by</span> <span>contracts</span> <span>that</span> <span>they</span> <span>didn''t</span> <span>even</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 217, 274.419, 0.0, 'by contracts that they didn''t even didn''t<00:04:34.870><c> even</c><00:04:34.960><c> understand</c><00:04:35.380><c> the</c><00:04:35.470><c> jargon</c><00:04:35.740><c> of</c><00:04:36.330><c> it</c>', '', '', '<span>by</span> <span>contracts</span> <span>that</span> <span>they</span> <span>didn''t</span> <span>even</span> <span>didn''t<00:04:34.870><c></span> <span>even</c><00:04:34.960><c></span> <span>understand</c><00:04:35.380><c></span> <span>the</c><00:04:35.470><c></span> <span>jargon</c><00:04:35.740><c></span> <span>of</c><00:04:36.330><c></span> <span>it</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 218, 277.32, 0.0, 'didn''t even understand the jargon of it', '', '', '<span>didn''t</span> <span>even</span> <span>understand</span> <span>the</span> <span>jargon</span> <span>of</span> <span>it</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 219, 277.33, 0.0, 'didn''t even understand the jargon of it makes<00:04:37.960><c> me</c><00:04:38.110><c> feel</c><00:04:38.259><c> like</c><00:04:38.470><c> okay</c><00:04:39.430><c> maybe</c><00:04:39.580><c> maybe</c><00:04:40.449><c> it</c>', '', '', '<span>didn''t</span> <span>even</span> <span>understand</span> <span>the</span> <span>jargon</span> <span>of</span> <span>it</span> <span>makes<00:04:37.960><c></span> <span>me</c><00:04:38.110><c></span> <span>feel</c><00:04:38.259><c></span> <span>like</c><00:04:38.470><c></span> <span>okay</c><00:04:39.430><c></span> <span>maybe</c><00:04:39.580><c></span> <span>maybe</c><00:04:40.449><c></span> <span>it</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 220, 280.62, 0.0, 'makes me feel like okay maybe maybe it', '', '', '<span>makes</span> <span>me</span> <span>feel</span> <span>like</span> <span>okay</span> <span>maybe</span> <span>maybe</span> <span>it</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 221, 280.63, 0.0, 'makes me feel like okay maybe maybe it was<00:04:40.750><c> good</c><00:04:40.960><c> that</c><00:04:41.169><c> I</c><00:04:41.199><c> started</c><00:04:41.560><c> talking</c><00:04:41.740><c> and</c><00:04:42.099><c> that</c>', '', '', '<span>makes</span> <span>me</span> <span>feel</span> <span>like</span> <span>okay</span> <span>maybe</span> <span>maybe</span> <span>it</span> <span>was<00:04:40.750><c></span> <span>good</c><00:04:40.960><c></span> <span>that</c><00:04:41.169><c></span> <span>I</c><00:04:41.199><c></span> <span>started</c><00:04:41.560><c></span> <span>talking</c><00:04:41.740><c></span> <span>and</c><00:04:42.099><c></span> <span>that</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 222, 282.24, 0.0, 'was good that I started talking and that', '', '', '<span>was</span> <span>good</span> <span>that</span> <span>I</span> <span>started</span> <span>talking</span> <span>and</span> <span>that</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 223, 282.25, 0.0, 'was good that I started talking and that I<00:04:42.280><c> posted</c><00:04:42.699><c> this</c><00:04:42.789><c> interview</c><00:04:43.270><c> and</c><00:04:43.479><c> that</c><00:04:43.840><c> I''m</c>', '', '', '<span>was</span> <span>good</span> <span>that</span> <span>I</span> <span>started</span> <span>talking</span> <span>and</span> <span>that</span> <span>I<00:04:42.280><c></span> <span>posted</c><00:04:42.699><c></span> <span>this</c><00:04:42.789><c></span> <span>interview</c><00:04:43.270><c></span> <span>and</c><00:04:43.479><c></span> <span>that</c><00:04:43.840><c></span> <span>I''m</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 224, 283.95, 0.0, 'I posted this interview and that I''m', '', '', '<span>I</span> <span>posted</span> <span>this</span> <span>interview</span> <span>and</span> <span>that</span> <span>I''m</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 225, 283.96, 0.0, 'I posted this interview and that I''m speaking<00:04:44.470><c> out</c><00:04:44.710><c> now</c><00:04:44.979><c> because</c><00:04:45.220><c> other</c><00:04:45.910><c> people</c>', '', '', '<span>I</span> <span>posted</span> <span>this</span> <span>interview</span> <span>and</span> <span>that</span> <span>I''m</span> <span>speaking<00:04:44.470><c></span> <span>out</c><00:04:44.710><c></span> <span>now</c><00:04:44.979><c></span> <span>because</c><00:04:45.220><c></span> <span>other</c><00:04:45.910><c></span> <span>people</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 226, 286.499, 0.0, 'speaking out now because other people', '', '', '<span>speaking</span> <span>out</span> <span>now</span> <span>because</span> <span>other</span> <span>people</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 227, 286.509, 0.0, 'speaking out now because other people feel<00:04:47.289><c> the</c><00:04:47.470><c> same</c><00:04:47.500><c> way</c><00:04:47.889><c> and</c><00:04:48.250><c> even</c><00:04:48.639><c> if</c><00:04:48.820><c> they</c><00:04:48.970><c> don''t</c>', '', '', '<span>speaking</span> <span>out</span> <span>now</span> <span>because</span> <span>other</span> <span>people</span> <span>feel<00:04:47.289><c></span> <span>the</c><00:04:47.470><c></span> <span>same</c><00:04:47.500><c></span> <span>way</c><00:04:47.889><c></span> <span>and</c><00:04:48.250><c></span> <span>even</c><00:04:48.639><c></span> <span>if</c><00:04:48.820><c></span> <span>they</c><00:04:48.970><c></span> <span>don''t</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 228, 289.2, 0.0, 'feel the same way and even if they don''t', '', '', '<span>feel</span> <span>the</span> <span>same</span> <span>way</span> <span>and</span> <span>even</span> <span>if</span> <span>they</span> <span>don''t</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 229, 289.21, 0.0, 'feel the same way and even if they don''t relate<00:04:49.930><c> on</c><00:04:50.880><c> as</c><00:04:51.880><c> deep</c><00:04:52.120><c> a</c><00:04:52.240><c> level</c><00:04:52.509><c> as</c><00:04:52.690><c> you</c><00:04:52.990><c> know</c>', '', '', '<span>feel</span> <span>the</span> <span>same</span> <span>way</span> <span>and</span> <span>even</span> <span>if</span> <span>they</span> <span>don''t</span> <span>relate<00:04:49.930><c></span> <span>on</c><00:04:50.880><c></span> <span>as</c><00:04:51.880><c></span> <span>deep</c><00:04:52.120><c></span> <span>a</c><00:04:52.240><c></span> <span>level</c><00:04:52.509><c></span> <span>as</c><00:04:52.690><c></span> <span>you</c><00:04:52.990><c></span> <span>know</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 230, 293.07, 0.0, 'relate on as deep a level as you know', '', '', '<span>relate</span> <span>on</span> <span>as</span> <span>deep</span> <span>a</span> <span>level</span> <span>as</span> <span>you</span> <span>know</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 231, 293.08, 0.0, 'relate on as deep a level as you know doing<00:04:53.380><c> porn</c><00:04:53.680><c> they</c><00:04:54.460><c> can</c><00:04:54.610><c> relate</c><00:04:54.910><c> on</c><00:04:55.180><c> the</c><00:04:55.300><c> level</c>', '', '', '<span>relate</span> <span>on</span> <span>as</span> <span>deep</span> <span>a</span> <span>level</span> <span>as</span> <span>you</span> <span>know</span> <span>doing<00:04:53.380><c></span> <span>porn</c><00:04:53.680><c></span> <span>they</c><00:04:54.460><c></span> <span>can</c><00:04:54.610><c></span> <span>relate</c><00:04:54.910><c></span> <span>on</c><00:04:55.180><c></span> <span>the</c><00:04:55.300><c></span> <span>level</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 232, 295.56, 0.0, 'doing porn they can relate on the level', '', '', '<span>doing</span> <span>porn</span> <span>they</span> <span>can</span> <span>relate</span> <span>on</span> <span>the</span> <span>level</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 233, 295.57, 0.0, 'doing porn they can relate on the level of<00:04:55.720><c> being</c><00:04:56.080><c> insecure</c><00:04:56.500><c> and</c><00:04:56.949><c> being</c><00:04:57.190><c> pressured</c>', '', '', '<span>doing</span> <span>porn</span> <span>they</span> <span>can</span> <span>relate</span> <span>on</span> <span>the</span> <span>level</span> <span>of<00:04:55.720><c></span> <span>being</c><00:04:56.080><c></span> <span>insecure</c><00:04:56.500><c></span> <span>and</c><00:04:56.949><c></span> <span>being</c><00:04:57.190><c></span> <span>pressured</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 234, 297.6, 0.0, 'of being insecure and being pressured', '', '', '<span>of</span> <span>being</span> <span>insecure</span> <span>and</span> <span>being</span> <span>pressured</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 235, 297.61, 0.0, 'of being insecure and being pressured into<00:04:57.669><c> doing</c><00:04:58.060><c> something</c><00:04:58.240><c> I</c><00:04:58.389><c> didn''t</c><00:04:58.660><c> want</c><00:04:58.780><c> to</c><00:04:58.840><c> do</c>', '', '', '<span>of</span> <span>being</span> <span>insecure</span> <span>and</span> <span>being</span> <span>pressured</span> <span>into<00:04:57.669><c></span> <span>doing</c><00:04:58.060><c></span> <span>something</c><00:04:58.240><c></span> <span>I</c><00:04:58.389><c></span> <span>didn''t</c><00:04:58.660><c></span> <span>want</c><00:04:58.780><c></span> <span>to</c><00:04:58.840><c></span> <span>do</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 236, 298.92, 0.0, 'into doing something I didn''t want to do', '', '', '<span>into</span> <span>doing</span> <span>something</span> <span>I</span> <span>didn''t</span> <span>want</span> <span>to</span> <span>do</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 237, 298.93, 0.0, 'into doing something I didn''t want to do you<00:04:59.289><c> were</c><00:04:59.410><c> wearing</c><00:04:59.830><c> the</c><00:05:00.250><c> Islamic</c><00:05:01.180><c> headscarf</c>', '', '', '<span>into</span> <span>doing</span> <span>something</span> <span>I</span> <span>didn''t</span> <span>want</span> <span>to</span> <span>do</span> <span>you<00:04:59.289><c></span> <span>were</c><00:04:59.410><c></span> <span>wearing</c><00:04:59.830><c></span> <span>the</c><00:05:00.250><c></span> <span>Islamic</c><00:05:01.180><c></span> <span>headscarf</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 238, 302.51, 0.0, 'you were wearing the Islamic headscarf', '', '', '<span>you</span> <span>were</span> <span>wearing</span> <span>the</span> <span>Islamic</span> <span>headscarf</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 239, 302.52, 0.0, 'you were wearing the Islamic headscarf often<00:05:03.520><c> known</c><00:05:03.639><c> as</c><00:05:03.789><c> her</c><00:05:03.940><c> job</c><00:05:04.180><c> and</c><00:05:04.479><c> of</c><00:05:05.470><c> course</c>', '', '', '<span>you</span> <span>were</span> <span>wearing</span> <span>the</span> <span>Islamic</span> <span>headscarf</span> <span>often<00:05:03.520><c></span> <span>known</c><00:05:03.639><c></span> <span>as</c><00:05:03.789><c></span> <span>her</c><00:05:03.940><c></span> <span>job</c><00:05:04.180><c></span> <span>and</c><00:05:04.479><c></span> <span>of</c><00:05:05.470><c></span> <span>course</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 240, 305.79, 0.0, 'often known as her job and of course', '', '', '<span>often</span> <span>known</span> <span>as</span> <span>her</span> <span>job</span> <span>and</span> <span>of</span> <span>course</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 241, 305.8, 0.0, 'often known as her job and of course then<00:05:05.949><c> it</c><00:05:06.070><c> developed</c><00:05:06.460><c> into</c><00:05:06.610><c> a</c><00:05:07.169><c> sex</c><00:05:08.169><c> scene</c><00:05:08.860><c> you</c>', '', '', '<span>often</span> <span>known</span> <span>as</span> <span>her</span> <span>job</span> <span>and</span> <span>of</span> <span>course</span> <span>then<00:05:05.949><c></span> <span>it</c><00:05:06.070><c></span> <span>developed</c><00:05:06.460><c></span> <span>into</c><00:05:06.610><c></span> <span>a</c><00:05:07.169><c></span> <span>sex</c><00:05:08.169><c></span> <span>scene</c><00:05:08.860><c></span> <span>you</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 242, 309.48, 0.0, 'then it developed into a sex scene you', '', '', '<span>then</span> <span>it</span> <span>developed</span> <span>into</span> <span>a</span> <span>sex</span> <span>scene</span> <span>you</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 243, 309.49, 0.0, 'then it developed into a sex scene you must<00:05:09.880><c> have</c><00:05:10.150><c> known</c><00:05:10.389><c> how</c><00:05:10.960><c> provocative</c><00:05:11.440><c> that</c><00:05:12.400><c> was</c>', '', '', '<span>then</span> <span>it</span> <span>developed</span> <span>into</span> <span>a</span> <span>sex</span> <span>scene</span> <span>you</span> <span>must<00:05:09.880><c></span> <span>have</c><00:05:10.150><c></span> <span>known</c><00:05:10.389><c></span> <span>how</c><00:05:10.960><c></span> <span>provocative</c><00:05:11.440><c></span> <span>that</c><00:05:12.400><c></span> <span>was</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 244, 312.659, 0.0, 'must have known how provocative that was', '', '', '<span>must</span> <span>have</span> <span>known</span> <span>how</span> <span>provocative</span> <span>that</span> <span>was</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 245, 312.669, 0.0, 'must have known how provocative that was a<00:05:13.060><c> verbatim</c><00:05:13.900><c> told</c><00:05:14.229><c> them</c><00:05:14.470><c> you</c><00:05:15.220><c> guys</c><00:05:15.370><c> are</c><00:05:15.490><c> gonna</c>', '', '', '<span>must</span> <span>have</span> <span>known</span> <span>how</span> <span>provocative</span> <span>that</span> <span>was</span> <span>a<00:05:13.060><c></span> <span>verbatim</c><00:05:13.900><c></span> <span>told</c><00:05:14.229><c></span> <span>them</c><00:05:14.470><c></span> <span>you</c><00:05:15.220><c></span> <span>guys</c><00:05:15.370><c></span> <span>are</c><00:05:15.490><c></span> <span>gonna</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 246, 315.57, 0.0, 'a verbatim told them you guys are gonna', '', '', '<span>a</span> <span>verbatim</span> <span>told</span> <span>them</span> <span>you</span> <span>guys</span> <span>are</span> <span>gonna</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 247, 315.58, 0.0, 'a verbatim told them you guys are gonna get<00:05:15.789><c> me</c><00:05:15.909><c> killed</c><00:05:15.940><c> and</c><00:05:17.669><c> they</c><00:05:18.669><c> said</c><00:05:19.500><c> they</c><00:05:20.500><c> just</c>', '', '', '<span>a</span> <span>verbatim</span> <span>told</span> <span>them</span> <span>you</span> <span>guys</span> <span>are</span> <span>gonna</span> <span>get<00:05:15.789><c></span> <span>me</c><00:05:15.909><c></span> <span>killed</c><00:05:15.940><c></span> <span>and</c><00:05:17.669><c></span> <span>they</c><00:05:18.669><c></span> <span>said</c><00:05:19.500><c></span> <span>they</c><00:05:20.500><c></span> <span>just</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 248, 320.7, 0.0, 'get me killed and they said they just', '', '', '<span>get</span> <span>me</span> <span>killed</span> <span>and</span> <span>they</span> <span>said</span> <span>they</span> <span>just</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 249, 320.71, 0.0, 'get me killed and they said they just laughed<00:05:21.810><c> why</c><00:05:22.810><c> didn''t</c><00:05:23.320><c> you</c><00:05:23.440><c> then</c><00:05:23.500><c> say</c><00:05:24.130><c> I''m</c><00:05:24.760><c> not</c>', '', '', '<span>get</span> <span>me</span> <span>killed</span> <span>and</span> <span>they</span> <span>said</span> <span>they</span> <span>just</span> <span>laughed<00:05:21.810><c></span> <span>why</c><00:05:22.810><c></span> <span>didn''t</c><00:05:23.320><c></span> <span>you</c><00:05:23.440><c></span> <span>then</c><00:05:23.500><c></span> <span>say</c><00:05:24.130><c></span> <span>I''m</c><00:05:24.760><c></span> <span>not</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 250, 324.93, 0.0, 'laughed why didn''t you then say I''m not', '', '', '<span>laughed</span> <span>why</span> <span>didn''t</span> <span>you</span> <span>then</span> <span>say</span> <span>I''m</span> <span>not</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 251, 324.94, 0.0, 'laughed why didn''t you then say I''m not doing<00:05:25.150><c> it</c>', '', '', '<span>laughed</span> <span>why</span> <span>didn''t</span> <span>you</span> <span>then</span> <span>say</span> <span>I''m</span> <span>not</span> <span>doing<00:05:25.150><c></span> <span>it</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 252, 325.56, 0.0, 'doing it', '', '', '<span>doing</span> <span>it</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 253, 325.57, 0.0, 'doing it intimidation<00:05:26.139><c> I</c><00:05:26.500><c> was</c><00:05:27.430><c> scared</c><00:05:28.320><c> right</c><00:05:29.320><c> I</c><00:05:29.500><c> knew</c>', '', '', '<span>doing</span> <span>it</span> <span>intimidation<00:05:26.139><c></span> <span>I</c><00:05:26.500><c></span> <span>was</c><00:05:27.430><c></span> <span>scared</c><00:05:28.320><c></span> <span>right</c><00:05:29.320><c></span> <span>I</c><00:05:29.500><c></span> <span>knew</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 254, 330.12, 0.0, 'intimidation I was scared right I knew', '', '', '<span>intimidation</span> <span>I</span> <span>was</span> <span>scared</span> <span>right</span> <span>I</span> <span>knew</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 255, 330.13, 0.0, 'intimidation I was scared right I knew that<00:05:30.370><c> if</c><00:05:30.580><c> I</c><00:05:30.729><c> said</c><00:05:30.970><c> no</c><00:05:31.210><c> it</c><00:05:31.479><c> would</c><00:05:31.930><c> it</c><00:05:32.889><c> would</c><00:05:33.010><c> you</c>', '', '', '<span>intimidation</span> <span>I</span> <span>was</span> <span>scared</span> <span>right</span> <span>I</span> <span>knew</span> <span>that<00:05:30.370><c></span> <span>if</c><00:05:30.580><c></span> <span>I</c><00:05:30.729><c></span> <span>said</c><00:05:30.970><c></span> <span>no</c><00:05:31.210><c></span> <span>it</c><00:05:31.479><c></span> <span>would</c><00:05:31.930><c></span> <span>it</c><00:05:32.889><c></span> <span>would</c><00:05:33.010><c></span> <span>you</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 256, 333.6, 0.0, 'that if I said no it would it would you', '', '', '<span>that</span> <span>if</span> <span>I</span> <span>said</span> <span>no</span> <span>it</span> <span>would</span> <span>it</span> <span>would</span> <span>you</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 257, 333.61, 0.0, 'that if I said no it would it would you know<00:05:33.699><c> they''re</c><00:05:33.880><c> not</c><00:05:34.030><c> you</c><00:05:34.449><c> keep</c><00:05:34.570><c> thinking</c>', '', '', '<span>that</span> <span>if</span> <span>I</span> <span>said</span> <span>no</span> <span>it</span> <span>would</span> <span>it</span> <span>would</span> <span>you</span> <span>know<00:05:33.699><c></span> <span>they''re</c><00:05:33.880><c></span> <span>not</c><00:05:34.030><c></span> <span>you</c><00:05:34.449><c></span> <span>keep</c><00:05:34.570><c></span> <span>thinking</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 258, 334.86, 0.0, 'know they''re not you keep thinking', '', '', '<span>know</span> <span>they''re</span> <span>not</span> <span>you</span> <span>keep</span> <span>thinking</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 259, 334.87, 0.0, 'know they''re not you keep thinking they''re<00:05:35.050><c> not</c><00:05:35.169><c> gonna</c><00:05:35.260><c> force</c><00:05:35.560><c> you</c><00:05:35.740><c> to</c><00:05:35.949><c> do</c><00:05:36.159><c> it</c>', '', '', '<span>know</span> <span>they''re</span> <span>not</span> <span>you</span> <span>keep</span> <span>thinking</span> <span>they''re<00:05:35.050><c></span> <span>not</c><00:05:35.169><c></span> <span>gonna</c><00:05:35.260><c></span> <span>force</c><00:05:35.560><c></span> <span>you</c><00:05:35.740><c></span> <span>to</c><00:05:35.949><c></span> <span>do</c><00:05:36.159><c></span> <span>it</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 260, 336.33, 0.0, 'they''re not gonna force you to do it', '', '', '<span>they''re</span> <span>not</span> <span>gonna</span> <span>force</span> <span>you</span> <span>to</span> <span>do</span> <span>it</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 261, 336.34, 0.0, 'they''re not gonna force you to do it that''s<00:05:36.940><c> at</c><00:05:37.539><c> that</c><00:05:37.690><c> point</c><00:05:37.900><c> that''s</c><00:05:38.020><c> rape</c><00:05:38.260><c> no</c>', '', '', '<span>they''re</span> <span>not</span> <span>gonna</span> <span>force</span> <span>you</span> <span>to</span> <span>do</span> <span>it</span> <span>that''s<00:05:36.940><c></span> <span>at</c><00:05:37.539><c></span> <span>that</c><00:05:37.690><c></span> <span>point</c><00:05:37.900><c></span> <span>that''s</c><00:05:38.020><c></span> <span>rape</c><00:05:38.260><c></span> <span>no</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 262, 339.0, 0.0, 'that''s at that point that''s rape no', '', '', '<span>that''s</span> <span>at</span> <span>that</span> <span>point</span> <span>that''s</span> <span>rape</span> <span>no</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 263, 339.01, 0.0, 'that''s at that point that''s rape no one''s<00:05:39.159><c> going</c><00:05:39.340><c> to</c><00:05:39.400><c> force</c><00:05:39.580><c> you</c><00:05:39.789><c> to</c><00:05:39.849><c> have</c><00:05:39.940><c> sex</c><00:05:40.800><c> but</c>', '', '', '<span>that''s</span> <span>at</span> <span>that</span> <span>point</span> <span>that''s</span> <span>rape</span> <span>no</span> <span>one''s<00:05:39.159><c></span> <span>going</c><00:05:39.340><c></span> <span>to</c><00:05:39.400><c></span> <span>force</c><00:05:39.580><c></span> <span>you</c><00:05:39.789><c></span> <span>to</c><00:05:39.849><c></span> <span>have</c><00:05:39.940><c></span> <span>sex</c><00:05:40.800><c></span> <span>but</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 264, 341.79, 0.0, 'one''s going to force you to have sex but', '', '', '<span>one''s</span> <span>going</span> <span>to</span> <span>force</span> <span>you</span> <span>to</span> <span>have</span> <span>sex</span> <span>but</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 265, 341.8, 0.0, 'one''s going to force you to have sex but I<00:05:42.070><c> was</c><00:05:42.639><c> still</c><00:05:42.789><c> scared</c><00:05:43.090><c> I</c><00:05:43.300><c> mean</c><00:05:43.479><c> I</c><00:05:44.550><c> have</c><00:05:45.550><c> you</c>', '', '', '<span>one''s</span> <span>going</span> <span>to</span> <span>force</span> <span>you</span> <span>to</span> <span>have</span> <span>sex</span> <span>but</span> <span>I<00:05:42.070><c></span> <span>was</c><00:05:42.639><c></span> <span>still</c><00:05:42.789><c></span> <span>scared</c><00:05:43.090><c></span> <span>I</c><00:05:43.300><c></span> <span>mean</c><00:05:43.479><c></span> <span>I</c><00:05:44.550><c></span> <span>have</c><00:05:45.550><c></span> <span>you</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 266, 345.57, 0.0, 'I was still scared I mean I have you', '', '', '<span>I</span> <span>was</span> <span>still</span> <span>scared</span> <span>I</span> <span>mean</span> <span>I</span> <span>have</span> <span>you</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 267, 345.58, 0.0, 'I was still scared I mean I have you ever<00:05:45.789><c> felt</c><00:05:46.150><c> scared</c><00:05:46.630><c> -</c><00:05:47.020><c> not</c><00:05:47.770><c> scared</c><00:05:47.919><c> but</c>', '', '', '<span>I</span> <span>was</span> <span>still</span> <span>scared</span> <span>I</span> <span>mean</span> <span>I</span> <span>have</span> <span>you</span> <span>ever<00:05:45.789><c></span> <span>felt</c><00:05:46.150><c></span> <span>scared</c><00:05:46.630><c></span> <span>-</c><00:05:47.020><c></span> <span>not</c><00:05:47.770><c></span> <span>scared</c><00:05:47.919><c></span> <span>but</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 268, 348.3, 0.0, 'ever felt scared - not scared but', '', '', '<span>ever</span> <span>felt</span> <span>scared</span> <span>-</span> <span>not</span> <span>scared</span> <span>but</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 269, 348.31, 0.0, 'ever felt scared - not scared but nervous<00:05:49.150><c> to</c><00:05:49.510><c> speak</c><00:05:50.110><c> up</c><00:05:50.260><c> and</c><00:05:50.500><c> say</c><00:05:50.650><c> something</c><00:05:50.979><c> at</c>', '', '', '<span>ever</span> <span>felt</span> <span>scared</span> <span>-</span> <span>not</span> <span>scared</span> <span>but</span> <span>nervous<00:05:49.150><c></span> <span>to</c><00:05:49.510><c></span> <span>speak</c><00:05:50.110><c></span> <span>up</c><00:05:50.260><c></span> <span>and</c><00:05:50.500><c></span> <span>say</c><00:05:50.650><c></span> <span>something</c><00:05:50.979><c></span> <span>at</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 270, 351.18, 0.0, 'nervous to speak up and say something at', '', '', '<span>nervous</span> <span>to</span> <span>speak</span> <span>up</span> <span>and</span> <span>say</span> <span>something</span> <span>at</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 271, 351.19, 0.0, 'nervous to speak up and say something at a<00:05:51.220><c> restaurant</c><00:05:51.580><c> when</c><00:05:51.820><c> your</c><00:05:51.940><c> foods</c><00:05:52.150><c> not</c><00:05:52.360><c> right</c>', '', '', '<span>nervous</span> <span>to</span> <span>speak</span> <span>up</span> <span>and</span> <span>say</span> <span>something</span> <span>at</span> <span>a<00:05:51.220><c></span> <span>restaurant</c><00:05:51.580><c></span> <span>when</c><00:05:51.820><c></span> <span>your</c><00:05:51.940><c></span> <span>foods</c><00:05:52.150><c></span> <span>not</c><00:05:52.360><c></span> <span>right</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 272, 352.56, 0.0, 'a restaurant when your foods not right', '', '', '<span>a</span> <span>restaurant</span> <span>when</span> <span>your</span> <span>foods</span> <span>not</span> <span>right</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 273, 352.57, 0.0, 'a restaurant when your foods not right and<00:05:52.720><c> the</c><00:05:52.810><c> waiter</c><00:05:52.960><c> comes</c><00:05:53.229><c> by</c><00:05:53.380><c> and</c><00:05:53.440><c> says</c><00:05:53.650><c> how</c><00:05:53.860><c> is</c>', '', '', '<span>a</span> <span>restaurant</span> <span>when</span> <span>your</span> <span>foods</span> <span>not</span> <span>right</span> <span>and<00:05:52.720><c></span> <span>the</c><00:05:52.810><c></span> <span>waiter</c><00:05:52.960><c></span> <span>comes</c><00:05:53.229><c></span> <span>by</c><00:05:53.380><c></span> <span>and</c><00:05:53.440><c></span> <span>says</c><00:05:53.650><c></span> <span>how</c><00:05:53.860><c></span> <span>is</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 274, 354.0, 0.0, 'and the waiter comes by and says how is', '', '', '<span>and</span> <span>the</span> <span>waiter</span> <span>comes</span> <span>by</span> <span>and</span> <span>says</span> <span>how</span> <span>is</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 275, 354.01, 0.0, 'and the waiter comes by and says how is everything<00:05:54.430><c> I</c><00:05:54.699><c> I</c><00:05:55.240><c> was</c><00:05:55.479><c> intimidated</c><00:05:55.690><c> I</c><00:05:56.080><c> was</c>', '', '', '<span>and</span> <span>the</span> <span>waiter</span> <span>comes</span> <span>by</span> <span>and</span> <span>says</span> <span>how</span> <span>is</span> <span>everything<00:05:54.430><c></span> <span>I</c><00:05:54.699><c></span> <span>I</c><00:05:55.240><c></span> <span>was</c><00:05:55.479><c></span> <span>intimidated</c><00:05:55.690><c></span> <span>I</c><00:05:56.080><c></span> <span>was</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 276, 356.219, 0.0, 'everything I I was intimidated I was', '', '', '<span>everything</span> <span>I</span> <span>I</span> <span>was</span> <span>intimidated</span> <span>I</span> <span>was</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 277, 356.229, 0.0, 'everything I I was intimidated I was nervous', '', '', '<span>everything</span> <span>I</span> <span>I</span> <span>was</span> <span>intimidated</span> <span>I</span> <span>was</span> <span>nervous</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 278, 356.82, 0.0, 'nervous', '', '', '<span>nervous</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 279, 356.83, 0.0, 'nervous we<00:05:57.460><c> need</c><00:05:57.580><c> to</c><00:05:57.699><c> view</c><00:05:57.789><c> a</c><00:05:57.849><c> lot</c><00:05:57.970><c> of</c><00:05:58.060><c> people</c><00:05:58.330><c> and</c><00:05:58.479><c> many</c>', '', '', '<span>nervous</span> <span>we<00:05:57.460><c></span> <span>need</c><00:05:57.580><c></span> <span>to</c><00:05:57.699><c></span> <span>view</c><00:05:57.789><c></span> <span>a</c><00:05:57.849><c></span> <span>lot</c><00:05:57.970><c></span> <span>of</c><00:05:58.060><c></span> <span>people</c><00:05:58.330><c></span> <span>and</c><00:05:58.479><c></span> <span>many</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 280, 358.56, 0.0, 'we need to view a lot of people and many', '', '', '<span>we</span> <span>need</span> <span>to</span> <span>view</span> <span>a</span> <span>lot</span> <span>of</span> <span>people</span> <span>and</span> <span>many</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 281, 358.57, 0.0, 'we need to view a lot of people and many of<00:05:58.720><c> them</c><00:05:58.870><c> are</c><00:05:58.930><c> middle-aged</c><00:05:59.349><c> or</c><00:05:59.590><c> older</c><00:05:59.620><c> it''s</c>', '', '', '<span>we</span> <span>need</span> <span>to</span> <span>view</span> <span>a</span> <span>lot</span> <span>of</span> <span>people</span> <span>and</span> <span>many</span> <span>of<00:05:58.720><c></span> <span>them</c><00:05:58.870><c></span> <span>are</c><00:05:58.930><c></span> <span>middle-aged</c><00:05:59.349><c></span> <span>or</c><00:05:59.590><c></span> <span>older</c><00:05:59.620><c></span> <span>it''s</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 282, 360.029, 0.0, 'of them are middle-aged or older it''s', '', '', '<span>of</span> <span>them</span> <span>are</span> <span>middle-aged</span> <span>or</span> <span>older</span> <span>it''s</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 283, 360.039, 0.0, 'of them are middle-aged or older it''s great<00:06:00.280><c> to</c><00:06:00.400><c> have</c><00:06:00.490><c> somebody</c><00:06:00.699><c> in</c><00:06:00.820><c> the</c><00:06:00.880><c> studio''s</c>', '', '', '<span>of</span> <span>them</span> <span>are</span> <span>middle-aged</span> <span>or</span> <span>older</span> <span>it''s</span> <span>great<00:06:00.280><c></span> <span>to</c><00:06:00.400><c></span> <span>have</c><00:06:00.490><c></span> <span>somebody</c><00:06:00.699><c></span> <span>in</c><00:06:00.820><c></span> <span>the</c><00:06:00.880><c></span> <span>studio''s</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 284, 361.23, 0.0, 'great to have somebody in the studio''s', '', '', '<span>great</span> <span>to</span> <span>have</span> <span>somebody</span> <span>in</span> <span>the</span> <span>studio''s</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 285, 361.24, 0.0, 'great to have somebody in the studio''s only<00:06:01.419><c> 26</c><00:06:01.900><c> years</c><00:06:01.990><c> old</c><00:06:02.349><c> there</c><00:06:03.099><c> is</c><00:06:03.130><c> a</c><00:06:03.250><c> school</c><00:06:04.210><c> of</c>', '', '', '<span>great</span> <span>to</span> <span>have</span> <span>somebody</span> <span>in</span> <span>the</span> <span>studio''s</span> <span>only<00:06:01.419><c></span> <span>26</c><00:06:01.900><c></span> <span>years</c><00:06:01.990><c></span> <span>old</c><00:06:02.349><c></span> <span>there</c><00:06:03.099><c></span> <span>is</c><00:06:03.130><c></span> <span>a</c><00:06:03.250><c></span> <span>school</c><00:06:04.210><c></span> <span>of</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 286, 364.23, 0.0, 'only 26 years old there is a school of', '', '', '<span>only</span> <span>26</span> <span>years</span> <span>old</span> <span>there</span> <span>is</span> <span>a</span> <span>school</span> <span>of</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 287, 364.24, 0.0, 'only 26 years old there is a school of thought<00:06:04.659><c> which</c><00:06:04.930><c> says</c><00:06:05.229><c> that</c><00:06:05.590><c> that</c><00:06:06.190><c> our</c><00:06:06.699><c> culture</c>', '', '', '<span>only</span> <span>26</span> <span>years</span> <span>old</span> <span>there</span> <span>is</span> <span>a</span> <span>school</span> <span>of</span> <span>thought<00:06:04.659><c></span> <span>which</c><00:06:04.930><c></span> <span>says</c><00:06:05.229><c></span> <span>that</c><00:06:05.590><c></span> <span>that</c><00:06:06.190><c></span> <span>our</c><00:06:06.699><c></span> <span>culture</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 288, 367.439, 0.0, 'thought which says that that our culture', '', '', '<span>thought</span> <span>which</span> <span>says</span> <span>that</span> <span>that</span> <span>our</span> <span>culture</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 289, 367.449, 0.0, 'thought which says that that our culture as<00:06:07.750><c> a</c><00:06:07.810><c> whole</c><00:06:07.900><c> I</c><00:06:08.020><c> want</c><00:06:08.289><c> just</c><00:06:08.409><c> talking</c><00:06:08.560><c> about</c><00:06:08.620><c> the</c>', '', '', '<span>thought</span> <span>which</span> <span>says</span> <span>that</span> <span>that</span> <span>our</span> <span>culture</span> <span>as<00:06:07.750><c></span> <span>a</c><00:06:07.810><c></span> <span>whole</c><00:06:07.900><c></span> <span>I</c><00:06:08.020><c></span> <span>want</c><00:06:08.289><c></span> <span>just</c><00:06:08.409><c></span> <span>talking</c><00:06:08.560><c></span> <span>about</c><00:06:08.620><c></span> <span>the</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 290, 368.76, 0.0, 'as a whole I want just talking about the', '', '', '<span>as</span> <span>a</span> <span>whole</span> <span>I</span> <span>want</span> <span>just</span> <span>talking</span> <span>about</span> <span>the</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 291, 368.77, 0.0, 'as a whole I want just talking about the United<00:06:09.039><c> States</c><00:06:09.280><c> or</c><00:06:09.460><c> the</c><00:06:09.490><c> UK</c><00:06:09.669><c> but</c><00:06:09.909><c> in</c><00:06:10.090><c> many</c><00:06:10.389><c> many</c>', '', '', '<span>as</span> <span>a</span> <span>whole</span> <span>I</span> <span>want</span> <span>just</span> <span>talking</span> <span>about</span> <span>the</span> <span>United<00:06:09.039><c></span> <span>States</c><00:06:09.280><c></span> <span>or</c><00:06:09.460><c></span> <span>the</c><00:06:09.490><c></span> <span>UK</c><00:06:09.669><c></span> <span>but</c><00:06:09.909><c></span> <span>in</c><00:06:10.090><c></span> <span>many</c><00:06:10.389><c></span> <span>many</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 292, 370.56, 0.0, 'United States or the UK but in many many', '', '', '<span>United</span> <span>States</span> <span>or</span> <span>the</span> <span>UK</span> <span>but</span> <span>in</span> <span>many</span> <span>many</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 293, 370.57, 0.0, 'United States or the UK but in many many countries<00:06:11.080><c> is</c><00:06:11.259><c> being</c><00:06:11.530><c> pornified</c>', '', '', '<span>United</span> <span>States</span> <span>or</span> <span>the</span> <span>UK</span> <span>but</span> <span>in</span> <span>many</span> <span>many</span> <span>countries<00:06:11.080><c></span> <span>is</c><00:06:11.259><c></span> <span>being</c><00:06:11.530><c></span> <span>pornified</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 294, 372.3, 0.0, 'countries is being pornified', '', '', '<span>countries</span> <span>is</span> <span>being</span> <span>pornified</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 295, 372.31, 0.0, 'countries is being pornified and<00:06:12.669><c> that</c><00:06:12.849><c> young</c><00:06:13.090><c> people</c><00:06:13.510><c> in</c><00:06:13.599><c> particular</c><00:06:13.779><c> are</c>', '', '', '<span>countries</span> <span>is</span> <span>being</span> <span>pornified</span> <span>and<00:06:12.669><c></span> <span>that</c><00:06:12.849><c></span> <span>young</c><00:06:13.090><c></span> <span>people</c><00:06:13.510><c></span> <span>in</c><00:06:13.599><c></span> <span>particular</c><00:06:13.779><c></span> <span>are</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 296, 374.37, 0.0, 'and that young people in particular are', '', '', '<span>and</span> <span>that</span> <span>young</span> <span>people</span> <span>in</span> <span>particular</span> <span>are</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 297, 374.38, 0.0, 'and that young people in particular are so<00:06:14.830><c> exposed</c><00:06:15.340><c> to</c>', '', '', '<span>and</span> <span>that</span> <span>young</span> <span>people</span> <span>in</span> <span>particular</span> <span>are</span> <span>so<00:06:14.830><c></span> <span>exposed</c><00:06:15.340><c></span> <span>to</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 298, 375.79, 0.0, 'so exposed to', '', '', '<span>so</span> <span>exposed</span> <span>to</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 299, 375.8, 0.0, 'so exposed to pornography<00:06:16.099><c> so</c><00:06:16.610><c> young</c><00:06:16.940><c> in</c><00:06:17.150><c> their</c><00:06:17.330><c> lives</c><00:06:17.629><c> that</c>', '', '', '<span>so</span> <span>exposed</span> <span>to</span> <span>pornography<00:06:16.099><c></span> <span>so</c><00:06:16.610><c></span> <span>young</c><00:06:16.940><c></span> <span>in</c><00:06:17.150><c></span> <span>their</c><00:06:17.330><c></span> <span>lives</c><00:06:17.629><c></span> <span>that</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 300, 378.399, 0.0, 'pornography so young in their lives that', '', '', '<span>pornography</span> <span>so</span> <span>young</span> <span>in</span> <span>their</span> <span>lives</span> <span>that</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 301, 378.409, 0.0, 'pornography so young in their lives that it''s<00:06:18.560><c> it''s</c><00:06:18.860><c> materially</c><00:06:19.639><c> changing</c><00:06:20.300><c> the</c><00:06:20.509><c> way</c>', '', '', '<span>pornography</span> <span>so</span> <span>young</span> <span>in</span> <span>their</span> <span>lives</span> <span>that</span> <span>it''s<00:06:18.560><c></span> <span>it''s</c><00:06:18.860><c></span> <span>materially</c><00:06:19.639><c></span> <span>changing</c><00:06:20.300><c></span> <span>the</c><00:06:20.509><c></span> <span>way</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 302, 380.649, 0.0, 'it''s it''s materially changing the way', '', '', '<span>it''s</span> <span>it''s</span> <span>materially</span> <span>changing</span> <span>the</span> <span>way</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 303, 380.659, 0.0, 'it''s it''s materially changing the way males<00:06:21.500><c> and</c><00:06:21.830><c> females</c><00:06:22.220><c> relate</c><00:06:22.580><c> to</c><00:06:22.759><c> each</c><00:06:22.879><c> other</c>', '', '', '<span>it''s</span> <span>it''s</span> <span>materially</span> <span>changing</span> <span>the</span> <span>way</span> <span>males<00:06:21.500><c></span> <span>and</c><00:06:21.830><c></span> <span>females</c><00:06:22.220><c></span> <span>relate</c><00:06:22.580><c></span> <span>to</c><00:06:22.759><c></span> <span>each</c><00:06:22.879><c></span> <span>other</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 304, 383.05, 0.0, 'males and females relate to each other', '', '', '<span>males</span> <span>and</span> <span>females</span> <span>relate</span> <span>to</span> <span>each</span> <span>other</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 305, 383.06, 0.0, 'males and females relate to each other the<00:06:23.300><c> way</c><00:06:23.419><c> they</c><00:06:23.449><c> think</c><00:06:23.870><c> about</c><00:06:23.990><c> relationships</c>', '', '', '<span>males</span> <span>and</span> <span>females</span> <span>relate</span> <span>to</span> <span>each</span> <span>other</span> <span>the<00:06:23.300><c></span> <span>way</c><00:06:23.419><c></span> <span>they</c><00:06:23.449><c></span> <span>think</c><00:06:23.870><c></span> <span>about</c><00:06:23.990><c></span> <span>relationships</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 306, 384.79, 0.0, 'the way they think about relationships', '', '', '<span>the</span> <span>way</span> <span>they</span> <span>think</span> <span>about</span> <span>relationships</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 307, 384.8, 0.0, 'the way they think about relationships in<00:06:25.009><c> a</c><00:06:25.370><c> potentially</c><00:06:26.270><c> very</c><00:06:26.740><c> corrosive</c><00:06:28.210><c> damaging</c>', '', '', '<span>the</span> <span>way</span> <span>they</span> <span>think</span> <span>about</span> <span>relationships</span> <span>in<00:06:25.009><c></span> <span>a</c><00:06:25.370><c></span> <span>potentially</c><00:06:26.270><c></span> <span>very</c><00:06:26.740><c></span> <span>corrosive</c><00:06:28.210><c></span> <span>damaging</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 308, 389.2, 0.0, 'in a potentially very corrosive damaging', '', '', '<span>in</span> <span>a</span> <span>potentially</span> <span>very</span> <span>corrosive</span> <span>damaging</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 309, 389.21, 0.0, 'in a potentially very corrosive damaging way<00:06:29.419><c> what''s</c><00:06:30.229><c> your</c><00:06:30.319><c> take</c><00:06:30.680><c> on</c><00:06:30.830><c> that</c>', '', '', '<span>in</span> <span>a</span> <span>potentially</span> <span>very</span> <span>corrosive</span> <span>damaging</span> <span>way<00:06:29.419><c></span> <span>what''s</c><00:06:30.229><c></span> <span>your</c><00:06:30.319><c></span> <span>take</c><00:06:30.680><c></span> <span>on</c><00:06:30.830><c></span> <span>that</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 310, 391.27, 0.0, 'way what''s your take on that', '', '', '<span>way</span> <span>what''s</span> <span>your</span> <span>take</span> <span>on</span> <span>that</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 311, 391.28, 0.0, 'way what''s your take on that of<00:06:31.940><c> course</c><00:06:32.210><c> it</c><00:06:32.330><c> affects</c><00:06:32.569><c> relationships</c><00:06:33.169><c> and</c>', '', '', '<span>way</span> <span>what''s</span> <span>your</span> <span>take</span> <span>on</span> <span>that</span> <span>of<00:06:31.940><c></span> <span>course</c><00:06:32.210><c></span> <span>it</c><00:06:32.330><c></span> <span>affects</c><00:06:32.569><c></span> <span>relationships</c><00:06:33.169><c></span> <span>and</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 312, 393.55, 0.0, 'of course it affects relationships and', '', '', '<span>of</span> <span>course</span> <span>it</span> <span>affects</span> <span>relationships</span> <span>and</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 313, 393.56, 0.0, 'of course it affects relationships and porn<00:06:34.220><c> addiction</c><00:06:34.310><c> is</c><00:06:34.810><c> very</c><00:06:35.810><c> prevalent</c><00:06:36.080><c> in</c>', '', '', '<span>of</span> <span>course</span> <span>it</span> <span>affects</span> <span>relationships</span> <span>and</span> <span>porn<00:06:34.220><c></span> <span>addiction</c><00:06:34.310><c></span> <span>is</c><00:06:34.810><c></span> <span>very</c><00:06:35.810><c></span> <span>prevalent</c><00:06:36.080><c></span> <span>in</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 314, 396.399, 0.0, 'porn addiction is very prevalent in', '', '', '<span>porn</span> <span>addiction</span> <span>is</span> <span>very</span> <span>prevalent</span> <span>in</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 315, 396.409, 0.0, 'porn addiction is very prevalent in America<00:06:36.889><c> and</c><00:06:37.009><c> I''m</c><00:06:37.099><c> sure</c><00:06:37.310><c> here</c><00:06:37.520><c> too</c><00:06:38.560><c> the</c><00:06:39.560><c> things</c>', '', '', '<span>porn</span> <span>addiction</span> <span>is</span> <span>very</span> <span>prevalent</span> <span>in</span> <span>America<00:06:36.889><c></span> <span>and</c><00:06:37.009><c></span> <span>I''m</c><00:06:37.099><c></span> <span>sure</c><00:06:37.310><c></span> <span>here</c><00:06:37.520><c></span> <span>too</c><00:06:38.560><c></span> <span>the</c><00:06:39.560><c></span> <span>things</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 316, 399.82, 0.0, 'America and I''m sure here too the things', '', '', '<span>America</span> <span>and</span> <span>I''m</span> <span>sure</span> <span>here</span> <span>too</span> <span>the</span> <span>things</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 317, 399.83, 0.0, 'America and I''m sure here too the things that<00:06:40.039><c> men</c><00:06:40.220><c> see</c><00:06:40.520><c> in</c><00:06:40.789><c> videos</c><00:06:41.180><c> they</c><00:06:41.479><c> expect</c><00:06:41.990><c> from</c>', '', '', '<span>America</span> <span>and</span> <span>I''m</span> <span>sure</span> <span>here</span> <span>too</span> <span>the</span> <span>things</span> <span>that<00:06:40.039><c></span> <span>men</c><00:06:40.220><c></span> <span>see</c><00:06:40.520><c></span> <span>in</c><00:06:40.789><c></span> <span>videos</c><00:06:41.180><c></span> <span>they</c><00:06:41.479><c></span> <span>expect</c><00:06:41.990><c></span> <span>from</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 318, 402.249, 0.0, 'that men see in videos they expect from', '', '', '<span>that</span> <span>men</span> <span>see</span> <span>in</span> <span>videos</span> <span>they</span> <span>expect</span> <span>from</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 319, 402.259, 0.0, 'that men see in videos they expect from the<00:06:42.590><c> women</c><00:06:42.860><c> in</c><00:06:42.979><c> their</c><00:06:43.099><c> lives</c><00:06:43.129><c> and</c><00:06:43.669><c> that''s</c><00:06:43.970><c> just</c>', '', '', '<span>that</span> <span>men</span> <span>see</span> <span>in</span> <span>videos</span> <span>they</span> <span>expect</span> <span>from</span> <span>the<00:06:42.590><c></span> <span>women</c><00:06:42.860><c></span> <span>in</c><00:06:42.979><c></span> <span>their</c><00:06:43.099><c></span> <span>lives</c><00:06:43.129><c></span> <span>and</c><00:06:43.669><c></span> <span>that''s</c><00:06:43.970><c></span> <span>just</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 320, 404.26, 0.0, 'the women in their lives and that''s just', '', '', '<span>the</span> <span>women</span> <span>in</span> <span>their</span> <span>lives</span> <span>and</span> <span>that''s</span> <span>just</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 321, 404.27, 0.0, 'the women in their lives and that''s just not<00:06:44.479><c> reality</c><00:06:44.800><c> no</c><00:06:45.800><c> one</c><00:06:45.979><c> is</c><00:06:46.129><c> going</c><00:06:46.280><c> to</c><00:06:46.400><c> be</c><00:06:46.669><c> that</c>', '', '', '<span>the</span> <span>women</span> <span>in</span> <span>their</span> <span>lives</span> <span>and</span> <span>that''s</span> <span>just</span> <span>not<00:06:44.479><c></span> <span>reality</c><00:06:44.800><c></span> <span>no</c><00:06:45.800><c></span> <span>one</c><00:06:45.979><c></span> <span>is</c><00:06:46.129><c></span> <span>going</c><00:06:46.280><c></span> <span>to</c><00:06:46.400><c></span> <span>be</c><00:06:46.669><c></span> <span>that</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 322, 407.35, 0.0, 'not reality no one is going to be that', '', '', '<span>not</span> <span>reality</span> <span>no</span> <span>one</span> <span>is</span> <span>going</span> <span>to</span> <span>be</span> <span>that</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 323, 407.36, 0.0, 'not reality no one is going to be that perfect<00:06:47.629><c> no</c><00:06:48.020><c> one</c><00:06:48.139><c> is</c><00:06:48.259><c> going</c><00:06:48.409><c> to</c><00:06:48.849><c> do</c><00:06:49.849><c> those</c><00:06:50.030><c> acts</c>', '', '', '<span>not</span> <span>reality</span> <span>no</span> <span>one</span> <span>is</span> <span>going</span> <span>to</span> <span>be</span> <span>that</span> <span>perfect<00:06:47.629><c></span> <span>no</c><00:06:48.020><c></span> <span>one</c><00:06:48.139><c></span> <span>is</c><00:06:48.259><c></span> <span>going</c><00:06:48.409><c></span> <span>to</c><00:06:48.849><c></span> <span>do</c><00:06:49.849><c></span> <span>those</c><00:06:50.030><c></span> <span>acts</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 324, 410.32, 0.0, 'perfect no one is going to do those acts', '', '', '<span>perfect</span> <span>no</span> <span>one</span> <span>is</span> <span>going</span> <span>to</span> <span>do</span> <span>those</span> <span>acts</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 325, 410.33, 0.0, 'perfect no one is going to do those acts on<00:06:50.750><c> a</c><00:06:50.990><c> Wednesday</c><00:06:51.650><c> night</c><00:06:51.680><c> with</c><00:06:52.039><c> the</c><00:06:52.129><c> person</c>', '', '', '<span>perfect</span> <span>no</span> <span>one</span> <span>is</span> <span>going</span> <span>to</span> <span>do</span> <span>those</span> <span>acts</span> <span>on<00:06:50.750><c></span> <span>a</c><00:06:50.990><c></span> <span>Wednesday</c><00:06:51.650><c></span> <span>night</c><00:06:51.680><c></span> <span>with</c><00:06:52.039><c></span> <span>the</c><00:06:52.129><c></span> <span>person</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 326, 412.48, 0.0, 'on a Wednesday night with the person', '', '', '<span>on</span> <span>a</span> <span>Wednesday</span> <span>night</span> <span>with</span> <span>the</span> <span>person</span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 327, 412.49, 0.0, 'on a Wednesday night with the person they<00:06:52.610><c> love</c>', '', '', '<span>on</span> <span>a</span> <span>Wednesday</span> <span>night</span> <span>with</span> <span>the</span> <span>person</span> <span>they<00:06:52.610><c></span> <span>love</c></span>'
FROM episodes e WHERE e.video_id = 'sQe2j4A_zYD1-8k';

-- episode 195: s_OlOCwlf9K6spM
INSERT INTO episodes (
  index, video_id, short_title, summary, remark, stars, voca_size,
  subtitle_count, clip_length, cover, video_url, audio_url, thumbnail_url,
  original_video_url, author_id, submitted_by_user_id, rejection_reason,
  created_at, is_demo, status, published_at
) VALUES (
  195, 's_OlOCwlf9K6spM', '董宇辉英文专访完整版',
  '董宇辉英文专访完整版，这才是电商主播的标杆和天花板吧', '',
  3, 0, 348,
  0.0, 'http://oss.sxakgs.com/en/h1-8kpaSaSQ/cover.webp',
  'http://oss.sxakgs.com/en/h1-8kpaSaSQ/video.mp4', 'http://oss.sxakgs.com/en/h1-8kpaSaSQ/audio.mp3',
  'http://oss.sxakgs.com/en/h1-8kpaSaSQ/cover.webp', 'https://www.youtube.com/watch?v=h1-8kpaSaSQ',
  (SELECT id FROM authors WHERE name = '飞翔xmfly' AND accent = '美国' LIMIT 1),
  NULL, NULL,
  '2026-07-02 15:51:01'::timestamp,
  FALSE, 'published',
  '2026-07-02 16:01:29'::timestamp
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
  SELECT s.id FROM subtitles s JOIN episodes e ON s.episode_id = e.id WHERE e.video_id = 's_OlOCwlf9K6spM'
);
DELETE FROM subtitles WHERE episode_id = (SELECT id FROM episodes WHERE video_id = 's_OlOCwlf9K6spM');
DELETE FROM episode_tags WHERE episode_id = (SELECT id FROM episodes WHERE video_id = 's_OlOCwlf9K6spM');

INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 0, 2.79, 0.0, 'It''s a pleasure to have you, Yui.', '很高兴见到你，Yui。', '/ɪts ə ˈplɛʒər tə hæv juː, ˈjuːiː/', '<span>It''s</span><span>a</span><span tid="50001" class="highlight highlight-a">pleasure</span><span>to</span><span>have</span><span>you,</span><span>Yui.</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 1, 2.8, 0.0, 'It''s a pleasure to have you, Yui.  My<00:00:03.120><c> pleasure.</c>', '很高兴见到你，Yui。 我的荣幸。', '/ɪts ə ˈplɛʒər tə hæv juː, ˈjuːiː. maɪ ˈplɛʒər/', '<span>It''s</span><span>a</span><span>pleasure</span><span>to</span><span>have</span><span>you,</span><span>Yui.</span><span>&gt;&gt;</span><span>My<00:00:03.120><c></span><span>pleasure.</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 2, 3.83, 0.0, 'My pleasure.', '我的荣幸。', '/maɪ ˈplɛʒər/', '<span>&gt;&gt;</span><span>My</span><span tid="50002" class="highlight highlight-a">pleasure.</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 3, 3.84, 0.0, 'My pleasure. &gt;&gt; So,<00:00:04.080><c> when</c><00:00:04.319><c> you</c><00:00:04.560><c> first</c><00:00:04.799><c> started,</c><00:00:05.520><c> there</c><00:00:05.680><c> was</c><00:00:05.839><c> a</c>', '我的荣幸。 那么，当你刚开始的时候，', '/maɪ ˈplɛʒər. soʊ, wɛn juː fɜːrst ˈstɑːrtɪd, ðɛr wʌz ə/', '<span>&gt;&gt;</span><span>My</span><span>pleasure.</span><span>&gt;&gt;</span><span>So,<00:00:04.080><c></span><span>when</c><00:00:04.319><c></span><span>you</c><00:00:04.560><c></span><span>first</c><00:00:04.799><c></span><span>started,</c><00:00:05.520><c></span><span>there</c><00:00:05.680><c></span><span>was</c><00:00:05.839><c></span><span>a</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 4, 5.99, 0.0, 'So, when you first started, there was a', '那么，当你刚开始的时候，有一个', '/soʊ, wɛn juː fɜːrst ˈstɑːrtɪd, ðɛr wʌz ə/', '<span>&gt;&gt;</span><span>So,</span><span>when</span><span>you</span><span>first</span><span>started,</span><span>there</span><span>was</span><span>a</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 5, 6.0, 0.0, 'So, when you first started, there was a time<00:00:06.080><c> that</c><00:00:06.319><c> you</c><00:00:06.480><c> couldn''t</c><00:00:06.799><c> sell.</c><00:00:07.680><c> You</c><00:00:07.919><c> had</c>', '那么，当你刚开始的时候，有一段时间你卖不出去。你只有', '/soʊ, wɛn juː fɜːrst ˈstɑːrtɪd, ðɛr wʌz ə taɪm ðæt juː ˈkʊdənt sɛl. juː hæd/', '<span>&gt;&gt;</span><span>So,</span><span>when</span><span>you</span><span>first</span><span>started,</span><span>there</span><span>was</span><span>a</span><span>time<00:00:06.080><c></span><span>that</c><00:00:06.319><c></span><span>you</c><00:00:06.480><c></span><span>couldn''t</c><00:00:06.799><c></span><span>sell.</c><00:00:07.680><c></span><span>You</c><00:00:07.919><c></span><span>had</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 6, 8.07, 0.0, 'time that you couldn''t sell. You had', '有一段时间你卖不出去。你只有', '/taɪm ðæt juː ˈkʊdənt sɛl. juː hæd/', '<span tid="50003" class="highlight highlight-a">time</span><span>that</span><span>you</span><span>couldn''t</span><span tid="50004" class="highlight highlight-a">sell.</span><span>You</span><span>had</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 7, 8.08, 0.0, 'time that you couldn''t sell. You had very<00:00:08.400><c> few</c><00:00:08.800><c> followers,</c><00:00:09.760><c> five</c><00:00:10.240><c> to</c><00:00:10.480><c> say.</c>', '有一段时间你卖不出去。你只有很少的粉丝，大概五个。', '/taɪm ðæt juː ˈkʊdənt sɛl. juː hæd ˈvɛri fjuː ˈfoʊloʊərz, faɪv tə seɪ/', '<span>time</span><span>that</span><span>you</span><span>couldn''t</span><span>sell.</span><span>You</span><span>had</span><span>very<00:00:08.400><c></span><span>few</c><00:00:08.800><c></span><span>followers,</c><00:00:09.760><c></span><span>five</c><00:00:10.240><c></span><span>to</c><00:00:10.480><c></span><span>say.</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 8, 10.87, 0.0, 'very few followers, five to say.', '很少的粉丝，大概五个。', '/ˈvɛri fjuː ˈfoʊloʊərz, faɪv tə seɪ/', '<span>very</span><span tid="50005" class="highlight highlight-a">few</span><span tid="50006" class="highlight highlight-a">followers</span><span>,</span><span>five</span><span>to</span><span>say</span><span>.</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 9, 10.88, 0.0, 'very few followers, five to say. Five<00:00:11.120><c> or</c><00:00:11.360><c> four?</c>', '很少的粉丝，大概五个。 五个还是四个？', '/ˈvɛri fjuː ˈfoʊloʊərz, faɪv tə seɪ. faɪv ɔːr fɔːr/', '<span>very</span><span>few</span><span>followers,</span><span>five</span><span>to</span><span>say.</span><span>&gt;&gt;</span><span>Five<00:00:11.120><c></span><span>or</c><00:00:11.360><c></span><span>four?</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 10, 11.749, 0.0, 'Five or four?', '五个还是四个？', '/faɪv ɔːr fɔːr/', '<span>&gt;&gt;</span><span>Five</span><span>or</span><span>four?</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 11, 11.759, 0.0, 'Five or four?  Yeah.', '五个还是四个？ 是的。', '/faɪv ɔːr fɔːr. jɛə/', '<span>&gt;&gt;</span><span>Five</span><span>or</span><span>four?</span><span>&gt;&gt;</span><span>Yeah.</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 12, 12.07, 0.0, 'Yeah.', ' 是的。', '/jɛə/', '<span>&gt;&gt;</span><span>Yeah.</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 13, 12.08, 0.0, 'Yeah. &gt;&gt; Yeah.<00:00:12.400><c> Did</c><00:00:12.559><c> you</c><00:00:12.719><c> see</c><00:00:12.800><c> a</c><00:00:13.040><c> point</c><00:00:13.280><c> of</c><00:00:13.519><c> making</c><00:00:13.759><c> that</c>', ' 是的。  是的。你有没有看到这样做的意义', '/jɛə. jɛə. dɪd juː siː ə pɔɪnt əv ˈmeɪkɪŋ ðæt/', '<span>&gt;&gt;</span><span>Yeah.</span><span>&gt;&gt;</span><span>Yeah.<00:00:12.400><c></span><span>Did</c><00:00:12.559><c></span><span>you</c><00:00:12.719><c></span><span>see</c><00:00:12.800><c></span><span>a</c><00:00:13.040><c></span><span>point</c><00:00:13.280><c></span><span>of</c><00:00:13.519><c></span><span>making</c><00:00:13.759><c></span><span>that</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 14, 13.99, 0.0, 'Yeah. Did you see a point of making that', ' 是的。你有没有看到这样做的意义', '/jɛə. dɪd juː siː ə pɔɪnt əv ˈmeɪkɪŋ ðæt/', '<span>&gt;&gt;</span><span>Yeah.</span><span>Did</span><span>you</span><span>see</span><span>a</span><span>point</span><span>of</span><span>making</span><span>that</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 15, 14.0, 0.0, 'Yeah. Did you see a point of making that effort<00:00:14.400><c> and</c><00:00:14.639><c> why</c><00:00:14.799><c> did</c><00:00:14.960><c> you</c><00:00:15.200><c> carry</c><00:00:15.440><c> on?</c><00:00:15.759><c> What</c>', ' 是的。你有没有看到这样做的意义，为什么你坚持了下来？是什么', '/jɛə. dɪd juː siː ə pɔɪnt əv ˈmeɪkɪŋ ðæt ˈɛfərt ænd waɪ dɪd juː ˈkæri ɑːn? wʌt/', '<span>&gt;&gt;</span><span>Yeah.</span><span>Did</span><span>you</span><span>see</span><span>a</span><span>point</span><span>of</span><span>making</span><span>that</span><span>effort<00:00:14.400><c></span><span>and</c><00:00:14.639><c></span><span>why</c><00:00:14.799><c></span><span>did</c><00:00:14.960><c></span><span>you</c><00:00:15.200><c></span><span>carry</c><00:00:15.440><c></span><span>on?</c><00:00:15.759><c></span><span>What</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 16, 15.99, 0.0, 'effort and why did you carry on? What', '努力，为什么你坚持了下来？是什么', '/ˈɛfərt ænd waɪ dɪd juː ˈkæri ɑːn? wʌt/', '<span tid="50007" class="highlight highlight-a">effort</span><span>and</span><span>why</span><span>did</span><span>you</span><span pid="501" class="highlight highlight-d">carry on</span><span>?</span><span>What</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 17, 16.0, 0.0, 'effort and why did you carry on? What made<00:00:16.160><c> you</c><00:00:16.400><c> carry</c><00:00:16.720><c> on?</c>', '努力，为什么你坚持了下来？是什么让你坚持了下来？', '/ˈɛfərt ænd waɪ dɪd juː ˈkæri ɑːn? wʌt meɪd juː ˈkæri ɑːn/', '<span>effort</span><span>and</span><span>why</span><span>did</span><span>you</span><span>carry</span><span>on?</span><span>What</span><span>made<00:00:16.160><c></span><span>you</c><00:00:16.400><c></span><span>carry</c><00:00:16.720><c></span><span>on?</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 18, 17.43, 0.0, 'made you carry on?', '是什么让你坚持了下来？', '/meɪd juː ˈkæri ɑːn/', '<span>made</span><span>you</span><span pid="502" class="highlight highlight-d">carry on</span><span>?</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 19, 17.44, 0.0, 'made you carry on? &gt;&gt; I<00:00:17.600><c> I</c><00:00:17.920><c> wasn''t</c><00:00:18.800><c> myself</c><00:00:19.520><c> at</c><00:00:19.760><c> the</c><00:00:20.000><c> beginning</c><00:00:20.640><c> when</c>', '是什么让你坚持了下来？ >> 我，我一开始并不是我自己，当', '/meɪd juː ˈkæri ɑːn? aɪ aɪ ˈwʌzənt maɪˈsɛlf æt ðə bɪˈgɪnɪŋ wɛn/', '<span>made</span><span>you</span><span>carry</span><span>on?</span><span>&gt;&gt;</span><span>I<00:00:17.600><c></span><span>I</c><00:00:17.920><c></span><span>wasn''t</c><00:00:18.800><c></span><span>myself</c><00:00:19.520><c></span><span>at</c><00:00:19.760><c></span><span>the</c><00:00:20.000><c></span><span>beginning</c><00:00:20.640><c></span><span>when</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 20, 20.87, 0.0, '&gt;&gt; I I wasn''t myself at the beginning when', ' 我，我一开始并不是我自己，当', '/aɪ aɪ ˈwʌzənt maɪˈsɛlf æt ðə bɪˈgɪnɪŋ wɛn/', '<span>&gt;&gt;</span><span>I</span><span>I</span><span>wasn''t</span><span>myself</span><span>at</span><span>the</span><span>beginning</span><span>when</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 21, 20.88, 0.0, '&gt;&gt; I I wasn''t myself at the beginning when I<00:00:21.039><c> was</c><00:00:21.199><c> trying</c><00:00:21.439><c> to</c><00:00:21.600><c> sell</c><00:00:21.840><c> goods</c><00:00:22.160><c> to</c><00:00:22.400><c> viewers</c><00:00:22.960><c> in</c>', ' 我，我一开始并不是我自己，当我试图向屏幕前的观众推销商品时，', '/aɪ aɪ ˈwʌzənt maɪˈsɛlf æt ðə bɪˈgɪnɪŋ wɛn aɪ wʌz ˈtraɪɪŋ tə sɛl gʊdz tə ˈvjuːərz ɪn/', '<span>&gt;&gt;</span><span>I</span><span>I</span><span>wasn''t</span><span>myself</span><span>at</span><span>the</span><span>beginning</span><span>when</span><span>I<00:00:21.039><c></span><span>was</c><00:00:21.199><c></span><span>trying</c><00:00:21.439><c></span><span>to</c><00:00:21.600><c></span><span>sell</c><00:00:21.840><c></span><span>goods</c><00:00:22.160><c></span><span>to</c><00:00:22.400><c></span><span>viewers</c><00:00:22.960><c></span><span>in</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 22, 23.189, 0.0, 'I was trying to sell goods to viewers in', '我试图向屏幕前的观众推销商品时，', '/aɪ wʌz ˈtraɪɪŋ tə sɛl gʊdz tə ˈvjuːərz ɪn/', '<span>I</span><span>was</span><span>trying</span><span>to</span><span tid="50008" class="highlight highlight-a">sell</span><span tid="50009" class="highlight highlight-a">goods</span><span>to</span><span tid="50010" class="highlight highlight-a">viewers</span><span>in</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 23, 23.199, 0.0, 'I was trying to sell goods to viewers in front<00:00:23.359><c> of</c><00:00:23.600><c> screen.</c><00:00:24.400><c> I</c><00:00:24.800><c> belittled</c><00:00:25.519><c> myself.</c><00:00:26.160><c> I</c>', '我试图向屏幕前的观众推销商品时，我贬低了自己。我', '/aɪ wʌz ˈtraɪɪŋ tə sɛl gʊdz tə ˈvjuːərz ɪn frʌnt əv skriːn. aɪ bɪˈlɪtəld maɪˈsɛlf. aɪ/', '<span>I</span><span>was</span><span>trying</span><span>to</span><span>sell</span><span>goods</span><span>to</span><span>viewers</span><span>in</span><span>front<00:00:23.359><c></span><span>of</c><00:00:23.600><c></span><span>screen.</c><00:00:24.400><c></span><span>I</c><00:00:24.800><c></span><span>belittled</c><00:00:25.519><c></span><span>myself.</c><00:00:26.160><c></span><span>I</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 24, 26.39, 0.0, 'front of screen. I belittled myself. I', '屏幕前。我贬低了自己。我', '/frʌnt əv skriːn. aɪ bɪˈlɪtəld maɪˈsɛlf. aɪ/', '<span pid="503" class="highlight highlight-c">front of screen.</span><span>I</span><span tid="50011" class="highlight highlight-a">belittled</span><span>myself.</span><span>I</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 25, 26.4, 0.0, 'front of screen. I belittled myself. I thought<00:00:26.560><c> that</c><00:00:26.800><c> was</c><00:00:27.359><c> meaningless</c><00:00:28.080><c> because</c><00:00:28.400><c> I</c>', '屏幕前。我贬低了自己。我觉得那毫无意义，因为我', '/frʌnt əv skriːn. aɪ bɪˈlɪtəld maɪˈsɛlf. aɪ θɔːt ðæt wʌz ˈmiːnɪŋləs bɪˈkɔːz aɪ/', '<span>front</span><span>of</span><span>screen.</span><span>I</span><span>belittled</span><span>myself.</span><span>I</span><span>thought<00:00:26.560><c></span><span>that</c><00:00:26.800><c></span><span>was</c><00:00:27.359><c></span><span>meaningless</c><00:00:28.080><c></span><span>because</c><00:00:28.400><c></span><span>I</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 26, 28.55, 0.0, 'thought that was meaningless because I', '觉得那毫无意义，因为我', '/θɔːt ðæt wʌz ˈmiːnɪŋləs bɪˈkɔːz aɪ/', '<span>thought</span><span>that</span><span>was</span><span tid="50012" class="highlight highlight-a">meaningless</span><span>because</span><span>I</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 27, 28.56, 0.0, 'thought that was meaningless because I used<00:00:28.800><c> to</c><00:00:28.960><c> be</c><00:00:29.039><c> a</c><00:00:29.199><c> teacher,</c><00:00:29.840><c> an</c><00:00:30.080><c> English</c><00:00:30.400><c> teacher</c>', '觉得那毫无意义，因为我曾经是一名老师，一名英语老师', '/θɔːt ðæt wʌz ˈmiːnɪŋləs bɪˈkɔːz aɪ juːst tə biː ə ˈtiːtʃər, ən ˈɪŋglɪʃ ˈtiːtʃər/', '<span>thought</span><span>that</span><span>was</span><span>meaningless</span><span>because</span><span>I</span><span>used<00:00:28.800><c></span><span>to</c><00:00:28.960><c></span><span>be</c><00:00:29.039><c></span><span>a</c><00:00:29.199><c></span><span>teacher,</c><00:00:29.840><c></span><span>an</c><00:00:30.080><c></span><span>English</c><00:00:30.400><c></span><span>teacher</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 28, 31.189, 0.0, 'used to be a teacher, an English teacher', '曾经是一名老师，一名英语老师', '/juːst tə biː ə ˈtiːtʃər, ən ˈɪŋglɪʃ ˈtiːtʃər/', '<span pid="504" class="highlight highlight-d">used to</span><span>be</span><span>a</span><span>teacher,</span><span>an</span><span>English</span><span>teacher</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 29, 31.199, 0.0, 'used to be a teacher, an English teacher for<00:00:31.439><c> eight</c><00:00:31.760><c> years.</c><00:00:32.320><c> So</c><00:00:32.719><c> I</c><00:00:33.040><c> define</c><00:00:33.520><c> myself</c><00:00:34.000><c> as</c>', '曾经是一名老师，一名英语老师，教了八年。所以我定义自己为', '/juːst tə biː ə ˈtiːtʃər, ən ˈɪŋglɪʃ ˈtiːtʃər fɔːr eɪt jɪrz. soʊ aɪ dɪˈfaɪn maɪˈsɛlf æz/', '<span>used</span><span>to</span><span>be</span><span>a</span><span>teacher,</span><span>an</span><span>English</span><span>teacher</span><span>for<00:00:31.439><c></span><span>eight</c><00:00:31.760><c></span><span>years.</c><00:00:32.320><c></span><span>So</c><00:00:32.719><c></span><span>I</c><00:00:33.040><c></span><span>define</c><00:00:33.520><c></span><span>myself</c><00:00:34.000><c></span><span>as</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 30, 34.549, 0.0, 'for eight years. So I define myself as', '八年了。所以我将自己定义为', '/fɔːr eɪt jɪrz soʊ aɪ dɪˈfaɪn maɪˈsɛlf æz/', '<span>for</span><span>eight</span><span>years.</span><span>So</span><span>I</span><span tid="50013" class="highlight highlight-a">define</span><span>myself</span><span>as</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 31, 34.559, 0.0, 'for eight years. So I define myself as someone<00:00:35.040><c> who</c><00:00:36.079><c> spread</c><00:00:36.399><c> the</c><00:00:36.559><c> knowledge</c><00:00:37.200><c> and</c>', '八年了。所以我将自己定义为一个传播知识的人', '/fɔːr eɪt jɪrz soʊ aɪ dɪˈfaɪn maɪˈsɛlf æz ˈsʌmwʌn huː sprɛd ðə ˈnɑlɪdʒ ænd/', '<span>for</span><span>eight</span><span>years.</span><span>So</span><span>I</span><span>define</span><span>myself</span><span>as</span><span>someone<00:00:35.040><c></span><span>who</c><00:00:36.079><c></span><span>spread</c><00:00:36.399><c></span><span>the</c><00:00:36.559><c></span><span>knowledge</c><00:00:37.200><c></span><span>and</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 32, 37.59, 0.0, 'someone who spread the knowledge and', '一个传播知识的人', '/ˈsʌmwʌn huː sprɛd ðə ˈnɑlɪdʒ ænd/', '<span>someone</span><span>who</span><span tid="50014" class="highlight highlight-a">spread</span><span>the</span><span tid="50015" class="highlight highlight-a">knowledge</span><span>and</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 33, 37.6, 0.0, 'someone who spread the knowledge and what<00:00:37.840><c> ambition,</c><00:00:38.800><c> what</c><00:00:39.120><c> mission</c><00:00:39.920><c> they</c><00:00:40.160><c> should</c>', '一个传播知识的人，以及他们应该有什么样的抱负和使命', '/ˈsʌmwʌn huː sprɛd ðə ˈnɑlɪdʒ ænd wʌt æmˈbɪʃən wʌt ˈmɪʃən ðeɪ ʃʊd/', '<span>someone</span><span>who</span><span>spread</span><span>the</span><span>knowledge</span><span>and</span><span>what<00:00:37.840><c></span><span>ambition,</c><00:00:38.800><c></span><span>what</c><00:00:39.120><c></span><span>mission</c><00:00:39.920><c></span><span>they</c><00:00:40.160><c></span><span>should</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 34, 40.389, 0.0, 'what ambition, what mission they should', '什么样的抱负，什么样的使命', '/wʌt æmˈbɪʃən wʌt ˈmɪʃən ðeɪ ʃʊd/', '<span>what</span><span tid="50016" class="highlight highlight-a">ambition</span><span>,</span><span>what</span><span tid="50017" class="highlight highlight-a">mission</span><span>they</span><span>should</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 35, 40.399, 0.0, 'what ambition, what mission they should to<00:00:40.640><c> make</c><00:00:40.879><c> for</c><00:00:41.120><c> the</c><00:00:41.280><c> future.</c><00:00:42.079><c> I</c><00:00:42.320><c> am</c><00:00:42.559><c> not</c><00:00:42.800><c> the</c>', '什么样的抱负，什么样的使命，他们应该为未来创造什么。我不是那种', '/wʌt æmˈbɪʃən wʌt ˈmɪʃən ðeɪ ʃʊd tuː meɪk fɔːr ðə ˈfjuːtʃər aɪ æm nɑt ðə/', '<span>what</span><span>ambition,</span><span>what</span><span>mission</span><span>they</span><span>should</span><span>to<00:00:40.640><c></span><span>make</c><00:00:40.879><c></span><span>for</c><00:00:41.120><c></span><span>the</c><00:00:41.280><c></span><span>future.</c><00:00:42.079><c></span><span>I</c><00:00:42.320><c></span><span>am</c><00:00:42.559><c></span><span>not</c><00:00:42.800><c></span><span>the</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 36, 43.03, 0.0, 'to make for the future. I am not the', '为未来创造什么。我不是那种', '/tuː meɪk fɔːr ðə ˈfjuːtʃər aɪ æm nɑt ðə/', '<span>to</span><span tid="50018" class="highlight highlight-a">make</span><span>for</span><span>the</span><span tid="50019" class="highlight highlight-a">future</span><span>.</span><span>I</span><span>am</span><span>not</span><span>the</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 37, 43.04, 0.0, 'to make for the future. I am not the person<00:00:43.280><c> to</c><00:00:43.600><c> yell</c><00:00:44.079><c> in</c><00:00:44.320><c> front</c><00:00:44.559><c> of</c><00:00:44.719><c> screen.</c><00:00:45.440><c> That</c>', '为未来创造什么。我不是那种在屏幕前大喊大叫的人。那', '/tuː meɪk fɔːr ðə ˈfjuːtʃər aɪ æm nɑt ðə ˈpɜːrsən tuː jɛl ɪn frʌnt ʌv skriːn ðæt/', '<span>to</span><span>make</span><span>for</span><span>the</span><span>future.</span><span>I</span><span>am</span><span>not</span><span>the</span><span>person<00:00:43.280><c></span><span>to</c><00:00:43.600><c></span><span>yell</c><00:00:44.079><c></span><span>in</c><00:00:44.320><c></span><span>front</c><00:00:44.559><c></span><span>of</c><00:00:44.719><c></span><span>screen.</c><00:00:45.440><c></span><span>That</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 38, 45.67, 0.0, 'person to yell in front of screen. That', '在屏幕前大喊大叫的人。那', '/ˈpɜːrsən tuː jɛl ɪn frʌnt ʌv skriːn ðæt/', '<span>person</span><span>to</span><span tid="50020" class="highlight highlight-a">yell</span><span>in</span><span>front</span><span>of</span><span tid="50021" class="highlight highlight-a">screen</span><span>.</span><span>That</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 39, 45.68, 0.0, 'person to yell in front of screen. That wasn''t<00:00:46.000><c> something</c><00:00:46.320><c> a</c><00:00:46.559><c> teacher</c><00:00:46.879><c> should</c><00:00:47.120><c> do.</c>', '在屏幕前大喊大叫的人。那不是老师应该做的事。', '/ˈpɜːrsən tuː jɛl ɪn frʌnt ʌv skriːn ðæt ˈwʌzənt ˈsʌmθɪŋ ə ˈtiːtʃər ʃʊd duː/', '<span>person</span><span>to</span><span>yell</span><span>in</span><span>front</span><span>of</span><span>screen.</span><span>That</span><span>wasn''t<00:00:46.000><c></span><span>something</c><00:00:46.320><c></span><span>a</c><00:00:46.559><c></span><span>teacher</c><00:00:46.879><c></span><span>should</c><00:00:47.120><c></span><span>do.</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 40, 47.51, 0.0, 'wasn''t something a teacher should do.', '那不是老师应该做的事。', '/ˈwʌzənt ˈsʌmθɪŋ ə ˈtiːtʃər ʃʊd duː/', '<span>wasn''t</span> <span>something</span> <span>a</span> <span>teacher</span> <span>should</span> <span>do.</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 41, 47.52, 0.0, 'wasn''t something a teacher should do. &gt;&gt; You<00:00:47.760><c> don''t</c><00:00:47.920><c> take</c><00:00:48.079><c> pride</c><00:00:48.320><c> in</c><00:00:48.559><c> what</c><00:00:48.960><c> you</c><00:00:49.200><c> had</c><00:00:49.440><c> to</c>', '那不是老师应该做的事。>> 你并不为你不得不做的事感到自豪', '/ˈwʌzənt ˈsʌmθɪŋ ə ˈtiːtʃər ʃʊd duː juː doʊnt teɪk praɪd ɪn wʌt juː hæd tuː/', '<span>wasn''t</span> <span>something</span> <span>a</span> <span>teacher</span> <span>should</span> <span>do.</span> <span>&gt;&gt;</span> <span>You<00:00:47.760><c></span> <span>don''t</c><00:00:47.920><c></span> <span>take</c><00:00:48.079><c></span> <span>pride</c><00:00:48.320><c></span> <span>in</c><00:00:48.559><c></span> <span>what</c><00:00:48.960><c></span> <span>you</c><00:00:49.200><c></span> <span>had</c><00:00:49.440><c></span> <span>to</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 42, 49.59, 0.0, '&gt;&gt; You don''t take pride in what you had to', '>> 你并不为你不得不做的事感到自豪', '/juː doʊnt teɪk praɪd ɪn wʌt juː hæd tuː/', '<span>&gt;&gt;</span> <span>You</span> <span>don''t</span> <span>take</span> <span>pride</span> <span>in</span> <span>what</span> <span>you</span> <span>had</span> <span>to</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 43, 49.6, 0.0, '&gt;&gt; You don''t take pride in what you had to do.', '>> 你并不为你不得不做的事感到自豪。', '/juː doʊnt teɪk praɪd ɪn wʌt juː hæd tuː duː/', '<span>&gt;&gt;</span> <span>You</span> <span>don''t</span> <span>take</span> <span>pride</span> <span>in</span> <span>what</span> <span>you</span> <span>had</span> <span>to</span> <span>do.</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 44, 50.63, 0.0, 'do.', '做。', '/duː/', '<span>do.</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 45, 50.64, 0.0, 'do. &gt;&gt; I<00:00:50.879><c> didn''t</c><00:00:51.120><c> find</c><00:00:51.360><c> the</c><00:00:51.600><c> turning</c><00:00:51.920><c> point</c><00:00:52.800><c> even</c>', '做。>> 我甚至没有找到转折点', '/duː aɪ ˈdɪdənt faɪnd ðə ˈtɜːrnɪŋ pɔɪnt ˈiːvən/', '<span>do.</span> <span>&gt;&gt;</span> <span>I<00:00:50.879><c></span> <span>didn''t</c><00:00:51.120><c></span> <span>find</c><00:00:51.360><c></span> <span>the</c><00:00:51.600><c></span> <span>turning</c><00:00:51.920><c></span> <span>point</c><00:00:52.800><c></span> <span>even</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 46, 53.11, 0.0, '&gt;&gt; I didn''t find the turning point even', '>> 我甚至没有找到转折点', '/aɪ ˈdɪdənt faɪnd ðə ˈtɜːrnɪŋ pɔɪnt ˈiːvən/', '<span>&gt;&gt;</span> <span>I</span> <span>didn''t</span> <span>find</span> <span>the</span> <span>turning</span> <span>point</span> <span>even</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 47, 53.12, 0.0, '&gt;&gt; I didn''t find the turning point even though<00:00:53.280><c> the</c><00:00:53.440><c> world</c><00:00:53.760><c> was</c><00:00:54.079><c> changing</c><00:00:54.480><c> for</c><00:00:54.719><c> me.</c>', '>> 我甚至没有找到转折点，尽管世界在为我改变。', '/aɪ ˈdɪdənt faɪnd ðə ˈtɜːrnɪŋ pɔɪnt ˈiːvən ðoʊ ðə wɜːrld wʌz ˈtʃeɪndʒɪŋ fɔːr miː/', '<span>&gt;&gt;</span> <span>I</span> <span>didn''t</span> <span>find</span> <span>the</span> <span>turning</span> <span>point</span> <span>even</span> <span>though<00:00:53.280><c></span> <span>the</c><00:00:53.440><c></span> <span>world</c><00:00:53.760><c></span> <span>was</c><00:00:54.079><c></span> <span>changing</c><00:00:54.480><c></span> <span>for</c><00:00:54.719><c></span> <span>me.</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 48, 55.51, 0.0, 'though the world was changing for me.', '尽管世界在为我改变。', '/ðoʊ ðə wɜːrld wʌz ˈtʃeɪndʒɪŋ fɔːr miː/', '<span>though</span> <span>the</span> <span>world</span> <span>was</span> <span>changing</span> <span>for</span> <span>me.</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 49, 55.52, 0.0, 'though the world was changing for me. collapsed<00:00:56.719><c> and</c><00:00:57.440><c> reconstructed</c><00:00:58.399><c> again.</c>', '尽管世界在为我改变。崩溃又重建。', '/ðoʊ ðə wɜːrld wʌz ˈtʃeɪndʒɪŋ fɔːr miː kəˈlæpsd ænd ˌriːkənˈstrʌktɪd əˈɡɛn/', '<span>though</span> <span>the</span> <span>world</span> <span>was</span> <span>changing</span> <span>for</span> <span>me.</span> <span>collapsed<00:00:56.719><c></span> <span>and</c><00:00:57.440><c></span> <span>reconstructed</c><00:00:58.399><c></span> <span>again.</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 50, 59.27, 0.0, 'collapsed and reconstructed again.', '崩溃又重建。', '/kəˈlæpsd ænd ˌriːkənˈstrʌktɪd əˈɡɛn/', '<span>collapsed</span> <span>and</span> <span>reconstructed</span> <span>again.</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 51, 59.28, 0.0, 'collapsed and reconstructed again. &gt;&gt; I<00:00:59.520><c> didn''t</c><00:00:59.760><c> realize</c><00:01:00.160><c> that.</c><00:01:00.879><c> I</c><00:01:01.120><c> was</c><00:01:01.680><c> too</c>', '崩溃又重建。>> 我没有意识到。我太', '/kəˈlæpsd ænd ˌriːkənˈstrʌktɪd əˈɡɛn aɪ ˈdɪdənt ˈriːəlaɪz ðæt aɪ wʌz tuː/', '<span>collapsed</span> <span>and</span> <span>reconstructed</span> <span>again.</span> <span>&gt;&gt;</span> <span>I<00:00:59.520><c></span> <span>didn''t</c><00:00:59.760><c></span> <span>realize</c><00:01:00.160><c></span> <span>that.</c><00:01:00.879><c></span> <span>I</c><00:01:01.120><c></span> <span>was</c><00:01:01.680><c></span> <span>too</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 52, 61.99, 0.0, '&gt;&gt; I didn''t realize that. I was too', '>> 我没有意识到。我太', '/aɪ ˈdɪdənt ˈriːəlaɪz ðæt aɪ wʌz tuː/', '<span>&gt;&gt;</span> <span>I</span> <span>didn''t</span> <span>realize</span> <span>that.</span> <span>I</span> <span>was</span> <span>too</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 53, 62.0, 0.0, '&gt;&gt; I didn''t realize that. I was too obsessed<00:01:02.480><c> with</c><00:01:02.719><c> my</c><00:01:02.960><c> past</c><00:01:04.159><c> until</c><00:01:04.879><c> one</c><00:01:05.199><c> day</c><00:01:05.840><c> I</c>', '>> 我没有意识到。我太沉迷于过去，直到有一天我', '/aɪ ˈdɪdənt ˈriːəlaɪz ðæt aɪ wʌz tuː əbˈsɛst wɪð maɪ pæst ənˈtɪl wʌn deɪ aɪ/', '<span>&gt;&gt;</span> <span>I</span> <span>didn''t</span> <span>realize</span> <span>that.</span> <span>I</span> <span>was</span> <span>too</span> <span>obsessed<00:01:02.480><c></span> <span>with</c><00:01:02.719><c></span> <span>my</c><00:01:02.960><c></span> <span>past</c><00:01:04.159><c></span> <span>until</c><00:01:04.879><c></span> <span>one</c><00:01:05.199><c></span> <span>day</c><00:01:05.840><c></span> <span>I</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 54, 66.07, 0.0, 'obsessed with my past until one day I', '沉迷于过去，直到有一天我', '/əbˈsɛst wɪð maɪ pæst ənˈtɪl wʌn deɪ aɪ/', '<span>obsessed</span> <span>with</span> <span>my</span> <span>past</span> <span>until</span> <span>one</span> <span>day</span> <span>I</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 55, 66.08, 0.0, 'obsessed with my past until one day I learned<00:01:06.320><c> the</c><00:01:06.560><c> story</c><00:01:07.119><c> behind</c><00:01:07.680><c> the</c><00:01:08.159><c> farm</c>', '沉迷于过去，直到有一天我了解了这个农场背后的故事', '/əbˈsɛst wɪð maɪ pæst ənˈtɪl wʌn deɪ aɪ lɜːrnd ðə ˈstɔːri bɪˈhaɪnd ðə fɑːrm/', '<span>obsessed</span> <span>with</span> <span>my</span> <span>past</span> <span>until</span> <span>one</span> <span>day</span> <span>I</span> <span>learned<00:01:06.320><c></span> <span>the</c><00:01:06.560><c></span> <span>story</c><00:01:07.119><c></span> <span>behind</c><00:01:07.680><c></span> <span>the</c><00:01:08.159><c></span> <span>farm</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 56, 68.55, 0.0, 'learned the story behind the farm', '了解了这个农场背后的故事', '/lɜːrnd ðə ˈstɔːri bɪˈhaɪnd ðə fɑːrm/', '<span>learned</span> <span>the</span> <span>story</span> <span>behind</span> <span>the</span> <span>farm</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 57, 68.56, 0.0, 'learned the story behind the farm product<00:01:09.119><c> from</c><00:01:09.439><c> Gansu</c><00:01:10.000><c> province.</c><00:01:10.720><c> A</c><00:01:10.960><c> small</c>', '了解了这个农场背后的故事，产品来自甘肃省。一个小', '/lɜːrnd ðə ˈstɔːri bɪˈhaɪnd ðə fɑːrm ˈprɑːdʌkt frʌm ˈɡænsuː ˈprɑːvɪns ə smɔːl/', '<span>learned</span> <span>the</span> <span>story</span> <span>behind</span> <span>the</span> <span>farm</span> <span>product<00:01:09.119><c></span> <span>from</c><00:01:09.439><c></span> <span>Gansu</c><00:01:10.000><c></span> <span>province.</c><00:01:10.720><c></span> <span>A</c><00:01:10.960><c></span> <span>small</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 58, 71.27, 0.0, 'product from Gansu province. A small', '产品来自甘肃省。一个小', '/ˈprɑːdʌkt frʌm ˈɡænsuː ˈprɑːvɪns ə smɔːl/', '<span>product</span> <span>from</span> <span>Gansu</span> <span>province.</span> <span>A</span> <span>small</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 59, 71.28, 0.0, 'product from Gansu province. A small county.<00:01:11.920><c> Young</c><00:01:12.320><c> people</c><00:01:12.960><c> go</c><00:01:13.200><c> to</c><00:01:13.680><c> big</c><00:01:13.920><c> cities</c>', '产品来自甘肃省。一个小县城。年轻人去大城市', '/ˈprɑːdʌkt frʌm ˈɡænsuː ˈprɑːvɪns ə smɔːl ˈkaʊnti jʌŋ ˈpiːpəl ɡoʊ tuː bɪɡ ˈsɪtiz/', '<span>product</span> <span>from</span> <span>Gansu</span> <span>province.</span> <span>A</span> <span>small</span> <span>county.<00:01:11.920><c></span> <span>Young</c><00:01:12.320><c></span> <span>people</c><00:01:12.960><c></span> <span>go</c><00:01:13.200><c></span> <span>to</c><00:01:13.680><c></span> <span>big</c><00:01:13.920><c></span> <span>cities</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 60, 74.39, 0.0, 'county. Young people go to big cities', '县。年轻人去大城市', '/ˈkaʊnti. ˈjʌŋ piːpəl ɡoʊ tuː bɪɡ ˈsɪtiz/', '<span>county.</span> <span>Young</span> <span>people</span> <span>go</span> <span>to</span> <span>big</span> <span>cities</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 61, 74.4, 0.0, 'county. Young people go to big cities for<00:01:14.720><c> better</c><00:01:15.200><c> jobs.</c><00:01:15.840><c> The</c><00:01:16.080><c> elderly</c><00:01:16.799><c> lack</c><00:01:17.200><c> of</c>', '县。年轻人去大城市寻找更好的工作。老年人缺乏', '/ˈkaʊnti. ˈjʌŋ piːpəl ɡoʊ tuː bɪɡ ˈsɪtiz fɔːr ˈbɛtər dʒɑːbz. ði ˈɛldərli læk ʌv/', '<span>county.</span> <span>Young</span> <span>people</span> <span>go</span> <span>to</span> <span>big</span> <span>cities</span> <span>for<00:01:14.720><c></span> <span>better</c><00:01:15.200><c></span> <span>jobs.</c><00:01:15.840><c></span> <span>The</c><00:01:16.080><c></span> <span>elderly</c><00:01:16.799><c></span> <span>lack</c><00:01:17.200><c></span> <span>of</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 62, 77.429, 0.0, 'for better jobs. The elderly lack of', '为了更好的工作。老年人缺乏', '/fɔːr ˈbɛtər dʒɑːbz. ði ˈɛldərli læk ʌv/', '<span>for</span> <span>better</span> <span>jobs.</span> <span>The</span> <span>elderly</span> <span>lack</span> <span>of</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 63, 77.439, 0.0, 'for better jobs. The elderly lack of care<00:01:17.920><c> and</c><00:01:18.240><c> they</c><00:01:18.560><c> still</c><00:01:18.799><c> need</c><00:01:19.040><c> to</c><00:01:19.200><c> work</c><00:01:19.439><c> in</c><00:01:19.680><c> a</c>', '为了更好的工作。老年人缺乏照顾，他们仍然需要在', '/fɔːr ˈbɛtər dʒɑːbz. ði ˈɛldərli læk ʌv kɛr ænd ðeɪ stɪl niːd tuː wɜːrk ɪn ə/', '<span>for</span> <span>better</span> <span>jobs.</span> <span>The</span> <span>elderly</span> <span>lack</span> <span>of</span> <span>care<00:01:17.920><c></span> <span>and</c><00:01:18.240><c></span> <span>they</c><00:01:18.560><c></span> <span>still</c><00:01:18.799><c></span> <span>need</c><00:01:19.040><c></span> <span>to</c><00:01:19.200><c></span> <span>work</c><00:01:19.439><c></span> <span>in</c><00:01:19.680><c></span> <span>a</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 64, 79.91, 0.0, 'care and they still need to work in a', '照顾，他们仍然需要在', '/kɛr ænd ðeɪ stɪl niːd tuː wɜːrk ɪn ə/', '<span>care</span> <span>and</span> <span>they</span> <span>still</span> <span>need</span> <span>to</span> <span>work</span> <span>in</span> <span>a</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 65, 79.92, 0.0, 'care and they still need to work in a fuse.<00:01:20.799><c> So</c><00:01:20.960><c> I</c><00:01:21.200><c> suddenly</c><00:01:21.600><c> realized</c><00:01:22.080><c> that</c><00:01:22.640><c> yeah,</c>', '照顾，他们仍然需要在忙碌中。所以我突然意识到，是的，', '/kɛr ænd ðeɪ stɪl niːd tuː wɜːrk ɪn ə fjuːz. soʊ aɪ ˈsʌdənli ˈriːəlaɪzd ðæt jɛs/', '<span>care</span> <span>and</span> <span>they</span> <span>still</span> <span>need</span> <span>to</span> <span>work</span> <span>in</span> <span>a</span> <span>fuse.<00:01:20.799><c></span> <span>So</c><00:01:20.960><c></span> <span>I</c><00:01:21.200><c></span> <span>suddenly</c><00:01:21.600><c></span> <span>realized</c><00:01:22.080><c></span> <span>that</c><00:01:22.640><c></span> <span>yeah,</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 66, 82.95, 0.0, 'fuse. So I suddenly realized that yeah,', '忙碌中。所以我突然意识到，是的，', '/fjuːz. soʊ aɪ ˈsʌdənli ˈriːəlaɪzd ðæt jɛs/', '<span>fuse.</span> <span>So</span> <span>I</span> <span>suddenly</span> <span>realized</span> <span>that</span> <span>yeah,</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 67, 82.96, 0.0, 'fuse. So I suddenly realized that yeah, that<00:01:23.200><c> was</c><00:01:23.360><c> me.</c><00:01:24.159><c> Come</c><00:01:24.400><c> on.</c><00:01:25.200><c> You</c><00:01:25.439><c> were</c><00:01:25.680><c> from</c><00:01:26.640><c> a</c>', '忙碌中。所以我突然意识到，是的，那是我。来吧。你来自一个', '/fjuːz. soʊ aɪ ˈsʌdənli ˈriːəlaɪzd ðæt jɛs, ðæt wʌz miː. kʌm ɑːn. juː wɜːr frʌm ə/', '<span>fuse.</span> <span>So</span> <span>I</span> <span>suddenly</span> <span>realized</span> <span>that</span> <span>yeah,</span> <span>that<00:01:23.200><c></span> <span>was</c><00:01:23.360><c></span> <span>me.</c><00:01:24.159><c></span> <span>Come</c><00:01:24.400><c></span> <span>on.</c><00:01:25.200><c></span> <span>You</c><00:01:25.439><c></span> <span>were</c><00:01:25.680><c></span> <span>from</c><00:01:26.640><c></span> <span>a</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 68, 86.95, 0.0, 'that was me. Come on. You were from a', '那是我。来吧。你来自一个', '/ðæt wʌz miː. kʌm ɑːn. juː wɜːr frʌm ə/', '<span>that</span> <span>was</span> <span>me.</span> <span>Come</span> <span>on.</span> <span>You</span> <span>were</span> <span>from</span> <span>a</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 69, 86.96, 0.0, 'that was me. Come on. You were from a certain<00:01:27.280><c> kind</c><00:01:27.520><c> of</c><00:01:27.920><c> village</c><00:01:28.560><c> just</c><00:01:28.880><c> like</c><00:01:29.119><c> that,</c>', '那是我。来吧。你来自一个特定的村庄，就像那样，', '/ðæt wʌz miː. kʌm ɑːn. juː wɜːr frʌm ə ˈsɜːrtən kaɪnd ʌv ˈvɪlɪdʒ dʒʌst laɪk ðæt/', '<span>that</span> <span>was</span> <span>me.</span> <span>Come</span> <span>on.</span> <span>You</span> <span>were</span> <span>from</span> <span>a</span> <span>certain<00:01:27.280><c></span> <span>kind</c><00:01:27.520><c></span> <span>of</c><00:01:27.920><c></span> <span>village</c><00:01:28.560><c></span> <span>just</c><00:01:28.880><c></span> <span>like</c><00:01:29.119><c></span> <span>that,</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 70, 89.67, 0.0, 'certain kind of village just like that,', '特定的村庄，就像那样，', '/ˈsɜːrtən kaɪnd ʌv ˈvɪlɪdʒ dʒʌst laɪk ðæt/', '<span>certain</span> <span>kind</span> <span>of</span> <span>village</span> <span>just</span> <span>like</span> <span>that,</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 71, 89.68, 0.0, 'certain kind of village just like that, a<00:01:30.000><c> small</c><00:01:30.320><c> county</c><00:01:30.799><c> just</c><00:01:31.119><c> like</c><00:01:31.280><c> that.</c><00:01:32.320><c> And</c><00:01:32.560><c> then</c>', '特定的村庄，就像那样，一个小县，就像那样。然后', '/ˈsɜːrtən kaɪnd ʌv ˈvɪlɪdʒ dʒʌst laɪk ðæt, ə smɔːl ˈkaʊnti dʒʌst laɪk ðæt. ænd ðɛn/', '<span>certain</span> <span>kind</span> <span>of</span> <span>village</span> <span>just</span> <span>like</span> <span>that,</span> <span>a<00:01:30.000><c></span> <span>small</c><00:01:30.320><c></span> <span>county</c><00:01:30.799><c></span> <span>just</c><00:01:31.119><c></span> <span>like</c><00:01:31.280><c></span> <span>that.</c><00:01:32.320><c></span> <span>And</c><00:01:32.560><c></span> <span>then</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 72, 92.71, 0.0, 'a small county just like that. And then', '一个小县，就像那样。然后', '/ə smɔːl ˈkaʊnti dʒʌst laɪk ðæt. ænd ðɛn/', '<span>a</span> <span>small</span> <span>county</span> <span>just</span> <span>like</span> <span>that.</span> <span>And</span> <span>then</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 73, 92.72, 0.0, 'a small county just like that. And then now<00:01:33.119><c> you</c><00:01:33.840><c> have</c><00:01:34.159><c> the</c><00:01:34.479><c> chance</c><00:01:34.960><c> to</c><00:01:35.280><c> do</c><00:01:35.439><c> the</c><00:01:35.680><c> right</c>', '一个小县，就像那样。然后现在你有机会做正确', '/ə smɔːl ˈkaʊnti dʒʌst laɪk ðæt. ænd ðɛn naʊ juː hæv ðə tʃæns tuː duː ðə raɪt/', '<span>a</span> <span>small</span> <span>county</span> <span>just</span> <span>like</span> <span>that.</span> <span>And</span> <span>then</span> <span>now<00:01:33.119><c></span> <span>you</c><00:01:33.840><c></span> <span>have</c><00:01:34.159><c></span> <span>the</c><00:01:34.479><c></span> <span>chance</c><00:01:34.960><c></span> <span>to</c><00:01:35.280><c></span> <span>do</c><00:01:35.439><c></span> <span>the</c><00:01:35.680><c></span> <span>right</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 74, 95.91, 0.0, 'now you have the chance to do the right', '现在你有机会做正确', '/naʊ juː hæv ðə tʃæns tuː duː ðə raɪt/', '<span>now</span> <span>you</span> <span>have</span> <span>the</span> <span>chance</span> <span>to</span> <span>do</span> <span>the</span> <span>right</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 75, 95.92, 0.0, 'now you have the chance to do the right thing.<00:01:36.400><c> Why</c><00:01:36.720><c> are</c><00:01:37.040><c> you</c><00:01:37.280><c> hesitating</c><00:01:38.240><c> for</c><00:01:38.560><c> a</c><00:01:38.720><c> long</c>', '现在你有机会做正确的事。你为什么犹豫了很长', '/naʊ juː hæv ðə tʃæns tuː duː ðə raɪt θɪŋ. waɪ ɑːr juː ˈhɛzɪteɪtɪŋ fɔːr ə lɔːŋ/', '<span>now</span> <span>you</span> <span>have</span> <span>the</span> <span>chance</span> <span>to</span> <span>do</span> <span>the</span> <span>right</span> <span>thing.<00:01:36.400><c></span> <span>Why</c><00:01:36.720><c></span> <span>are</c><00:01:37.040><c></span> <span>you</c><00:01:37.280><c></span> <span>hesitating</c><00:01:38.240><c></span> <span>for</c><00:01:38.560><c></span> <span>a</c><00:01:38.720><c></span> <span>long</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 76, 98.95, 0.0, 'thing. Why are you hesitating for a long', '事。你为什么犹豫了很长', '/θɪŋ. waɪ ɑːr juː ˈhɛzɪteɪtɪŋ fɔːr ə lɔːŋ/', '<span>thing.</span> <span>Why</span> <span>are</span> <span>you</span> <span>hesitating</span> <span>for</span> <span>a</span> <span>long</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 77, 98.96, 0.0, 'thing. Why are you hesitating for a long time?<00:01:39.520><c> So</c><00:01:39.680><c> I</c><00:01:39.840><c> suddenly</c><00:01:40.320><c> realized</c><00:01:40.640><c> that</c><00:01:41.280><c> I</c>', '事。你为什么犹豫了很长时间？所以我突然意识到我', '/θɪŋ. waɪ ɑːr juː ˈhɛzɪteɪtɪŋ fɔːr ə lɔːŋ taɪm? soʊ aɪ ˈsʌdənli ˈriːəlaɪzd ðæt aɪ/', '<span>thing.</span> <span>Why</span> <span>are</span> <span>you</span> <span>hesitating</span> <span>for</span> <span>a</span> <span>long</span> <span>time?<00:01:39.520><c></span> <span>So</c><00:01:39.680><c></span> <span>I</c><00:01:39.840><c></span> <span>suddenly</c><00:01:40.320><c></span> <span>realized</c><00:01:40.640><c></span> <span>that</c><00:01:41.280><c></span> <span>I</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 78, 101.51, 0.0, 'time? So I suddenly realized that I', '时间？所以我突然意识到我', '/taɪm? soʊ aɪ ˈsʌdənli ˈriːəlaɪzd ðæt aɪ/', '<span>time?</span> <span>So</span> <span>I</span> <span>suddenly</span> <span>realized</span> <span>that</span> <span>I</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 79, 101.52, 0.0, 'time? So I suddenly realized that I cannot<00:01:42.159><c> be</c><00:01:42.479><c> obsessed</c><00:01:43.280><c> with</c><00:01:43.759><c> my</c><00:01:44.079><c> past</c><00:01:44.720><c> as</c><00:01:45.119><c> a</c>', '时间？所以我突然意识到我不能沉迷于我的过去，作为一个', '/taɪm? soʊ aɪ ˈsʌdənli ˈriːəlaɪzd ðæt aɪ ˈkænɑːt biː əbˈsɛst wɪð maɪ pæst æz ə/', '<span>time?</span> <span>So</span> <span>I</span> <span>suddenly</span> <span>realized</span> <span>that</span> <span>I</span> <span>cannot<00:01:42.159><c></span> <span>be</c><00:01:42.479><c></span> <span>obsessed</c><00:01:43.280><c></span> <span>with</c><00:01:43.759><c></span> <span>my</c><00:01:44.079><c></span> <span>past</c><00:01:44.720><c></span> <span>as</c><00:01:45.119><c></span> <span>a</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 80, 105.429, 0.0, 'cannot be obsessed with my past as a', '不能沉迷于我的过去，作为一个', '/ˈkænɑːt biː əbˈsɛst wɪð maɪ pæst æz ə/', '<span>cannot</span> <span>be</span> <span>obsessed</span> <span>with</span> <span>my</span> <span>past</span> <span>as</span> <span>a</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 81, 105.439, 0.0, 'cannot be obsessed with my past as a teacher.<00:01:46.320><c> I</c><00:01:46.960><c> do</c><00:01:47.680><c> enjoy</c><00:01:48.240><c> it</c><00:01:48.960><c> but</c><00:01:49.920><c> when</c><00:01:50.240><c> you</c><00:01:51.040><c> have</c>', '不能沉迷于我的过去，作为一个老师。我确实喜欢它，但当你', '/ˈkænɑːt biː əbˈsɛst wɪð maɪ pæst æz ə ˈtiːtʃər. aɪ duː ɪnˈdʒɔɪ ɪt bʌt wɛn juː hæv/', '<span>cannot</span> <span>be</span> <span>obsessed</span> <span>with</span> <span>my</span> <span>past</span> <span>as</span> <span>a</span> <span>teacher.<00:01:46.320><c></span> <span>I</c><00:01:46.960><c></span> <span>do</c><00:01:47.680><c></span> <span>enjoy</c><00:01:48.240><c></span> <span>it</c><00:01:48.960><c></span> <span>but</c><00:01:49.920><c></span> <span>when</c><00:01:50.240><c></span> <span>you</c><00:01:51.040><c></span> <span>have</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 82, 111.27, 0.0, 'teacher. I do enjoy it but when you have', '老师。我确实喜欢它，但当你', '/ˈtiːtʃər. aɪ duː ɪnˈdʒɔɪ ɪt bʌt wɛn juː hæv/', '<span>teacher.</span> <span>I</span> <span>do</span> <span>enjoy</span> <span>it</span> <span>but</span> <span>when</span> <span>you</span> <span>have</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 83, 111.28, 0.0, 'teacher. I do enjoy it but when you have no<00:01:51.600><c> choice</c><00:01:52.560><c> make</c><00:01:52.720><c> your</c><00:01:53.040><c> current</c><00:01:53.520><c> choice</c>', '老师。我确实喜欢它，但当你没有选择，让你当前的选择', '/ˈtiːtʃər. aɪ duː ɪnˈdʒɔɪ ɪt bʌt wɛn juː hæv noʊ tʃɔɪs meɪk jʊr ˈkɜːrənt tʃɔɪs/', '<span>teacher.</span> <span>I</span> <span>do</span> <span>enjoy</span> <span>it</span> <span>but</span> <span>when</span> <span>you</span> <span>have</span> <span>no<00:01:51.600><c></span> <span>choice</c><00:01:52.560><c></span> <span>make</c><00:01:52.720><c></span> <span>your</c><00:01:53.040><c></span> <span>current</c><00:01:53.520><c></span> <span>choice</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 84, 114.069, 0.0, 'no choice make your current choice', '没有选择，让你当前的选择', '/noʊ tʃɔɪs meɪk jʊr ˈkɜːrənt tʃɔɪs/', '<span>no</span> <span>choice</span> <span>make</span> <span>your</span> <span>current</span> <span>choice</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 85, 114.079, 0.0, 'no choice make your current choice correct.', '没有选择，让你当前的选择正确。', '/noʊ tʃɔɪs meɪk jʊr ˈkɜːrənt tʃɔɪs kəˈrɛkt./', '<span>no</span> <span>choice</span> <span>make</span> <span>your</span> <span>current</span> <span>choice</span> <span>correct.</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 86, 115.03, 0.0, 'correct.', '正确。', '/kəˈrɛkt./', '<span>correct.</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 87, 115.04, 0.0, 'correct. &gt;&gt; So<00:01:55.200><c> when</c><00:01:55.439><c> you</c><00:01:55.680><c> were</c><00:01:55.840><c> making</c><00:01:56.079><c> that</c>', '正确。>> 所以当你做出那个', '/kəˈrɛkt. soʊ wɛn juː wɜːr ˈmeɪkɪŋ ðæt/', '<span>correct.</span> <span>&gt;&gt;</span> <span>So<00:01:55.200><c></span> <span>when</c><00:01:55.439><c></span> <span>you</c><00:01:55.680><c></span> <span>were</c><00:01:55.840><c></span> <span>making</c><00:01:56.079><c></span> <span>that</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 88, 116.31, 0.0, '&gt;&gt; So when you were making that', '>> 所以当你做出那个', '/soʊ wɛn juː wɜːr ˈmeɪkɪŋ ðæt/', '<span>&gt;&gt;</span> <span>So</span> <span>when</span> <span>you</span> <span>were</span> <span>making</span> <span>that</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 89, 116.32, 0.0, '&gt;&gt; So when you were making that transformation<00:01:57.280><c> what</c><00:01:57.520><c> was</c><00:01:57.680><c> the</c><00:01:57.920><c> most</c>', '>> 所以当你做出那个转变时，最', '/soʊ wɛn juː wɜːr ˈmeɪkɪŋ ðæt ˌtrænsfərˈmeɪʃən wʌt wʌz ðə moʊst/', '<span>&gt;&gt;</span> <span>So</span> <span>when</span> <span>you</span> <span>were</span> <span>making</span> <span>that</span> <span>transformation<00:01:57.280><c></span> <span>what</c><00:01:57.520><c></span> <span>was</c><00:01:57.680><c></span> <span>the</c><00:01:57.920><c></span> <span>most</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 90, 118.149, 0.0, 'transformation what was the most', '转变，什么是最', '/trænsfərˈmeɪʃən wʌt wʌz ðə moʊst/', '<span>transformation</span> <span>what</span> <span>was</span> <span>the</span> <span>most</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 91, 118.159, 0.0, 'transformation what was the most difficult<00:01:58.640><c> thing</c><00:01:58.960><c> for</c><00:01:59.280><c> you?</c>', '转变，对你来说最困难的是什么？', '/trænsfərˈmeɪʃən wʌt wʌz ðə moʊst ˈdɪfɪkəlt θɪŋ fɔr juː/', '<span>transformation</span> <span>what</span> <span>was</span> <span>the</span> <span>most</span> <span>difficult<00:01:58.640><c></span> <span>thing</c><00:01:58.960><c></span> <span>for</c><00:01:59.280><c></span> <span>you?</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 92, 120.389, 0.0, 'difficult thing for you?', '对你来说最困难的事？', '/ˈdɪfɪkəlt θɪŋ fɔr juː/', '<span>difficult</span> <span>thing</span> <span>for</span> <span>you?</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 93, 120.399, 0.0, 'difficult thing for you? &gt;&gt; How<00:02:00.799><c> do</c><00:02:01.040><c> I</c><00:02:01.520><c> define</c><00:02:02.159><c> myself?</c>', '对你来说最困难的事？>> 我如何定义自己？', '/ˈdɪfɪkəlt θɪŋ fɔr juː haʊ duː aɪ dɪˈfaɪn maɪˈsɛlf/', '<span>difficult</span> <span>thing</span> <span>for</span> <span>you?</span> <span>&gt;&gt;</span> <span>How<00:02:00.799><c></span> <span>do</c><00:02:01.040><c></span> <span>I</c><00:02:01.520><c></span> <span>define</c><00:02:02.159><c></span> <span>myself?</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 94, 123.67, 0.0, '&gt;&gt; How do I define myself?', '>> 我如何定义自己？', '/haʊ duː aɪ dɪˈfaɪn maɪˈsɛlf/', '<span>&gt;&gt;</span> <span>How</span> <span>do</span> <span>I</span> <span>define</span> <span>myself?</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 95, 123.68, 0.0, '&gt;&gt; How do I define myself? Yeah.<00:02:04.880><c> How</c><00:02:05.119><c> I</c><00:02:05.439><c> define</c><00:02:05.920><c> myself</c><00:02:06.719><c> is</c><00:02:07.040><c> the</c><00:02:07.360><c> major</c>', '>> 我如何定义自己？是的。我如何定义自己是主要的', '/jɛs haʊ aɪ dɪˈfaɪn maɪˈsɛlf ɪz ðə ˈmeɪdʒər/', '<span>&gt;&gt;</span> <span>How</span> <span>do</span> <span>I</span> <span>define</span> <span>myself?</span> <span>Yeah.<00:02:04.880><c></span> <span>How</c><00:02:05.119><c></span> <span>I</c><00:02:05.439><c></span> <span>define</c><00:02:05.920><c></span> <span>myself</c><00:02:06.719><c></span> <span>is</c><00:02:07.040><c></span> <span>the</c><00:02:07.360><c></span> <span>major</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 96, 127.91, 0.0, 'Yeah. How I define myself is the major', '是的。我如何定义自己是主要的', '/jɛs haʊ aɪ dɪˈfaɪn maɪˈsɛlf ɪz ðə ˈmeɪdʒər/', '<span>Yeah.</span> <span>How</span> <span>I</span> <span>define</span> <span>myself</span> <span>is</span> <span>the</span> <span>major</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 97, 127.92, 0.0, 'Yeah. How I define myself is the major key<00:02:08.479><c> for</c><00:02:09.280><c> my</c><00:02:09.599><c> work</c><00:02:10.319><c> cuz</c>', '是的。我如何定义自己是关键，因为', '/jɛs haʊ aɪ dɪˈfaɪn maɪˈsɛlf ɪz ðə ˈmeɪdʒər kiː fɔr maɪ wɜːrk kʌz/', '<span>Yeah.</span> <span>How</span> <span>I</span> <span>define</span> <span>myself</span> <span>is</span> <span>the</span> <span>major</span> <span>key<00:02:08.479><c></span> <span>for</c><00:02:09.280><c></span> <span>my</c><00:02:09.599><c></span> <span>work</c><00:02:10.319><c></span> <span>cuz</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 98, 131.99, 0.0, 'key for my work cuz', '关键，因为', '/kiː fɔr maɪ wɜːrk kʌz/', '<span>key</span> <span>for</span> <span>my</span> <span>work</span> <span>cuz</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 99, 132.0, 0.0, 'key for my work cuz who<00:02:12.239><c> do</c><00:02:12.319><c> you</c><00:02:12.480><c> think</c><00:02:12.640><c> you</c><00:02:12.879><c> are</c><00:02:13.360><c> and</c><00:02:13.920><c> what</c><00:02:14.720><c> do</c><00:02:14.879><c> you</c>', '关键，因为你以为你是谁，你', '/kiː fɔr maɪ wɜːrk kʌz huː duː juː θɪŋk juː ɑːr ænd wʌt duː juː/', '<span>key</span> <span>for</span> <span>my</span> <span>work</span> <span>cuz</span> <span>who<00:02:12.239><c></span> <span>do</c><00:02:12.319><c></span> <span>you</c><00:02:12.480><c></span> <span>think</c><00:02:12.640><c></span> <span>you</c><00:02:12.879><c></span> <span>are</c><00:02:13.360><c></span> <span>and</c><00:02:13.920><c></span> <span>what</c><00:02:14.720><c></span> <span>do</c><00:02:14.879><c></span> <span>you</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 100, 135.03, 0.0, 'who do you think you are and what do you', '你以为你是谁，你', '/huː duː juː θɪŋk juː ɑːr ænd wʌt duː juː/', '<span>who</span> <span>do</span> <span>you</span> <span>think</span> <span>you</span> <span>are</span> <span>and</span> <span>what</span> <span>do</span> <span>you</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 101, 135.04, 0.0, 'who do you think you are and what do you think<00:02:15.280><c> you</c><00:02:15.599><c> are?</c><00:02:16.400><c> I</c><00:02:16.720><c> think</c><00:02:16.879><c> this</c><00:02:17.120><c> is</c><00:02:17.680><c> the</c><00:02:18.000><c> two</c>', '你以为你是谁，你以为你是谁？我认为这是两个', '/huː duː juː θɪŋk juː ɑːr ænd wʌt duː juː θɪŋk juː ɑːr aɪ θɪŋk ðɪs ɪz ðə tuː/', '<span>who</span> <span>do</span> <span>you</span> <span>think</span> <span>you</span> <span>are</span> <span>and</span> <span>what</span> <span>do</span> <span>you</span> <span>think<00:02:15.280><c></span> <span>you</c><00:02:15.599><c></span> <span>are?</c><00:02:16.400><c></span> <span>I</c><00:02:16.720><c></span> <span>think</c><00:02:16.879><c></span> <span>this</c><00:02:17.120><c></span> <span>is</c><00:02:17.680><c></span> <span>the</c><00:02:18.000><c></span> <span>two</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 102, 138.309, 0.0, 'think you are? I think this is the two', '你以为你是谁？我认为这是两个', '/θɪŋk juː ɑːr aɪ θɪŋk ðɪs ɪz ðə tuː/', '<span>think</span> <span>you</span> <span>are?</span> <span>I</span> <span>think</span> <span>this</span> <span>is</span> <span>the</span> <span>two</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 103, 138.319, 0.0, 'think you are? I think this is the two major<00:02:18.959><c> questions</c><00:02:19.520><c> everybody</c><00:02:20.080><c> should</c>', '你以为你是谁？我认为这是两个主要问题，每个人都应该', '/θɪŋk juː ɑːr aɪ θɪŋk ðɪs ɪz ðə tuː ˈmeɪdʒər ˈkwɛstʃənz ˈɛvriˌbɑdi ʃʊd/', '<span>think</span> <span>you</span> <span>are?</span> <span>I</span> <span>think</span> <span>this</span> <span>is</span> <span>the</span> <span>two</span> <span>major<00:02:18.959><c></span> <span>questions</c><00:02:19.520><c></span> <span>everybody</c><00:02:20.080><c></span> <span>should</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 104, 140.39, 0.0, 'major questions everybody should', '主要问题，每个人都应该', '/ˈmeɪdʒər ˈkwɛstʃənz ˈɛvriˌbɑdi ʃʊd/', '<span>major</span> <span>questions</span> <span>everybody</span> <span>should</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 105, 140.4, 0.0, 'major questions everybody should consider.', '主要问题，每个人都应该考虑。', '/ˈmeɪdʒər ˈkwɛstʃənz ˈɛvriˌbɑdi ʃʊd kənˈsɪdər/', '<span>major</span> <span>questions</span> <span>everybody</span> <span>should</span> <span>consider.</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 106, 141.03, 0.0, 'consider.', '考虑。', '/kənˈsɪdər/', '<span>consider.</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 107, 141.04, 0.0, 'consider. &gt;&gt; But<00:02:21.200><c> now</c><00:02:21.520><c> how</c><00:02:21.760><c> would</c><00:02:21.920><c> you</c><00:02:22.080><c> describe</c><00:02:22.480><c> yourself?</c>', '考虑。>> 但现在你会如何描述自己？', '/kənˈsɪdər bʌt naʊ haʊ wʊd juː dɪˈskraɪb jɔːrˈsɛlf/', '<span>consider.</span> <span>&gt;&gt;</span> <span>But<00:02:21.200><c></span> <span>now</c><00:02:21.520><c></span> <span>how</c><00:02:21.760><c></span> <span>would</c><00:02:21.920><c></span> <span>you</c><00:02:22.080><c></span> <span>describe</c><00:02:22.480><c></span> <span>yourself?</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 108, 142.869, 0.0, '&gt;&gt; But now how would you describe yourself?', '>> 但现在你会如何描述自己？', '/bʌt naʊ haʊ wʊd juː dɪˈskraɪb jɔːrˈsɛlf/', '<span>&gt;&gt;</span> <span>But</span> <span>now</span> <span>how</span> <span>would</span> <span>you</span> <span>describe</span> <span>yourself?</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 109, 142.879, 0.0, '&gt;&gt; But now how would you describe yourself? If<00:02:23.120><c> you</c><00:02:23.280><c> were</c><00:02:23.440><c> to</c><00:02:23.599><c> use</c><00:02:23.840><c> just</c><00:02:24.080><c> one</c><00:02:24.400><c> word</c><00:02:24.879><c> to</c>', '>> 但现在你会如何描述自己？如果你只用一句话来', '/bʌt naʊ haʊ wʊd juː dɪˈskraɪb jɔːrˈsɛlf ɪf juː wɜːr tuː juːz dʒʌst wʌn wɜːrd tuː/', '<span>&gt;&gt;</span> <span>But</span> <span>now</span> <span>how</span> <span>would</span> <span>you</span> <span>describe</span> <span>yourself?</span> <span>If<00:02:23.120><c></span> <span>you</c><00:02:23.280><c></span> <span>were</c><00:02:23.440><c></span> <span>to</c><00:02:23.599><c></span> <span>use</c><00:02:23.840><c></span> <span>just</c><00:02:24.080><c></span> <span>one</c><00:02:24.400><c></span> <span>word</c><00:02:24.879><c></span> <span>to</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 110, 146.309, 0.0, 'If you were to use just one word to', '如果你只用一句话来', '/ɪf juː wɜːr tuː juːz dʒʌst wʌn wɜːrd tuː/', '<span>If</span> <span>you</span> <span>were</span> <span>to</span> <span>use</span> <span>just</span> <span>one</span> <span>word</span> <span>to</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 111, 146.319, 0.0, 'If you were to use just one word to identify<00:02:26.800><c> what</c><00:02:27.040><c> you''re</c><00:02:27.280><c> doing</c><00:02:27.440><c> right</c><00:02:27.680><c> now,</c>', '如果你只用一句话来定义你现在正在做的事情，', '/ɪf juː wɜːr tuː juːz dʒʌst wʌn wɜːrd tuː aɪˈdɛntɪfaɪ wʌt jʊr ˈduːɪŋ raɪt naʊ/', '<span>If</span> <span>you</span> <span>were</span> <span>to</span> <span>use</span> <span>just</span> <span>one</span> <span>word</span> <span>to</span> <span>identify<00:02:26.800><c></span> <span>what</c><00:02:27.040><c></span> <span>you''re</c><00:02:27.280><c></span> <span>doing</c><00:02:27.440><c></span> <span>right</c><00:02:27.680><c></span> <span>now,</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 112, 147.91, 0.0, 'identify what you''re doing right now,', '定义你现在正在做的事情，', '/aɪˈdɛntɪfaɪ wʌt jʊr ˈduːɪŋ raɪt naʊ/', '<span>identify</span> <span>what</span> <span>you''re</span> <span>doing</span> <span>right</span> <span>now,</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 113, 147.92, 0.0, 'identify what you''re doing right now, would<00:02:28.080><c> it</c><00:02:28.319><c> be</c><00:02:28.560><c> a</c><00:02:28.800><c> teacher,</c><00:02:29.440><c> an</c><00:02:29.680><c> influencer,</c><00:02:30.720><c> an</c>', '定义你现在正在做的事情，会是老师、影响者、', '/aɪˈdɛntɪfaɪ wʌt jʊr ˈduːɪŋ raɪt naʊ wʊd ɪt biː ə ˈtiːtʃər ən ˈɪnfluənsər ən/', '<span>identify</span> <span>what</span> <span>you''re</span> <span>doing</span> <span>right</span> <span>now,</span> <span>would<00:02:28.080><c></span> <span>it</c><00:02:28.319><c></span> <span>be</c><00:02:28.560><c></span> <span>a</c><00:02:28.800><c></span> <span>teacher,</c><00:02:29.440><c></span> <span>an</c><00:02:29.680><c></span> <span>influencer,</c><00:02:30.720><c></span> <span>an</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 114, 151.03, 0.0, 'would it be a teacher, an influencer, an', '会是老师、影响者、', '/wʊd ɪt biː ə ˈtiːtʃər ən ˈɪnfluənsər ən/', '<span>would</span> <span>it</span> <span>be</span> <span>a</span> <span>teacher,</span> <span>an</span> <span>influencer,</span> <span>an</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 115, 151.04, 0.0, 'would it be a teacher, an influencer, an e-commerce<00:02:31.920><c> salesperson,</c><00:02:32.720><c> or</c><00:02:33.120><c> something</c>', '会是老师、影响者、电商销售员，还是别的什么？', '/wʊd ɪt biː ə ˈtiːtʃər ən ˈɪnfluənsər ən iːˈkɑːmɜːrs ˈseɪlzpɜːrsən ɔːr ˈsʌmθɪŋ/', '<span>would</span> <span>it</span> <span>be</span> <span>a</span> <span>teacher,</span> <span>an</span> <span>influencer,</span> <span>an</span> <span>e-commerce<00:02:31.920><c></span> <span>salesperson,</c><00:02:32.720><c></span> <span>or</c><00:02:33.120><c></span> <span>something</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 116, 153.35, 0.0, 'e-commerce salesperson, or something', '电商销售员，还是别的什么？', '/iːˈkɑːmɜːrs ˈseɪlzpɜːrsən ɔːr ˈsʌmθɪŋ/', '<span>e-commerce</span> <span>salesperson,</span> <span>or</span> <span>something</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 117, 153.36, 0.0, 'e-commerce salesperson, or something else?<00:02:33.680><c> What</c><00:02:33.840><c> would</c><00:02:34.000><c> it</c><00:02:34.160><c> be?</c>', '电商销售员，还是别的什么？会是什么？', '/iːˈkɑːmɜːrs ˈseɪlzpɜːrsən ɔːr ˈsʌmθɪŋ ɛls wʌt wʊd ɪt biː/', '<span>e-commerce</span> <span>salesperson,</span> <span>or</span> <span>something</span> <span>else?<00:02:33.680><c></span> <span>What</c><00:02:33.840><c></span> <span>would</c><00:02:34.000><c></span> <span>it</c><00:02:34.160><c></span> <span>be?</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 118, 154.55, 0.0, 'else? What would it be?', '别的什么？会是什么？', '/ɛls wʌt wʊd ɪt biː/', '<span>else?</span> <span>What</span> <span>would</span> <span>it</span> <span>be?</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 119, 154.56, 0.0, 'else? What would it be? &gt;&gt; I<00:02:34.879><c> was</c><00:02:35.599><c> an</c><00:02:35.920><c> English</c><00:02:36.239><c> teacher,</c><00:02:36.640><c> but</c><00:02:36.959><c> now</c><00:02:37.200><c> to</c><00:02:37.440><c> be</c>', '别的什么？会是什么？>> 我曾经是一名英语老师，但现在要', '/ɛls wʌt wʊd ɪt biː aɪ wʌz ən ˈɪŋɡlɪʃ ˈtiːtʃər bʌt naʊ tuː biː/', '<span>else?</span> <span>What</span> <span>would</span> <span>it</span> <span>be?</span> <span>&gt;&gt;</span> <span>I<00:02:34.879><c></span> <span>was</c><00:02:35.599><c></span> <span>an</c><00:02:35.920><c></span> <span>English</c><00:02:36.239><c></span> <span>teacher,</c><00:02:36.640><c></span> <span>but</c><00:02:36.959><c></span> <span>now</c><00:02:37.200><c></span> <span>to</c><00:02:37.440><c></span> <span>be</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 120, 157.43, 0.0, '&gt;&gt; I was an English teacher, but now to be', '我曾是一名英语老师，但现在要', '/aɪ wʌz ən ˈɪŋɡlɪʃ ˈtitʃər bət naʊ tu bi/', '<span>&gt;&gt;</span> <span>I</span> <span>was</span> <span>an</span> <span>English</span> <span>teacher,</span> <span>but</span> <span>now</span> <span>to</span> <span>be</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 121, 157.44, 0.0, '&gt;&gt; I was an English teacher, but now to be honest<00:02:37.760><c> that</c><00:02:38.000><c> I</c><00:02:38.239><c> am</c><00:02:39.519><c> a</c><00:02:39.840><c> promoter.</c>', '我曾是一名英语老师，但现在老实说，我是一个推广者。', '/aɪ wʌz ən ˈɪŋɡlɪʃ ˈtitʃər bət naʊ tu bi ˈɑnɪst ðæt aɪ æm ə prəˈmoʊtər/', '<span>&gt;&gt;</span> <span>I</span> <span>was</span> <span>an</span> <span>English</span> <span>teacher,</span> <span>but</span> <span>now</span> <span>to</span> <span>be</span> <span>honest<00:02:37.760><c></span> <span>that</c><00:02:38.000><c></span> <span>I</c><00:02:38.239><c></span> <span>am</c><00:02:39.519><c></span> <span>a</c><00:02:39.840><c></span> <span>promoter.</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 122, 160.949, 0.0, 'honest that I am a promoter.', '老实说，我是一个推广者。', '/ˈɑnɪst ðæt aɪ æm ə prəˈmoʊtər/', '<span>honest</span> <span>that</span> <span>I</span> <span>am</span> <span>a</span> <span>promoter.</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 123, 160.959, 0.0, 'honest that I am a promoter. &gt;&gt; A<00:02:41.200><c> promoter.</c>', '老实说，我是一个推广者。 >> 一个推广者。', '/ˈɑnɪst ðæt aɪ æm ə prəˈmoʊtər ə prəˈmoʊtər/', '<span>honest</span> <span>that</span> <span>I</span> <span>am</span> <span>a</span> <span>promoter.</span> <span>&gt;&gt;</span> <span>A<00:02:41.200><c></span> <span>promoter.</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 124, 161.91, 0.0, '&gt;&gt; A promoter.', '>> 一个推广者。', '/ə prəˈmoʊtər/', '<span>&gt;&gt;</span> <span>A</span> <span>promoter.</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 125, 161.92, 0.0, '&gt;&gt; A promoter. &gt;&gt; But<00:02:42.080><c> I</c><00:02:42.319><c> try</c><00:02:42.640><c> to</c><00:02:42.879><c> be</c><00:02:43.599><c> an</c><00:02:43.840><c> influencer</c><00:02:44.400><c> in</c><00:02:44.560><c> the</c>', '>> 一个推广者。 >> 但我试图成为一个影响者，在', '/ə prəˈmoʊtər bət aɪ traɪ tu bi ən ˈɪnfluənsər ɪn ðə/', '<span>&gt;&gt;</span> <span>A</span> <span>promoter.</span> <span>&gt;&gt;</span> <span>But<00:02:42.080><c></span> <span>I</c><00:02:42.319><c></span> <span>try</c><00:02:42.640><c></span> <span>to</c><00:02:42.879><c></span> <span>be</c><00:02:43.599><c></span> <span>an</c><00:02:43.840><c></span> <span>influencer</c><00:02:44.400><c></span> <span>in</c><00:02:44.560><c></span> <span>the</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 126, 164.71, 0.0, '&gt;&gt; But I try to be an influencer in the', '>> 但我试图成为一个影响者，在', '/bət aɪ traɪ tu bi ən ˈɪnfluənsər ɪn ðə/', '<span>&gt;&gt;</span> <span>But</span> <span>I</span> <span>try</span> <span>to</span> <span>be</span> <span>an</span> <span>influencer</span> <span>in</span> <span>the</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 127, 164.72, 0.0, '&gt;&gt; But I try to be an influencer in the future.', '>> 但我试图在未来成为一个影响者。', '/bət aɪ traɪ tu bi ən ˈɪnfluənsər ɪn ðə ˈfjutʃər/', '<span>&gt;&gt;</span> <span>But</span> <span>I</span> <span>try</span> <span>to</span> <span>be</span> <span>an</span> <span>influencer</span> <span>in</span> <span>the</span> <span>future.</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 128, 165.99, 0.0, 'future.', '未来。', '/ˈfjutʃər/', '<span>future.</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 129, 166.0, 0.0, 'future. &gt;&gt; That''s<00:02:46.239><c> totally</c><00:02:46.720><c> different.</c><00:02:47.680><c> I</c><00:02:48.000><c> don''t</c><00:02:48.080><c> think</c>', '未来。 >> 那完全不同。我不认为', '/ˈfjutʃər ðæts ˈtɑtəli ˈdɪfərənt aɪ doʊnt θɪŋk/', '<span>future.</span> <span>&gt;&gt;</span> <span>That''s<00:02:46.239><c></span> <span>totally</c><00:02:46.720><c></span> <span>different.</c><00:02:47.680><c></span> <span>I</c><00:02:48.000><c></span> <span>don''t</c><00:02:48.080><c></span> <span>think</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 130, 168.229, 0.0, '&gt;&gt; That''s totally different. I don''t think', '>> 那完全不同。我不认为', '/ðæts ˈtɑtəli ˈdɪfərənt aɪ doʊnt θɪŋk/', '<span>&gt;&gt;</span> <span>That''s</span> <span>totally</span> <span>different.</span> <span>I</span> <span>don''t</span> <span>think</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 131, 168.239, 0.0, '&gt;&gt; That''s totally different. I don''t think I''m<00:02:48.560><c> an</c><00:02:48.800><c> influencer</c><00:02:50.160><c> currently.</c>', '>> 那完全不同。我不认为我现在是一个影响者。', '/ðæts ˈtɑtəli ˈdɪfərənt aɪ doʊnt θɪŋk aɪm ən ˈɪnfluənsər ˈkɜrəntli/', '<span>&gt;&gt;</span> <span>That''s</span> <span>totally</span> <span>different.</span> <span>I</span> <span>don''t</span> <span>think</span> <span>I''m<00:02:48.560><c></span> <span>an</c><00:02:48.800><c></span> <span>influencer</c><00:02:50.160><c></span> <span>currently.</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 132, 171.11, 0.0, 'I''m an influencer currently.', '我现在是一个影响者。', '/aɪm ən ˈɪnfluənsər ˈkɜrəntli/', '<span>I''m</span> <span>an</span> <span>influencer</span> <span>currently.</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 133, 171.12, 0.0, 'I''m an influencer currently. &gt;&gt; Not<00:02:51.360><c> yet.</c>', '我现在是一个影响者。 >> 还没有。', '/aɪm ən ˈɪnfluənsər ˈkɜrəntli nɑt jɛt/', '<span>I''m</span> <span>an</span> <span>influencer</span> <span>currently.</span> <span>&gt;&gt;</span> <span>Not<00:02:51.360><c></span> <span>yet.</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 134, 171.99, 0.0, '&gt;&gt; Not yet.', '>> 还没有。', '/nɑt jɛt/', '<span>&gt;&gt;</span> <span>Not</span> <span>yet.</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 135, 172.0, 0.0, '&gt;&gt; Not yet. &gt;&gt; Not<00:02:52.239><c> yet.</c><00:02:52.800><c> If</c><00:02:53.040><c> you</c><00:02:53.200><c> want</c><00:02:53.360><c> to</c><00:02:53.599><c> be</c><00:02:53.840><c> an</c>', '>> 还没有。 >> 还没有。如果你想成为一个', '/nɑt jɛt nɑt jɛt ɪf ju wɑnt tu bi ən/', '<span>&gt;&gt;</span> <span>Not</span> <span>yet.</span> <span>&gt;&gt;</span> <span>Not<00:02:52.239><c></span> <span>yet.</c><00:02:52.800><c></span> <span>If</c><00:02:53.040><c></span> <span>you</c><00:02:53.200><c></span> <span>want</c><00:02:53.360><c></span> <span>to</c><00:02:53.599><c></span> <span>be</c><00:02:53.840><c></span> <span>an</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 136, 174.07, 0.0, '&gt;&gt; Not yet. If you want to be an', '>> 还没有。如果你想成为一个', '/nɑt jɛt ɪf ju wɑnt tu bi ən/', '<span>&gt;&gt;</span> <span>Not</span> <span>yet.</span> <span>If</span> <span>you</span> <span>want</span> <span>to</span> <span>be</span> <span>an</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 137, 174.08, 0.0, '&gt;&gt; Not yet. If you want to be an influencer,<00:02:55.200><c> you</c><00:02:55.680><c> need</c><00:02:55.920><c> to</c><00:02:56.319><c> pay</c><00:02:56.640><c> too</c><00:02:56.959><c> much</c>', '>> 还没有。如果你想成为一个影响者，你需要付出太多', '/nɑt jɛt ɪf ju wɑnt tu bi ən ˈɪnfluənsər ju nid tu peɪ tu mʌtʃ/', '<span>&gt;&gt;</span> <span>Not</span> <span>yet.</span> <span>If</span> <span>you</span> <span>want</span> <span>to</span> <span>be</span> <span>an</span> <span>influencer,<00:02:55.200><c></span> <span>you</c><00:02:55.680><c></span> <span>need</c><00:02:55.920><c></span> <span>to</c><00:02:56.319><c></span> <span>pay</c><00:02:56.640><c></span> <span>too</c><00:02:56.959><c></span> <span>much</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 138, 177.19, 0.0, 'influencer, you need to pay too much', '影响者，你需要付出太多', '/ˈɪnfluənsər ju nid tu peɪ tu mʌtʃ/', '<span>influencer,</span> <span>you</span> <span>need</span> <span>to</span> <span>pay</span> <span>too</span> <span>much</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 139, 177.2, 0.0, 'influencer, you need to pay too much attention<00:02:58.640><c> to</c><00:02:59.280><c> what</c><00:02:59.599><c> you</c><00:02:59.840><c> are</c><00:03:00.080><c> trying</c><00:03:00.480><c> to</c>', '影响者，你需要付出太多关注于你试图', '/ˈɪnfluənsər ju nid tu peɪ tu mʌtʃ əˈtɛnʃən tu wʌt ju ɑr ˈtraɪɪŋ tu/', '<span>influencer,</span> <span>you</span> <span>need</span> <span>to</span> <span>pay</span> <span>too</span> <span>much</span> <span>attention<00:02:58.640><c></span> <span>to</c><00:02:59.280><c></span> <span>what</c><00:02:59.599><c></span> <span>you</c><00:02:59.840><c></span> <span>are</c><00:03:00.080><c></span> <span>trying</c><00:03:00.480><c></span> <span>to</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 140, 180.949, 0.0, 'attention to what you are trying to', '关注于你试图', '/əˈtɛnʃən tu wʌt ju ɑr ˈtraɪɪŋ tu/', '<span>attention</span> <span>to</span> <span>what</span> <span>you</span> <span>are</span> <span>trying</span> <span>to</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 141, 180.959, 0.0, 'attention to what you are trying to spread.<00:03:01.680><c> What</c><00:03:01.920><c> kind</c><00:03:02.080><c> of</c><00:03:02.239><c> values?</c><00:03:02.959><c> What</c><00:03:03.120><c> kind</c>', '关注于你试图传播的东西。什么样的价值观？什么样的', '/əˈtɛnʃən tu wʌt ju ɑr ˈtraɪɪŋ tu sprɛd wʌt kaɪnd əv ˈvæljuz wʌt kaɪnd/', '<span>attention</span> <span>to</span> <span>what</span> <span>you</span> <span>are</span> <span>trying</span> <span>to</span> <span>spread.<00:03:01.680><c></span> <span>What</c><00:03:01.920><c></span> <span>kind</c><00:03:02.080><c></span> <span>of</c><00:03:02.239><c></span> <span>values?</c><00:03:02.959><c></span> <span>What</c><00:03:03.120><c></span> <span>kind</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 142, 183.27, 0.0, 'spread. What kind of values? What kind', '传播。什么样的价值观？什么样的', '/sprɛd wʌt kaɪnd əv ˈvæljuz wʌt kaɪnd/', '<span>spread.</span> <span>What</span> <span>kind</span> <span>of</span> <span>values?</span> <span>What</span> <span>kind</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 143, 183.28, 0.0, 'spread. What kind of values? What kind of<00:03:03.519><c> knowledge,</c><00:03:04.159><c> what</c><00:03:04.400><c> kind</c><00:03:04.560><c> of</c><00:03:04.720><c> lifestyle?</c>', '传播。什么样的价值观？什么样的知识，什么样的生活方式？', '/sprɛd wʌt kaɪnd əv ˈvæljuz wʌt kaɪnd əv ˈnɑlɪdʒ wʌt kaɪnd əv ˈlaɪfstaɪl/', '<span>spread.</span> <span>What</span> <span>kind</span> <span>of</span> <span>values?</span> <span>What</span> <span>kind</span> <span>of<00:03:03.519><c></span> <span>knowledge,</c><00:03:04.159><c></span> <span>what</c><00:03:04.400><c></span> <span>kind</c><00:03:04.560><c></span> <span>of</c><00:03:04.720><c></span> <span>lifestyle?</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 144, 185.83, 0.0, 'of knowledge, what kind of lifestyle?', '知识，什么样的生活方式？', '/əv ˈnɑlɪdʒ wʌt kaɪnd əv ˈlaɪfstaɪl/', '<span>of</span> <span>knowledge,</span> <span>what</span> <span>kind</span> <span>of</span> <span>lifestyle?</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 145, 185.84, 0.0, 'of knowledge, what kind of lifestyle? Because<00:03:06.560><c> if</c><00:03:06.879><c> people</c><00:03:07.200><c> adore</c><00:03:07.680><c> you,</c><00:03:08.080><c> people</c><00:03:08.400><c> will</c>', '知识，什么样的生活方式？因为如果人们崇拜你，人们会', '/əv ˈnɑlɪdʒ wʌt kaɪnd əv ˈlaɪfstaɪl bɪˈkɔz ɪf ˈpipəl əˈdɔr ju ˈpipəl wɪl/', '<span>of</span> <span>knowledge,</span> <span>what</span> <span>kind</span> <span>of</span> <span>lifestyle?</span> <span>Because<00:03:06.560><c></span> <span>if</c><00:03:06.879><c></span> <span>people</c><00:03:07.200><c></span> <span>adore</c><00:03:07.680><c></span> <span>you,</c><00:03:08.080><c></span> <span>people</c><00:03:08.400><c></span> <span>will</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 146, 188.949, 0.0, 'Because if people adore you, people will', '因为如果人们崇拜你，人们会', '/bɪˈkɔz ɪf ˈpipəl əˈdɔr ju ˈpipəl wɪl/', '<span>Because</span> <span>if</span> <span>people</span> <span>adore</span> <span>you,</span> <span>people</span> <span>will</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 147, 188.959, 0.0, 'Because if people adore you, people will learn<00:03:09.200><c> to</c><00:03:09.519><c> be</c><00:03:09.760><c> you.</c>', '因为如果人们崇拜你，人们会学着成为你。', '/bɪˈkɔz ɪf ˈpipəl əˈdɔr ju ˈpipəl wɪl lɜrn tu bi ju/', '<span>Because</span> <span>if</span> <span>people</span> <span>adore</span> <span>you,</span> <span>people</span> <span>will</span> <span>learn<00:03:09.200><c></span> <span>to</c><00:03:09.519><c></span> <span>be</c><00:03:09.760><c></span> <span>you.</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 148, 190.47, 0.0, 'learn to be you.', '学着成为你。', '/lɜrn tu bi ju/', '<span>learn</span> <span>to</span> <span>be</span> <span>you.</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 149, 190.48, 0.0, 'learn to be you. &gt;&gt; But<00:03:10.800><c> an</c><00:03:11.120><c> influencer</c><00:03:11.920><c> is</c><00:03:12.640><c> what</c><00:03:12.959><c> exactly</c><00:03:13.440><c> a</c><00:03:13.680><c> lot</c>', '学着成为你。 >> 但一个影响者正是很多', '/lɜrn tu bi ju bət ən ˈɪnfluənsər ɪz wʌt ɪɡˈzæktli ə lɑt/', '<span>learn</span> <span>to</span> <span>be</span> <span>you.</span> <span>&gt;&gt;</span> <span>But<00:03:10.800><c></span> <span>an</c><00:03:11.120><c></span> <span>influencer</c><00:03:11.920><c></span> <span>is</c><00:03:12.640><c></span> <span>what</c><00:03:12.959><c></span> <span>exactly</c><00:03:13.440><c></span> <span>a</c><00:03:13.680><c></span> <span>lot</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 150, 193.75, 0.0, '&gt;&gt; But an influencer is what exactly a lot', '', '', '<span>&gt;&gt;</span> <span>But</span> <span>an</span> <span>influencer</span> <span>is</span> <span>what</span> <span>exactly</span> <span>a</span> <span>lot</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 151, 193.76, 0.0, '&gt;&gt; But an influencer is what exactly a lot of<00:03:13.920><c> followers</c><00:03:15.040><c> consider</c><00:03:15.519><c> you</c><00:03:15.680><c> to</c><00:03:15.920><c> be</c><00:03:16.319><c> because</c>', '', '', '<span>&gt;&gt;</span> <span>But</span> <span>an</span> <span>influencer</span> <span>is</span> <span>what</span> <span>exactly</span> <span>a</span> <span>lot</span> <span>of<00:03:13.920><c></span> <span>followers</c><00:03:15.040><c></span> <span>consider</c><00:03:15.519><c></span> <span>you</c><00:03:15.680><c></span> <span>to</c><00:03:15.920><c></span> <span>be</c><00:03:16.319><c></span> <span>because</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 152, 196.63, 0.0, 'of followers consider you to be because', '', '', '<span>of</span> <span>followers</span> <span>consider</span> <span>you</span> <span>to</span> <span>be</span> <span>because</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 153, 196.64, 0.0, 'of followers consider you to be because they<00:03:16.959><c> think</c><00:03:17.120><c> that</c><00:03:17.360><c> you</c><00:03:17.680><c> create</c><00:03:17.920><c> a</c><00:03:18.159><c> different</c>', '', '', '<span>of</span> <span>followers</span> <span>consider</span> <span>you</span> <span>to</span> <span>be</span> <span>because</span> <span>they<00:03:16.959><c></span> <span>think</c><00:03:17.120><c></span> <span>that</c><00:03:17.360><c></span> <span>you</c><00:03:17.680><c></span> <span>create</c><00:03:17.920><c></span> <span>a</c><00:03:18.159><c></span> <span>different</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 154, 198.39, 0.0, 'they think that you create a different', '', '', '<span>they</span> <span>think</span> <span>that</span> <span>you</span> <span>create</span> <span>a</span> <span>different</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 155, 198.4, 0.0, 'they think that you create a different vibe<00:03:18.720><c> in</c><00:03:18.879><c> your</c><00:03:19.040><c> live</c><00:03:19.280><c> streaming</c><00:03:19.760><c> sessions</c><00:03:20.239><c> and</c>', '', '', '<span>they</span> <span>think</span> <span>that</span> <span>you</span> <span>create</span> <span>a</span> <span>different</span> <span>vibe<00:03:18.720><c></span> <span>in</c><00:03:18.879><c></span> <span>your</c><00:03:19.040><c></span> <span>live</c><00:03:19.280><c></span> <span>streaming</c><00:03:19.760><c></span> <span>sessions</c><00:03:20.239><c></span> <span>and</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 156, 200.55, 0.0, 'vibe in your live streaming sessions and', '', '', '<span>vibe</span> <span>in</span> <span>your</span> <span>live</span> <span>streaming</span> <span>sessions</span> <span>and</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 157, 200.56, 0.0, 'vibe in your live streaming sessions and you<00:03:21.200><c> get</c><00:03:21.440><c> a</c><00:03:21.680><c> lot</c><00:03:21.760><c> of</c><00:03:21.920><c> messages</c><00:03:22.400><c> across.</c><00:03:22.959><c> Not</c>', '', '', '<span>vibe</span> <span>in</span> <span>your</span> <span>live</span> <span>streaming</span> <span>sessions</span> <span>and</span> <span>you<00:03:21.200><c></span> <span>get</c><00:03:21.440><c></span> <span>a</c><00:03:21.680><c></span> <span>lot</c><00:03:21.760><c></span> <span>of</c><00:03:21.920><c></span> <span>messages</c><00:03:22.400><c></span> <span>across.</c><00:03:22.959><c></span> <span>Not</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 158, 203.11, 0.0, 'you get a lot of messages across. Not', '', '', '<span>you</span> <span>get</span> <span>a</span> <span>lot</span> <span>of</span> <span>messages</span> <span>across.</span> <span>Not</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 159, 203.12, 0.0, 'you get a lot of messages across. Not just<00:03:23.280><c> the</c><00:03:23.519><c> products</c><00:03:23.840><c> themselves,</c><00:03:24.400><c> but</c><00:03:24.720><c> also,</c>', '', '', '<span>you</span> <span>get</span> <span>a</span> <span>lot</span> <span>of</span> <span>messages</span> <span>across.</span> <span>Not</span> <span>just<00:03:23.280><c></span> <span>the</c><00:03:23.519><c></span> <span>products</c><00:03:23.840><c></span> <span>themselves,</c><00:03:24.400><c></span> <span>but</c><00:03:24.720><c></span> <span>also,</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 160, 205.35, 0.0, 'just the products themselves, but also,', '', '', '<span>just</span> <span>the</span> <span>products</span> <span>themselves,</span> <span>but</span> <span>also,</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 161, 205.36, 0.0, 'just the products themselves, but also, you<00:03:25.519><c> know,</c><00:03:25.599><c> there''s</c><00:03:25.920><c> a</c><00:03:26.080><c> sense</c><00:03:26.319><c> of</c><00:03:26.879><c> um</c>', '', '', '<span>just</span> <span>the</span> <span>products</span> <span>themselves,</span> <span>but</span> <span>also,</span> <span>you<00:03:25.519><c></span> <span>know,</c><00:03:25.599><c></span> <span>there''s</c><00:03:25.920><c></span> <span>a</c><00:03:26.080><c></span> <span>sense</c><00:03:26.319><c></span> <span>of</c><00:03:26.879><c></span> <span>um</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 162, 207.35, 0.0, 'you know, there''s a sense of um', '', '', '<span>you</span> <span>know,</span> <span>there''s</span> <span>a</span> <span>sense</span> <span>of</span> <span>um</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 163, 207.36, 0.0, 'you know, there''s a sense of um complexity,<00:03:28.319><c> sophistication.</c><00:03:29.599><c> What</c><00:03:29.840><c> more</c>', '', '', '<span>you</span> <span>know,</span> <span>there''s</span> <span>a</span> <span>sense</span> <span>of</span> <span>um</span> <span>complexity,<00:03:28.319><c></span> <span>sophistication.</c><00:03:29.599><c></span> <span>What</c><00:03:29.840><c></span> <span>more</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 164, 210.07, 0.0, 'complexity, sophistication. What more', '', '', '<span>complexity,</span> <span>sophistication.</span> <span>What</span> <span>more</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 165, 210.08, 0.0, 'complexity, sophistication. What more does<00:03:30.319><c> it</c><00:03:30.480><c> take</c><00:03:30.720><c> to</c><00:03:31.200><c> become</c><00:03:31.440><c> an</c><00:03:31.680><c> influencer?</c>', '', '', '<span>complexity,</span> <span>sophistication.</span> <span>What</span> <span>more</span> <span>does<00:03:30.319><c></span> <span>it</c><00:03:30.480><c></span> <span>take</c><00:03:30.720><c></span> <span>to</c><00:03:31.200><c></span> <span>become</c><00:03:31.440><c></span> <span>an</c><00:03:31.680><c></span> <span>influencer?</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 166, 212.949, 0.0, 'does it take to become an influencer?', '', '', '<span>does</span> <span>it</span> <span>take</span> <span>to</span> <span>become</span> <span>an</span> <span>influencer?</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 167, 212.959, 0.0, 'does it take to become an influencer? &gt;&gt; I<00:03:33.040><c> I</c><00:03:33.440><c> define</c><00:03:33.840><c> myself</c><00:03:34.400><c> as</c>', '', '', '<span>does</span> <span>it</span> <span>take</span> <span>to</span> <span>become</span> <span>an</span> <span>influencer?</span> <span>&gt;&gt;</span> <span>I<00:03:33.040><c></span> <span>I</c><00:03:33.440><c></span> <span>define</c><00:03:33.840><c></span> <span>myself</c><00:03:34.400><c></span> <span>as</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 168, 216.149, 0.0, '&gt;&gt; I I define myself as', '', '', '<span>&gt;&gt;</span> <span>I</span> <span>I</span> <span>define</span> <span>myself</span> <span>as</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 169, 216.159, 0.0, '&gt;&gt; I I define myself as a<00:03:36.400><c> man</c><00:03:36.640><c> from</c><00:03:36.959><c> the</c><00:03:37.200><c> village</c>', '', '', '<span>&gt;&gt;</span> <span>I</span> <span>I</span> <span>define</span> <span>myself</span> <span>as</span> <span>a<00:03:36.400><c></span> <span>man</c><00:03:36.640><c></span> <span>from</c><00:03:36.959><c></span> <span>the</c><00:03:37.200><c></span> <span>village</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 170, 218.39, 0.0, 'a man from the village', '', '', '<span>a</span> <span>man</span> <span>from</span> <span>the</span> <span>village</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 171, 218.4, 0.0, 'a man from the village &gt;&gt; and<00:03:38.640><c> I</c><00:03:38.879><c> try</c><00:03:39.200><c> to</c><00:03:39.440><c> help</c><00:03:39.760><c> the</c><00:03:40.319><c> farmers,</c><00:03:40.959><c> the</c><00:03:41.200><c> low</c>', '', '', '<span>a</span> <span>man</span> <span>from</span> <span>the</span> <span>village</span> <span>&gt;&gt;</span> <span>and<00:03:38.640><c></span> <span>I</c><00:03:38.879><c></span> <span>try</c><00:03:39.200><c></span> <span>to</c><00:03:39.440><c></span> <span>help</c><00:03:39.760><c></span> <span>the</c><00:03:40.319><c></span> <span>farmers,</c><00:03:40.959><c></span> <span>the</c><00:03:41.200><c></span> <span>low</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 172, 221.43, 0.0, '&gt;&gt; and I try to help the farmers, the low', '', '', '<span>&gt;&gt;</span> <span>and</span> <span>I</span> <span>try</span> <span>to</span> <span>help</span> <span>the</span> <span>farmers,</span> <span>the</span> <span>low</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 173, 221.44, 0.0, '&gt;&gt; and I try to help the farmers, the low income<00:03:42.159><c> class,</c><00:03:43.440><c> which</c><00:03:43.760><c> is</c><00:03:44.319><c> highly</c><00:03:44.720><c> related</c><00:03:45.120><c> to</c>', '', '', '<span>&gt;&gt;</span> <span>and</span> <span>I</span> <span>try</span> <span>to</span> <span>help</span> <span>the</span> <span>farmers,</span> <span>the</span> <span>low</span> <span>income<00:03:42.159><c></span> <span>class,</c><00:03:43.440><c></span> <span>which</c><00:03:43.760><c></span> <span>is</c><00:03:44.319><c></span> <span>highly</c><00:03:44.720><c></span> <span>related</c><00:03:45.120><c></span> <span>to</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 174, 225.35, 0.0, 'income class, which is highly related to', '', '', '<span>income</span> <span>class,</span> <span>which</span> <span>is</span> <span>highly</span> <span>related</span> <span>to</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 175, 225.36, 0.0, 'income class, which is highly related to the<00:03:45.680><c> land,</c><00:03:46.480><c> but</c><00:03:47.360><c> we''ve</c><00:03:47.760><c> just</c><00:03:48.080><c> started.</c><00:03:48.959><c> This</c>', '', '', '<span>income</span> <span>class,</span> <span>which</span> <span>is</span> <span>highly</span> <span>related</span> <span>to</span> <span>the<00:03:45.680><c></span> <span>land,</c><00:03:46.480><c></span> <span>but</c><00:03:47.360><c></span> <span>we''ve</c><00:03:47.760><c></span> <span>just</c><00:03:48.080><c></span> <span>started.</c><00:03:48.959><c></span> <span>This</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 176, 229.19, 0.0, 'the land, but we''ve just started. This', '', '', '<span>the</span> <span>land,</span> <span>but</span> <span>we''ve</span> <span>just</span> <span>started.</span> <span>This</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 177, 229.2, 0.0, 'the land, but we''ve just started. This is<00:03:49.599><c> the</c><00:03:49.920><c> only</c><00:03:50.239><c> beginning.</c>', '', '', '<span>the</span> <span>land,</span> <span>but</span> <span>we''ve</span> <span>just</span> <span>started.</span> <span>This</span> <span>is<00:03:49.599><c></span> <span>the</c><00:03:49.920><c></span> <span>only</c><00:03:50.239><c></span> <span>beginning.</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 178, 231.19, 0.0, 'is the only beginning.', '', '', '<span>is</span> <span>the</span> <span>only</span> <span>beginning.</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 179, 231.2, 0.0, 'is the only beginning. &gt;&gt; Is<00:03:51.360><c> this</c><00:03:51.599><c> your</c><00:03:51.920><c> way</c><00:03:52.080><c> of</c><00:03:53.200><c> staying</c><00:03:53.599><c> connected</c><00:03:54.000><c> to</c>', '', '', '<span>is</span> <span>the</span> <span>only</span> <span>beginning.</span> <span>&gt;&gt;</span> <span>Is<00:03:51.360><c></span> <span>this</c><00:03:51.599><c></span> <span>your</c><00:03:51.920><c></span> <span>way</c><00:03:52.080><c></span> <span>of</c><00:03:53.200><c></span> <span>staying</c><00:03:53.599><c></span> <span>connected</c><00:03:54.000><c></span> <span>to</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 180, 234.229, 0.0, '&gt;&gt; Is this your way of staying connected to', '', '', '<span>&gt;&gt;</span> <span>Is</span> <span>this</span> <span>your</span> <span>way</span> <span>of</span> <span>staying</span> <span>connected</span> <span>to</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 181, 234.239, 0.0, '&gt;&gt; Is this your way of staying connected to your<00:03:54.480><c> roots?</c>', '', '', '<span>&gt;&gt;</span> <span>Is</span> <span>this</span> <span>your</span> <span>way</span> <span>of</span> <span>staying</span> <span>connected</span> <span>to</span> <span>your<00:03:54.480><c></span> <span>roots?</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 182, 235.27, 0.0, 'your roots?', '', '', '<span>your</span> <span>roots?</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 183, 235.28, 0.0, 'your roots? &gt;&gt; Definitely.<00:03:55.680><c> Are</c><00:03:55.920><c> you</c><00:03:56.080><c> trying</c><00:03:56.239><c> to</c><00:03:56.480><c> give</c><00:03:56.720><c> back</c>', '', '', '<span>your</span> <span>roots?</span> <span>&gt;&gt;</span> <span>Definitely.<00:03:55.680><c></span> <span>Are</c><00:03:55.920><c></span> <span>you</c><00:03:56.080><c></span> <span>trying</c><00:03:56.239><c></span> <span>to</c><00:03:56.480><c></span> <span>give</c><00:03:56.720><c></span> <span>back</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 184, 237.27, 0.0, '&gt;&gt; Definitely. Are you trying to give back', '', '', '<span>&gt;&gt;</span> <span>Definitely.</span> <span>Are</span> <span>you</span> <span>trying</span> <span>to</span> <span>give</span> <span>back</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 185, 237.28, 0.0, '&gt;&gt; Definitely. Are you trying to give back something<00:03:57.599><c> to</c><00:03:57.840><c> the</c><00:03:58.000><c> land</c><00:03:58.239><c> where</c><00:03:58.480><c> you</c><00:03:58.640><c> grew</c><00:03:58.879><c> up?</c>', '', '', '<span>&gt;&gt;</span> <span>Definitely.</span> <span>Are</span> <span>you</span> <span>trying</span> <span>to</span> <span>give</span> <span>back</span> <span>something<00:03:57.599><c></span> <span>to</c><00:03:57.840><c></span> <span>the</c><00:03:58.000><c></span> <span>land</c><00:03:58.239><c></span> <span>where</c><00:03:58.480><c></span> <span>you</c><00:03:58.640><c></span> <span>grew</c><00:03:58.879><c></span> <span>up?</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 186, 239.67, 0.0, 'something to the land where you grew up?', '', '', '<span>something</span> <span>to</span> <span>the</span> <span>land</span> <span>where</span> <span>you</span> <span>grew</span> <span>up?</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 187, 239.68, 0.0, 'something to the land where you grew up? &gt;&gt; You<00:03:59.840><c> know,</c><00:04:00.159><c> I</c><00:04:00.480><c> grew</c><00:04:00.720><c> up</c><00:04:00.959><c> in</c><00:04:01.200><c> a</c><00:04:01.439><c> rural</c><00:04:01.840><c> village.</c>', '', '', '<span>something</span> <span>to</span> <span>the</span> <span>land</span> <span>where</span> <span>you</span> <span>grew</span> <span>up?</span> <span>&gt;&gt;</span> <span>You<00:03:59.840><c></span> <span>know,</c><00:04:00.159><c></span> <span>I</c><00:04:00.480><c></span> <span>grew</c><00:04:00.720><c></span> <span>up</c><00:04:00.959><c></span> <span>in</c><00:04:01.200><c></span> <span>a</c><00:04:01.439><c></span> <span>rural</c><00:04:01.840><c></span> <span>village.</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 188, 242.949, 0.0, '&gt;&gt; You know, I grew up in a rural village.', '', '', '<span>&gt;&gt;</span> <span>You</span> <span>know,</span> <span>I</span> <span>grew</span> <span>up</span> <span>in</span> <span>a</span> <span>rural</span> <span>village.</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 189, 242.959, 0.0, '&gt;&gt; You know, I grew up in a rural village. So,<00:04:03.200><c> I</c><00:04:03.519><c> know</c><00:04:03.680><c> the</c><00:04:04.000><c> life.</c><00:04:04.720><c> I</c><00:04:04.959><c> know</c><00:04:05.120><c> they</c><00:04:05.360><c> work</c>', '', '', '<span>&gt;&gt;</span> <span>You</span> <span>know,</span> <span>I</span> <span>grew</span> <span>up</span> <span>in</span> <span>a</span> <span>rural</span> <span>village.</span> <span>So,<00:04:03.200><c></span> <span>I</c><00:04:03.519><c></span> <span>know</c><00:04:03.680><c></span> <span>the</c><00:04:04.000><c></span> <span>life.</c><00:04:04.720><c></span> <span>I</c><00:04:04.959><c></span> <span>know</c><00:04:05.120><c></span> <span>they</c><00:04:05.360><c></span> <span>work</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 190, 245.75, 0.0, 'So, I know the life. I know they work', '', '', '<span>So,</span> <span>I</span> <span>know</span> <span>the</span> <span>life.</span> <span>I</span> <span>know</span> <span>they</span> <span>work</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 191, 245.76, 0.0, 'So, I know the life. I know they work really<00:04:06.159><c> hard</c><00:04:06.480><c> to</c><00:04:06.720><c> get</c><00:04:07.120><c> very</c><00:04:07.599><c> poor</c><00:04:08.560><c> income.</c><00:04:09.840><c> So,</c>', '', '', '<span>So,</span> <span>I</span> <span>know</span> <span>the</span> <span>life.</span> <span>I</span> <span>know</span> <span>they</span> <span>work</span> <span>really<00:04:06.159><c></span> <span>hard</c><00:04:06.480><c></span> <span>to</c><00:04:06.720><c></span> <span>get</c><00:04:07.120><c></span> <span>very</c><00:04:07.599><c></span> <span>poor</c><00:04:08.560><c></span> <span>income.</c><00:04:09.840><c></span> <span>So,</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 192, 250.309, 0.0, 'really hard to get very poor income. So,', '', '', '<span>really</span> <span>hard</span> <span>to</span> <span>get</span> <span>very</span> <span>poor</span> <span>income.</span> <span>So,</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 193, 250.319, 0.0, 'really hard to get very poor income. So, it''s<00:04:10.720><c> not</c><00:04:10.959><c> all</c><00:04:11.200><c> about</c><00:04:11.680><c> they''re</c><00:04:11.920><c> selling</c>', '', '', '<span>really</span> <span>hard</span> <span>to</span> <span>get</span> <span>very</span> <span>poor</span> <span>income.</span> <span>So,</span> <span>it''s<00:04:10.720><c></span> <span>not</c><00:04:10.959><c></span> <span>all</c><00:04:11.200><c></span> <span>about</c><00:04:11.680><c></span> <span>they''re</c><00:04:11.920><c></span> <span>selling</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 194, 252.229, 0.0, 'it''s not all about they''re selling', '', '', '<span>it''s</span> <span>not</span> <span>all</span> <span>about</span> <span>they''re</span> <span>selling</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 195, 252.239, 0.0, 'it''s not all about they''re selling things.<00:04:12.959><c> Sometimes</c><00:04:13.920><c> the</c><00:04:14.319><c> consumers</c><00:04:15.280><c> and</c><00:04:15.519><c> the</c>', '', '', '<span>it''s</span> <span>not</span> <span>all</span> <span>about</span> <span>they''re</span> <span>selling</span> <span>things.<00:04:12.959><c></span> <span>Sometimes</c><00:04:13.920><c></span> <span>the</c><00:04:14.319><c></span> <span>consumers</c><00:04:15.280><c></span> <span>and</c><00:04:15.519><c></span> <span>the</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 196, 255.83, 0.0, 'things. Sometimes the consumers and the', '', '', '<span>things.</span> <span>Sometimes</span> <span>the</span> <span>consumers</span> <span>and</span> <span>the</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 197, 255.84, 0.0, 'things. Sometimes the consumers and the providers<00:04:16.880><c> of</c><00:04:17.519><c> agricultural</c><00:04:18.479><c> product,</c><00:04:19.440><c> they</c>', '', '', '<span>things.</span> <span>Sometimes</span> <span>the</span> <span>consumers</span> <span>and</span> <span>the</span> <span>providers<00:04:16.880><c></span> <span>of</c><00:04:17.519><c></span> <span>agricultural</c><00:04:18.479><c></span> <span>product,</c><00:04:19.440><c></span> <span>they</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 198, 259.749, 0.0, 'providers of agricultural product, they', '', '', '<span>providers</span> <span>of</span> <span>agricultural</span> <span>product,</span> <span>they</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 199, 259.759, 0.0, 'providers of agricultural product, they have<00:04:20.000><c> no</c><00:04:20.720><c> simultaneous</c><00:04:21.919><c> information</c>', '', '', '<span>providers</span> <span>of</span> <span>agricultural</span> <span>product,</span> <span>they</span> <span>have<00:04:20.000><c></span> <span>no</c><00:04:20.720><c></span> <span>simultaneous</c><00:04:21.919><c></span> <span>information</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 200, 262.629, 0.0, 'have no simultaneous information', '', '', '<span>have</span> <span>no</span> <span>simultaneous</span> <span>information</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 201, 262.639, 0.0, 'have no simultaneous information exchange.<00:04:23.680><c> You</c><00:04:23.919><c> need</c><00:04:24.080><c> to</c><00:04:24.240><c> make</c><00:04:24.400><c> it</c><00:04:24.639><c> balanced.</c>', '', '', '<span>have</span> <span>no</span> <span>simultaneous</span> <span>information</span> <span>exchange.<00:04:23.680><c></span> <span>You</c><00:04:23.919><c></span> <span>need</c><00:04:24.080><c></span> <span>to</c><00:04:24.240><c></span> <span>make</c><00:04:24.400><c></span> <span>it</c><00:04:24.639><c></span> <span>balanced.</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 202, 265.99, 0.0, 'exchange. You need to make it balanced.', '', '', '<span>exchange.</span> <span>You</span> <span>need</span> <span>to</span> <span>make</span> <span>it</span> <span>balanced.</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 203, 266.0, 0.0, 'exchange. You need to make it balanced. You<00:04:26.240><c> need</c><00:04:26.400><c> to</c><00:04:26.639><c> make</c><00:04:26.800><c> the</c><00:04:27.040><c> profit</c><00:04:27.680><c> more</c><00:04:28.000><c> profit</c>', '', '', '<span>exchange.</span> <span>You</span> <span>need</span> <span>to</span> <span>make</span> <span>it</span> <span>balanced.</span> <span>You<00:04:26.240><c></span> <span>need</c><00:04:26.400><c></span> <span>to</c><00:04:26.639><c></span> <span>make</c><00:04:26.800><c></span> <span>the</c><00:04:27.040><c></span> <span>profit</c><00:04:27.680><c></span> <span>more</c><00:04:28.000><c></span> <span>profit</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 204, 268.39, 0.0, 'You need to make the profit more profit', '', '', '<span>You</span> <span>need</span> <span>to</span> <span>make</span> <span>the</span> <span>profit</span> <span>more</span> <span>profit</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 205, 268.4, 0.0, 'You need to make the profit more profit into<00:04:28.720><c> the</c><00:04:28.880><c> farmers.</c><00:04:29.680><c> When</c><00:04:30.080><c> people</c><00:04:30.400><c> need</c><00:04:30.560><c> to</c>', '', '', '<span>You</span> <span>need</span> <span>to</span> <span>make</span> <span>the</span> <span>profit</span> <span>more</span> <span>profit</span> <span>into<00:04:28.720><c></span> <span>the</c><00:04:28.880><c></span> <span>farmers.</c><00:04:29.680><c></span> <span>When</c><00:04:30.080><c></span> <span>people</c><00:04:30.400><c></span> <span>need</c><00:04:30.560><c></span> <span>to</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 206, 270.71, 0.0, 'into the farmers. When people need to', '', '', '<span>into</span> <span>the</span> <span>farmers.</span> <span>When</span> <span>people</span> <span>need</span> <span>to</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 207, 270.72, 0.0, 'into the farmers. When people need to buy<00:04:30.960><c> something,</c><00:04:31.520><c> people</c><00:04:32.000><c> want</c><00:04:32.639><c> cheaper</c>', '', '', '<span>into</span> <span>the</span> <span>farmers.</span> <span>When</span> <span>people</span> <span>need</span> <span>to</span> <span>buy<00:04:30.960><c></span> <span>something,</c><00:04:31.520><c></span> <span>people</c><00:04:32.000><c></span> <span>want</c><00:04:32.639><c></span> <span>cheaper</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 208, 273.11, 0.0, 'buy something, people want cheaper', '', '', '<span>buy</span> <span>something,</span> <span>people</span> <span>want</span> <span>cheaper</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 209, 273.12, 0.0, 'buy something, people want cheaper price.<00:04:34.080><c> But</c><00:04:34.560><c> to</c><00:04:34.880><c> be</c><00:04:34.960><c> honest,</c><00:04:35.199><c> the</c><00:04:35.440><c> cheaper</c>', '', '', '<span>buy</span> <span>something,</span> <span>people</span> <span>want</span> <span>cheaper</span> <span>price.<00:04:34.080><c></span> <span>But</c><00:04:34.560><c></span> <span>to</c><00:04:34.880><c></span> <span>be</c><00:04:34.960><c></span> <span>honest,</c><00:04:35.199><c></span> <span>the</c><00:04:35.440><c></span> <span>cheaper</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 210, 275.83, 0.0, 'price. But to be honest, the cheaper', '', '', '<span>price.</span> <span>But</span> <span>to</span> <span>be</span> <span>honest,</span> <span>the</span> <span>cheaper</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 211, 275.84, 0.0, 'price. But to be honest, the cheaper price<00:04:36.880><c> always</c><00:04:37.919><c> means</c>', '', '', '<span>price.</span> <span>But</span> <span>to</span> <span>be</span> <span>honest,</span> <span>the</span> <span>cheaper</span> <span>price<00:04:36.880><c></span> <span>always</c><00:04:37.919><c></span> <span>means</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 212, 278.87, 0.0, 'price always means', '', '', '<span>price</span> <span>always</span> <span>means</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 213, 278.88, 0.0, 'price always means &gt;&gt; bad<00:04:39.280><c> quality.</c><00:04:40.080><c> I</c><00:04:40.320><c> I''m</c><00:04:40.560><c> trying</c><00:04:40.800><c> to</c><00:04:41.199><c> use</c><00:04:41.520><c> another</c>', '', '', '<span>price</span> <span>always</span> <span>means</span> <span>&gt;&gt;</span> <span>bad<00:04:39.280><c></span> <span>quality.</c><00:04:40.080><c></span> <span>I</c><00:04:40.320><c></span> <span>I''m</c><00:04:40.560><c></span> <span>trying</c><00:04:40.800><c></span> <span>to</c><00:04:41.199><c></span> <span>use</c><00:04:41.520><c></span> <span>another</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 214, 281.83, 0.0, '&gt;&gt; bad quality. I I''m trying to use another', '', '', '<span>&gt;&gt;</span> <span>bad</span> <span>quality.</span> <span>I</span> <span>I''m</span> <span>trying</span> <span>to</span> <span>use</span> <span>another</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 215, 281.84, 0.0, '&gt;&gt; bad quality. I I''m trying to use another word<00:04:42.160><c> but</c><00:04:42.560><c> yes</c><00:04:43.440><c> if</c><00:04:43.759><c> we</c><00:04:44.000><c> want</c><00:04:44.560><c> lower</c><00:04:44.960><c> price</c><00:04:45.360><c> for</c>', '', '', '<span>&gt;&gt;</span> <span>bad</span> <span>quality.</span> <span>I</span> <span>I''m</span> <span>trying</span> <span>to</span> <span>use</span> <span>another</span> <span>word<00:04:42.160><c></span> <span>but</c><00:04:42.560><c></span> <span>yes</c><00:04:43.440><c></span> <span>if</c><00:04:43.759><c></span> <span>we</c><00:04:44.000><c></span> <span>want</c><00:04:44.560><c></span> <span>lower</c><00:04:44.960><c></span> <span>price</c><00:04:45.360><c></span> <span>for</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 216, 285.99, 0.0, 'word but yes if we want lower price for', '', '', '<span>word</span> <span>but</span> <span>yes</span> <span>if</span> <span>we</span> <span>want</span> <span>lower</span> <span>price</span> <span>for</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 217, 286.0, 0.0, 'word but yes if we want lower price for agricultural<00:04:46.880><c> products</c><00:04:47.360><c> all</c><00:04:47.520><c> the</c><00:04:47.759><c> time</c><00:04:48.479><c> those</c>', '', '', '<span>word</span> <span>but</span> <span>yes</span> <span>if</span> <span>we</span> <span>want</span> <span>lower</span> <span>price</span> <span>for</span> <span>agricultural<00:04:46.880><c></span> <span>products</c><00:04:47.360><c></span> <span>all</c><00:04:47.520><c></span> <span>the</c><00:04:47.759><c></span> <span>time</c><00:04:48.479><c></span> <span>those</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 218, 289.03, 0.0, 'agricultural products all the time those', '', '', '<span>agricultural</span> <span>products</span> <span>all</span> <span>the</span> <span>time</span> <span>those</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 219, 289.04, 0.0, 'agricultural products all the time those who<00:04:49.360><c> have</c><00:04:49.680><c> no</c><00:04:50.479><c> right</c><00:04:50.880><c> to</c><00:04:51.199><c> speak</c><00:04:51.840><c> for</c>', '', '', '<span>agricultural</span> <span>products</span> <span>all</span> <span>the</span> <span>time</span> <span>those</span> <span>who<00:04:49.360><c></span> <span>have</c><00:04:49.680><c></span> <span>no</c><00:04:50.479><c></span> <span>right</c><00:04:50.880><c></span> <span>to</c><00:04:51.199><c></span> <span>speak</c><00:04:51.840><c></span> <span>for</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 220, 292.15, 0.0, 'who have no right to speak for', '', '', '<span>who</span> <span>have</span> <span>no</span> <span>right</span> <span>to</span> <span>speak</span> <span>for</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 221, 292.16, 0.0, 'who have no right to speak for themselves<00:04:53.280><c> they</c><00:04:53.520><c> will</c><00:04:53.759><c> suffer</c><00:04:54.160><c> the</c><00:04:54.479><c> most.</c>', '', '', '<span>who</span> <span>have</span> <span>no</span> <span>right</span> <span>to</span> <span>speak</span> <span>for</span> <span>themselves<00:04:53.280><c></span> <span>they</c><00:04:53.520><c></span> <span>will</c><00:04:53.759><c></span> <span>suffer</c><00:04:54.160><c></span> <span>the</c><00:04:54.479><c></span> <span>most.</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 222, 295.99, 0.0, 'themselves they will suffer the most.', '', '', '<span>themselves</span> <span>they</span> <span>will</span> <span>suffer</span> <span>the</span> <span>most.</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 223, 296.0, 0.0, 'themselves they will suffer the most. &gt;&gt; What<00:04:56.160><c> do</c><00:04:56.320><c> you</c><00:04:56.400><c> envision</c><00:04:56.800><c> to</c><00:04:57.040><c> be</c><00:04:57.120><c> the</c><00:04:57.360><c> future</c><00:04:57.520><c> of</c>', '', '', '<span>themselves</span> <span>they</span> <span>will</span> <span>suffer</span> <span>the</span> <span>most.</span> <span>&gt;&gt;</span> <span>What<00:04:56.160><c></span> <span>do</c><00:04:56.320><c></span> <span>you</c><00:04:56.400><c></span> <span>envision</c><00:04:56.800><c></span> <span>to</c><00:04:57.040><c></span> <span>be</c><00:04:57.120><c></span> <span>the</c><00:04:57.360><c></span> <span>future</c><00:04:57.520><c></span> <span>of</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 224, 297.67, 0.0, '&gt;&gt; What do you envision to be the future of', '', '', '<span>&gt;&gt;</span> <span>What</span> <span>do</span> <span>you</span> <span>envision</span> <span>to</span> <span>be</span> <span>the</span> <span>future</span> <span>of</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 225, 297.68, 0.0, '&gt;&gt; What do you envision to be the future of the<00:04:57.840><c> e-commerce</c><00:04:58.400><c> industry?</c><00:04:59.120><c> I</c><00:04:59.440><c> don''t</c><00:04:59.520><c> know</c><00:05:00.160><c> to</c>', '', '', '<span>&gt;&gt;</span> <span>What</span> <span>do</span> <span>you</span> <span>envision</span> <span>to</span> <span>be</span> <span>the</span> <span>future</span> <span>of</span> <span>the<00:04:57.840><c></span> <span>e-commerce</c><00:04:58.400><c></span> <span>industry?</c><00:04:59.120><c></span> <span>I</c><00:04:59.440><c></span> <span>don''t</c><00:04:59.520><c></span> <span>know</c><00:05:00.160><c></span> <span>to</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 226, 300.39, 0.0, 'the e-commerce industry? I don''t know to', '', '', '<span>the</span> <span>e-commerce</span> <span>industry?</span> <span>I</span> <span>don''t</span> <span>know</span> <span>to</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 227, 300.4, 0.0, 'the e-commerce industry? I don''t know to be<00:05:00.479><c> honest</c><00:05:01.120><c> I''m</c><00:05:01.360><c> not</c><00:05:01.520><c> a</c><00:05:01.759><c> business</c><00:05:02.080><c> leader</c><00:05:02.960><c> I''m</c>', '', '', '<span>the</span> <span>e-commerce</span> <span>industry?</span> <span>I</span> <span>don''t</span> <span>know</span> <span>to</span> <span>be<00:05:00.479><c></span> <span>honest</c><00:05:01.120><c></span> <span>I''m</c><00:05:01.360><c></span> <span>not</c><00:05:01.520><c></span> <span>a</c><00:05:01.759><c></span> <span>business</c><00:05:02.080><c></span> <span>leader</c><00:05:02.960><c></span> <span>I''m</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 228, 303.189, 0.0, 'be honest I''m not a business leader I''m', '', '', '<span>be</span> <span>honest</span> <span>I''m</span> <span>not</span> <span>a</span> <span>business</span> <span>leader</span> <span>I''m</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 229, 303.199, 0.0, 'be honest I''m not a business leader I''m just<00:05:03.360><c> a</c><00:05:03.600><c> lucky</c><00:05:04.320><c> young</c><00:05:04.720><c> person</c><00:05:05.680><c> but</c><00:05:05.919><c> in</c><00:05:06.240><c> my</c>', '', '', '<span>be</span> <span>honest</span> <span>I''m</span> <span>not</span> <span>a</span> <span>business</span> <span>leader</span> <span>I''m</span> <span>just<00:05:03.360><c></span> <span>a</c><00:05:03.600><c></span> <span>lucky</c><00:05:04.320><c></span> <span>young</c><00:05:04.720><c></span> <span>person</c><00:05:05.680><c></span> <span>but</c><00:05:05.919><c></span> <span>in</c><00:05:06.240><c></span> <span>my</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 230, 306.469, 0.0, 'just a lucky young person but in my', '', '', '<span>just</span> <span>a</span> <span>lucky</span> <span>young</span> <span>person</span> <span>but</span> <span>in</span> <span>my</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 231, 306.479, 0.0, 'just a lucky young person but in my opinion<00:05:07.039><c> e-commerce</c><00:05:07.680><c> is</c><00:05:07.919><c> just</c><00:05:08.160><c> a</c><00:05:08.400><c> different</c>', '', '', '<span>just</span> <span>a</span> <span>lucky</span> <span>young</span> <span>person</span> <span>but</span> <span>in</span> <span>my</span> <span>opinion<00:05:07.039><c></span> <span>e-commerce</c><00:05:07.680><c></span> <span>is</c><00:05:07.919><c></span> <span>just</c><00:05:08.160><c></span> <span>a</c><00:05:08.400><c></span> <span>different</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 232, 308.87, 0.0, 'opinion e-commerce is just a different', '', '', '<span>opinion</span> <span>e-commerce</span> <span>is</span> <span>just</span> <span>a</span> <span>different</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 233, 308.88, 0.0, 'opinion e-commerce is just a different way<00:05:09.280><c> a</c><00:05:09.600><c> different</c><00:05:09.840><c> approach</c><00:05:10.800><c> you</c><00:05:11.039><c> need</c><00:05:11.199><c> to</c>', '', '', '<span>opinion</span> <span>e-commerce</span> <span>is</span> <span>just</span> <span>a</span> <span>different</span> <span>way<00:05:09.280><c></span> <span>a</c><00:05:09.600><c></span> <span>different</c><00:05:09.840><c></span> <span>approach</c><00:05:10.800><c></span> <span>you</c><00:05:11.039><c></span> <span>need</c><00:05:11.199><c></span> <span>to</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 234, 311.99, 0.0, 'way a different approach you need to', '', '', '<span>way</span> <span>a</span> <span>different</span> <span>approach</span> <span>you</span> <span>need</span> <span>to</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 235, 312.0, 0.0, 'way a different approach you need to improve<00:05:12.479><c> the</c><00:05:12.720><c> quality</c><00:05:13.440><c> you</c><00:05:13.600><c> need</c><00:05:13.759><c> to</c><00:05:13.919><c> improve</c>', '', '', '<span>way</span> <span>a</span> <span>different</span> <span>approach</span> <span>you</span> <span>need</span> <span>to</span> <span>improve<00:05:12.479><c></span> <span>the</c><00:05:12.720><c></span> <span>quality</c><00:05:13.440><c></span> <span>you</c><00:05:13.600><c></span> <span>need</c><00:05:13.759><c></span> <span>to</c><00:05:13.919><c></span> <span>improve</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 236, 314.39, 0.0, 'improve the quality you need to improve', '', '', '<span>improve</span> <span>the</span> <span>quality</span> <span>you</span> <span>need</span> <span>to</span> <span>improve</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 237, 314.4, 0.0, 'improve the quality you need to improve the<00:05:15.280><c> uh</c><00:05:15.440><c> industry</c><00:05:16.240><c> standards</c><00:05:17.280><c> you</c><00:05:17.520><c> need</c><00:05:17.680><c> to</c>', '', '', '<span>improve</span> <span>the</span> <span>quality</span> <span>you</span> <span>need</span> <span>to</span> <span>improve</span> <span>the<00:05:15.280><c></span> <span>uh</c><00:05:15.440><c></span> <span>industry</c><00:05:16.240><c></span> <span>standards</c><00:05:17.280><c></span> <span>you</c><00:05:17.520><c></span> <span>need</c><00:05:17.680><c></span> <span>to</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 238, 318.15, 0.0, 'the uh industry standards you need to', '', '', '<span>the</span> <span>uh</span> <span>industry</span> <span>standards</span> <span>you</span> <span>need</span> <span>to</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 239, 318.16, 0.0, 'the uh industry standards you need to build<00:05:18.960><c> the</c><00:05:19.199><c> whole</c><00:05:19.440><c> line</c><00:05:20.000><c> to</c><00:05:20.240><c> sell</c><00:05:20.479><c> things</c><00:05:20.880><c> at</c><00:05:21.440><c> a</c>', '', '', '<span>the</span> <span>uh</span> <span>industry</span> <span>standards</span> <span>you</span> <span>need</span> <span>to</span> <span>build<00:05:18.960><c></span> <span>the</c><00:05:19.199><c></span> <span>whole</c><00:05:19.440><c></span> <span>line</c><00:05:20.000><c></span> <span>to</c><00:05:20.240><c></span> <span>sell</c><00:05:20.479><c></span> <span>things</c><00:05:20.880><c></span> <span>at</c><00:05:21.440><c></span> <span>a</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 240, 321.99, 0.0, 'build the whole line to sell things at a', '', '', '<span>build</span> <span>the</span> <span>whole</span> <span>line</span> <span>to</span> <span>sell</span> <span>things</span> <span>at</span> <span>a</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 241, 322.0, 0.0, 'build the whole line to sell things at a proper<00:05:22.400><c> price</c><00:05:23.360><c> because</c><00:05:23.680><c> the</c><00:05:24.000><c> business</c>', '', '', '<span>build</span> <span>the</span> <span>whole</span> <span>line</span> <span>to</span> <span>sell</span> <span>things</span> <span>at</span> <span>a</span> <span>proper<00:05:22.400><c></span> <span>price</c><00:05:23.360><c></span> <span>because</c><00:05:23.680><c></span> <span>the</c><00:05:24.000><c></span> <span>business</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 242, 324.95, 0.0, 'proper price because the business', '', '', '<span>proper</span> <span>price</span> <span>because</span> <span>the</span> <span>business</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 243, 324.96, 0.0, 'proper price because the business industry<00:05:25.520><c> they</c><00:05:25.919><c> still</c><00:05:26.160><c> need</c><00:05:26.880><c> profit</c><00:05:27.680><c> to</c><00:05:27.919><c> make</c>', '', '', '<span>proper</span> <span>price</span> <span>because</span> <span>the</span> <span>business</span> <span>industry<00:05:25.520><c></span> <span>they</c><00:05:25.919><c></span> <span>still</c><00:05:26.160><c></span> <span>need</c><00:05:26.880><c></span> <span>profit</c><00:05:27.680><c></span> <span>to</c><00:05:27.919><c></span> <span>make</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 244, 328.23, 0.0, 'industry they still need profit to make', '', '', '<span>industry</span> <span>they</span> <span>still</span> <span>need</span> <span>profit</span> <span>to</span> <span>make</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 245, 328.24, 0.0, 'industry they still need profit to make improvement<00:05:28.560><c> ments</c><00:05:28.960><c> to</c><00:05:29.120><c> pay</c><00:05:29.280><c> the</c><00:05:29.520><c> workers.</c>', '', '', '<span>industry</span> <span>they</span> <span>still</span> <span>need</span> <span>profit</span> <span>to</span> <span>make</span> <span>improvement<00:05:28.560><c></span> <span>ments</c><00:05:28.960><c></span> <span>to</c><00:05:29.120><c></span> <span>pay</c><00:05:29.280><c></span> <span>the</c><00:05:29.520><c></span> <span>workers.</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 246, 330.31, 0.0, 'improvement ments to pay the workers.', '', '', '<span>improvement</span> <span>ments</span> <span>to</span> <span>pay</span> <span>the</span> <span>workers.</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 247, 330.32, 0.0, 'improvement ments to pay the workers. &gt;&gt; But<00:05:30.479><c> then</c><00:05:30.639><c> you</c><00:05:30.880><c> found</c><00:05:31.120><c> a</c><00:05:31.360><c> way</c><00:05:31.759><c> to</c><00:05:32.639><c> associate</c><00:05:33.280><c> or</c>', '', '', '<span>improvement</span> <span>ments</span> <span>to</span> <span>pay</span> <span>the</span> <span>workers.</span> <span>&gt;&gt;</span> <span>But<00:05:30.479><c></span> <span>then</c><00:05:30.639><c></span> <span>you</c><00:05:30.880><c></span> <span>found</c><00:05:31.120><c></span> <span>a</c><00:05:31.360><c></span> <span>way</c><00:05:31.759><c></span> <span>to</c><00:05:32.639><c></span> <span>associate</c><00:05:33.280><c></span> <span>or</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 248, 333.51, 0.0, '&gt;&gt; But then you found a way to associate or', '', '', '<span>&gt;&gt;</span> <span>But</span> <span>then</span> <span>you</span> <span>found</span> <span>a</span> <span>way</span> <span>to</span> <span>associate</span> <span>or</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 249, 333.52, 0.0, '&gt;&gt; But then you found a way to associate or to<00:05:33.759><c> transfer</c><00:05:34.320><c> what</c><00:05:34.560><c> you</c><00:05:34.720><c> did</c><00:05:34.800><c> in</c><00:05:34.960><c> the</c><00:05:35.120><c> past.</c>', '', '', '<span>&gt;&gt;</span> <span>But</span> <span>then</span> <span>you</span> <span>found</span> <span>a</span> <span>way</span> <span>to</span> <span>associate</span> <span>or</span> <span>to<00:05:33.759><c></span> <span>transfer</c><00:05:34.320><c></span> <span>what</c><00:05:34.560><c></span> <span>you</c><00:05:34.720><c></span> <span>did</c><00:05:34.800><c></span> <span>in</c><00:05:34.960><c></span> <span>the</c><00:05:35.120><c></span> <span>past.</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 250, 335.67, 0.0, 'to transfer what you did in the past.', '', '', '<span>to</span> <span>transfer</span> <span>what</span> <span>you</span> <span>did</span> <span>in</span> <span>the</span> <span>past.</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 251, 335.68, 0.0, 'to transfer what you did in the past. How<00:05:35.919><c> do</c><00:05:36.000><c> you</c><00:05:36.160><c> interpret</c><00:05:36.560><c> your</c><00:05:36.880><c> own</c><00:05:37.199><c> success?</c>', '', '', '<span>to</span> <span>transfer</span> <span>what</span> <span>you</span> <span>did</span> <span>in</span> <span>the</span> <span>past.</span> <span>How<00:05:35.919><c></span> <span>do</c><00:05:36.000><c></span> <span>you</c><00:05:36.160><c></span> <span>interpret</c><00:05:36.560><c></span> <span>your</c><00:05:36.880><c></span> <span>own</c><00:05:37.199><c></span> <span>success?</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 252, 338.71, 0.0, 'How do you interpret your own success?', '', '', '<span>How</span> <span>do</span> <span>you</span> <span>interpret</span> <span>your</span> <span>own</span> <span>success?</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 253, 338.72, 0.0, 'How do you interpret your own success? &gt;&gt; First,<00:05:39.280><c> how</c><00:05:39.520><c> do</c><00:05:39.680><c> you</c><00:05:39.840><c> define</c><00:05:40.320><c> success?</c><00:05:41.600><c> If</c><00:05:41.919><c> you</c>', '', '', '<span>How</span> <span>do</span> <span>you</span> <span>interpret</span> <span>your</span> <span>own</span> <span>success?</span> <span>&gt;&gt;</span> <span>First,<00:05:39.280><c></span> <span>how</c><00:05:39.520><c></span> <span>do</c><00:05:39.680><c></span> <span>you</c><00:05:39.840><c></span> <span>define</c><00:05:40.320><c></span> <span>success?</c><00:05:41.600><c></span> <span>If</c><00:05:41.919><c></span> <span>you</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 254, 342.23, 0.0, '&gt;&gt; First, how do you define success? If you', '', '', '<span>&gt;&gt;</span> <span>First,</span> <span>how</span> <span>do</span> <span>you</span> <span>define</span> <span>success?</span> <span>If</span> <span>you</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 255, 342.24, 0.0, '&gt;&gt; First, how do you define success? If you define<00:05:42.639><c> yourself</c><00:05:43.039><c> as</c><00:05:43.840><c> a</c><00:05:44.240><c> successful</c><00:05:45.120><c> person,</c>', '', '', '<span>&gt;&gt;</span> <span>First,</span> <span>how</span> <span>do</span> <span>you</span> <span>define</span> <span>success?</span> <span>If</span> <span>you</span> <span>define<00:05:42.639><c></span> <span>yourself</c><00:05:43.039><c></span> <span>as</c><00:05:43.840><c></span> <span>a</c><00:05:44.240><c></span> <span>successful</c><00:05:45.120><c></span> <span>person,</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 256, 345.59, 0.0, 'define yourself as a successful person,', '', '', '<span>define</span> <span>yourself</span> <span>as</span> <span>a</span> <span>successful</span> <span>person,</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 257, 345.6, 0.0, 'define yourself as a successful person, you<00:05:45.840><c> need</c><00:05:45.919><c> to</c><00:05:46.160><c> achieve</c><00:05:46.560><c> something</c><00:05:46.960><c> which</c><00:05:48.000><c> can</c>', '', '', '<span>define</span> <span>yourself</span> <span>as</span> <span>a</span> <span>successful</span> <span>person,</span> <span>you<00:05:45.840><c></span> <span>need</c><00:05:45.919><c></span> <span>to</c><00:05:46.160><c></span> <span>achieve</c><00:05:46.560><c></span> <span>something</c><00:05:46.960><c></span> <span>which</c><00:05:48.000><c></span> <span>can</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 258, 348.31, 0.0, 'you need to achieve something which can', '', '', '<span>you</span> <span>need</span> <span>to</span> <span>achieve</span> <span>something</span> <span>which</span> <span>can</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 259, 348.32, 0.0, 'you need to achieve something which can be<00:05:48.720><c> beneficial</c><00:05:49.280><c> to</c><00:05:49.600><c> yourself</c><00:05:50.000><c> and</c><00:05:50.400><c> to</c><00:05:50.560><c> others.</c>', '', '', '<span>you</span> <span>need</span> <span>to</span> <span>achieve</span> <span>something</span> <span>which</span> <span>can</span> <span>be<00:05:48.720><c></span> <span>beneficial</c><00:05:49.280><c></span> <span>to</c><00:05:49.600><c></span> <span>yourself</c><00:05:50.000><c></span> <span>and</c><00:05:50.400><c></span> <span>to</c><00:05:50.560><c></span> <span>others.</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 260, 351.029, 0.0, 'be beneficial to yourself and to others.', '', '', '<span>be</span> <span>beneficial</span> <span>to</span> <span>yourself</span> <span>and</span> <span>to</span> <span>others.</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 261, 351.039, 0.0, 'be beneficial to yourself and to others. I<00:05:51.360><c> am</c><00:05:51.680><c> not</c><00:05:52.320><c> successful</c><00:05:53.360><c> because</c><00:05:54.000><c> who</c><00:05:54.320><c> I</c><00:05:54.560><c> am.</c><00:05:55.360><c> I</c>', '', '', '<span>be</span> <span>beneficial</span> <span>to</span> <span>yourself</span> <span>and</span> <span>to</span> <span>others.</span> <span>I<00:05:51.360><c></span> <span>am</c><00:05:51.680><c></span> <span>not</c><00:05:52.320><c></span> <span>successful</c><00:05:53.360><c></span> <span>because</c><00:05:54.000><c></span> <span>who</c><00:05:54.320><c></span> <span>I</c><00:05:54.560><c></span> <span>am.</c><00:05:55.360><c></span> <span>I</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 262, 355.67, 0.0, 'I am not successful because who I am. I', '', '', '<span>I</span> <span>am</span> <span>not</span> <span>successful</span> <span>because</span> <span>who</span> <span>I</span> <span>am.</span> <span>I</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 263, 355.68, 0.0, 'I am not successful because who I am. I am<00:05:55.919><c> lucky</c><00:05:56.320><c> for</c><00:05:57.280><c> who</c><00:05:57.520><c> I</c><00:05:57.680><c> am</c><00:05:57.840><c> and</c><00:05:58.080><c> what</c><00:05:58.320><c> I</c><00:05:58.560><c> am.</c>', '', '', '<span>I</span> <span>am</span> <span>not</span> <span>successful</span> <span>because</span> <span>who</span> <span>I</span> <span>am.</span> <span>I</span> <span>am<00:05:55.919><c></span> <span>lucky</c><00:05:56.320><c></span> <span>for</c><00:05:57.280><c></span> <span>who</c><00:05:57.520><c></span> <span>I</c><00:05:57.680><c></span> <span>am</c><00:05:57.840><c></span> <span>and</c><00:05:58.080><c></span> <span>what</c><00:05:58.320><c></span> <span>I</c><00:05:58.560><c></span> <span>am.</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 264, 359.029, 0.0, 'am lucky for who I am and what I am.', '', '', '<span>am</span> <span>lucky</span> <span>for</span> <span>who</span> <span>I</span> <span>am</span> <span>and</span> <span>what</span> <span>I</span> <span>am.</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 265, 359.039, 0.0, 'am lucky for who I am and what I am. When<00:05:59.280><c> you</c><00:05:59.440><c> have</c><00:05:59.680><c> people''s</c><00:06:00.080><c> attention,</c><00:06:00.720><c> you</c>', '', '', '<span>am</span> <span>lucky</span> <span>for</span> <span>who</span> <span>I</span> <span>am</span> <span>and</span> <span>what</span> <span>I</span> <span>am.</span> <span>When<00:05:59.280><c></span> <span>you</c><00:05:59.440><c></span> <span>have</c><00:05:59.680><c></span> <span>people''s</c><00:06:00.080><c></span> <span>attention,</c><00:06:00.720><c></span> <span>you</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 266, 361.029, 0.0, 'When you have people''s attention, you', '', '', '<span>When</span> <span>you</span> <span>have</span> <span>people''s</span> <span>attention,</span> <span>you</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 267, 361.039, 0.0, 'When you have people''s attention, you need<00:06:01.199><c> to</c><00:06:01.520><c> cherish</c><00:06:01.919><c> the</c><00:06:02.240><c> time</c><00:06:02.479><c> they</c><00:06:02.720><c> spent</c><00:06:03.039><c> with</c>', '', '', '<span>When</span> <span>you</span> <span>have</span> <span>people''s</span> <span>attention,</span> <span>you</span> <span>need<00:06:01.199><c></span> <span>to</c><00:06:01.520><c></span> <span>cherish</c><00:06:01.919><c></span> <span>the</c><00:06:02.240><c></span> <span>time</c><00:06:02.479><c></span> <span>they</c><00:06:02.720><c></span> <span>spent</c><00:06:03.039><c></span> <span>with</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 268, 363.27, 0.0, 'need to cherish the time they spent with', '', '', '<span>need</span> <span>to</span> <span>cherish</span> <span>the</span> <span>time</span> <span>they</span> <span>spent</span> <span>with</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 269, 363.28, 0.0, 'need to cherish the time they spent with you.<00:06:03.840><c> What</c><00:06:04.080><c> kind</c><00:06:04.240><c> of</c><00:06:04.400><c> values,</c><00:06:05.039><c> what</c><00:06:05.280><c> kind</c><00:06:05.440><c> of</c>', '', '', '<span>need</span> <span>to</span> <span>cherish</span> <span>the</span> <span>time</span> <span>they</span> <span>spent</span> <span>with</span> <span>you.<00:06:03.840><c></span> <span>What</c><00:06:04.080><c></span> <span>kind</c><00:06:04.240><c></span> <span>of</c><00:06:04.400><c></span> <span>values,</c><00:06:05.039><c></span> <span>what</c><00:06:05.280><c></span> <span>kind</c><00:06:05.440><c></span> <span>of</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 270, 365.67, 0.0, 'you. What kind of values, what kind of', '', '', '<span>you.</span> <span>What</span> <span>kind</span> <span>of</span> <span>values,</span> <span>what</span> <span>kind</span> <span>of</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 271, 365.68, 0.0, 'you. What kind of values, what kind of knowledge,<00:06:06.400><c> what</c><00:06:06.720><c> you</c><00:06:06.960><c> are</c><00:06:07.199><c> trying</c><00:06:07.600><c> to</c>', '', '', '<span>you.</span> <span>What</span> <span>kind</span> <span>of</span> <span>values,</span> <span>what</span> <span>kind</span> <span>of</span> <span>knowledge,<00:06:06.400><c></span> <span>what</c><00:06:06.720><c></span> <span>you</c><00:06:06.960><c></span> <span>are</c><00:06:07.199><c></span> <span>trying</c><00:06:07.600><c></span> <span>to</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 272, 368.07, 0.0, 'knowledge, what you are trying to', '', '', '<span>knowledge,</span> <span>what</span> <span>you</span> <span>are</span> <span>trying</span> <span>to</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 273, 368.08, 0.0, 'knowledge, what you are trying to spread.', '', '', '<span>knowledge,</span> <span>what</span> <span>you</span> <span>are</span> <span>trying</span> <span>to</span> <span>spread.</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 274, 368.95, 0.0, 'spread.', '', '', '<span>spread.</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 275, 368.96, 0.0, 'spread. &gt;&gt; Does<00:06:09.199><c> your</c><00:06:09.360><c> current</c><00:06:09.680><c> job</c><00:06:09.919><c> make</c><00:06:10.080><c> you</c><00:06:10.319><c> happy?</c>', '', '', '<span>spread.</span> <span>&gt;&gt;</span> <span>Does<00:06:09.199><c></span> <span>your</c><00:06:09.360><c></span> <span>current</c><00:06:09.680><c></span> <span>job</c><00:06:09.919><c></span> <span>make</c><00:06:10.080><c></span> <span>you</c><00:06:10.319><c></span> <span>happy?</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 276, 370.79, 0.0, '&gt;&gt; Does your current job make you happy?', '', '', '<span>&gt;&gt;</span> <span>Does</span> <span>your</span> <span>current</span> <span>job</span> <span>make</span> <span>you</span> <span>happy?</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 277, 370.8, 0.0, '&gt;&gt; Does your current job make you happy? &gt;&gt; A<00:06:10.960><c> part</c><00:06:11.199><c> of</c><00:06:11.520><c> Yeah.</c><00:06:12.560><c> I</c><00:06:12.800><c> cannot</c><00:06:13.120><c> say</c><00:06:13.360><c> the</c><00:06:13.600><c> whole</c>', '', '', '<span>&gt;&gt;</span> <span>Does</span> <span>your</span> <span>current</span> <span>job</span> <span>make</span> <span>you</span> <span>happy?</span> <span>&gt;&gt;</span> <span>A<00:06:10.960><c></span> <span>part</c><00:06:11.199><c></span> <span>of</c><00:06:11.520><c></span> <span>Yeah.</c><00:06:12.560><c></span> <span>I</c><00:06:12.800><c></span> <span>cannot</c><00:06:13.120><c></span> <span>say</c><00:06:13.360><c></span> <span>the</c><00:06:13.600><c></span> <span>whole</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 278, 373.749, 0.0, '&gt;&gt; A part of Yeah. I cannot say the whole', '', '', '<span>&gt;&gt;</span> <span>A</span> <span>part</span> <span>of</span> <span>Yeah.</span> <span>I</span> <span>cannot</span> <span>say</span> <span>the</span> <span>whole</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 279, 373.759, 0.0, '&gt;&gt; A part of Yeah. I cannot say the whole thing.<00:06:14.080><c> No,</c><00:06:14.560><c> I</c><00:06:14.800><c> don''t</c><00:06:15.039><c> enjoy</c><00:06:15.680><c> selling</c><00:06:16.000><c> people</c>', '', '', '<span>&gt;&gt;</span> <span>A</span> <span>part</span> <span>of</span> <span>Yeah.</span> <span>I</span> <span>cannot</span> <span>say</span> <span>the</span> <span>whole</span> <span>thing.<00:06:14.080><c></span> <span>No,</c><00:06:14.560><c></span> <span>I</c><00:06:14.800><c></span> <span>don''t</c><00:06:15.039><c></span> <span>enjoy</c><00:06:15.680><c></span> <span>selling</c><00:06:16.000><c></span> <span>people</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 280, 376.309, 0.0, 'thing. No, I don''t enjoy selling people', '', '', '<span>thing.</span> <span>No,</span> <span>I</span> <span>don''t</span> <span>enjoy</span> <span>selling</span> <span>people</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 281, 376.319, 0.0, 'thing. No, I don''t enjoy selling people things.<00:06:16.800><c> Honestly,</c>', '', '', '<span>thing.</span> <span>No,</span> <span>I</span> <span>don''t</span> <span>enjoy</span> <span>selling</span> <span>people</span> <span>things.<00:06:16.800><c></span> <span>Honestly,</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 282, 377.43, 0.0, 'things. Honestly,', '', '', '<span>things.</span> <span>Honestly,</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 283, 377.44, 0.0, 'things. Honestly, &gt;&gt; still.', '', '', '<span>things.</span> <span>Honestly,</span> <span>&gt;&gt;</span> <span>still.</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 284, 377.99, 0.0, '&gt;&gt; still.', '', '', '<span>&gt;&gt;</span> <span>still.</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 285, 378.0, 0.0, '&gt;&gt; still. &gt;&gt; Still<00:06:18.479><c> I</c><00:06:18.720><c> cannot</c><00:06:19.120><c> enjoy</c><00:06:19.600><c> people</c><00:06:20.000><c> buy</c><00:06:20.319><c> too</c><00:06:20.639><c> much</c>', '', '', '<span>&gt;&gt;</span> <span>still.</span> <span>&gt;&gt;</span> <span>Still<00:06:18.479><c></span> <span>I</c><00:06:18.720><c></span> <span>cannot</c><00:06:19.120><c></span> <span>enjoy</c><00:06:19.600><c></span> <span>people</c><00:06:20.000><c></span> <span>buy</c><00:06:20.319><c></span> <span>too</c><00:06:20.639><c></span> <span>much</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 286, 380.87, 0.0, '&gt;&gt; Still I cannot enjoy people buy too much', '', '', '<span>&gt;&gt;</span> <span>Still</span> <span>I</span> <span>cannot</span> <span>enjoy</span> <span>people</span> <span>buy</span> <span>too</span> <span>much</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 287, 380.88, 0.0, '&gt;&gt; Still I cannot enjoy people buy too much things<00:06:21.280><c> just</c><00:06:21.600><c> because</c><00:06:21.919><c> they</c><00:06:22.160><c> love</c><00:06:22.400><c> me.</c>', '', '', '<span>&gt;&gt;</span> <span>Still</span> <span>I</span> <span>cannot</span> <span>enjoy</span> <span>people</span> <span>buy</span> <span>too</span> <span>much</span> <span>things<00:06:21.280><c></span> <span>just</c><00:06:21.600><c></span> <span>because</c><00:06:21.919><c></span> <span>they</c><00:06:22.160><c></span> <span>love</c><00:06:22.400><c></span> <span>me.</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 288, 382.79, 0.0, 'things just because they love me.', '', '', '<span>things</span> <span>just</span> <span>because</span> <span>they</span> <span>love</span> <span>me.</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 289, 382.8, 0.0, 'things just because they love me. &gt;&gt; You<00:06:22.960><c> consider</c><00:06:23.280><c> that</c><00:06:23.520><c> a</c><00:06:23.680><c> bad</c><00:06:23.919><c> thing?</c><00:06:24.639><c> That</c><00:06:24.960><c> is</c>', '', '', '<span>things</span> <span>just</span> <span>because</span> <span>they</span> <span>love</span> <span>me.</span> <span>&gt;&gt;</span> <span>You<00:06:22.960><c></span> <span>consider</c><00:06:23.280><c></span> <span>that</c><00:06:23.520><c></span> <span>a</c><00:06:23.680><c></span> <span>bad</c><00:06:23.919><c></span> <span>thing?</c><00:06:24.639><c></span> <span>That</c><00:06:24.960><c></span> <span>is</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 290, 385.11, 0.0, '&gt;&gt; You consider that a bad thing? That is', '', '', '<span>&gt;&gt;</span> <span>You</span> <span>consider</span> <span>that</span> <span>a</span> <span>bad</span> <span>thing?</span> <span>That</span> <span>is</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 291, 385.12, 0.0, '&gt;&gt; You consider that a bad thing? That is definitely<00:06:25.759><c> vicious.</c>', '', '', '<span>&gt;&gt;</span> <span>You</span> <span>consider</span> <span>that</span> <span>a</span> <span>bad</span> <span>thing?</span> <span>That</span> <span>is</span> <span>definitely<00:06:25.759><c></span> <span>vicious.</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 292, 387.99, 0.0, 'definitely vicious.', '', '', '<span>definitely</span> <span>vicious.</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 293, 388.0, 0.0, 'definitely vicious. &gt;&gt; And<00:06:28.319><c> men</c><00:06:28.639><c> are</c><00:06:29.120><c> constantly</c><00:06:29.680><c> searching</c><00:06:30.080><c> for</c>', '', '', '<span>definitely</span> <span>vicious.</span> <span>&gt;&gt;</span> <span>And<00:06:28.319><c></span> <span>men</c><00:06:28.639><c></span> <span>are</c><00:06:29.120><c></span> <span>constantly</c><00:06:29.680><c></span> <span>searching</c><00:06:30.080><c></span> <span>for</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 294, 390.23, 0.0, '&gt;&gt; And men are constantly searching for', '', '', '<span>&gt;&gt;</span> <span>And</span> <span>men</span> <span>are</span> <span>constantly</span> <span>searching</span> <span>for</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 295, 390.24, 0.0, '&gt;&gt; And men are constantly searching for meaning.<00:06:31.120><c> There</c><00:06:31.440><c> needs</c><00:06:31.680><c> to</c><00:06:31.919><c> be</c><00:06:32.080><c> a</c><00:06:32.319><c> sense</c><00:06:32.560><c> of</c>', '', '', '<span>&gt;&gt;</span> <span>And</span> <span>men</span> <span>are</span> <span>constantly</span> <span>searching</span> <span>for</span> <span>meaning.<00:06:31.120><c></span> <span>There</c><00:06:31.440><c></span> <span>needs</c><00:06:31.680><c></span> <span>to</c><00:06:31.919><c></span> <span>be</c><00:06:32.080><c></span> <span>a</c><00:06:32.319><c></span> <span>sense</c><00:06:32.560><c></span> <span>of</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 296, 392.71, 0.0, 'meaning. There needs to be a sense of', '', '', '<span>meaning.</span> <span>There</span> <span>needs</span> <span>to</span> <span>be</span> <span>a</span> <span>sense</span> <span>of</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 297, 392.72, 0.0, 'meaning. There needs to be a sense of purpose.<00:06:33.440><c> Yeah.</c>', '', '', '<span>meaning.</span> <span>There</span> <span>needs</span> <span>to</span> <span>be</span> <span>a</span> <span>sense</span> <span>of</span> <span>purpose.<00:06:33.440><c></span> <span>Yeah.</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 298, 393.67, 0.0, 'purpose. Yeah.', '', '', '<span>purpose.</span> <span>Yeah.</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 299, 393.68, 0.0, 'purpose. Yeah. &gt;&gt; To<00:06:33.840><c> keep</c><00:06:34.000><c> you</c><00:06:34.240><c> going,</c><00:06:34.560><c> to</c><00:06:34.720><c> keep</c><00:06:34.880><c> you</c><00:06:35.120><c> strong.</c>', '', '', '<span>purpose.</span> <span>Yeah.</span> <span>&gt;&gt;</span> <span>To<00:06:33.840><c></span> <span>keep</c><00:06:34.000><c></span> <span>you</c><00:06:34.240><c></span> <span>going,</c><00:06:34.560><c></span> <span>to</c><00:06:34.720><c></span> <span>keep</c><00:06:34.880><c></span> <span>you</c><00:06:35.120><c></span> <span>strong.</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 300, 395.59, 0.0, '&gt;&gt; To keep you going, to keep you strong.', '', '', '<span>&gt;&gt;</span> <span>To</span> <span>keep</span> <span>you</span> <span>going,</span> <span>to</span> <span>keep</span> <span>you</span> <span>strong.</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 301, 395.6, 0.0, '&gt;&gt; To keep you going, to keep you strong. &gt;&gt; Uh-huh.', '', '', '<span>&gt;&gt;</span> <span>To</span> <span>keep</span> <span>you</span> <span>going,</span> <span>to</span> <span>keep</span> <span>you</span> <span>strong.</span> <span>&gt;&gt;</span> <span>Uh-huh.</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 302, 396.15, 0.0, '&gt;&gt; Uh-huh.', '', '', '<span>&gt;&gt;</span> <span>Uh-huh.</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 303, 396.16, 0.0, '&gt;&gt; Uh-huh. &gt;&gt; Have<00:06:36.319><c> you</c><00:06:36.479><c> found</c><00:06:36.720><c> that</c><00:06:37.039><c> purpose?</c>', '', '', '<span>&gt;&gt;</span> <span>Uh-huh.</span> <span>&gt;&gt;</span> <span>Have<00:06:36.319><c></span> <span>you</c><00:06:36.479><c></span> <span>found</c><00:06:36.720><c></span> <span>that</c><00:06:37.039><c></span> <span>purpose?</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 304, 398.629, 0.0, '&gt;&gt; Have you found that purpose?', '', '', '<span>&gt;&gt;</span> <span>Have</span> <span>you</span> <span>found</span> <span>that</span> <span>purpose?</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 305, 398.639, 0.0, '&gt;&gt; Have you found that purpose? &gt;&gt; I<00:06:38.880><c> think</c><00:06:39.039><c> so.</c>', '', '', '<span>&gt;&gt;</span> <span>Have</span> <span>you</span> <span>found</span> <span>that</span> <span>purpose?</span> <span>&gt;&gt;</span> <span>I<00:06:38.880><c></span> <span>think</c><00:06:39.039><c></span> <span>so.</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 306, 400.71, 0.0, '&gt;&gt; I think so.', '', '', '<span>&gt;&gt;</span> <span>I</span> <span>think</span> <span>so.</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 307, 400.72, 0.0, '&gt;&gt; I think so. I<00:06:41.039><c> think</c><00:06:41.199><c> so.</c><00:06:42.400><c> Making</c>', '', '', '<span>&gt;&gt;</span> <span>I</span> <span>think</span> <span>so.</span> <span>I<00:06:41.039><c></span> <span>think</c><00:06:41.199><c></span> <span>so.</c><00:06:42.400><c></span> <span>Making</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 308, 404.07, 0.0, 'I think so. Making', '', '', '<span>I</span> <span>think</span> <span>so.</span> <span>Making</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 309, 404.08, 0.0, 'I think so. Making more<00:06:45.280><c> people''s</c><00:06:46.080><c> life</c><00:06:46.880><c> better</c><00:06:47.840><c> with</c><00:06:48.160><c> my</c><00:06:48.400><c> own</c>', '', '', '<span>I</span> <span>think</span> <span>so.</span> <span>Making</span> <span>more<00:06:45.280><c></span> <span>people''s</c><00:06:46.080><c></span> <span>life</c><00:06:46.880><c></span> <span>better</c><00:06:47.840><c></span> <span>with</c><00:06:48.160><c></span> <span>my</c><00:06:48.400><c></span> <span>own</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 310, 408.629, 0.0, 'more people''s life better with my own', '', '', '<span>more</span> <span>people''s</span> <span>life</span> <span>better</span> <span>with</span> <span>my</span> <span>own</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 311, 408.639, 0.0, 'more people''s life better with my own ability', '', '', '<span>more</span> <span>people''s</span> <span>life</span> <span>better</span> <span>with</span> <span>my</span> <span>own</span> <span>ability</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 312, 419.029, 0.0, 'From my previous education, I think I''m', '', '', '<span>From</span> <span>my</span> <span>previous</span> <span>education,</span> <span>I</span> <span>think</span> <span>I''m</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 313, 419.039, 0.0, 'From my previous education, I think I''m a<00:06:59.280><c> person</c><00:06:59.520><c> with</c><00:06:59.840><c> mission.</c><00:07:01.039><c> I</c><00:07:01.360><c> still</c><00:07:01.680><c> consider</c>', '', '', '<span>From</span> <span>my</span> <span>previous</span> <span>education,</span> <span>I</span> <span>think</span> <span>I''m</span> <span>a<00:06:59.280><c></span> <span>person</c><00:06:59.520><c></span> <span>with</c><00:06:59.840><c></span> <span>mission.</c><00:07:01.039><c></span> <span>I</c><00:07:01.360><c></span> <span>still</c><00:07:01.680><c></span> <span>consider</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 314, 422.79, 0.0, 'a person with mission. I still consider', '', '', '<span>a</span> <span>person</span> <span>with</span> <span>mission.</span> <span>I</span> <span>still</span> <span>consider</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 315, 422.8, 0.0, 'a person with mission. I still consider uh<00:07:03.280><c> the</c><00:07:03.599><c> chance</c><00:07:04.720><c> my</c><00:07:05.039><c> fame</c><00:07:06.000><c> or</c><00:07:06.240><c> the</c><00:07:06.479><c> social</c>', '', '', '<span>a</span> <span>person</span> <span>with</span> <span>mission.</span> <span>I</span> <span>still</span> <span>consider</span> <span>uh<00:07:03.280><c></span> <span>the</c><00:07:03.599><c></span> <span>chance</c><00:07:04.720><c></span> <span>my</c><00:07:05.039><c></span> <span>fame</c><00:07:06.000><c></span> <span>or</c><00:07:06.240><c></span> <span>the</c><00:07:06.479><c></span> <span>social</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 316, 426.79, 0.0, 'uh the chance my fame or the social', '', '', '<span>uh</span> <span>the</span> <span>chance</span> <span>my</span> <span>fame</span> <span>or</span> <span>the</span> <span>social</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 317, 426.8, 0.0, 'uh the chance my fame or the social attention<00:07:07.199><c> paid</c><00:07:07.599><c> to</c><00:07:07.840><c> me.</c><00:07:08.880><c> That</c><00:07:09.199><c> was</c><00:07:09.440><c> something</c>', '', '', '<span>uh</span> <span>the</span> <span>chance</span> <span>my</span> <span>fame</span> <span>or</span> <span>the</span> <span>social</span> <span>attention<00:07:07.199><c></span> <span>paid</c><00:07:07.599><c></span> <span>to</c><00:07:07.840><c></span> <span>me.</c><00:07:08.880><c></span> <span>That</c><00:07:09.199><c></span> <span>was</c><00:07:09.440><c></span> <span>something</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 318, 432.23, 0.0, 'attention paid to me. That was something', '', '', '<span>attention</span> <span>paid</span> <span>to</span> <span>me.</span> <span>That</span> <span>was</span> <span>something</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 319, 432.24, 0.0, 'attention paid to me. That was something the<00:07:12.479><c> fate</c><00:07:12.880><c> has</c><00:07:13.120><c> chosen</c><00:07:13.440><c> to</c><00:07:13.599><c> give</c><00:07:13.840><c> me</c><00:07:14.000><c> and</c><00:07:14.319><c> make</c>', '', '', '<span>attention</span> <span>paid</span> <span>to</span> <span>me.</span> <span>That</span> <span>was</span> <span>something</span> <span>the<00:07:12.479><c></span> <span>fate</c><00:07:12.880><c></span> <span>has</c><00:07:13.120><c></span> <span>chosen</c><00:07:13.440><c></span> <span>to</c><00:07:13.599><c></span> <span>give</c><00:07:13.840><c></span> <span>me</c><00:07:14.000><c></span> <span>and</c><00:07:14.319><c></span> <span>make</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 320, 434.55, 0.0, 'the fate has chosen to give me and make', '', '', '<span>the</span> <span>fate</span> <span>has</span> <span>chosen</span> <span>to</span> <span>give</span> <span>me</span> <span>and</span> <span>make</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 321, 434.56, 0.0, 'the fate has chosen to give me and make me<00:07:14.800><c> to</c><00:07:14.960><c> do</c><00:07:15.360><c> correct</c><00:07:15.840><c> things</c><00:07:16.400><c> instead</c><00:07:16.800><c> of</c><00:07:17.039><c> to</c>', '', '', '<span>the</span> <span>fate</span> <span>has</span> <span>chosen</span> <span>to</span> <span>give</span> <span>me</span> <span>and</span> <span>make</span> <span>me<00:07:14.800><c></span> <span>to</c><00:07:14.960><c></span> <span>do</c><00:07:15.360><c></span> <span>correct</c><00:07:15.840><c></span> <span>things</c><00:07:16.400><c></span> <span>instead</c><00:07:16.800><c></span> <span>of</c><00:07:17.039><c></span> <span>to</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 322, 437.35, 0.0, 'me to do correct things instead of to', '', '', '<span>me</span> <span>to</span> <span>do</span> <span>correct</span> <span>things</span> <span>instead</span> <span>of</span> <span>to</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 323, 437.36, 0.0, 'me to do correct things instead of to make<00:07:17.680><c> profit</c><00:07:18.080><c> for</c><00:07:18.400><c> myself.</c><00:07:19.120><c> There</c><00:07:19.280><c> got</c><00:07:19.440><c> to</c><00:07:19.599><c> be</c>', '', '', '<span>me</span> <span>to</span> <span>do</span> <span>correct</span> <span>things</span> <span>instead</span> <span>of</span> <span>to</span> <span>make<00:07:17.680><c></span> <span>profit</c><00:07:18.080><c></span> <span>for</c><00:07:18.400><c></span> <span>myself.</c><00:07:19.120><c></span> <span>There</c><00:07:19.280><c></span> <span>got</c><00:07:19.440><c></span> <span>to</c><00:07:19.599><c></span> <span>be</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 324, 439.67, 0.0, 'make profit for myself. There got to be', '', '', '<span>make</span> <span>profit</span> <span>for</span> <span>myself.</span> <span>There</span> <span>got</span> <span>to</span> <span>be</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 325, 439.68, 0.0, 'make profit for myself. There got to be a<00:07:19.840><c> reason</c><00:07:20.639><c> why</c><00:07:20.960><c> I</c><00:07:21.199><c> was</c><00:07:21.360><c> the</c><00:07:21.599><c> chosen</c><00:07:22.000><c> one.</c>', '', '', '<span>make</span> <span>profit</span> <span>for</span> <span>myself.</span> <span>There</span> <span>got</span> <span>to</span> <span>be</span> <span>a<00:07:19.840><c></span> <span>reason</c><00:07:20.639><c></span> <span>why</c><00:07:20.960><c></span> <span>I</c><00:07:21.199><c></span> <span>was</c><00:07:21.360><c></span> <span>the</c><00:07:21.599><c></span> <span>chosen</c><00:07:22.000><c></span> <span>one.</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 326, 448.55, 0.0, 'We live in an age when everything change', '', '', '<span>We</span> <span>live</span> <span>in</span> <span>an</span> <span>age</span> <span>when</span> <span>everything</span> <span>change</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 327, 448.56, 0.0, 'We live in an age when everything change so<00:07:28.880><c> fast.</c><00:07:29.680><c> So</c><00:07:30.400><c> please</c><00:07:30.800><c> do</c><00:07:31.120><c> not</c>', '', '', '<span>We</span> <span>live</span> <span>in</span> <span>an</span> <span>age</span> <span>when</span> <span>everything</span> <span>change</span> <span>so<00:07:28.880><c></span> <span>fast.</c><00:07:29.680><c></span> <span>So</c><00:07:30.400><c></span> <span>please</c><00:07:30.800><c></span> <span>do</c><00:07:31.120><c></span> <span>not</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 328, 453.189, 0.0, 'so fast. So please do not', '', '', '<span>so</span> <span>fast.</span> <span>So</span> <span>please</span> <span>do</span> <span>not</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 329, 453.199, 0.0, 'so fast. So please do not predict<00:07:33.680><c> the</c><00:07:34.000><c> future,</c><00:07:34.479><c> shape</c><00:07:34.800><c> the</c><00:07:35.039><c> future</c><00:07:35.360><c> or</c>', '', '', '<span>so</span> <span>fast.</span> <span>So</span> <span>please</span> <span>do</span> <span>not</span> <span>predict<00:07:33.680><c></span> <span>the</c><00:07:34.000><c></span> <span>future,</c><00:07:34.479><c></span> <span>shape</c><00:07:34.800><c></span> <span>the</c><00:07:35.039><c></span> <span>future</c><00:07:35.360><c></span> <span>or</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 330, 455.589, 0.0, 'predict the future, shape the future or', '', '', '<span>predict</span> <span>the</span> <span>future,</span> <span>shape</span> <span>the</span> <span>future</span> <span>or</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 331, 455.599, 0.0, 'predict the future, shape the future or make<00:07:35.759><c> the</c><00:07:36.000><c> future.</c><00:07:36.479><c> Don''t</c><00:07:36.800><c> expect</c><00:07:37.360><c> yourself</c>', '', '', '<span>predict</span> <span>the</span> <span>future,</span> <span>shape</span> <span>the</span> <span>future</span> <span>or</span> <span>make<00:07:35.759><c></span> <span>the</c><00:07:36.000><c></span> <span>future.</c><00:07:36.479><c></span> <span>Don''t</c><00:07:36.800><c></span> <span>expect</c><00:07:37.360><c></span> <span>yourself</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 332, 457.83, 0.0, 'make the future. Don''t expect yourself', '', '', '<span>make</span> <span>the</span> <span>future.</span> <span>Don''t</span> <span>expect</span> <span>yourself</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 333, 457.84, 0.0, 'make the future. Don''t expect yourself to<00:07:38.160><c> make</c><00:07:38.400><c> the</c><00:07:38.960><c> correct</c><00:07:39.360><c> choice</c><00:07:39.680><c> all</c><00:07:39.840><c> the</c><00:07:40.080><c> time,</c>', '', '', '<span>make</span> <span>the</span> <span>future.</span> <span>Don''t</span> <span>expect</span> <span>yourself</span> <span>to<00:07:38.160><c></span> <span>make</c><00:07:38.400><c></span> <span>the</c><00:07:38.960><c></span> <span>correct</c><00:07:39.360><c></span> <span>choice</c><00:07:39.680><c></span> <span>all</c><00:07:39.840><c></span> <span>the</c><00:07:40.080><c></span> <span>time,</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 334, 460.87, 0.0, 'to make the correct choice all the time,', '', '', '<span>to</span> <span>make</span> <span>the</span> <span>correct</span> <span>choice</span> <span>all</span> <span>the</span> <span>time,</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 335, 460.88, 0.0, 'to make the correct choice all the time, but<00:07:41.280><c> please</c><00:07:41.759><c> follow</c><00:07:42.080><c> the</c><00:07:42.319><c> trends</c><00:07:43.039><c> faster.</c>', '', '', '<span>to</span> <span>make</span> <span>the</span> <span>correct</span> <span>choice</span> <span>all</span> <span>the</span> <span>time,</span> <span>but<00:07:41.280><c></span> <span>please</c><00:07:41.759><c></span> <span>follow</c><00:07:42.080><c></span> <span>the</c><00:07:42.319><c></span> <span>trends</c><00:07:43.039><c></span> <span>faster.</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 336, 463.99, 0.0, 'but please follow the trends faster.', '', '', '<span>but</span> <span>please</span> <span>follow</span> <span>the</span> <span>trends</span> <span>faster.</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 337, 464.0, 0.0, 'but please follow the trends faster. &gt;&gt; Yeah.', '', '', '<span>but</span> <span>please</span> <span>follow</span> <span>the</span> <span>trends</span> <span>faster.</span> <span>&gt;&gt;</span> <span>Yeah.</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 338, 464.79, 0.0, '&gt;&gt; Yeah.', '', '', '<span>&gt;&gt;</span> <span>Yeah.</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 339, 464.8, 0.0, '&gt;&gt; Yeah. &gt;&gt; Well,<00:07:45.120><c> thank</c><00:07:45.280><c> you</c><00:07:45.360><c> so</c><00:07:45.599><c> much,</c><00:07:45.759><c> U.</c><00:07:46.240><c> It</c><00:07:46.400><c> was</c><00:07:46.479><c> such</c>', '', '', '<span>&gt;&gt;</span> <span>Yeah.</span> <span>&gt;&gt;</span> <span>Well,<00:07:45.120><c></span> <span>thank</c><00:07:45.280><c></span> <span>you</c><00:07:45.360><c></span> <span>so</c><00:07:45.599><c></span> <span>much,</c><00:07:45.759><c></span> <span>U.</c><00:07:46.240><c></span> <span>It</c><00:07:46.400><c></span> <span>was</c><00:07:46.479><c></span> <span>such</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 340, 466.55, 0.0, '&gt;&gt; Well, thank you so much, U. It was such', '', '', '<span>&gt;&gt;</span> <span>Well,</span> <span>thank</span> <span>you</span> <span>so</span> <span>much,</span> <span>U.</span> <span>It</span> <span>was</span> <span>such</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 341, 466.56, 0.0, '&gt;&gt; Well, thank you so much, U. It was such a<00:07:46.800><c> pleasure</c><00:07:47.039><c> talking</c><00:07:47.360><c> to</c><00:07:47.520><c> you.</c>', '', '', '<span>&gt;&gt;</span> <span>Well,</span> <span>thank</span> <span>you</span> <span>so</span> <span>much,</span> <span>U.</span> <span>It</span> <span>was</span> <span>such</span> <span>a<00:07:46.800><c></span> <span>pleasure</c><00:07:47.039><c></span> <span>talking</c><00:07:47.360><c></span> <span>to</c><00:07:47.520><c></span> <span>you.</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 342, 467.909, 0.0, 'a pleasure talking to you.', '', '', '<span>a</span> <span>pleasure</span> <span>talking</span> <span>to</span> <span>you.</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 343, 467.919, 0.0, 'a pleasure talking to you. &gt;&gt; Pleasure.', '', '', '<span>a</span> <span>pleasure</span> <span>talking</span> <span>to</span> <span>you.</span> <span>&gt;&gt;</span> <span>Pleasure.</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 344, 468.39, 0.0, '&gt;&gt; Pleasure.', '', '', '<span>&gt;&gt;</span> <span>Pleasure.</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 345, 468.4, 0.0, '&gt;&gt; Pleasure. &gt;&gt; Thank<00:07:48.639><c> you.</c>', '', '', '<span>&gt;&gt;</span> <span>Pleasure.</span> <span>&gt;&gt;</span> <span>Thank<00:07:48.639><c></span> <span>you.</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 346, 468.95, 0.0, '&gt;&gt; Thank you.', '', '', '<span>&gt;&gt;</span> <span>Thank</span> <span>you.</span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 347, 468.96, 0.0, '&gt;&gt; Thank you. &gt;&gt; Thank<00:07:49.199><c> you.</c>', '', '', '<span>&gt;&gt;</span> <span>Thank</span> <span>you.</span> <span>&gt;&gt;</span> <span>Thank<00:07:49.199><c></span> <span>you.</c></span>'
FROM episodes e WHERE e.video_id = 's_OlOCwlf9K6spM';

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

-- imported video_ids: pgdzTec-K5LxriI, 1ZOWIuMJ1FHBY7w, BxBL4RohKg_s2a0, sQe2j4A_zYD1-8k, s_OlOCwlf9K6spM
