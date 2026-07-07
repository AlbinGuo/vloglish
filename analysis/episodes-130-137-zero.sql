-- vlogish episode import SQL
-- generated: 2026-06-30T16:27:41.052149Z
-- episodes: 10 (indices [0, 130, 131, 132, 134, 137])
-- Run on production PostgreSQL inside transaction.

BEGIN;

INSERT INTO authors (name, gender, nationality, accent)
SELECT 'Taylor Bell', 'f', '🇺🇸', '美国'
WHERE NOT EXISTS (
  SELECT 1 FROM authors x
  WHERE x.name = 'Taylor Bell' AND x.accent = '美国'
);
INSERT INTO authors (name, gender, nationality, accent)
SELECT 'abc7ny', 'f', 'us', '美国'
WHERE NOT EXISTS (
  SELECT 1 FROM authors x
  WHERE x.name = 'abc7ny' AND x.accent = '美国'
);
INSERT INTO authors (name, gender, nationality, accent)
SELECT 'user2171291792157', 'm', '🇺🇸', '美国'
WHERE NOT EXISTS (
  SELECT 1 FROM authors x
  WHERE x.name = 'user2171291792157' AND x.accent = '美国'
);
INSERT INTO authors (name, gender, nationality, accent)
SELECT 'chen971031', 'm', '', '美国'
WHERE NOT EXISTS (
  SELECT 1 FROM authors x
  WHERE x.name = 'chen971031' AND x.accent = '美国'
);
INSERT INTO authors (name, gender, nationality, accent)
SELECT 'Miki Rai', 'f', '🇺🇸', '美国'
WHERE NOT EXISTS (
  SELECT 1 FROM authors x
  WHERE x.name = 'Miki Rai' AND x.accent = '美国'
);
INSERT INTO authors (name, gender, nationality, accent)
SELECT 'John Laurito', 'm', '🇺🇸', '美国'
WHERE NOT EXISTS (
  SELECT 1 FROM authors x
  WHERE x.name = 'John Laurito' AND x.accent = '美国'
);
INSERT INTO authors (name, gender, nationality, accent)
SELECT 'Gu Ailing', 'f', '🇺🇸🇨🇳', '美国'
WHERE NOT EXISTS (
  SELECT 1 FROM authors x
  WHERE x.name = 'Gu Ailing' AND x.accent = '美国'
);
INSERT INTO authors (name, gender, nationality, accent)
SELECT 'Naval Ravikant', 'm', '🇺🇸', '美国'
WHERE NOT EXISTS (
  SELECT 1 FROM authors x
  WHERE x.name = 'Naval Ravikant' AND x.accent = '美国'
);
INSERT INTO authors (name, gender, nationality, accent)
SELECT 'Audacy Music', 'm', '', ''
WHERE NOT EXISTS (
  SELECT 1 FROM authors x
  WHERE x.name = 'Audacy Music' AND x.accent = ''
);

INSERT INTO tags (id, name)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM tags), '新闻'
WHERE NOT EXISTS (SELECT 1 FROM tags WHERE name = '新闻');
INSERT INTO tags (id, name)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM tags), '演讲'
WHERE NOT EXISTS (SELECT 1 FROM tags WHERE name = '演讲');
INSERT INTO tags (id, name)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM tags), '生活'
WHERE NOT EXISTS (SELECT 1 FROM tags WHERE name = '生活');
INSERT INTO tags (id, name)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM tags), '建议'
WHERE NOT EXISTS (SELECT 1 FROM tags WHERE name = '建议');
INSERT INTO tags (id, name)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM tags), '成长'
WHERE NOT EXISTS (SELECT 1 FROM tags WHERE name = '成长');
INSERT INTO tags (id, name)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM tags), '访谈'
WHERE NOT EXISTS (SELECT 1 FROM tags WHERE name = '访谈');
INSERT INTO tags (id, name)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM tags), '运动'
WHERE NOT EXISTS (SELECT 1 FROM tags WHERE name = '运动');
INSERT INTO tags (id, name)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM tags), '人生'
WHERE NOT EXISTS (SELECT 1 FROM tags WHERE name = '人生');

-- episode 0: dlfC9v8siowrhA8
INSERT INTO episodes (
  index, video_id, short_title, summary, remark, stars, voca_size,
  subtitle_count, clip_length, cover, video_url, audio_url, thumbnail_url,
  original_video_url, author_id, submitted_by_user_id, rejection_reason,
  created_at, is_demo, status, published_at
) VALUES (
  0, 'dlfC9v8siowrhA8', '我在一天之内游览了纽约市最著名的 10 个地方.',
  'I Went to 10 of NYC''s Most Famous Spots in One Day', '',
  3, 120, 278,
  1504.64, 'https://i.ytimg.com/an_webp/LVGi5soXQoI/mqdefault_6s.webp?du=3000&sqp=CMix8NEG&rs=AOn4CLBmOmbLGv3Vk3CMsS28oS6cObEQOw',
  'https://www.youtube.com/watch?v=LVGi5soXQoI', '',
  'https://i.ytimg.com/an_webp/LVGi5soXQoI/mqdefault_6s.webp?du=3000&sqp=CMix8NEG&rs=AOn4CLBmOmbLGv3Vk3CMsS28oS6cObEQOw', 'https://www.youtube.com/watch?v=LVGi5soXQoI',
  (SELECT id FROM authors WHERE name = 'Taylor Bell' AND accent = '美国' LIMIT 1),
  NULL, NULL,
  '2026-06-24 18:19:29'::timestamp,
  FALSE, 'published',
  '2026-06-24 18:19:29'::timestamp
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
  SELECT s.id FROM subtitles s JOIN episodes e ON s.episode_id = e.id WHERE e.video_id = 'dlfC9v8siowrhA8'
);
DELETE FROM subtitles WHERE episode_id = (SELECT id FROM episodes WHERE video_id = 'dlfC9v8siowrhA8');
DELETE FROM episode_tags WHERE episode_id = (SELECT id FROM episodes WHERE video_id = 'dlfC9v8siowrhA8');

INSERT INTO episode_tags (episode_id, tag_id)
SELECT e.id, t.id FROM episodes e, tags t
WHERE e.video_id = 'dlfC9v8siowrhA8' AND t.name = '新闻'
ON CONFLICT DO NOTHING;
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 0, 10.88, 14.4, '>> I think we should go explore the city today.', '', '', '<span>>></span> <span>I</span> <span>think</span> <span>we</span> <span>should</span> <span>go</span> <span>explore</span> <span>the</span> <span>city</span> <span>today.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 1, 17.685, 19.705, '>>', '', '', '<span>>></span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 2, 25.28, 31.44, '>> What better way to get into the city than walking over the Brooklyn Bridge, baby?', '', '', '<span>>></span> <span>What</span> <span>better</span> <span>way</span> <span>to</span> <span>get</span> <span>into</span> <span>the</span> <span>city</span> <span>than</span> <span>walking</span> <span>over</span> <span>the</span> <span>Brooklyn</span> <span>Bridge,</span> <span>baby?</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 3, 40.52, 50.04, 'All right, first off is the original Russ & Daughters here in the Lower East Side. Unfortunate scaffolding, usually the neon is on and', '', '', '<span>All</span> <span>right,</span> <span>first</span> <span>off</span> <span>is</span> <span>the</span> <span>original</span> <span>Russ</span> <span>&</span> <span>Daughters</span> <span>here</span> <span>in</span> <span>the</span> <span>Lower</span> <span>East</span> <span>Side.</span> <span>Unfortunate</span> <span>scaffolding,</span> <span>usually</span> <span>the</span> <span>neon</span> <span>is</span> <span>on</span> <span>and</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 4, 46.84, 50.04, 'it looks really cool, but uh', '', '', '<span>it</span> <span>looks</span> <span>really</span> <span>cool,</span> <span>but</span> <span>uh</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 5, 51.09, 53.11, '>>', '', '', '<span>>></span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 6, 59.44, 62.224, '>> How are you?', '', '', '<span>>></span> <span>How</span> <span>are</span> <span>you?</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 7, 60.4, 67.44, 'Black and white cookie, babka, >> >> cinnamon, variety.', '', '', '<span>Black</span> <span>and</span> <span>white</span> <span>cookie,</span> <span>babka,</span> <span>>></span> <span>>></span> <span>cinnamon,</span> <span>variety.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 8, 65.84, 75.0, 'Hell yeah. All right, y''all, we made it out alive. A little chaotic, but this is Russ & Daughters, one of the kind of', '', '', '<span>Hell</span> <span>yeah.</span> <span>All</span> <span>right,</span> <span>y''all,</span> <span>we</span> <span>made</span> <span>it</span> <span>out</span> <span>alive.</span> <span>A</span> <span>little</span> <span>chaotic,</span> <span>but</span> <span>this</span> <span>is</span> <span>Russ</span> <span>&</span> <span>Daughters,</span> <span>one</span> <span>of</span> <span>the</span> <span>kind</span> <span>of</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 9, 72.48, 82.0, 'most classic New York spots. It''s a Jewish deli. It was founded in 1914 by a Polish immigrant.', '', '', '<span>most</span> <span>classic</span> <span>New</span> <span>York</span> <span>spots.</span> <span>It''s</span> <span>a</span> <span>Jewish</span> <span>deli.</span> <span>It</span> <span>was</span> <span>founded</span> <span>in</span> <span>1914</span> <span>by</span> <span>a</span> <span>Polish</span> <span>immigrant.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 10, 80.36, 88.48, 'Are our sweet treats first thing in the morning. His name was Joel Russ, and he actually started the business by a', '', '', '<span>Are</span> <span>our</span> <span>sweet</span> <span>treats</span> <span>first</span> <span>thing</span> <span>in</span> <span>the</span> <span>morning.</span> <span>His</span> <span>name</span> <span>was</span> <span>Joel</span> <span>Russ,</span> <span>and</span> <span>he</span> <span>actually</span> <span>started</span> <span>the</span> <span>business</span> <span>by</span> <span>a</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 11, 86.96, 93.64, 'pushing a pushcart full of herring fish on Orchard Street, right over here. So, 1914, that''s how long', '', '', '<span>pushing</span> <span>a</span> <span>pushcart</span> <span>full</span> <span>of</span> <span>herring</span> <span>fish</span> <span>on</span> <span>Orchard</span> <span>Street,</span> <span>right</span> <span>over</span> <span>here.</span> <span>So,</span> <span>1914,</span> <span>that''s</span> <span>how</span> <span>long</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 12, 92.04, 100.32, 'it''s been around. That''s the original location as well, right there on Houston. This is my roommate''s', '', '', '<span>it''s</span> <span>been</span> <span>around.</span> <span>That''s</span> <span>the</span> <span>original</span> <span>location</span> <span>as</span> <span>well,</span> <span>right</span> <span>there</span> <span>on</span> <span>Houston.</span> <span>This</span> <span>is</span> <span>my</span> <span>roommate''s</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 13, 98.0, 103.16, 'bagel.', '', '', '<span>bagel.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 14, 100.32, 103.16, 'Oh, baby.', '', '', '<span>Oh,</span> <span>baby.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 15, 103.28, 105.8, 'So good.', '', '', '<span>So</span> <span>good.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 16, 104.36, 110.696, 'Full of flavor. All right, y''all, real quick, not going to eat it all right now, but cinnamon babka.', '', '', '<span>Full</span> <span>of</span> <span>flavor.</span> <span>All</span> <span>right,</span> <span>y''all,</span> <span>real</span> <span>quick,</span> <span>not</span> <span>going</span> <span>to</span> <span>eat</span> <span>it</span> <span>all</span> <span>right</span> <span>now,</span> <span>but</span> <span>cinnamon</span> <span>babka.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 17, 109.2, 112.28, 'Got to taste it.', '', '', '<span>Got</span> <span>to</span> <span>taste</span> <span>it.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 18, 110.696, 121.6, '>> >> Oh, oh, baby. It''s like a moist brioche with cinnamon swirls, delicious.', '', '', '<span>>></span> <span>>></span> <span>Oh,</span> <span>oh,</span> <span>baby.</span> <span>It''s</span> <span>like</span> <span>a</span> <span>moist</span> <span>brioche</span> <span>with</span> <span>cinnamon</span> <span>swirls,</span> <span>delicious.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 19, 119.04, 125.761, 'Katz''s. You guys might think cuz this is a classic New York video that we''re going to go in there. Some of you might', '', '', '<span>Katz''s.</span> <span>You</span> <span>guys</span> <span>might</span> <span>think</span> <span>cuz</span> <span>this</span> <span>is</span> <span>a</span> <span>classic</span> <span>New</span> <span>York</span> <span>video</span> <span>that</span> <span>we''re</span> <span>going</span> <span>to</span> <span>go</span> <span>in</span> <span>there.</span> <span>Some</span> <span>of</span> <span>you</span> <span>might</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 20, 124.48, 127.6, 'remember, some of you might forget.', '', '', '<span>remember,</span> <span>some</span> <span>of</span> <span>you</span> <span>might</span> <span>forget.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 21, 125.761, 134.64, 'I''m not going in there until I hit 1 million subscribers. That''s the deal. Originally though, the plan was for me to go into Katz''s on my', '', '', '<span>I''m</span> <span>not</span> <span>going</span> <span>in</span> <span>there</span> <span>until</span> <span>I</span> <span>hit</span> <span>1</span> <span>million</span> <span>subscribers.</span> <span>That''s</span> <span>the</span> <span>deal.</span> <span>Originally</span> <span>though,</span> <span>the</span> <span>plan</span> <span>was</span> <span>for</span> <span>me</span> <span>to</span> <span>go</span> <span>into</span> <span>Katz''s</span> <span>on</span> <span>my</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 22, 133.0, 136.52, 'thousandth day of living in New York.', '', '', '<span>thousandth</span> <span>day</span> <span>of</span> <span>living</span> <span>in</span> <span>New</span> <span>York.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 23, 134.64, 137.76, 'That''s come and passed many years ago.', '', '', '<span>That''s</span> <span>come</span> <span>and</span> <span>passed</span> <span>many</span> <span>years</span> <span>ago.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 24, 137.551, 145.48, '>> >> And so now, the newer deadline is 1 million subscribers, but I still can tell you a little bit about it because', '', '', '<span>>></span> <span>>></span> <span>And</span> <span>so</span> <span>now,</span> <span>the</span> <span>newer</span> <span>deadline</span> <span>is</span> <span>1</span> <span>million</span> <span>subscribers,</span> <span>but</span> <span>I</span> <span>still</span> <span>can</span> <span>tell</span> <span>you</span> <span>a</span> <span>little</span> <span>bit</span> <span>about</span> <span>it</span> <span>because</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 25, 142.24, 151.64, 'it is so classic. So, sorry, maybe we get over there and then I don''t want to put you in harm''s way.', '', '', '<span>it</span> <span>is</span> <span>so</span> <span>classic.</span> <span>So,</span> <span>sorry,</span> <span>maybe</span> <span>we</span> <span>get</span> <span>over</span> <span>there</span> <span>and</span> <span>then</span> <span>I</span> <span>don''t</span> <span>want</span> <span>to</span> <span>put</span> <span>you</span> <span>in</span> <span>harm''s</span> <span>way.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 26, 149.96, 155.16, 'Lord almighty.', '', '', '<span>Lord</span> <span>almighty.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 27, 151.64, 163.04, 'Woo! Okay, it''s really windy, guys, and freezing, but you should know that Katz''s has been open since 1888.', '', '', '<span>Woo!</span> <span>Okay,</span> <span>it''s</span> <span>really</span> <span>windy,</span> <span>guys,</span> <span>and</span> <span>freezing,</span> <span>but</span> <span>you</span> <span>should</span> <span>know</span> <span>that</span> <span>Katz''s</span> <span>has</span> <span>been</span> <span>open</span> <span>since</span> <span>1888.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 28, 159.4, 168.96, 'Okay, apparently 1898. I don''t know what to believe. It has been here, it''s been a neighborhood staple of the Lower East', '', '', '<span>Okay,</span> <span>apparently</span> <span>1898.</span> <span>I</span> <span>don''t</span> <span>know</span> <span>what</span> <span>to</span> <span>believe.</span> <span>It</span> <span>has</span> <span>been</span> <span>here,</span> <span>it''s</span> <span>been</span> <span>a</span> <span>neighborhood</span> <span>staple</span> <span>of</span> <span>the</span> <span>Lower</span> <span>East</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 29, 166.04, 176.44, 'Side ever since then. It''s survived two world wars, it''s survived the crack epidemic absolutely hollowing out Lower', '', '', '<span>Side</span> <span>ever</span> <span>since</span> <span>then.</span> <span>It''s</span> <span>survived</span> <span>two</span> <span>world</span> <span>wars,</span> <span>it''s</span> <span>survived</span> <span>the</span> <span>crack</span> <span>epidemic</span> <span>absolutely</span> <span>hollowing</span> <span>out</span> <span>Lower</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 30, 173.4, 181.32, 'East Side in the ''80s, and a whole bunch more. I have never been, but what you might know about it, I''m walking', '', '', '<span>East</span> <span>Side</span> <span>in</span> <span>the</span> <span>''80s,</span> <span>and</span> <span>a</span> <span>whole</span> <span>bunch</span> <span>more.</span> <span>I</span> <span>have</span> <span>never</span> <span>been,</span> <span>but</span> <span>what</span> <span>you</span> <span>might</span> <span>know</span> <span>about</span> <span>it,</span> <span>I''m</span> <span>walking</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 31, 179.6, 186.96, 'backwards, it''s like a college tour. All right, what you might know about it is that really, really famous When Harry', '', '', '<span>backwards,</span> <span>it''s</span> <span>like</span> <span>a</span> <span>college</span> <span>tour.</span> <span>All</span> <span>right,</span> <span>what</span> <span>you</span> <span>might</span> <span>know</span> <span>about</span> <span>it</span> <span>is</span> <span>that</span> <span>really,</span> <span>really</span> <span>famous</span> <span>When</span> <span>Harry</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 32, 184.28, 193.24, 'Met Sally scene, you know, that one. Don''t ask me to imitate it, but I do know that the table where that', '', '', '<span>Met</span> <span>Sally</span> <span>scene,</span> <span>you</span> <span>know,</span> <span>that</span> <span>one.</span> <span>Don''t</span> <span>ask</span> <span>me</span> <span>to</span> <span>imitate</span> <span>it,</span> <span>but</span> <span>I</span> <span>do</span> <span>know</span> <span>that</span> <span>the</span> <span>table</span> <span>where</span> <span>that</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 33, 190.96, 196.36, 'happened inside of Katz''s is commemorated with a plaque of sorts.', '', '', '<span>happened</span> <span>inside</span> <span>of</span> <span>Katz''s</span> <span>is</span> <span>commemorated</span> <span>with</span> <span>a</span> <span>plaque</span> <span>of</span> <span>sorts.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 34, 194.84, 199.48, 'That''s what I read, I''ve never been in there.', '', '', '<span>That''s</span> <span>what</span> <span>I</span> <span>read,</span> <span>I''ve</span> <span>never</span> <span>been</span> <span>in</span> <span>there.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 35, 197.72, 200.359, 'Like and subscribe.', '', '', '<span>Like</span> <span>and</span> <span>subscribe.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 36, 199.48, 202.452, 'All right, let''s go to our next location.', '', '', '<span>All</span> <span>right,</span> <span>let''s</span> <span>go</span> <span>to</span> <span>our</span> <span>next</span> <span>location.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 37, 204.84, 214.48, 'All right, this little open-air thrift area in Lower East Side is where I bought this ring a few years ago, fun', '', '', '<span>All</span> <span>right,</span> <span>this</span> <span>little</span> <span>open-air</span> <span>thrift</span> <span>area</span> <span>in</span> <span>Lower</span> <span>East</span> <span>Side</span> <span>is</span> <span>where</span> <span>I</span> <span>bought</span> <span>this</span> <span>ring</span> <span>a</span> <span>few</span> <span>years</span> <span>ago,</span> <span>fun</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 38, 212.6, 218.92, 'fact. So, we''re on Ludlow Street in Lower East Side. I used to spend a lot of time down here cuz I lived in East', '', '', '<span>fact.</span> <span>So,</span> <span>we''re</span> <span>on</span> <span>Ludlow</span> <span>Street</span> <span>in</span> <span>Lower</span> <span>East</span> <span>Side.</span> <span>I</span> <span>used</span> <span>to</span> <span>spend</span> <span>a</span> <span>lot</span> <span>of</span> <span>time</span> <span>down</span> <span>here</span> <span>cuz</span> <span>I</span> <span>lived</span> <span>in</span> <span>East</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 39, 217.16, 224.679, 'Village. It''s a young area, for sure. A lot of people live here as one of their first spots after graduating from', '', '', '<span>Village.</span> <span>It''s</span> <span>a</span> <span>young</span> <span>area,</span> <span>for</span> <span>sure.</span> <span>A</span> <span>lot</span> <span>of</span> <span>people</span> <span>live</span> <span>here</span> <span>as</span> <span>one</span> <span>of</span> <span>their</span> <span>first</span> <span>spots</span> <span>after</span> <span>graduating</span> <span>from</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 40, 222.56, 231.24, 'college or in the years afterwards. So, so many bars, restaurants, salons. And like I said, there is like a grittiness', '', '', '<span>college</span> <span>or</span> <span>in</span> <span>the</span> <span>years</span> <span>afterwards.</span> <span>So,</span> <span>so</span> <span>many</span> <span>bars,</span> <span>restaurants,</span> <span>salons.</span> <span>And</span> <span>like</span> <span>I</span> <span>said,</span> <span>there</span> <span>is</span> <span>like</span> <span>a</span> <span>grittiness</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 41, 229.16, 236.68, 'to it, but there''s certainly a real level of gentrification, too, but it leaves behind this pretty cool mix of', '', '', '<span>to</span> <span>it,</span> <span>but</span> <span>there''s</span> <span>certainly</span> <span>a</span> <span>real</span> <span>level</span> <span>of</span> <span>gentrification,</span> <span>too,</span> <span>but</span> <span>it</span> <span>leaves</span> <span>behind</span> <span>this</span> <span>pretty</span> <span>cool</span> <span>mix</span> <span>of</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 42, 234.8, 243.08, 'things, I must say. Also, we''re not going there today because it''s not a place you can just casually go to, but', '', '', '<span>things,</span> <span>I</span> <span>must</span> <span>say.</span> <span>Also,</span> <span>we''re</span> <span>not</span> <span>going</span> <span>there</span> <span>today</span> <span>because</span> <span>it''s</span> <span>not</span> <span>a</span> <span>place</span> <span>you</span> <span>can</span> <span>just</span> <span>casually</span> <span>go</span> <span>to,</span> <span>but</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 43, 240.04, 250.08, 'Una Pizza Napoletana is right down here, and it''s been voted as the number one pizza spot in the entire freaking world', '', '', '<span>Una</span> <span>Pizza</span> <span>Napoletana</span> <span>is</span> <span>right</span> <span>down</span> <span>here,</span> <span>and</span> <span>it''s</span> <span>been</span> <span>voted</span> <span>as</span> <span>the</span> <span>number</span> <span>one</span> <span>pizza</span> <span>spot</span> <span>in</span> <span>the</span> <span>entire</span> <span>freaking</span> <span>world</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 44, 248.04, 254.04, 'for years in a row. And we went there one day last winter. It was absolutely freezing, kind of like today, but it was', '', '', '<span>for</span> <span>years</span> <span>in</span> <span>a</span> <span>row.</span> <span>And</span> <span>we</span> <span>went</span> <span>there</span> <span>one</span> <span>day</span> <span>last</span> <span>winter.</span> <span>It</span> <span>was</span> <span>absolutely</span> <span>freezing,</span> <span>kind</span> <span>of</span> <span>like</span> <span>today,</span> <span>but</span> <span>it</span> <span>was</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 45, 253.0, 258.0, 'a three-day weekend and we were like, you know what, we''re just going to stand in line cuz you cannot get a reservation', '', '', '<span>a</span> <span>three-day</span> <span>weekend</span> <span>and</span> <span>we</span> <span>were</span> <span>like,</span> <span>you</span> <span>know</span> <span>what,</span> <span>we''re</span> <span>just</span> <span>going</span> <span>to</span> <span>stand</span> <span>in</span> <span>line</span> <span>cuz</span> <span>you</span> <span>cannot</span> <span>get</span> <span>a</span> <span>reservation</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 46, 256.358, 263.32, 'at this place. Ended up waiting in line for a while, got to the front, and then they were like, "No spots now, but if', '', '', '<span>at</span> <span>this</span> <span>place.</span> <span>Ended</span> <span>up</span> <span>waiting</span> <span>in</span> <span>line</span> <span>for</span> <span>a</span> <span>while,</span> <span>got</span> <span>to</span> <span>the</span> <span>front,</span> <span>and</span> <span>then</span> <span>they</span> <span>were</span> <span>like,</span> <span>"No</span> <span>spots</span> <span>now,</span> <span>but</span> <span>if</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 47, 261.358, 268.04, 'you come back at 9:30 p.m., we can get you in." So, we had a beer, we just waited, we went, and it was the best', '', '', '<span>you</span> <span>come</span> <span>back</span> <span>at</span> <span>9:30</span> <span>p.m.,</span> <span>we</span> <span>can</span> <span>get</span> <span>you</span> <span>in."</span> <span>So,</span> <span>we</span> <span>had</span> <span>a</span> <span>beer,</span> <span>we</span> <span>just</span> <span>waited,</span> <span>we</span> <span>went,</span> <span>and</span> <span>it</span> <span>was</span> <span>the</span> <span>best</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 48, 266.2, 271.44, 'pizza I''ve ever had. Okay, let''s go to the next location. Start over here.', '', '', '<span>pizza</span> <span>I''ve</span> <span>ever</span> <span>had.</span> <span>Okay,</span> <span>let''s</span> <span>go</span> <span>to</span> <span>the</span> <span>next</span> <span>location.</span> <span>Start</span> <span>over</span> <span>here.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 49, 272.56, 278.64, 'Okay, guys, we are here at Economy Candy.', '', '', '<span>Okay,</span> <span>guys,</span> <span>we</span> <span>are</span> <span>here</span> <span>at</span> <span>Economy</span> <span>Candy.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 50, 280.998, 283.018, '>>', '', '', '<span>>></span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 51, 288.36, 297.12, '>> All right, guys, so this place, Economy Candy, was originally opened in 1937, originally as a hat and hosiery shop', '', '', '<span>>></span> <span>All</span> <span>right,</span> <span>guys,</span> <span>so</span> <span>this</span> <span>place,</span> <span>Economy</span> <span>Candy,</span> <span>was</span> <span>originally</span> <span>opened</span> <span>in</span> <span>1937,</span> <span>originally</span> <span>as</span> <span>a</span> <span>hat</span> <span>and</span> <span>hosiery</span> <span>shop</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 52, 295.92, 304.44, 'that sold candy on the side during the Depression. Pretty cool, it''s lasted all these years, and they have a ton of', '', '', '<span>that</span> <span>sold</span> <span>candy</span> <span>on</span> <span>the</span> <span>side</span> <span>during</span> <span>the</span> <span>Depression.</span> <span>Pretty</span> <span>cool,</span> <span>it''s</span> <span>lasted</span> <span>all</span> <span>these</span> <span>years,</span> <span>and</span> <span>they</span> <span>have</span> <span>a</span> <span>ton</span> <span>of</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 53, 301.56, 307.36, 'imported candies, nostalgic candies, jelly bellies.', '', '', '<span>imported</span> <span>candies,</span> <span>nostalgic</span> <span>candies,</span> <span>jelly</span> <span>bellies.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 54, 305.888, 316.92, '>> >> It''s the best flavor. My favorite flavor. Oh, sh- Oh, wait, hang on. Easy fix, easy fix. Easy fix.', '', '', '<span>>></span> <span>>></span> <span>It''s</span> <span>the</span> <span>best</span> <span>flavor.</span> <span>My</span> <span>favorite</span> <span>flavor.</span> <span>Oh,</span> <span>sh-</span> <span>Oh,</span> <span>wait,</span> <span>hang</span> <span>on.</span> <span>Easy</span> <span>fix,</span> <span>easy</span> <span>fix.</span> <span>Easy</span> <span>fix.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 55, 313.28, 316.919, 'No one saw a thing.', '', '', '<span>No</span> <span>one</span> <span>saw</span> <span>a</span> <span>thing.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 56, 318.333, 325.159, '>> >> Okay, I''m going to get some of those, and yeah, it''s like floor-to-ceiling, floor-to-ceiling windows,', '', '', '<span>>></span> <span>>></span> <span>Okay,</span> <span>I''m</span> <span>going</span> <span>to</span> <span>get</span> <span>some</span> <span>of</span> <span>those,</span> <span>and</span> <span>yeah,</span> <span>it''s</span> <span>like</span> <span>floor-to-ceiling,</span> <span>floor-to-ceiling</span> <span>windows,</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 57, 322.92, 326.72, 'floor-to-ceiling of all these different kinds of candies.', '', '', '<span>floor-to-ceiling</span> <span>of</span> <span>all</span> <span>these</span> <span>different</span> <span>kinds</span> <span>of</span> <span>candies.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 58, 326.72, 330.52, 'All right, I don''t want to drop a single one.', '', '', '<span>All</span> <span>right,</span> <span>I</span> <span>don''t</span> <span>want</span> <span>to</span> <span>drop</span> <span>a</span> <span>single</span> <span>one.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 59, 334.0, 341.258, 'Fun fact, I went to a lot of factories with my family when I was growing up, and the Jelly Belly Factory was my', '', '', '<span>Fun</span> <span>fact,</span> <span>I</span> <span>went</span> <span>to</span> <span>a</span> <span>lot</span> <span>of</span> <span>factories</span> <span>with</span> <span>my</span> <span>family</span> <span>when</span> <span>I</span> <span>was</span> <span>growing</span> <span>up,</span> <span>and</span> <span>the</span> <span>Jelly</span> <span>Belly</span> <span>Factory</span> <span>was</span> <span>my</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 60, 340.04, 343.278, 'favorite.', '', '', '<span>favorite.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 61, 341.258, 343.277, '>>', '', '', '<span>>></span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 62, 347.48, 354.8, '>> All right, guys, we are on our way to our next location up further into East Village, but as you might have seen, we', '', '', '<span>>></span> <span>All</span> <span>right,</span> <span>guys,</span> <span>we</span> <span>are</span> <span>on</span> <span>our</span> <span>way</span> <span>to</span> <span>our</span> <span>next</span> <span>location</span> <span>up</span> <span>further</span> <span>into</span> <span>East</span> <span>Village,</span> <span>but</span> <span>as</span> <span>you</span> <span>might</span> <span>have</span> <span>seen,</span> <span>we</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 63, 353.24, 362.4, 'absolutely chugged our coffee at Russ & Daughters, so we''re going to Essex Market for an emergency bathroom break. All right,', '', '', '<span>absolutely</span> <span>chugged</span> <span>our</span> <span>coffee</span> <span>at</span> <span>Russ</span> <span>&</span> <span>Daughters,</span> <span>so</span> <span>we''re</span> <span>going</span> <span>to</span> <span>Essex</span> <span>Market</span> <span>for</span> <span>an</span> <span>emergency</span> <span>bathroom</span> <span>break.</span> <span>All</span> <span>right,</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 64, 360.16, 366.8, 'guys, this is Essex Market. Wasn''t planned to be part of the video, but for the emergency bathroom break, thought it', '', '', '<span>guys,</span> <span>this</span> <span>is</span> <span>Essex</span> <span>Market.</span> <span>Wasn''t</span> <span>planned</span> <span>to</span> <span>be</span> <span>part</span> <span>of</span> <span>the</span> <span>video,</span> <span>but</span> <span>for</span> <span>the</span> <span>emergency</span> <span>bathroom</span> <span>break,</span> <span>thought</span> <span>it</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 65, 365.72, 372.72, 'was pretty cool. You got a lot of different restaurant stalls and little shops and grocery stores, and', '', '', '<span>was</span> <span>pretty</span> <span>cool.</span> <span>You</span> <span>got</span> <span>a</span> <span>lot</span> <span>of</span> <span>different</span> <span>restaurant</span> <span>stalls</span> <span>and</span> <span>little</span> <span>shops</span> <span>and</span> <span>grocery</span> <span>stores,</span> <span>and</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 66, 371.0, 376.4, 'some of it''s bougie, some of it''s not, but it''s pretty nice.', '', '', '<span>some</span> <span>of</span> <span>it''s</span> <span>bougie,</span> <span>some</span> <span>of</span> <span>it''s</span> <span>not,</span> <span>but</span> <span>it''s</span> <span>pretty</span> <span>nice.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 67, 374.48, 380.12, 'Back on track, we''re feeling good. We are back up here in East Village.', '', '', '<span>Back</span> <span>on</span> <span>track,</span> <span>we''re</span> <span>feeling</span> <span>good.</span> <span>We</span> <span>are</span> <span>back</span> <span>up</span> <span>here</span> <span>in</span> <span>East</span> <span>Village.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 68, 378.8, 386.159, 'It''s home sweet home, guys. Where I lived for years. We are here in Tompkins Square Park, and right behind us is', '', '', '<span>It''s</span> <span>home</span> <span>sweet</span> <span>home,</span> <span>guys.</span> <span>Where</span> <span>I</span> <span>lived</span> <span>for</span> <span>years.</span> <span>We</span> <span>are</span> <span>here</span> <span>in</span> <span>Tompkins</span> <span>Square</span> <span>Park,</span> <span>and</span> <span>right</span> <span>behind</span> <span>us</span> <span>is</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 69, 384.24, 393.88, 'Avenue A, which is where our next location is. But we are going to Ray''s Candy Store, where Anthony Bourdain also goes in his video. Pretty', '', '', '<span>Avenue</span> <span>A,</span> <span>which</span> <span>is</span> <span>where</span> <span>our</span> <span>next</span> <span>location</span> <span>is.</span> <span>But</span> <span>we</span> <span>are</span> <span>going</span> <span>to</span> <span>Ray''s</span> <span>Candy</span> <span>Store,</span> <span>where</span> <span>Anthony</span> <span>Bourdain</span> <span>also</span> <span>goes</span> <span>in</span> <span>his</span> <span>video.</span> <span>Pretty</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 70, 391.84, 399.56, 'cool. It was founded by a very, very awesome, cool guy named Ray Alvarez, which is the name he took when', '', '', '<span>cool.</span> <span>It</span> <span>was</span> <span>founded</span> <span>by</span> <span>a</span> <span>very,</span> <span>very</span> <span>awesome,</span> <span>cool</span> <span>guy</span> <span>named</span> <span>Ray</span> <span>Alvarez,</span> <span>which</span> <span>is</span> <span>the</span> <span>name</span> <span>he</span> <span>took</span> <span>when</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 71, 398.24, 406.88, 'he came to the US. So, he''s actually an Iranian immigrant. He was in the Iranian Navy, and this is crazy, I read this recently, but he', '', '', '<span>he</span> <span>came</span> <span>to</span> <span>the</span> <span>US.</span> <span>So,</span> <span>he''s</span> <span>actually</span> <span>an</span> <span>Iranian</span> <span>immigrant.</span> <span>He</span> <span>was</span> <span>in</span> <span>the</span> <span>Iranian</span> <span>Navy,</span> <span>and</span> <span>this</span> <span>is</span> <span>crazy,</span> <span>I</span> <span>read</span> <span>this</span> <span>recently,</span> <span>but</span> <span>he</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 72, 404.52, 413.36, 'jumped ship off of the Virginia coast, swam to shore, and then made it to the US with no money in his pocket,', '', '', '<span>jumped</span> <span>ship</span> <span>off</span> <span>of</span> <span>the</span> <span>Virginia</span> <span>coast,</span> <span>swam</span> <span>to</span> <span>shore,</span> <span>and</span> <span>then</span> <span>made</span> <span>it</span> <span>to</span> <span>the</span> <span>US</span> <span>with</span> <span>no</span> <span>money</span> <span>in</span> <span>his</span> <span>pocket,</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 73, 410.84, 418.08, 'came up to New York, worked 16-hour days as a busboy in different restaurants, opened up Ray''s Candy Store in', '', '', '<span>came</span> <span>up</span> <span>to</span> <span>New</span> <span>York,</span> <span>worked</span> <span>16-hour</span> <span>days</span> <span>as</span> <span>a</span> <span>busboy</span> <span>in</span> <span>different</span> <span>restaurants,</span> <span>opened</span> <span>up</span> <span>Ray''s</span> <span>Candy</span> <span>Store</span> <span>in</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 74, 416.56, 426.56, '1974 with, I believe it was $33,000 that he''d saved up over the years, opened this up, and it''s been open ever since', '', '', '<span>1974</span> <span>with,</span> <span>I</span> <span>believe</span> <span>it</span> <span>was</span> <span>$33,000</span> <span>that</span> <span>he''d</span> <span>saved</span> <span>up</span> <span>over</span> <span>the</span> <span>years,</span> <span>opened</span> <span>this</span> <span>up,</span> <span>and</span> <span>it''s</span> <span>been</span> <span>open</span> <span>ever</span> <span>since</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 75, 424.0, 431.6, 'then. He is now 93 years old. Also, Ray''s almost closed down a couple times, once during the recession and', '', '', '<span>then.</span> <span>He</span> <span>is</span> <span>now</span> <span>93</span> <span>years</span> <span>old.</span> <span>Also,</span> <span>Ray''s</span> <span>almost</span> <span>closed</span> <span>down</span> <span>a</span> <span>couple</span> <span>times,</span> <span>once</span> <span>during</span> <span>the</span> <span>recession</span> <span>and</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 76, 430.16, 437.2, 'during COVID, and the East Village community came together through a Kickstarter and fundraisers and all that', '', '', '<span>during</span> <span>COVID,</span> <span>and</span> <span>the</span> <span>East</span> <span>Village</span> <span>community</span> <span>came</span> <span>together</span> <span>through</span> <span>a</span> <span>Kickstarter</span> <span>and</span> <span>fundraisers</span> <span>and</span> <span>all</span> <span>that</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 77, 435.16, 438.56, 'and saved Ray''s several times.', '', '', '<span>and</span> <span>saved</span> <span>Ray''s</span> <span>several</span> <span>times.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 78, 437.2, 443.44, 'So, the community absolutely loves Ray''s. Everyone knows who he is. I hope he''s in there. Let''s go see.', '', '', '<span>So,</span> <span>the</span> <span>community</span> <span>absolutely</span> <span>loves</span> <span>Ray''s.</span> <span>Everyone</span> <span>knows</span> <span>who</span> <span>he</span> <span>is.</span> <span>I</span> <span>hope</span> <span>he''s</span> <span>in</span> <span>there.</span> <span>Let''s</span> <span>go</span> <span>see.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 79, 443.48, 449.39, 'Hi, Ray. How are you? I''m so glad you''re here.', '', '', '<span>Hi,</span> <span>Ray.</span> <span>How</span> <span>are</span> <span>you?</span> <span>I''m</span> <span>so</span> <span>glad</span> <span>you''re</span> <span>here.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 80, 447.37, 449.39, '>>', '', '', '<span>>></span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 81, 458.04, 460.24, '>> This is Ray.', '', '', '<span>>></span> <span>This</span> <span>is</span> <span>Ray.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 82, 459.815, 463.32, '>> >> This is Ray.', '', '', '<span>>></span> <span>>></span> <span>This</span> <span>is</span> <span>Ray.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 83, 463.96, 471.48, 'Thank you, Ray. Thank you so much. I know you''ve been here in New York for a long time, and I know a little', '', '', '<span>Thank</span> <span>you,</span> <span>Ray.</span> <span>Thank</span> <span>you</span> <span>so</span> <span>much.</span> <span>I</span> <span>know</span> <span>you''ve</span> <span>been</span> <span>here</span> <span>in</span> <span>New</span> <span>York</span> <span>for</span> <span>a</span> <span>long</span> <span>time,</span> <span>and</span> <span>I</span> <span>know</span> <span>a</span> <span>little</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 84, 469.64, 477.56, 'bit about your story getting here. I wanted to ask what your favorite part about being in New York has been over', '', '', '<span>bit</span> <span>about</span> <span>your</span> <span>story</span> <span>getting</span> <span>here.</span> <span>I</span> <span>wanted</span> <span>to</span> <span>ask</span> <span>what</span> <span>your</span> <span>favorite</span> <span>part</span> <span>about</span> <span>being</span> <span>in</span> <span>New</span> <span>York</span> <span>has</span> <span>been</span> <span>over</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 85, 474.68, 482.92, 'the years. Oh, I love New York. New York is a international city. Absolutely.', '', '', '<span>the</span> <span>years.</span> <span>Oh,</span> <span>I</span> <span>love</span> <span>New</span> <span>York.</span> <span>New</span> <span>York</span> <span>is</span> <span>a</span> <span>international</span> <span>city.</span> <span>Absolutely.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 86, 480.64, 485.159, 'Everybody speaking different language.', '', '', '<span>Everybody</span> <span>speaking</span> <span>different</span> <span>language.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 87, 482.92, 487.08, 'Yep. And we all get along very well.', '', '', '<span>Yep.</span> <span>And</span> <span>we</span> <span>all</span> <span>get</span> <span>along</span> <span>very</span> <span>well.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 88, 485.16, 491.12, 'It''s the best community.', '', '', '<span>It''s</span> <span>the</span> <span>best</span> <span>community.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 89, 487.08, 504.2, 'And the job available for everybody. And they hire you. I have one of them hired black, Jewish, Arab, Hindu. We have no bad feeling', '', '', '<span>And</span> <span>the</span> <span>job</span> <span>available</span> <span>for</span> <span>everybody.</span> <span>And</span> <span>they</span> <span>hire</span> <span>you.</span> <span>I</span> <span>have</span> <span>one</span> <span>of</span> <span>them</span> <span>hired</span> <span>black,</span> <span>Jewish,</span> <span>Arab,</span> <span>Hindu.</span> <span>We</span> <span>have</span> <span>no</span> <span>bad</span> <span>feeling</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 90, 502.08, 507.44, 'about anything. Right. That''s one of my favorite parts, too.', '', '', '<span>about</span> <span>anything.</span> <span>Right.</span> <span>That''s</span> <span>one</span> <span>of</span> <span>my</span> <span>favorite</span> <span>parts,</span> <span>too.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 91, 505.16, 511.6, '>> Yeah, New York is very special. Well, you''re such a staple in the community.', '', '', '<span>>></span> <span>Yeah,</span> <span>New</span> <span>York</span> <span>is</span> <span>very</span> <span>special.</span> <span>Well,</span> <span>you''re</span> <span>such</span> <span>a</span> <span>staple</span> <span>in</span> <span>the</span> <span>community.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 92, 509.2, 516.08, 'Everyone here loves coming to see you, and The community is good.', '', '', '<span>Everyone</span> <span>here</span> <span>loves</span> <span>coming</span> <span>to</span> <span>see</span> <span>you,</span> <span>and</span> <span>The</span> <span>community</span> <span>is</span> <span>good.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 93, 513.52, 517.76, '>> It is. Yeah, they help me a lot.', '', '', '<span>>></span> <span>It</span> <span>is.</span> <span>Yeah,</span> <span>they</span> <span>help</span> <span>me</span> <span>a</span> <span>lot.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 94, 516.08, 522.719, '>> Well, thank you, Ray. I''ve I''ve loved coming here over the years, and >> Oh, yeah. I love your story.', '', '', '<span>>></span> <span>Well,</span> <span>thank</span> <span>you,</span> <span>Ray.</span> <span>I''ve</span> <span>I''ve</span> <span>loved</span> <span>coming</span> <span>here</span> <span>over</span> <span>the</span> <span>years,</span> <span>and</span> <span>>></span> <span>Oh,</span> <span>yeah.</span> <span>I</span> <span>love</span> <span>your</span> <span>story.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 95, 523.35, 528.0, '>> >> Well, I couldn''t have been more perfect.', '', '', '<span>>></span> <span>>></span> <span>Well,</span> <span>I</span> <span>couldn''t</span> <span>have</span> <span>been</span> <span>more</span> <span>perfect.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 96, 526.36, 532.4, 'Ray was there. He''s not always, cuz sometimes at nighttime he''s a little sleepy, but during the day it', '', '', '<span>Ray</span> <span>was</span> <span>there.</span> <span>He''s</span> <span>not</span> <span>always,</span> <span>cuz</span> <span>sometimes</span> <span>at</span> <span>nighttime</span> <span>he''s</span> <span>a</span> <span>little</span> <span>sleepy,</span> <span>but</span> <span>during</span> <span>the</span> <span>day</span> <span>it</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 97, 530.44, 535.599, 'sounds like he''s up and working at his age, which is crazy. Got a vanilla egg cream.', '', '', '<span>sounds</span> <span>like</span> <span>he''s</span> <span>up</span> <span>and</span> <span>working</span> <span>at</span> <span>his</span> <span>age,</span> <span>which</span> <span>is</span> <span>crazy.</span> <span>Got</span> <span>a</span> <span>vanilla</span> <span>egg</span> <span>cream.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 98, 535.141, 542.72, '>> >> First Not first reaction, I''ve had a bunch of them before, but it''s so good. I''ve had it like chocolate', '', '', '<span>>></span> <span>>></span> <span>First</span> <span>Not</span> <span>first</span> <span>reaction,</span> <span>I''ve</span> <span>had</span> <span>a</span> <span>bunch</span> <span>of</span> <span>them</span> <span>before,</span> <span>but</span> <span>it''s</span> <span>so</span> <span>good.</span> <span>I''ve</span> <span>had</span> <span>it</span> <span>like</span> <span>chocolate</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 99, 541.76, 548.36, 'one before, and I didn''t love it as much, but vanilla is delicious. It''s like a vanilla milk with a little', '', '', '<span>one</span> <span>before,</span> <span>and</span> <span>I</span> <span>didn''t</span> <span>love</span> <span>it</span> <span>as</span> <span>much,</span> <span>but</span> <span>vanilla</span> <span>is</span> <span>delicious.</span> <span>It''s</span> <span>like</span> <span>a</span> <span>vanilla</span> <span>milk</span> <span>with</span> <span>a</span> <span>little</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 100, 546.2, 553.24, 'carbonation surprise. That''s the best way to describe it. Excellent. Should we go to our next location?', '', '', '<span>carbonation</span> <span>surprise.</span> <span>That''s</span> <span>the</span> <span>best</span> <span>way</span> <span>to</span> <span>describe</span> <span>it.</span> <span>Excellent.</span> <span>Should</span> <span>we</span> <span>go</span> <span>to</span> <span>our</span> <span>next</span> <span>location?</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 101, 552.0, 560.6, 'Let''s do it. All right, on our way to the next place, but guys, you might recall Hanoi House, absolute Village staple', '', '', '<span>Let''s</span> <span>do</span> <span>it.</span> <span>All</span> <span>right,</span> <span>on</span> <span>our</span> <span>way</span> <span>to</span> <span>the</span> <span>next</span> <span>place,</span> <span>but</span> <span>guys,</span> <span>you</span> <span>might</span> <span>recall</span> <span>Hanoi</span> <span>House,</span> <span>absolute</span> <span>Village</span> <span>staple</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 102, 558.96, 565.8, 'when I lived here. Would go there all the time, really, really great Vietnamese, but I''m excited to show you', '', '', '<span>when</span> <span>I</span> <span>lived</span> <span>here.</span> <span>Would</span> <span>go</span> <span>there</span> <span>all</span> <span>the</span> <span>time,</span> <span>really,</span> <span>really</span> <span>great</span> <span>Vietnamese,</span> <span>but</span> <span>I''m</span> <span>excited</span> <span>to</span> <span>show</span> <span>you</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 103, 563.92, 570.76, 'the next spot. It''s also a classic staple. I haven''t been as many times, but it''s good. But we''re here on', '', '', '<span>the</span> <span>next</span> <span>spot.</span> <span>It''s</span> <span>also</span> <span>a</span> <span>classic</span> <span>staple.</span> <span>I</span> <span>haven''t</span> <span>been</span> <span>as</span> <span>many</span> <span>times,</span> <span>but</span> <span>it''s</span> <span>good.</span> <span>But</span> <span>we''re</span> <span>here</span> <span>on</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 104, 568.8, 577.12, 'St. Mark''s, which is sort of the birthplace, at least in New York, of the punk rock scene. I read Just Kids by', '', '', '<span>St.</span> <span>Mark''s,</span> <span>which</span> <span>is</span> <span>sort</span> <span>of</span> <span>the</span> <span>birthplace,</span> <span>at</span> <span>least</span> <span>in</span> <span>New</span> <span>York,</span> <span>of</span> <span>the</span> <span>punk</span> <span>rock</span> <span>scene.</span> <span>I</span> <span>read</span> <span>Just</span> <span>Kids</span> <span>by</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 105, 575.12, 582.12, 'Patti Smith, and St. Mark''s has come up time and time again with that scene, and yeah, the underground', '', '', '<span>Patti</span> <span>Smith,</span> <span>and</span> <span>St.</span> <span>Mark''s</span> <span>has</span> <span>come</span> <span>up</span> <span>time</span> <span>and</span> <span>time</span> <span>again</span> <span>with</span> <span>that</span> <span>scene,</span> <span>and</span> <span>yeah,</span> <span>the</span> <span>underground</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 106, 580.28, 587.0, 'concerts that would happen and such. So, pretty cool. You can still see some of the punk influence a little bit', '', '', '<span>concerts</span> <span>that</span> <span>would</span> <span>happen</span> <span>and</span> <span>such.</span> <span>So,</span> <span>pretty</span> <span>cool.</span> <span>You</span> <span>can</span> <span>still</span> <span>see</span> <span>some</span> <span>of</span> <span>the</span> <span>punk</span> <span>influence</span> <span>a</span> <span>little</span> <span>bit</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 107, 585.44, 592.52, 'further down. I always like walking on St. Mark''s. And then in the summer, oh my god, it comes out. They close down', '', '', '<span>further</span> <span>down.</span> <span>I</span> <span>always</span> <span>like</span> <span>walking</span> <span>on</span> <span>St.</span> <span>Mark''s.</span> <span>And</span> <span>then</span> <span>in</span> <span>the</span> <span>summer,</span> <span>oh</span> <span>my</span> <span>god,</span> <span>it</span> <span>comes</span> <span>out.</span> <span>They</span> <span>close</span> <span>down</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 108, 590.56, 598.6, 'the driving and just put seats out on the street, and people stay out drinking all night long on the street. Also,', '', '', '<span>the</span> <span>driving</span> <span>and</span> <span>just</span> <span>put</span> <span>seats</span> <span>out</span> <span>on</span> <span>the</span> <span>street,</span> <span>and</span> <span>people</span> <span>stay</span> <span>out</span> <span>drinking</span> <span>all</span> <span>night</span> <span>long</span> <span>on</span> <span>the</span> <span>street.</span> <span>Also,</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 109, 596.72, 603.4, 'huh? I don''t know how many videos I''ve shown that in at this point, but it''s worth pointing out.', '', '', '<span>huh?</span> <span>I</span> <span>don''t</span> <span>know</span> <span>how</span> <span>many</span> <span>videos</span> <span>I''ve</span> <span>shown</span> <span>that</span> <span>in</span> <span>at</span> <span>this</span> <span>point,</span> <span>but</span> <span>it''s</span> <span>worth</span> <span>pointing</span> <span>out.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 110, 610.28, 615.4, 'All right, guys. We just got our food, but I''ll tell you where we are.', '', '', '<span>All</span> <span>right,</span> <span>guys.</span> <span>We</span> <span>just</span> <span>got</span> <span>our</span> <span>food,</span> <span>but</span> <span>I''ll</span> <span>tell</span> <span>you</span> <span>where</span> <span>we</span> <span>are.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 111, 613.24, 623.8, 'So, we''re here at Veselka, which is a classic Ukrainian diner. It''s been open since 1954. Originally was a candy and', '', '', '<span>So,</span> <span>we''re</span> <span>here</span> <span>at</span> <span>Veselka,</span> <span>which</span> <span>is</span> <span>a</span> <span>classic</span> <span>Ukrainian</span> <span>diner.</span> <span>It''s</span> <span>been</span> <span>open</span> <span>since</span> <span>1954.</span> <span>Originally</span> <span>was</span> <span>a</span> <span>candy</span> <span>and</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 112, 621.8, 627.199, 'newsstand spot right here, same location on 2nd Ave.', '', '', '<span>newsstand</span> <span>spot</span> <span>right</span> <span>here,</span> <span>same</span> <span>location</span> <span>on</span> <span>2nd</span> <span>Ave.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 113, 625.64, 631.56, 'And here''s what we got. It''s a regular blintz with some raspberry cream on the side. We got some potato pierogies.', '', '', '<span>And</span> <span>here''s</span> <span>what</span> <span>we</span> <span>got.</span> <span>It''s</span> <span>a</span> <span>regular</span> <span>blintz</span> <span>with</span> <span>some</span> <span>raspberry</span> <span>cream</span> <span>on</span> <span>the</span> <span>side.</span> <span>We</span> <span>got</span> <span>some</span> <span>potato</span> <span>pierogies.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 114, 631.56, 640.0, 'We got some more coffee. For the most part, keeping it light cuz we''ve already had some meals as you''ve seen, and we', '', '', '<span>We</span> <span>got</span> <span>some</span> <span>more</span> <span>coffee.</span> <span>For</span> <span>the</span> <span>most</span> <span>part,</span> <span>keeping</span> <span>it</span> <span>light</span> <span>cuz</span> <span>we''ve</span> <span>already</span> <span>had</span> <span>some</span> <span>meals</span> <span>as</span> <span>you''ve</span> <span>seen,</span> <span>and</span> <span>we</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 115, 637.88, 646.439, 'have a couple more ahead of us. Lots of cool murals, Ukrainian regalia in general. I do know at the beginning of', '', '', '<span>have</span> <span>a</span> <span>couple</span> <span>more</span> <span>ahead</span> <span>of</span> <span>us.</span> <span>Lots</span> <span>of</span> <span>cool</span> <span>murals,</span> <span>Ukrainian</span> <span>regalia</span> <span>in</span> <span>general.</span> <span>I</span> <span>do</span> <span>know</span> <span>at</span> <span>the</span> <span>beginning</span> <span>of</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 116, 644.76, 649.16, 'the Russia-Ukraine war, there was some kind of like Ukraine special. Oh, here we go.', '', '', '<span>the</span> <span>Russia-Ukraine</span> <span>war,</span> <span>there</span> <span>was</span> <span>some</span> <span>kind</span> <span>of</span> <span>like</span> <span>Ukraine</span> <span>special.</span> <span>Oh,</span> <span>here</span> <span>we</span> <span>go.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 117, 649.112, 657.92, '>> >> Nice stand with Ukraine bowl. A portion of the proceeds will be donated to Ukrainian relief. So, I know they bought', '', '', '<span>>></span> <span>>></span> <span>Nice</span> <span>stand</span> <span>with</span> <span>Ukraine</span> <span>bowl.</span> <span>A</span> <span>portion</span> <span>of</span> <span>the</span> <span>proceeds</span> <span>will</span> <span>be</span> <span>donated</span> <span>to</span> <span>Ukrainian</span> <span>relief.</span> <span>So,</span> <span>I</span> <span>know</span> <span>they</span> <span>bought</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 118, 655.08, 660.959, 'this since what, 2022? All right, real quick.', '', '', '<span>this</span> <span>since</span> <span>what,</span> <span>2022?</span> <span>All</span> <span>right,</span> <span>real</span> <span>quick.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 119, 658.92, 662.28, 'And then I can let my roommate eat also.', '', '', '<span>And</span> <span>then</span> <span>I</span> <span>can</span> <span>let</span> <span>my</span> <span>roommate</span> <span>eat</span> <span>also.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 120, 660.96, 668.439, 'So, it''s kind of like a slightly sweetened ricotta on the inside, right? I''ve only had a couple of blintzes in my life, but I', '', '', '<span>So,</span> <span>it''s</span> <span>kind</span> <span>of</span> <span>like</span> <span>a</span> <span>slightly</span> <span>sweetened</span> <span>ricotta</span> <span>on</span> <span>the</span> <span>inside,</span> <span>right?</span> <span>I''ve</span> <span>only</span> <span>had</span> <span>a</span> <span>couple</span> <span>of</span> <span>blintzes</span> <span>in</span> <span>my</span> <span>life,</span> <span>but</span> <span>I</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 121, 666.52, 676.022, 'know I want to put some raspberries, some compote on it. It''s good.', '', '', '<span>know</span> <span>I</span> <span>want</span> <span>to</span> <span>put</span> <span>some</span> <span>raspberries,</span> <span>some</span> <span>compote</span> <span>on</span> <span>it.</span> <span>It''s</span> <span>good.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 122, 674.002, 679.6, '>> >> All right, just finished in Veselka.', '', '', '<span>>></span> <span>>></span> <span>All</span> <span>right,</span> <span>just</span> <span>finished</span> <span>in</span> <span>Veselka.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 123, 677.72, 684.719, 'Heading to the next location, but did want to mention that this part of East Village is referred to as Little', '', '', '<span>Heading</span> <span>to</span> <span>the</span> <span>next</span> <span>location,</span> <span>but</span> <span>did</span> <span>want</span> <span>to</span> <span>mention</span> <span>that</span> <span>this</span> <span>part</span> <span>of</span> <span>East</span> <span>Village</span> <span>is</span> <span>referred</span> <span>to</span> <span>as</span> <span>Little</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 124, 683.12, 691.839, 'Ukraine. So, there''s a lot of other Ukrainian establishments around. In fact, we had one day last winter where', '', '', '<span>Ukraine.</span> <span>So,</span> <span>there''s</span> <span>a</span> <span>lot</span> <span>of</span> <span>other</span> <span>Ukrainian</span> <span>establishments</span> <span>around.</span> <span>In</span> <span>fact,</span> <span>we</span> <span>had</span> <span>one</span> <span>day</span> <span>last</span> <span>winter</span> <span>where</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 125, 689.52, 699.12, 'we just had a random kind of Eastern European themed day. So, we started at the Russian Turkish back bathhouses on', '', '', '<span>we</span> <span>just</span> <span>had</span> <span>a</span> <span>random</span> <span>kind</span> <span>of</span> <span>Eastern</span> <span>European</span> <span>themed</span> <span>day.</span> <span>So,</span> <span>we</span> <span>started</span> <span>at</span> <span>the</span> <span>Russian</span> <span>Turkish</span> <span>back</span> <span>bathhouses</span> <span>on</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 126, 696.839, 705.6, 'this street, went to Veselka afterwards, and then later in the evening came to this Ukrainian like hole-in-the-wall', '', '', '<span>this</span> <span>street,</span> <span>went</span> <span>to</span> <span>Veselka</span> <span>afterwards,</span> <span>and</span> <span>then</span> <span>later</span> <span>in</span> <span>the</span> <span>evening</span> <span>came</span> <span>to</span> <span>this</span> <span>Ukrainian</span> <span>like</span> <span>hole-in-the-wall</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 127, 703.72, 712.08, 'Ukrainian bar and took two shots of Ukrainian vodka, and it was awesome. Two shots of vodka?', '', '', '<span>Ukrainian</span> <span>bar</span> <span>and</span> <span>took</span> <span>two</span> <span>shots</span> <span>of</span> <span>Ukrainian</span> <span>vodka,</span> <span>and</span> <span>it</span> <span>was</span> <span>awesome.</span> <span>Two</span> <span>shots</span> <span>of</span> <span>vodka?</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 128, 714.2, 720.839, 'Anyways, on to the next location. It''s a fun one, and it''s not food. I know you guys think we''re just eating all day,', '', '', '<span>Anyways,</span> <span>on</span> <span>to</span> <span>the</span> <span>next</span> <span>location.</span> <span>It''s</span> <span>a</span> <span>fun</span> <span>one,</span> <span>and</span> <span>it''s</span> <span>not</span> <span>food.</span> <span>I</span> <span>know</span> <span>you</span> <span>guys</span> <span>think</span> <span>we''re</span> <span>just</span> <span>eating</span> <span>all</span> <span>day,</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 129, 719.24, 727.32, 'which we mainly are, but right now we''re going to a non-edible establishment.', '', '', '<span>which</span> <span>we</span> <span>mainly</span> <span>are,</span> <span>but</span> <span>right</span> <span>now</span> <span>we''re</span> <span>going</span> <span>to</span> <span>a</span> <span>non-edible</span> <span>establishment.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 130, 723.52, 727.319, 'It''s for the intellectuals, so.', '', '', '<span>It''s</span> <span>for</span> <span>the</span> <span>intellectuals,</span> <span>so.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 131, 727.713, 729.733, '>>', '', '', '<span>>></span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 132, 730.76, 737.92, '>> All right, guys. We made it to the Strand Bookstore.', '', '', '<span>>></span> <span>All</span> <span>right,</span> <span>guys.</span> <span>We</span> <span>made</span> <span>it</span> <span>to</span> <span>the</span> <span>Strand</span> <span>Bookstore.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 133, 735.8, 747.56, 'Woo! Woo! Woo! Absolute New York City staple. This is one of 48 original used bookstores on 4th Ave, which is kind of', '', '', '<span>Woo!</span> <span>Woo!</span> <span>Woo!</span> <span>Absolute</span> <span>New</span> <span>York</span> <span>City</span> <span>staple.</span> <span>This</span> <span>is</span> <span>one</span> <span>of</span> <span>48</span> <span>original</span> <span>used</span> <span>bookstores</span> <span>on</span> <span>4th</span> <span>Ave,</span> <span>which</span> <span>is</span> <span>kind</span> <span>of</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 134, 745.44, 753.6, 'seen as or at one point was the used bookstore row. This is the last one standing. It''s been open since 1927.', '', '', '<span>seen</span> <span>as</span> <span>or</span> <span>at</span> <span>one</span> <span>point</span> <span>was</span> <span>the</span> <span>used</span> <span>bookstore</span> <span>row.</span> <span>This</span> <span>is</span> <span>the</span> <span>last</span> <span>one</span> <span>standing.</span> <span>It''s</span> <span>been</span> <span>open</span> <span>since</span> <span>1927.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 135, 752.12, 760.463, 'Pretty crazy. And real quick, before we go in, I want to show you something. All of these $3 apparently. I thought they', '', '', '<span>Pretty</span> <span>crazy.</span> <span>And</span> <span>real</span> <span>quick,</span> <span>before</span> <span>we</span> <span>go</span> <span>in,</span> <span>I</span> <span>want</span> <span>to</span> <span>show</span> <span>you</span> <span>something.</span> <span>All</span> <span>of</span> <span>these</span> <span>$3</span> <span>apparently.</span> <span>I</span> <span>thought</span> <span>they</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 136, 758.2, 760.68, 'were like $1, but still great price.', '', '', '<span>were</span> <span>like</span> <span>$1,</span> <span>but</span> <span>still</span> <span>great</span> <span>price.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 137, 760.463, 768.36, '>> >> Book stands right out on East 12th Street. Pretty cool. There''s so many of them, too. This actually starts to make', '', '', '<span>>></span> <span>>></span> <span>Book</span> <span>stands</span> <span>right</span> <span>out</span> <span>on</span> <span>East</span> <span>12th</span> <span>Street.</span> <span>Pretty</span> <span>cool.</span> <span>There''s</span> <span>so</span> <span>many</span> <span>of</span> <span>them,</span> <span>too.</span> <span>This</span> <span>actually</span> <span>starts</span> <span>to</span> <span>make</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 138, 766.2, 774.0, 'sense as to how they can claim that they have 18 miles of books on the inside.', '', '', '<span>sense</span> <span>as</span> <span>to</span> <span>how</span> <span>they</span> <span>can</span> <span>claim</span> <span>that</span> <span>they</span> <span>have</span> <span>18</span> <span>miles</span> <span>of</span> <span>books</span> <span>on</span> <span>the</span> <span>inside.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 139, 771.72, 780.113, 'So, all of the rows added together. They have a sign right here, 18 miles. And almost their 100-year anniversary. All', '', '', '<span>So,</span> <span>all</span> <span>of</span> <span>the</span> <span>rows</span> <span>added</span> <span>together.</span> <span>They</span> <span>have</span> <span>a</span> <span>sign</span> <span>right</span> <span>here,</span> <span>18</span> <span>miles.</span> <span>And</span> <span>almost</span> <span>their</span> <span>100-year</span> <span>anniversary.</span> <span>All</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 140, 777.8, 782.132, 'right, let''s go in.', '', '', '<span>right,</span> <span>let''s</span> <span>go</span> <span>in.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 141, 780.113, 782.133, '>>', '', '', '<span>>></span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 142, 786.08, 793.32, '>> Just came to the Strand Bookstore, ran into the sweetest subscribers in the world. Do you guys want to say hi? Uh,', '', '', '<span>>></span> <span>Just</span> <span>came</span> <span>to</span> <span>the</span> <span>Strand</span> <span>Bookstore,</span> <span>ran</span> <span>into</span> <span>the</span> <span>sweetest</span> <span>subscribers</span> <span>in</span> <span>the</span> <span>world.</span> <span>Do</span> <span>you</span> <span>guys</span> <span>want</span> <span>to</span> <span>say</span> <span>hi?</span> <span>Uh,</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 143, 791.28, 801.56, 'my name is Danny. Hi, originally from Colombia. My name is Duri. I have YouTube channel here in New York.', '', '', '<span>my</span> <span>name</span> <span>is</span> <span>Danny.</span> <span>Hi,</span> <span>originally</span> <span>from</span> <span>Colombia.</span> <span>My</span> <span>name</span> <span>is</span> <span>Duri.</span> <span>I</span> <span>have</span> <span>YouTube</span> <span>channel</span> <span>here</span> <span>in</span> <span>New</span> <span>York.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 144, 798.48, 803.32, 'Subscribe my YouTube channel.', '', '', '<span>Subscribe</span> <span>my</span> <span>YouTube</span> <span>channel.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 145, 801.56, 807.024, 'Link down below. Oh, it was so nice meeting you guys. Thank you for saying hi.', '', '', '<span>Link</span> <span>down</span> <span>below.</span> <span>Oh,</span> <span>it</span> <span>was</span> <span>so</span> <span>nice</span> <span>meeting</span> <span>you</span> <span>guys.</span> <span>Thank</span> <span>you</span> <span>for</span> <span>saying</span> <span>hi.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 146, 808.08, 814.72, 'All right, my roommate and I split up to find our respective books, and I thought I would show you some of my recent', '', '', '<span>All</span> <span>right,</span> <span>my</span> <span>roommate</span> <span>and</span> <span>I</span> <span>split</span> <span>up</span> <span>to</span> <span>find</span> <span>our</span> <span>respective</span> <span>books,</span> <span>and</span> <span>I</span> <span>thought</span> <span>I</span> <span>would</span> <span>show</span> <span>you</span> <span>some</span> <span>of</span> <span>my</span> <span>recent</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 147, 813.32, 821.12, 'absolute favorites that I could not recommend higher. Pachinko over there.', '', '', '<span>absolute</span> <span>favorites</span> <span>that</span> <span>I</span> <span>could</span> <span>not</span> <span>recommend</span> <span>higher.</span> <span>Pachinko</span> <span>over</span> <span>there.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 148, 818.04, 827.0, 'My third to last read, I believe. Epic multigenerational family tale. Learned a lot about Korean Japanese history in the', '', '', '<span>My</span> <span>third</span> <span>to</span> <span>last</span> <span>read,</span> <span>I</span> <span>believe.</span> <span>Epic</span> <span>multigenerational</span> <span>family</span> <span>tale.</span> <span>Learned</span> <span>a</span> <span>lot</span> <span>about</span> <span>Korean</span> <span>Japanese</span> <span>history</span> <span>in</span> <span>the</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 149, 825.4, 831.72, '20th century. Highly recommend, especially if you like reading books that span decades and decades. Here''s', '', '', '<span>20th</span> <span>century.</span> <span>Highly</span> <span>recommend,</span> <span>especially</span> <span>if</span> <span>you</span> <span>like</span> <span>reading</span> <span>books</span> <span>that</span> <span>span</span> <span>decades</span> <span>and</span> <span>decades.</span> <span>Here''s</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 150, 830.2, 834.2, 'another one. Actually, two more here.', '', '', '<span>another</span> <span>one.</span> <span>Actually,</span> <span>two</span> <span>more</span> <span>here.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 151, 831.72, 840.839, 'Just Kids and most importantly, East of Eden by John Steinbeck. It''s a thick boy, but worth every single second. Just', '', '', '<span>Just</span> <span>Kids</span> <span>and</span> <span>most</span> <span>importantly,</span> <span>East</span> <span>of</span> <span>Eden</span> <span>by</span> <span>John</span> <span>Steinbeck.</span> <span>It''s</span> <span>a</span> <span>thick</span> <span>boy,</span> <span>but</span> <span>worth</span> <span>every</span> <span>single</span> <span>second.</span> <span>Just</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 152, 838.92, 845.28, 'Kids I liked, but admittedly, I think I liked it a lot because I live in New York and you can just you know all the', '', '', '<span>Kids</span> <span>I</span> <span>liked,</span> <span>but</span> <span>admittedly,</span> <span>I</span> <span>think</span> <span>I</span> <span>liked</span> <span>it</span> <span>a</span> <span>lot</span> <span>because</span> <span>I</span> <span>live</span> <span>in</span> <span>New</span> <span>York</span> <span>and</span> <span>you</span> <span>can</span> <span>just</span> <span>you</span> <span>know</span> <span>all</span> <span>the</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 153, 843.96, 850.88, 'streets that she''s referencing in the book, but it''s obviously very popular for a reason, so I do recommend', '', '', '<span>streets</span> <span>that</span> <span>she''s</span> <span>referencing</span> <span>in</span> <span>the</span> <span>book,</span> <span>but</span> <span>it''s</span> <span>obviously</span> <span>very</span> <span>popular</span> <span>for</span> <span>a</span> <span>reason,</span> <span>so</span> <span>I</span> <span>do</span> <span>recommend</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 154, 848.56, 857.44, 'it. However, East of Eden captures life in California very well and spans multiple different families once again', '', '', '<span>it.</span> <span>However,</span> <span>East</span> <span>of</span> <span>Eden</span> <span>captures</span> <span>life</span> <span>in</span> <span>California</span> <span>very</span> <span>well</span> <span>and</span> <span>spans</span> <span>multiple</span> <span>different</span> <span>families</span> <span>once</span> <span>again</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 155, 855.04, 863.079, 'across decades. So, similar to Pachinko in that way, and highly recommend. But, the book I''m looking for right now,', '', '', '<span>across</span> <span>decades.</span> <span>So,</span> <span>similar</span> <span>to</span> <span>Pachinko</span> <span>in</span> <span>that</span> <span>way,</span> <span>and</span> <span>highly</span> <span>recommend.</span> <span>But,</span> <span>the</span> <span>book</span> <span>I''m</span> <span>looking</span> <span>for</span> <span>right</span> <span>now,</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 156, 860.8, 871.079, 'which I think I see, is A Tree Grows in Brooklyn. I''ve heard very good things about this book. And you know what? I keep picking up thick', '', '', '<span>which</span> <span>I</span> <span>think</span> <span>I</span> <span>see,</span> <span>is</span> <span>A</span> <span>Tree</span> <span>Grows</span> <span>in</span> <span>Brooklyn.</span> <span>I''ve</span> <span>heard</span> <span>very</span> <span>good</span> <span>things</span> <span>about</span> <span>this</span> <span>book.</span> <span>And</span> <span>you</span> <span>know</span> <span>what?</span> <span>I</span> <span>keep</span> <span>picking</span> <span>up</span> <span>thick</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 157, 869.24, 877.64, 'ones, but I got to say, I''m kind of into it. You can cover a lot of ground, get very in-depth with character arcs and so', '', '', '<span>ones,</span> <span>but</span> <span>I</span> <span>got</span> <span>to</span> <span>say,</span> <span>I''m</span> <span>kind</span> <span>of</span> <span>into</span> <span>it.</span> <span>You</span> <span>can</span> <span>cover</span> <span>a</span> <span>lot</span> <span>of</span> <span>ground,</span> <span>get</span> <span>very</span> <span>in-depth</span> <span>with</span> <span>character</span> <span>arcs</span> <span>and</span> <span>so</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 158, 875.16, 878.8, 'on over many pages. So, it''s not just a flex.', '', '', '<span>on</span> <span>over</span> <span>many</span> <span>pages.</span> <span>So,</span> <span>it''s</span> <span>not</span> <span>just</span> <span>a</span> <span>flex.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 159, 878.365, 885.625, '>> >> I also actually have been liking the long books. Anyway, look how cool this freaking bookstore is.', '', '', '<span>>></span> <span>>></span> <span>I</span> <span>also</span> <span>actually</span> <span>have</span> <span>been</span> <span>liking</span> <span>the</span> <span>long</span> <span>books.</span> <span>Anyway,</span> <span>look</span> <span>how</span> <span>cool</span> <span>this</span> <span>freaking</span> <span>bookstore</span> <span>is.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 160, 883.605, 885.625, '>>', '', '', '<span>>></span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 161, 889.4, 896.88, '>> All right, guys. Let''s go to the third floor, which is the rare book room, which sounds pretty cool. I''ve actually never', '', '', '<span>>></span> <span>All</span> <span>right,</span> <span>guys.</span> <span>Let''s</span> <span>go</span> <span>to</span> <span>the</span> <span>third</span> <span>floor,</span> <span>which</span> <span>is</span> <span>the</span> <span>rare</span> <span>book</span> <span>room,</span> <span>which</span> <span>sounds</span> <span>pretty</span> <span>cool.</span> <span>I''ve</span> <span>actually</span> <span>never</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 162, 895.44, 903.91, 'been up here before. You''re coming with me for the first time. I kind of want it to be gloomy and gray and mysterious.', '', '', '<span>been</span> <span>up</span> <span>here</span> <span>before.</span> <span>You''re</span> <span>coming</span> <span>with</span> <span>me</span> <span>for</span> <span>the</span> <span>first</span> <span>time.</span> <span>I</span> <span>kind</span> <span>of</span> <span>want</span> <span>it</span> <span>to</span> <span>be</span> <span>gloomy</span> <span>and</span> <span>gray</span> <span>and</span> <span>mysterious.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 163, 902.44, 905.93, 'Ooh, cool.', '', '', '<span>Ooh,</span> <span>cool.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 164, 903.91, 905.93, '>>', '', '', '<span>>></span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 165, 913.6, 919.76, '>> Unshelved first editions, signed copies.', '', '', '<span>>></span> <span>Unshelved</span> <span>first</span> <span>editions,</span> <span>signed</span> <span>copies.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 166, 917.16, 919.76, 'So neat.', '', '', '<span>So</span> <span>neat.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 167, 925.525, 927.545, '>>', '', '', '<span>>></span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 168, 928.92, 937.28, '>> Here we are at McSorley''s. Somehow my first time here, even though I used to live in the area. This is the oldest bar', '', '', '<span>>></span> <span>Here</span> <span>we</span> <span>are</span> <span>at</span> <span>McSorley''s.</span> <span>Somehow</span> <span>my</span> <span>first</span> <span>time</span> <span>here,</span> <span>even</span> <span>though</span> <span>I</span> <span>used</span> <span>to</span> <span>live</span> <span>in</span> <span>the</span> <span>area.</span> <span>This</span> <span>is</span> <span>the</span> <span>oldest</span> <span>bar</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 169, 935.839, 945.64, 'in all of New York City. One of the oldest continuously operating bars in all of the US. 1854.', '', '', '<span>in</span> <span>all</span> <span>of</span> <span>New</span> <span>York</span> <span>City.</span> <span>One</span> <span>of</span> <span>the</span> <span>oldest</span> <span>continuously</span> <span>operating</span> <span>bars</span> <span>in</span> <span>all</span> <span>of</span> <span>the</span> <span>US.</span> <span>1854.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 170, 943.52, 951.959, 'That''s pretty old. It''s pretty old. All right, so word on the street is they only serve dark beer and light beer. Two', '', '', '<span>That''s</span> <span>pretty</span> <span>old.</span> <span>It''s</span> <span>pretty</span> <span>old.</span> <span>All</span> <span>right,</span> <span>so</span> <span>word</span> <span>on</span> <span>the</span> <span>street</span> <span>is</span> <span>they</span> <span>only</span> <span>serve</span> <span>dark</span> <span>beer</span> <span>and</span> <span>light</span> <span>beer.</span> <span>Two</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 171, 949.92, 957.0, 'beers inside. I kind of want to go half and half situation. After all the intellectual work in uh in the', '', '', '<span>beers</span> <span>inside.</span> <span>I</span> <span>kind</span> <span>of</span> <span>want</span> <span>to</span> <span>go</span> <span>half</span> <span>and</span> <span>half</span> <span>situation.</span> <span>After</span> <span>all</span> <span>the</span> <span>intellectual</span> <span>work</span> <span>in</span> <span>uh</span> <span>in</span> <span>the</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 172, 955.72, 960.0, 'bookstore, I think we I think we need a beer. Don''t you think?', '', '', '<span>bookstore,</span> <span>I</span> <span>think</span> <span>we</span> <span>I</span> <span>think</span> <span>we</span> <span>need</span> <span>a</span> <span>beer.</span> <span>Don''t</span> <span>you</span> <span>think?</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 173, 958.839, 963.0, 'Yeah.', '', '', '<span>Yeah.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 174, 960.0, 963.0, 'All right, let''s go inside.', '', '', '<span>All</span> <span>right,</span> <span>let''s</span> <span>go</span> <span>inside.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 175, 971.76, 976.24, 'Here.', '', '', '<span>Here.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 176, 973.64, 981.48, 'Two at a time cuz they''re small. I got light, he got dark. All right, we made friends at McSorley''s. You want to', '', '', '<span>Two</span> <span>at</span> <span>a</span> <span>time</span> <span>cuz</span> <span>they''re</span> <span>small.</span> <span>I</span> <span>got</span> <span>light,</span> <span>he</span> <span>got</span> <span>dark.</span> <span>All</span> <span>right,</span> <span>we</span> <span>made</span> <span>friends</span> <span>at</span> <span>McSorley''s.</span> <span>You</span> <span>want</span> <span>to</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 177, 979.92, 985.719, 'introduce yourself? Yeah, hi. I''m Shawn Byrne. And how many years have you been coming here?', '', '', '<span>introduce</span> <span>yourself?</span> <span>Yeah,</span> <span>hi.</span> <span>I''m</span> <span>Shawn</span> <span>Byrne.</span> <span>And</span> <span>how</span> <span>many</span> <span>years</span> <span>have</span> <span>you</span> <span>been</span> <span>coming</span> <span>here?</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 178, 983.68, 992.439, '>> I''ve been coming here for over for 40 years. When I was 22 years old. Before we were born. Before you were born.', '', '', '<span>>></span> <span>I''ve</span> <span>been</span> <span>coming</span> <span>here</span> <span>for</span> <span>over</span> <span>for</span> <span>40</span> <span>years.</span> <span>When</span> <span>I</span> <span>was</span> <span>22</span> <span>years</span> <span>old.</span> <span>Before</span> <span>we</span> <span>were</span> <span>born.</span> <span>Before</span> <span>you</span> <span>were</span> <span>born.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 179, 990.76, 997.24, 'Before I was Before I was born, this place has been here. I am Tracy Maloney.', '', '', '<span>Before</span> <span>I</span> <span>was</span> <span>Before</span> <span>I</span> <span>was</span> <span>born,</span> <span>this</span> <span>place</span> <span>has</span> <span>been</span> <span>here.</span> <span>I</span> <span>am</span> <span>Tracy</span> <span>Maloney.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 180, 995.079, 999.599, 'How many times have you been thrown out?', '', '', '<span>How</span> <span>many</span> <span>times</span> <span>have</span> <span>you</span> <span>been</span> <span>thrown</span> <span>out?</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 181, 997.24, 1006.8, 'I was thrown out once with my husband and my brother after waiting 30 minutes in line cuz I got caught carving my name', '', '', '<span>I</span> <span>was</span> <span>thrown</span> <span>out</span> <span>once</span> <span>with</span> <span>my</span> <span>husband</span> <span>and</span> <span>my</span> <span>brother</span> <span>after</span> <span>waiting</span> <span>30</span> <span>minutes</span> <span>in</span> <span>line</span> <span>cuz</span> <span>I</span> <span>got</span> <span>caught</span> <span>carving</span> <span>my</span> <span>name</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 182, 1005.32, 1008.56, 'in the wooden table.', '', '', '<span>in</span> <span>the</span> <span>wooden</span> <span>table.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 183, 1006.8, 1016.16, '>> thrown out of here three times over my years. All 48 to 25. One time for singing, one time for chugging beer, and', '', '', '<span>>></span> <span>thrown</span> <span>out</span> <span>of</span> <span>here</span> <span>three</span> <span>times</span> <span>over</span> <span>my</span> <span>years.</span> <span>All</span> <span>48</span> <span>to</span> <span>25.</span> <span>One</span> <span>time</span> <span>for</span> <span>singing,</span> <span>one</span> <span>time</span> <span>for</span> <span>chugging</span> <span>beer,</span> <span>and</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 184, 1014.56, 1020.28, 'one time for getting mustard on the glass. Oh my god.', '', '', '<span>one</span> <span>time</span> <span>for</span> <span>getting</span> <span>mustard</span> <span>on</span> <span>the</span> <span>glass.</span> <span>Oh</span> <span>my</span> <span>god.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 185, 1018.32, 1024.76, 'Those are small infractions. They always had a line out front. They were trying to get new customers in. I see. I see.', '', '', '<span>Those</span> <span>are</span> <span>small</span> <span>infractions.</span> <span>They</span> <span>always</span> <span>had</span> <span>a</span> <span>line</span> <span>out</span> <span>front.</span> <span>They</span> <span>were</span> <span>trying</span> <span>to</span> <span>get</span> <span>new</span> <span>customers</span> <span>in.</span> <span>I</span> <span>see.</span> <span>I</span> <span>see.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 186, 1023.4, 1026.56, 'Cheers.', '', '', '<span>Cheers.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 187, 1024.76, 1028.199, 'Cheers everybody.', '', '', '<span>Cheers</span> <span>everybody.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 188, 1026.56, 1032.12, 'It''s our chief''s birthday, so happy birthday. Oh, yeah. Happy birthday.', '', '', '<span>It''s</span> <span>our</span> <span>chief''s</span> <span>birthday,</span> <span>so</span> <span>happy</span> <span>birthday.</span> <span>Oh,</span> <span>yeah.</span> <span>Happy</span> <span>birthday.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 189, 1029.76, 1035.639, '>> Thank you. Chief, 40 years young. Aw, you don''t look a day over 20.', '', '', '<span>>></span> <span>Thank</span> <span>you.</span> <span>Chief,</span> <span>40</span> <span>years</span> <span>young.</span> <span>Aw,</span> <span>you</span> <span>don''t</span> <span>look</span> <span>a</span> <span>day</span> <span>over</span> <span>20.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 190, 1033.48, 1035.64, '>> Thank you.', '', '', '<span>>></span> <span>Thank</span> <span>you.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 191, 1039.496, 1043.48, '>> >> Just coming out of McSorley''s.', '', '', '<span>>></span> <span>>></span> <span>Just</span> <span>coming</span> <span>out</span> <span>of</span> <span>McSorley''s.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 192, 1042.04, 1048.12, 'I don''t maybe one or two more beers than expected. That was so fun and chaotic.', '', '', '<span>I</span> <span>don''t</span> <span>maybe</span> <span>one</span> <span>or</span> <span>two</span> <span>more</span> <span>beers</span> <span>than</span> <span>expected.</span> <span>That</span> <span>was</span> <span>so</span> <span>fun</span> <span>and</span> <span>chaotic.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 193, 1047.04, 1051.52, 'Sitting with those people. They were actually the ones who were next to me in line, and we just happened to', '', '', '<span>Sitting</span> <span>with</span> <span>those</span> <span>people.</span> <span>They</span> <span>were</span> <span>actually</span> <span>the</span> <span>ones</span> <span>who</span> <span>were</span> <span>next</span> <span>to</span> <span>me</span> <span>in</span> <span>line,</span> <span>and</span> <span>we</span> <span>just</span> <span>happened</span> <span>to</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 194, 1050.2, 1057.36, 'get seated at the same table, and we just hung out and cheers and drank beer the whole time, and they bought us beer.', '', '', '<span>get</span> <span>seated</span> <span>at</span> <span>the</span> <span>same</span> <span>table,</span> <span>and</span> <span>we</span> <span>just</span> <span>hung</span> <span>out</span> <span>and</span> <span>cheers</span> <span>and</span> <span>drank</span> <span>beer</span> <span>the</span> <span>whole</span> <span>time,</span> <span>and</span> <span>they</span> <span>bought</span> <span>us</span> <span>beer.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 195, 1055.12, 1059.159, 'It was very fun. Even fun next location.', '', '', '<span>It</span> <span>was</span> <span>very</span> <span>fun.</span> <span>Even</span> <span>fun</span> <span>next</span> <span>location.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 196, 1057.36, 1061.04, 'Let''s grab our things.', '', '', '<span>Let''s</span> <span>grab</span> <span>our</span> <span>things.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 197, 1059.16, 1063.84, 'Whole bunch of books. Whole bunch of jelly beans.', '', '', '<span>Whole</span> <span>bunch</span> <span>of</span> <span>books.</span> <span>Whole</span> <span>bunch</span> <span>of</span> <span>jelly</span> <span>beans.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 198, 1067.007, 1073.6, '>> >> All right, I know what you guys are thinking. Like, you''re Taylor, you''re just eating all day. Food, food, food.', '', '', '<span>>></span> <span>>></span> <span>All</span> <span>right,</span> <span>I</span> <span>know</span> <span>what</span> <span>you</span> <span>guys</span> <span>are</span> <span>thinking.</span> <span>Like,</span> <span>you''re</span> <span>Taylor,</span> <span>you''re</span> <span>just</span> <span>eating</span> <span>all</span> <span>day.</span> <span>Food,</span> <span>food,</span> <span>food.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 199, 1072.0, 1078.04, 'There''s more to life than food. Well, jokes on you. I''m actually going to take you to a really renowned cultural', '', '', '<span>There''s</span> <span>more</span> <span>to</span> <span>life</span> <span>than</span> <span>food.</span> <span>Well,</span> <span>jokes</span> <span>on</span> <span>you.</span> <span>I''m</span> <span>actually</span> <span>going</span> <span>to</span> <span>take</span> <span>you</span> <span>to</span> <span>a</span> <span>really</span> <span>renowned</span> <span>cultural</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 200, 1076.72, 1086.002, 'establishment, cornerstone of the neighborhood. But first, emergency slice. Joe''s Pizza. Come on. Come on', '', '', '<span>establishment,</span> <span>cornerstone</span> <span>of</span> <span>the</span> <span>neighborhood.</span> <span>But</span> <span>first,</span> <span>emergency</span> <span>slice.</span> <span>Joe''s</span> <span>Pizza.</span> <span>Come</span> <span>on.</span> <span>Come</span> <span>on</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 201, 1083.56, 1086.2, 'now. Jokes aside, Joe''s Pizza.', '', '', '<span>now.</span> <span>Jokes</span> <span>aside,</span> <span>Joe''s</span> <span>Pizza.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 202, 1086.002, 1092.44, '>> >> This is widely regarded as kind of the gold standard of a New York City slice.', '', '', '<span>>></span> <span>>></span> <span>This</span> <span>is</span> <span>widely</span> <span>regarded</span> <span>as</span> <span>kind</span> <span>of</span> <span>the</span> <span>gold</span> <span>standard</span> <span>of</span> <span>a</span> <span>New</span> <span>York</span> <span>City</span> <span>slice.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 203, 1090.587, 1095.48, 'We got a little droop in the middle. There it is. There it is.', '', '', '<span>We</span> <span>got</span> <span>a</span> <span>little</span> <span>droop</span> <span>in</span> <span>the</span> <span>middle.</span> <span>There</span> <span>it</span> <span>is.</span> <span>There</span> <span>it</span> <span>is.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 204, 1093.96, 1103.24, 'Perfectly golden on the bottom, delicious tomato sauce. It''s pretty much as good as you get for a like a $5 slice. This', '', '', '<span>Perfectly</span> <span>golden</span> <span>on</span> <span>the</span> <span>bottom,</span> <span>delicious</span> <span>tomato</span> <span>sauce.</span> <span>It''s</span> <span>pretty</span> <span>much</span> <span>as</span> <span>good</span> <span>as</span> <span>you</span> <span>get</span> <span>for</span> <span>a</span> <span>like</span> <span>a</span> <span>$5</span> <span>slice.</span> <span>This</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 205, 1101.04, 1109.24, 'is the original location here on Carmine and Bleecker Street. It''s opened in 1975 by a Neapolitan immigrant. It''s', '', '', '<span>is</span> <span>the</span> <span>original</span> <span>location</span> <span>here</span> <span>on</span> <span>Carmine</span> <span>and</span> <span>Bleecker</span> <span>Street.</span> <span>It''s</span> <span>opened</span> <span>in</span> <span>1975</span> <span>by</span> <span>a</span> <span>Neapolitan</span> <span>immigrant.</span> <span>It''s</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 206, 1107.88, 1114.04, 'how you know the pizza''s good. And it just hits every time. Our favorite part about it? Oh, no.', '', '', '<span>how</span> <span>you</span> <span>know</span> <span>the</span> <span>pizza''s</span> <span>good.</span> <span>And</span> <span>it</span> <span>just</span> <span>hits</span> <span>every</span> <span>time.</span> <span>Our</span> <span>favorite</span> <span>part</span> <span>about</span> <span>it?</span> <span>Oh,</span> <span>no.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 207, 1115.76, 1122.879, 'Our favorite part about it is the tomato sauce. We think that it''s rarely about the cheese and more so about the tomato', '', '', '<span>Our</span> <span>favorite</span> <span>part</span> <span>about</span> <span>it</span> <span>is</span> <span>the</span> <span>tomato</span> <span>sauce.</span> <span>We</span> <span>think</span> <span>that</span> <span>it''s</span> <span>rarely</span> <span>about</span> <span>the</span> <span>cheese</span> <span>and</span> <span>more</span> <span>so</span> <span>about</span> <span>the</span> <span>tomato</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 208, 1120.84, 1126.52, 'sauce that just really sets a slice apart from another slice, you know?', '', '', '<span>sauce</span> <span>that</span> <span>just</span> <span>really</span> <span>sets</span> <span>a</span> <span>slice</span> <span>apart</span> <span>from</span> <span>another</span> <span>slice,</span> <span>you</span> <span>know?</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 209, 1124.28, 1131.04, 'Anyway, emergency slice ingesting. Another fun fact about Joe''s Pizza is that if you guys have seen the', '', '', '<span>Anyway,</span> <span>emergency</span> <span>slice</span> <span>ingesting.</span> <span>Another</span> <span>fun</span> <span>fact</span> <span>about</span> <span>Joe''s</span> <span>Pizza</span> <span>is</span> <span>that</span> <span>if</span> <span>you</span> <span>guys</span> <span>have</span> <span>seen</span> <span>the</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 210, 1129.76, 1137.093, 'original Spider-Man with Tobey Maguire, you might remember that he works for Joe''s Pizza, specifically this', '', '', '<span>original</span> <span>Spider-Man</span> <span>with</span> <span>Tobey</span> <span>Maguire,</span> <span>you</span> <span>might</span> <span>remember</span> <span>that</span> <span>he</span> <span>works</span> <span>for</span> <span>Joe''s</span> <span>Pizza,</span> <span>specifically</span> <span>this</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 211, 1135.76, 1142.32, 'location. And there''s kind of an iconic scene where he pulls up right here in his like little scooter and runs', '', '', '<span>location.</span> <span>And</span> <span>there''s</span> <span>kind</span> <span>of</span> <span>an</span> <span>iconic</span> <span>scene</span> <span>where</span> <span>he</span> <span>pulls</span> <span>up</span> <span>right</span> <span>here</span> <span>in</span> <span>his</span> <span>like</span> <span>little</span> <span>scooter</span> <span>and</span> <span>runs</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 212, 1141.0, 1146.72, 'into the owner, and the owner''s like, "You''re doing a bad job." And yeah, anyway. So, that''s this location.', '', '', '<span>into</span> <span>the</span> <span>owner,</span> <span>and</span> <span>the</span> <span>owner''s</span> <span>like,</span> <span>"You''re</span> <span>doing</span> <span>a</span> <span>bad</span> <span>job."</span> <span>And</span> <span>yeah,</span> <span>anyway.</span> <span>So,</span> <span>that''s</span> <span>this</span> <span>location.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 213, 1145.32, 1151.8, 'On to our next spot, I want to show you guys something right around the corner first, though, which is also kind of', '', '', '<span>On</span> <span>to</span> <span>our</span> <span>next</span> <span>spot,</span> <span>I</span> <span>want</span> <span>to</span> <span>show</span> <span>you</span> <span>guys</span> <span>something</span> <span>right</span> <span>around</span> <span>the</span> <span>corner</span> <span>first,</span> <span>though,</span> <span>which</span> <span>is</span> <span>also</span> <span>kind</span> <span>of</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 214, 1150.159, 1158.0, 'historic New York City. So, this one I wanted to show you right around the corner from Joe''s is IFC Theater.', '', '', '<span>historic</span> <span>New</span> <span>York</span> <span>City.</span> <span>So,</span> <span>this</span> <span>one</span> <span>I</span> <span>wanted</span> <span>to</span> <span>show</span> <span>you</span> <span>right</span> <span>around</span> <span>the</span> <span>corner</span> <span>from</span> <span>Joe''s</span> <span>is</span> <span>IFC</span> <span>Theater.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 215, 1155.919, 1161.56, 'It''s a building that has housed a theater since the 1930s.', '', '', '<span>It''s</span> <span>a</span> <span>building</span> <span>that</span> <span>has</span> <span>housed</span> <span>a</span> <span>theater</span> <span>since</span> <span>the</span> <span>1930s.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 216, 1159.8, 1168.64, 'Originally, it was the Waverly Theater, and it''s kind of gone through a series of them, and it was rebranded to IFC', '', '', '<span>Originally,</span> <span>it</span> <span>was</span> <span>the</span> <span>Waverly</span> <span>Theater,</span> <span>and</span> <span>it''s</span> <span>kind</span> <span>of</span> <span>gone</span> <span>through</span> <span>a</span> <span>series</span> <span>of</span> <span>them,</span> <span>and</span> <span>it</span> <span>was</span> <span>rebranded</span> <span>to</span> <span>IFC</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 217, 1165.258, 1174.639, 'Center in 2005. And we just saw that they''re playing After Hours, which is one of our favorite Scorsese movies.', '', '', '<span>Center</span> <span>in</span> <span>2005.</span> <span>And</span> <span>we</span> <span>just</span> <span>saw</span> <span>that</span> <span>they''re</span> <span>playing</span> <span>After</span> <span>Hours,</span> <span>which</span> <span>is</span> <span>one</span> <span>of</span> <span>our</span> <span>favorite</span> <span>Scorsese</span> <span>movies.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 218, 1172.919, 1182.48, 'It''s like old Soho when it was still kind of dingy, but it''s like a very like really like whimsical movie. No, but a', '', '', '<span>It''s</span> <span>like</span> <span>old</span> <span>Soho</span> <span>when</span> <span>it</span> <span>was</span> <span>still</span> <span>kind</span> <span>of</span> <span>dingy,</span> <span>but</span> <span>it''s</span> <span>like</span> <span>a</span> <span>very</span> <span>like</span> <span>really</span> <span>like</span> <span>whimsical</span> <span>movie.</span> <span>No,</span> <span>but</span> <span>a</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 219, 1181.04, 1189.679, 'very trippy movie is a better word for it. Anyways, this is one of the kind of last great independent theaters', '', '', '<span>very</span> <span>trippy</span> <span>movie</span> <span>is</span> <span>a</span> <span>better</span> <span>word</span> <span>for</span> <span>it.</span> <span>Anyways,</span> <span>this</span> <span>is</span> <span>one</span> <span>of</span> <span>the</span> <span>kind</span> <span>of</span> <span>last</span> <span>great</span> <span>independent</span> <span>theaters</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 220, 1187.48, 1193.72, 'in Manhattan. We have been here to see Paris, Texas before, which was super super fun.', '', '', '<span>in</span> <span>Manhattan.</span> <span>We</span> <span>have</span> <span>been</span> <span>here</span> <span>to</span> <span>see</span> <span>Paris,</span> <span>Texas</span> <span>before,</span> <span>which</span> <span>was</span> <span>super</span> <span>super</span> <span>fun.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 221, 1192.64, 1199.318, 'And I think we''re going to come back to the after hours probably sometime in the next couple weeks. So, I wanted to point', '', '', '<span>And</span> <span>I</span> <span>think</span> <span>we''re</span> <span>going</span> <span>to</span> <span>come</span> <span>back</span> <span>to</span> <span>the</span> <span>after</span> <span>hours</span> <span>probably</span> <span>sometime</span> <span>in</span> <span>the</span> <span>next</span> <span>couple</span> <span>weeks.</span> <span>So,</span> <span>I</span> <span>wanted</span> <span>to</span> <span>point</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 222, 1196.64, 1199.76, 'that out. It''s pretty awesome.', '', '', '<span>that</span> <span>out.</span> <span>It''s</span> <span>pretty</span> <span>awesome.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 223, 1199.318, 1206.72, '>> >> On our way to the next location, but guys, New York''s got so much and while we''re on this lane, I might as well just', '', '', '<span>>></span> <span>>></span> <span>On</span> <span>our</span> <span>way</span> <span>to</span> <span>the</span> <span>next</span> <span>location,</span> <span>but</span> <span>guys,</span> <span>New</span> <span>York''s</span> <span>got</span> <span>so</span> <span>much</span> <span>and</span> <span>while</span> <span>we''re</span> <span>on</span> <span>this</span> <span>lane,</span> <span>I</span> <span>might</span> <span>as</span> <span>well</span> <span>just</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 224, 1205.0, 1214.879, 'point out what''s here cuz kind of historic in its own right. Blue Note Jazz Club. I don''t have the stats and the facts to read off right', '', '', '<span>point</span> <span>out</span> <span>what''s</span> <span>here</span> <span>cuz</span> <span>kind</span> <span>of</span> <span>historic</span> <span>in</span> <span>its</span> <span>own</span> <span>right.</span> <span>Blue</span> <span>Note</span> <span>Jazz</span> <span>Club.</span> <span>I</span> <span>don''t</span> <span>have</span> <span>the</span> <span>stats</span> <span>and</span> <span>the</span> <span>facts</span> <span>to</span> <span>read</span> <span>off</span> <span>right</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 225, 1212.04, 1222.16, 'now, but absolutely classic iconic jazz bar and a bunch of the classic comedy spots. Been to all of these many,', '', '', '<span>now,</span> <span>but</span> <span>absolutely</span> <span>classic</span> <span>iconic</span> <span>jazz</span> <span>bar</span> <span>and</span> <span>a</span> <span>bunch</span> <span>of</span> <span>the</span> <span>classic</span> <span>comedy</span> <span>spots.</span> <span>Been</span> <span>to</span> <span>all</span> <span>of</span> <span>these</span> <span>many,</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 226, 1219.52, 1228.08, 'many times each. All really great. And it''s not very rare that really, really famous comedians will pop up at', '', '', '<span>many</span> <span>times</span> <span>each.</span> <span>All</span> <span>really</span> <span>great.</span> <span>And</span> <span>it''s</span> <span>not</span> <span>very</span> <span>rare</span> <span>that</span> <span>really,</span> <span>really</span> <span>famous</span> <span>comedians</span> <span>will</span> <span>pop</span> <span>up</span> <span>at</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 227, 1225.84, 1232.4, 'some of these clubs a lot of the time on Wednesday nights because that''s when it''s they''re a little less crowded.', '', '', '<span>some</span> <span>of</span> <span>these</span> <span>clubs</span> <span>a</span> <span>lot</span> <span>of</span> <span>the</span> <span>time</span> <span>on</span> <span>Wednesday</span> <span>nights</span> <span>because</span> <span>that''s</span> <span>when</span> <span>it''s</span> <span>they''re</span> <span>a</span> <span>little</span> <span>less</span> <span>crowded.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 228, 1230.84, 1238.2, 'Really, really cool. But, without further ado, let''s go to the next location. All right, guys. Here we are', '', '', '<span>Really,</span> <span>really</span> <span>cool.</span> <span>But,</span> <span>without</span> <span>further</span> <span>ado,</span> <span>let''s</span> <span>go</span> <span>to</span> <span>the</span> <span>next</span> <span>location.</span> <span>All</span> <span>right,</span> <span>guys.</span> <span>Here</span> <span>we</span> <span>are</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 229, 1235.64, 1242.64, 'at Cafe Reggio. There is a cool historical significance here, but I''ll tell you inside.', '', '', '<span>at</span> <span>Cafe</span> <span>Reggio.</span> <span>There</span> <span>is</span> <span>a</span> <span>cool</span> <span>historical</span> <span>significance</span> <span>here,</span> <span>but</span> <span>I''ll</span> <span>tell</span> <span>you</span> <span>inside.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 230, 1243.859, 1245.879, '>>', '', '', '<span>>></span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 231, 1249.76, 1258.88, '>> All right, guys. Here we are on the inside of the historical significance I may now tell you. So, this was', '', '', '<span>>></span> <span>All</span> <span>right,</span> <span>guys.</span> <span>Here</span> <span>we</span> <span>are</span> <span>on</span> <span>the</span> <span>inside</span> <span>of</span> <span>the</span> <span>historical</span> <span>significance</span> <span>I</span> <span>may</span> <span>now</span> <span>tell</span> <span>you.</span> <span>So,</span> <span>this</span> <span>was</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 232, 1256.16, 1266.6, 'the first cappuccino introduced to the US. This place, Cafe Reggio, has been open since 1927.', '', '', '<span>the</span> <span>first</span> <span>cappuccino</span> <span>introduced</span> <span>to</span> <span>the</span> <span>US.</span> <span>This</span> <span>place,</span> <span>Cafe</span> <span>Reggio,</span> <span>has</span> <span>been</span> <span>open</span> <span>since</span> <span>1927.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 233, 1263.52, 1272.16, 'And even cooler, their original espresso machine, which is on display over there, was built in 1902.', '', '', '<span>And</span> <span>even</span> <span>cooler,</span> <span>their</span> <span>original</span> <span>espresso</span> <span>machine,</span> <span>which</span> <span>is</span> <span>on</span> <span>display</span> <span>over</span> <span>there,</span> <span>was</span> <span>built</span> <span>in</span> <span>1902.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 234, 1270.52, 1278.679, 'Pretty cool. And they have like quite an eclectic mix of art, Renaissance paintings, and little sculptures. And', '', '', '<span>Pretty</span> <span>cool.</span> <span>And</span> <span>they</span> <span>have</span> <span>like</span> <span>quite</span> <span>an</span> <span>eclectic</span> <span>mix</span> <span>of</span> <span>art,</span> <span>Renaissance</span> <span>paintings,</span> <span>and</span> <span>little</span> <span>sculptures.</span> <span>And</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 235, 1276.56, 1282.88, 'pretty cool, this place was featured in Godfather Part II.', '', '', '<span>pretty</span> <span>cool,</span> <span>this</span> <span>place</span> <span>was</span> <span>featured</span> <span>in</span> <span>Godfather</span> <span>Part</span> <span>II.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 236, 1280.76, 1289.28, 'Fun fact. All right, first reactions. I never get cappuccinos. I never think to, but here we go.', '', '', '<span>Fun</span> <span>fact.</span> <span>All</span> <span>right,</span> <span>first</span> <span>reactions.</span> <span>I</span> <span>never</span> <span>get</span> <span>cappuccinos.</span> <span>I</span> <span>never</span> <span>think</span> <span>to,</span> <span>but</span> <span>here</span> <span>we</span> <span>go.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 237, 1287.44, 1290.36, 'Delish. Very warm and comforting.', '', '', '<span>Delish.</span> <span>Very</span> <span>warm</span> <span>and</span> <span>comforting.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 238, 1289.28, 1294.88, 'Honestly, guys, it''s cold out there and uh we''re kind of enjoying these little respites inside with a warm', '', '', '<span>Honestly,</span> <span>guys,</span> <span>it''s</span> <span>cold</span> <span>out</span> <span>there</span> <span>and</span> <span>uh</span> <span>we''re</span> <span>kind</span> <span>of</span> <span>enjoying</span> <span>these</span> <span>little</span> <span>respites</span> <span>inside</span> <span>with</span> <span>a</span> <span>warm</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 239, 1293.88, 1299.24, 'bev or a hot piece of pizza. They''re all good.', '', '', '<span>bev</span> <span>or</span> <span>a</span> <span>hot</span> <span>piece</span> <span>of</span> <span>pizza.</span> <span>They''re</span> <span>all</span> <span>good.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 240, 1300.844, 1302.864, '>>', '', '', '<span>>></span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 241, 1304.84, 1313.04, '>> Passing Stonewall in the West Village, historic LGBTQ rights monument.', '', '', '<span>>></span> <span>Passing</span> <span>Stonewall</span> <span>in</span> <span>the</span> <span>West</span> <span>Village,</span> <span>historic</span> <span>LGBTQ</span> <span>rights</span> <span>monument.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 242, 1313.29, 1315.31, '>>', '', '', '<span>>></span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 243, 1322.64, 1326.36, '>> Oh, this light right now.', '', '', '<span>>></span> <span>Oh,</span> <span>this</span> <span>light</span> <span>right</span> <span>now.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 244, 1325.12, 1327.239, 'Wow.', '', '', '<span>Wow.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 245, 1326.36, 1334.24, 'All right, guys. Here in the West Village, as the sun''s going down, it''s made an appearance in so many of my', '', '', '<span>All</span> <span>right,</span> <span>guys.</span> <span>Here</span> <span>in</span> <span>the</span> <span>West</span> <span>Village,</span> <span>as</span> <span>the</span> <span>sun''s</span> <span>going</span> <span>down,</span> <span>it''s</span> <span>made</span> <span>an</span> <span>appearance</span> <span>in</span> <span>so</span> <span>many</span> <span>of</span> <span>my</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 246, 1332.6, 1339.88, 'videos, but it''s got to make an appearance in this one, too. Not as old as some of the other locations, but just', '', '', '<span>videos,</span> <span>but</span> <span>it''s</span> <span>got</span> <span>to</span> <span>make</span> <span>an</span> <span>appearance</span> <span>in</span> <span>this</span> <span>one,</span> <span>too.</span> <span>Not</span> <span>as</span> <span>old</span> <span>as</span> <span>some</span> <span>of</span> <span>the</span> <span>other</span> <span>locations,</span> <span>but</span> <span>just</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 247, 1338.12, 1347.08, 'as prominent in terms of iconic New York City. Magnolia Bakery. It opened up in 1996 and more importantly, made', '', '', '<span>as</span> <span>prominent</span> <span>in</span> <span>terms</span> <span>of</span> <span>iconic</span> <span>New</span> <span>York</span> <span>City.</span> <span>Magnolia</span> <span>Bakery.</span> <span>It</span> <span>opened</span> <span>up</span> <span>in</span> <span>1996</span> <span>and</span> <span>more</span> <span>importantly,</span> <span>made</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 248, 1345.28, 1352.84, 'an appearance in Sex and the City in 1999 where Carrie and Miranda were sitting right outside of this original', '', '', '<span>an</span> <span>appearance</span> <span>in</span> <span>Sex</span> <span>and</span> <span>the</span> <span>City</span> <span>in</span> <span>1999</span> <span>where</span> <span>Carrie</span> <span>and</span> <span>Miranda</span> <span>were</span> <span>sitting</span> <span>right</span> <span>outside</span> <span>of</span> <span>this</span> <span>original</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 249, 1350.92, 1358.56, 'location eating cupcakes, which really helped spark the cupcakes craze of the 2000s. And since then, the banana', '', '', '<span>location</span> <span>eating</span> <span>cupcakes,</span> <span>which</span> <span>really</span> <span>helped</span> <span>spark</span> <span>the</span> <span>cupcakes</span> <span>craze</span> <span>of</span> <span>the</span> <span>2000s.</span> <span>And</span> <span>since</span> <span>then,</span> <span>the</span> <span>banana</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 250, 1356.44, 1362.04, 'pudding has taken over the cupcakes in terms of the order here.', '', '', '<span>pudding</span> <span>has</span> <span>taken</span> <span>over</span> <span>the</span> <span>cupcakes</span> <span>in</span> <span>terms</span> <span>of</span> <span>the</span> <span>order</span> <span>here.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 251, 1365.56, 1368.28, 'So, let''s get some.', '', '', '<span>So,</span> <span>let''s</span> <span>get</span> <span>some.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 252, 1368.31, 1370.33, '>>', '', '', '<span>>></span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 253, 1375.679, 1382.064, '>> All right, y''all. First bite of this particular batch. Hang on.', '', '', '<span>>></span> <span>All</span> <span>right,</span> <span>y''all.</span> <span>First</span> <span>bite</span> <span>of</span> <span>this</span> <span>particular</span> <span>batch.</span> <span>Hang</span> <span>on.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 254, 1379.8, 1386.12, 'There we go. Oh, >> >> okay.', '', '', '<span>There</span> <span>we</span> <span>go.</span> <span>Oh,</span> <span>>></span> <span>>></span> <span>okay.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 255, 1384.32, 1389.399, 'Going to eat this first. We eat from the lid.', '', '', '<span>Going</span> <span>to</span> <span>eat</span> <span>this</span> <span>first.</span> <span>We</span> <span>eat</span> <span>from</span> <span>the</span> <span>lid.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 256, 1387.2, 1393.4, 'Mhm. So good every time. It''s one of those things where you just don''t think you like banana pudding that much cuz', '', '', '<span>Mhm.</span> <span>So</span> <span>good</span> <span>every</span> <span>time.</span> <span>It''s</span> <span>one</span> <span>of</span> <span>those</span> <span>things</span> <span>where</span> <span>you</span> <span>just</span> <span>don''t</span> <span>think</span> <span>you</span> <span>like</span> <span>banana</span> <span>pudding</span> <span>that</span> <span>much</span> <span>cuz</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 257, 1392.4, 1399.76, 'it''s how high of a ceiling can it really have? And then it''s just very good every time.', '', '', '<span>it''s</span> <span>how</span> <span>high</span> <span>of</span> <span>a</span> <span>ceiling</span> <span>can</span> <span>it</span> <span>really</span> <span>have?</span> <span>And</span> <span>then</span> <span>it''s</span> <span>just</span> <span>very</span> <span>good</span> <span>every</span> <span>time.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 258, 1397.56, 1405.678, 'Delish. I think that today was just sort of a great symbolic itinerary on why living in New York is so awesome.', '', '', '<span>Delish.</span> <span>I</span> <span>think</span> <span>that</span> <span>today</span> <span>was</span> <span>just</span> <span>sort</span> <span>of</span> <span>a</span> <span>great</span> <span>symbolic</span> <span>itinerary</span> <span>on</span> <span>why</span> <span>living</span> <span>in</span> <span>New</span> <span>York</span> <span>is</span> <span>so</span> <span>awesome.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 259, 1404.4, 1411.399, 'There''s just so much to do. There''s so much history at the end of the day. Also just gems that I haven''t been to even', '', '', '<span>There''s</span> <span>just</span> <span>so</span> <span>much</span> <span>to</span> <span>do.</span> <span>There''s</span> <span>so</span> <span>much</span> <span>history</span> <span>at</span> <span>the</span> <span>end</span> <span>of</span> <span>the</span> <span>day.</span> <span>Also</span> <span>just</span> <span>gems</span> <span>that</span> <span>I</span> <span>haven''t</span> <span>been</span> <span>to</span> <span>even</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 260, 1410.28, 1416.28, 'though I''ve lived here for almost 5 years. But, there''s always something new to discover even if it''s been here for', '', '', '<span>though</span> <span>I''ve</span> <span>lived</span> <span>here</span> <span>for</span> <span>almost</span> <span>5</span> <span>years.</span> <span>But,</span> <span>there''s</span> <span>always</span> <span>something</span> <span>new</span> <span>to</span> <span>discover</span> <span>even</span> <span>if</span> <span>it''s</span> <span>been</span> <span>here</span> <span>for</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 261, 1414.72, 1422.96, 'forever and ever. So, it was fun to really pick out some historic spots, go to them either for the hundredth time, as is the case with', '', '', '<span>forever</span> <span>and</span> <span>ever.</span> <span>So,</span> <span>it</span> <span>was</span> <span>fun</span> <span>to</span> <span>really</span> <span>pick</span> <span>out</span> <span>some</span> <span>historic</span> <span>spots,</span> <span>go</span> <span>to</span> <span>them</span> <span>either</span> <span>for</span> <span>the</span> <span>hundredth</span> <span>time,</span> <span>as</span> <span>is</span> <span>the</span> <span>case</span> <span>with</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 262, 1420.679, 1428.679, 'Magnolia, or for the first time. And glad you guys got to join me. Let me know if you have any themes like old New', '', '', '<span>Magnolia,</span> <span>or</span> <span>for</span> <span>the</span> <span>first</span> <span>time.</span> <span>And</span> <span>glad</span> <span>you</span> <span>guys</span> <span>got</span> <span>to</span> <span>join</span> <span>me.</span> <span>Let</span> <span>me</span> <span>know</span> <span>if</span> <span>you</span> <span>have</span> <span>any</span> <span>themes</span> <span>like</span> <span>old</span> <span>New</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 263, 1427.24, 1431.64, 'York that you would want me to do in the future.', '', '', '<span>York</span> <span>that</span> <span>you</span> <span>would</span> <span>want</span> <span>me</span> <span>to</span> <span>do</span> <span>in</span> <span>the</span> <span>future.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 264, 1429.84, 1436.96, 'And I will heavily consider them. Thanks for watching. Like and subscribe.', '', '', '<span>And</span> <span>I</span> <span>will</span> <span>heavily</span> <span>consider</span> <span>them.</span> <span>Thanks</span> <span>for</span> <span>watching.</span> <span>Like</span> <span>and</span> <span>subscribe.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 265, 1433.679, 1438.679, 'And until next time, Turtle out.', '', '', '<span>And</span> <span>until</span> <span>next</span> <span>time,</span> <span>Turtle</span> <span>out.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 266, 1436.96, 1444.12, 'If that''s not the most New York thing, a black and white cookie baby teether.', '', '', '<span>If</span> <span>that''s</span> <span>not</span> <span>the</span> <span>most</span> <span>New</span> <span>York</span> <span>thing,</span> <span>a</span> <span>black</span> <span>and</span> <span>white</span> <span>cookie</span> <span>baby</span> <span>teether.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 267, 1441.28, 1444.12, 'It''s a rubber.', '', '', '<span>It''s</span> <span>a</span> <span>rubber.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 268, 1446.24, 1450.92, 'All right, let''s eat. Should we wait?', '', '', '<span>All</span> <span>right,</span> <span>let''s</span> <span>eat.</span> <span>Should</span> <span>we</span> <span>wait?</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 269, 1447.8, 1450.919, 'It''s okay.', '', '', '<span>It''s</span> <span>okay.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 270, 1454.24, 1456.72, 'Jesus.', '', '', '<span>Jesus.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 271, 1460.72, 1465.0, 'Oh, smells like books. I love that smell.', '', '', '<span>Oh,</span> <span>smells</span> <span>like</span> <span>books.</span> <span>I</span> <span>love</span> <span>that</span> <span>smell.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 272, 1469.48, 1479.04, 'Oh my god. And thank you to my roommate for filming this whole thing and braving the cold with me today. Very', '', '', '<span>Oh</span> <span>my</span> <span>god.</span> <span>And</span> <span>thank</span> <span>you</span> <span>to</span> <span>my</span> <span>roommate</span> <span>for</span> <span>filming</span> <span>this</span> <span>whole</span> <span>thing</span> <span>and</span> <span>braving</span> <span>the</span> <span>cold</span> <span>with</span> <span>me</span> <span>today.</span> <span>Very</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 273, 1476.2, 1481.879, 'sweet, very generous. Asks for nothing in return.', '', '', '<span>sweet,</span> <span>very</span> <span>generous.</span> <span>Asks</span> <span>for</span> <span>nothing</span> <span>in</span> <span>return.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 274, 1482.282, 1488.48, '>> >> It was pretty warm in the summer.', '', '', '<span>>></span> <span>>></span> <span>It</span> <span>was</span> <span>pretty</span> <span>warm</span> <span>in</span> <span>the</span> <span>summer.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 275, 1486.56, 1491.399, 'Still dead right now, okay.', '', '', '<span>Still</span> <span>dead</span> <span>right</span> <span>now,</span> <span>okay.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 276, 1488.48, 1491.4, 'You are the best.', '', '', '<span>You</span> <span>are</span> <span>the</span> <span>best.</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 277, 1501.4, 1504.64, 'Why don''t you listen to me?', '', '', '<span>Why</span> <span>don''t</span> <span>you</span> <span>listen</span> <span>to</span> <span>me?</span>'
FROM episodes e WHERE e.video_id = 'dlfC9v8siowrhA8';

-- episode 0: 7wO304w7y7rT6wM
INSERT INTO episodes (
  index, video_id, short_title, summary, remark, stars, voca_size,
  subtitle_count, clip_length, cover, video_url, audio_url, thumbnail_url,
  original_video_url, author_id, submitted_by_user_id, rejection_reason,
  created_at, is_demo, status, published_at
) VALUES (
  0, '7wO304w7y7rT6wM', '自学成才的程序员创建 RealEstate.org，助力人们轻松发现低于市场价的经济适用房',
  '贝克特·泽赫迪和小德里克·韦伯斯特自学了软件开发，在了解了经济适用房危机后，他们创造了realerestate.org，帮助人们更容易找到低于市场价值的房子', '',
  3, 100, 62,
  262.898, 'http://oss.sxakgs.com/en/tk01/cover.webp',
  'http://oss.sxakgs.com/en/tk01/tk-01.mp4?v=2', 'http://oss.sxakgs.com/en/tk01/audio.mp3',
  'http://oss.sxakgs.com/en/tk01/tk-01.webp', 'https://www.tiktok.com/@abc7ny/video/7586739022223904055?q=software%20developer&t=1770742067256',
  (SELECT id FROM authors WHERE name = 'abc7ny' AND accent = '美国' LIMIT 1),
  NULL, NULL,
  '2026-06-25 16:26:40'::timestamp,
  TRUE, 'published',
  '2026-06-25 16:26:40'::timestamp
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
  SELECT s.id FROM subtitles s JOIN episodes e ON s.episode_id = e.id WHERE e.video_id = '7wO304w7y7rT6wM'
);
DELETE FROM subtitles WHERE episode_id = (SELECT id FROM episodes WHERE video_id = '7wO304w7y7rT6wM');
DELETE FROM episode_tags WHERE episode_id = (SELECT id FROM episodes WHERE video_id = '7wO304w7y7rT6wM');

INSERT INTO episode_tags (episode_id, tag_id)
SELECT e.id, t.id FROM episodes e, tags t
WHERE e.video_id = '7wO304w7y7rT6wM' AND t.name = '新闻'
ON CONFLICT DO NOTHING;
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 0, 0.0, 1.26, 'Oh, we thought this is pretty interesting.', '哦，我们觉得这挺有意思的。', '', '<span>Oh,</span> <span>we</span> <span>thought</span> <span>this</span> <span>is</span> <span>pretty</span> <span>interesting.</span>'
FROM episodes e WHERE e.video_id = '7wO304w7y7rT6wM';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 1, 1.261, 8.18, 'Two teenagers who have never yet paid rent in their lives, taught themselves how to code on a computer.', '两个从未付过房租的青少年，自学了电脑编程。', '', '<span>Two</span> <span>teenagers</span> <span>who</span> <span>have</span> <span>never</span> <span>yet</span> <span>paid</span> <span>rent</span> <span>in</span> <span>their</span> <span>lives,</span> <span>taught</span> <span>themselves</span> <span>how</span> <span>to</span> <span>code</span> <span>on</span> <span>a</span> <span>computer.</span>'
FROM episodes e WHERE e.video_id = '7wO304w7y7rT6wM';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 2, 8.181, 14.821, 'Developed a simple, free tool to find affordable, affordable, undervalued, and rent stabilized apartments in New York City.', '开发了一个简单免费的工具，用来寻找纽约市可负担、被低估和租金稳定的公寓。', '', '<span>Developed</span> <span>a</span> <span>simple,</span> <span>free</span> <span>tool</span> <span>to</span> <span>find</span> <span>affordable,</span> <span>affordable,</span> <span>undervalued,</span> <span>and</span> <span>rent</span> <span>stabilized</span> <span>apartments</span> <span>in</span> <span>New</span> <span>York</span> <span>City.</span>'
FROM episodes e WHERE e.video_id = '7wO304w7y7rT6wM';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 3, 14.822, 18.661, 'The site is called Real Reeler estate.org.', '这个网站叫Real Reeler estate.org。', '', '<span>The</span> <span>site</span> <span>is</span> <span>called</span> <span>Real</span> <span>Reeler</span> <span>estate.org.</span>'
FROM episodes e WHERE e.video_id = '7wO304w7y7rT6wM';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 4, 18.662, 19.061, 'That''s right.', '没错。', '', '<span>That''s</span> <span>right.</span>'
FROM episodes e WHERE e.video_id = '7wO304w7y7rT6wM';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 5, 19.062, 24.921, 'The teens built the site to scan public records and listings to make renters lives easier.', '这两个青少年建立了这个网站，扫描公共记录和房源信息，让租房者的生活更轻松。', '', '<span>The</span> <span>teens</span> <span>built</span> <span>the</span> <span>site</span> <span>to</span> <span>scan</span> <span>public</span> <span>records</span> <span>and</span> <span>listings</span> <span>to</span> <span>make</span> <span>renters</span> <span>lives</span> <span>easier.</span>'
FROM episodes e WHERE e.video_id = '7wO304w7y7rT6wM';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 6, 24.94, 30.801, 'Uh, they join us to talk about why they built it and how it works and how it can help you.', '他们加入我们，谈谈为什么建立这个网站，它如何运作，以及如何帮助你。', '', '<span>Uh,</span> <span>they</span> <span>join</span> <span>us</span> <span>to</span> <span>talk</span> <span>about</span> <span>why</span> <span>they</span> <span>built</span> <span>it</span> <span>and</span> <span>how</span> <span>it</span> <span>works</span> <span>and</span> <span>how</span> <span>it</span> <span>can</span> <span>help</span> <span>you.</span>'
FROM episodes e WHERE e.video_id = '7wO304w7y7rT6wM';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 7, 31.7, 41.981, 'Okay, so we are joined by Beckett Zehidi and Derrick Webster, who taught themselves to code real time data into a site called', '好的，我们请到了Beckett Zehidi和Derrick Webster，他们自学编程，将实时数据整合到一个名为', '', '<span>Okay,</span> <span>so</span> <span>we</span> <span>are</span> <span>joined</span> <span>by</span> <span>Beckett</span> <span>Zehidi</span> <span>and</span> <span>Derrick</span> <span>Webster,</span> <span>who</span> <span>taught</span> <span>themselves</span> <span>to</span> <span>code</span> <span>real</span> <span>time</span> <span>data</span> <span>into</span> <span>a</span> <span>site</span> <span>called</span>'
FROM episodes e WHERE e.video_id = '7wO304w7y7rT6wM';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 8, 41.982, 44.221, 'Realer Estate. Right.', 'Realer Estate的网站。对吧？', '', '<span>Realer</span> <span>Estate.</span> <span>Right.</span>'
FROM episodes e WHERE e.video_id = '7wO304w7y7rT6wM';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 9, 44.222, 45.341, 'Did I get it right? Yes.', '我说对了吗？是的。', '', '<span>Did</span> <span>I</span> <span>get</span> <span>it</span> <span>right?</span> <span>Yes.</span>'
FROM episodes e WHERE e.video_id = '7wO304w7y7rT6wM';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 10, 45.342, 46.661, 'Hello. Welcome.', '你们好，欢迎。', '', '<span>Hello.</span> <span>Welcome.</span>'
FROM episodes e WHERE e.video_id = '7wO304w7y7rT6wM';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 11, 46.662, 48.661, 'How did you guys come up with this idea?', '你们是怎么想到这个主意的？', '', '<span>How</span> <span>did</span> <span>you</span> <span>guys</span> <span>come</span> <span>up</span> <span>with</span> <span>this</span> <span>idea?</span>'
FROM episodes e WHERE e.video_id = '7wO304w7y7rT6wM';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 12, 48.662, 51.381, 'Yeah. Thank you guys for having us on here.', '谢谢你们邀请我们。', '', '<span>Yeah.</span> <span>Thank</span> <span>you</span> <span>guys</span> <span>for</span> <span>having</span> <span>us</span> <span>on</span> <span>here.</span>'
FROM episodes e WHERE e.video_id = '7wO304w7y7rT6wM';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 13, 51.382, 58.981, 'I really appreciate it. And so it started, um, you know, growing up, after my parents got divorced, I''ve been trying to help my dad find a more affordable apartment', '我非常感激。事情是这样的，在我父母离婚后，我一直想帮我爸爸找到一个更便宜的公寓', '', '<span>I</span> <span>really</span> <span>appreciate</span> <span>it.</span> <span>And</span> <span>so</span> <span>it</span> <span>started,</span> <span>um,</span> <span>you</span> <span>know,</span> <span>growing</span> <span>up,</span> <span>after</span> <span>my</span> <span>parents</span> <span>got</span> <span>divorced,</span> <span>I''ve</span> <span>been</span> <span>trying</span> <span>to</span> <span>help</span> <span>my</span> <span>dad</span> <span>find</span> <span>a</span> <span>more</span> <span>affordable</span> <span>apartment</span>'
FROM episodes e WHERE e.video_id = '7wO304w7y7rT6wM';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 14, 58.982, 64.141, 'in New York City. And, just through the process of going to open houses with him on weekends and just trying to, you know,', '在纽约市。通过周末和他一起去看房，以及', '', '<span>in</span> <span>New</span> <span>York</span> <span>City.</span> <span>And,</span> <span>just</span> <span>through</span> <span>the</span> <span>process</span> <span>of</span> <span>going</span> <span>to</span> <span>open</span> <span>houses</span> <span>with</span> <span>him</span> <span>on</span> <span>weekends</span> <span>and</span> <span>just</span> <span>trying</span> <span>to,</span> <span>you</span> <span>know,</span>'
FROM episodes e WHERE e.video_id = '7wO304w7y7rT6wM';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 15, 64.142, 69.541, 'scroll on street easy and find a home, uh, I just, you know, saw how difficult that process was, and, you know,', '在StreetEasy上滚动寻找房源，我看到了这个过程有多困难。', '', '<span>scroll</span> <span>on</span> <span>street</span> <span>easy</span> <span>and</span> <span>find</span> <span>a</span> <span>home,</span> <span>uh,</span> <span>I</span> <span>just,</span> <span>you</span> <span>know,</span> <span>saw</span> <span>how</span> <span>difficult</span> <span>that</span> <span>process</span> <span>was,</span> <span>and,</span> <span>you</span> <span>know,</span>'
FROM episodes e WHERE e.video_id = '7wO304w7y7rT6wM';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 16, 69.542, 74.381, 'growing up, I was just something I wanted to, you know, help him with, but I didn''t know how. And in,', '从小到大，我一直想帮他，但不知道怎么做。', '', '<span>growing</span> <span>up,</span> <span>I</span> <span>was</span> <span>just</span> <span>something</span> <span>I</span> <span>wanted</span> <span>to,</span> <span>you</span> <span>know,</span> <span>help</span> <span>him</span> <span>with,</span> <span>but</span> <span>I</span> <span>didn''t</span> <span>know</span> <span>how.</span> <span>And</span> <span>in,</span>'
FROM episodes e WHERE e.video_id = '7wO304w7y7rT6wM';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 17, 74.382, 78.541, 'you know, junior year, so last year, me and Derek started Getting interested in software development', '在高三，也就是去年，我和Derek开始对软件开发感兴趣', '', '<span>you</span> <span>know,</span> <span>junior</span> <span>year,</span> <span>so</span> <span>last</span> <span>year,</span> <span>me</span> <span>and</span> <span>Derek</span> <span>started</span> <span>Getting</span> <span>interested</span> <span>in</span> <span>software</span> <span>development</span>'
FROM episodes e WHERE e.video_id = '7wO304w7y7rT6wM';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 18, 78.542, 85.061, 'and just trying to learn how to code, um, various, like, apps and, um, different things. And one thing we,', '并尝试学习编程，开发各种应用和不同的东西。有一件事我们', '', '<span>and</span> <span>just</span> <span>trying</span> <span>to</span> <span>learn</span> <span>how</span> <span>to</span> <span>code,</span> <span>um,</span> <span>various,</span> <span>like,</span> <span>apps</span> <span>and,</span> <span>um,</span> <span>different</span> <span>things.</span> <span>And</span> <span>one</span> <span>thing</span> <span>we,</span>'
FROM episodes e WHERE e.video_id = '7wO304w7y7rT6wM';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 19, 85.062, 86.221, 'you know, want to take on.', '想尝试。', '', '<span>you</span> <span>know,</span> <span>want</span> <span>to</span> <span>take</span> <span>on.</span>'
FROM episodes e WHERE e.video_id = '7wO304w7y7rT6wM';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 20, 86.222, 92.421, 'After a economics debate in our class, um, we learn about, you know, how the affordable housing crisis is affecting,', '在班上的一次经济学辩论后，我们了解到可负担住房危机不仅影响', '', '<span>After</span> <span>a</span> <span>economics</span> <span>debate</span> <span>in</span> <span>our</span> <span>class,</span> <span>um,</span> <span>we</span> <span>learn</span> <span>about,</span> <span>you</span> <span>know,</span> <span>how</span> <span>the</span> <span>affordable</span> <span>housing</span> <span>crisis</span> <span>is</span> <span>affecting,</span>'
FROM episodes e WHERE e.video_id = '7wO304w7y7rT6wM';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 21, 92.422, 96.101, 'you know, more than just, like, my own family, but, you know, millions of others nationwide.', '我自己的家庭，还影响全国数百万其他人。', '', '<span>you</span> <span>know,</span> <span>more</span> <span>than</span> <span>just,</span> <span>like,</span> <span>my</span> <span>own</span> <span>family,</span> <span>but,</span> <span>you</span> <span>know,</span> <span>millions</span> <span>of</span> <span>others</span> <span>nationwide.</span>'
FROM episodes e WHERE e.video_id = '7wO304w7y7rT6wM';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 22, 96.102, 100.961, 'We thought, like, you know, let''s try to make a tool that makes it easier for New Yorkers to find affordable apartments.', '我们想，不如试着做一个工具，让纽约人更容易找到可负担的公寓。', '', '<span>We</span> <span>thought,</span> <span>like,</span> <span>you</span> <span>know,</span> <span>let''s</span> <span>try</span> <span>to</span> <span>make</span> <span>a</span> <span>tool</span> <span>that</span> <span>makes</span> <span>it</span> <span>easier</span> <span>for</span> <span>New</span> <span>Yorkers</span> <span>to</span> <span>find</span> <span>affordable</span> <span>apartments.</span>'
FROM episodes e WHERE e.video_id = '7wO304w7y7rT6wM';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 23, 101.28, 104.3, 'And so that was kind of the main inspiration.', '这就是主要的灵感来源。', '', '<span>And</span> <span>so</span> <span>that</span> <span>was</span> <span>kind</span> <span>of</span> <span>the</span> <span>main</span> <span>inspiration.</span>'
FROM episodes e WHERE e.video_id = '7wO304w7y7rT6wM';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 24, 104.301, 106.981, 'It was a whole process of building it, but, yeah.', '构建它是一个完整的过程，但，是的。', '', '<span>It</span> <span>was</span> <span>a</span> <span>whole</span> <span>process</span> <span>of</span> <span>building</span> <span>it,</span> <span>but,</span> <span>yeah.</span>'
FROM episodes e WHERE e.video_id = '7wO304w7y7rT6wM';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 25, 106.982, 113.421, 'So for people to realize there are a million rent stabilized apartments, actually 980,000 in New York,', '所以让人们意识到有100万套租金稳定的公寓，实际上是98万套在纽约，', '', '<span>So</span> <span>for</span> <span>people</span> <span>to</span> <span>realize</span> <span>there</span> <span>are</span> <span>a</span> <span>million</span> <span>rent</span> <span>stabilized</span> <span>apartments,</span> <span>actually</span> <span>980,000</span> <span>in</span> <span>New</span> <span>York,</span>'
FROM episodes e WHERE e.video_id = '7wO304w7y7rT6wM';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 26, 113.422, 114.941, 'about half of the apartments available.', '大约占可用公寓的一半。', '', '<span>about</span> <span>half</span> <span>of</span> <span>the</span> <span>apartments</span> <span>available.</span>'
FROM episodes e WHERE e.video_id = '7wO304w7y7rT6wM';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 27, 114.942, 118.101, 'Were you, like, amazed that no one has done this?', '你们有没有惊讶于之前没人做过这个？', '', '<span>Were</span> <span>you,</span> <span>like,</span> <span>amazed</span> <span>that</span> <span>no</span> <span>one</span> <span>has</span> <span>done</span> <span>this?</span>'
FROM episodes e WHERE e.video_id = '7wO304w7y7rT6wM';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 28, 118.102, 125.26, 'Yeah. And at the bottom of realtor estate.com, it, you have a little note about how much money people are saving.', '是的。在realtor estate.com的底部，你们有一个小提示，显示人们节省了多少钱。', '', '<span>Yeah.</span> <span>And</span> <span>at</span> <span>the</span> <span>bottom</span> <span>of</span> <span>realtor</span> <span>estate.com,</span> <span>it,</span> <span>you</span> <span>have</span> <span>a</span> <span>little</span> <span>note</span> <span>about</span> <span>how</span> <span>much</span> <span>money</span> <span>people</span> <span>are</span> <span>saving.</span>'
FROM episodes e WHERE e.video_id = '7wO304w7y7rT6wM';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 29, 125.261, 126.621, 'Yeah, tell us about that.', '是的，跟我们说说。', '', '<span>Yeah,</span> <span>tell</span> <span>us</span> <span>about</span> <span>that.</span>'
FROM episodes e WHERE e.video_id = '7wO304w7y7rT6wM';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 30, 126.622, 132.701, 'Yeah. So I was actually more so surprised of how difficult it is to even find a, for a rent stabilized apartment in New York City,', '好的。我其实更惊讶于在纽约市找到一套租金稳定的公寓有多难，', '', '<span>Yeah.</span> <span>So</span> <span>I</span> <span>was</span> <span>actually</span> <span>more</span> <span>so</span> <span>surprised</span> <span>of</span> <span>how</span> <span>difficult</span> <span>it</span> <span>is</span> <span>to</span> <span>even</span> <span>find</span> <span>a,</span> <span>for</span> <span>a</span> <span>rent</span> <span>stabilized</span> <span>apartment</span> <span>in</span> <span>New</span> <span>York</span> <span>City,</span>'
FROM episodes e WHERE e.video_id = '7wO304w7y7rT6wM';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 31, 132.702, 135.901, 'because there''s only one, like, city list called the DHCR.', '因为只有一个城市列表叫DHCR。', '', '<span>because</span> <span>there''s</span> <span>only</span> <span>one,</span> <span>like,</span> <span>city</span> <span>list</span> <span>called</span> <span>the</span> <span>DHCR.</span>'
FROM episodes e WHERE e.video_id = '7wO304w7y7rT6wM';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 32, 135.902, 142.461, 'So division of Housing, Community Renewal, rent stabilized building list that has just, you know, 6,000 rent stabilized buildings in,', '也就是住房和社区重建部，租金稳定建筑列表，里面只有6000栋租金稳定的建筑，', '', '<span>So</span> <span>division</span> <span>of</span> <span>Housing,</span> <span>Community</span> <span>Renewal,</span> <span>rent</span> <span>stabilized</span> <span>building</span> <span>list</span> <span>that</span> <span>has</span> <span>just,</span> <span>you</span> <span>know,</span> <span>6,000</span> <span>rent</span> <span>stabilized</span> <span>buildings</span> <span>in,</span>'
FROM episodes e WHERE e.video_id = '7wO304w7y7rT6wM';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 33, 142.462, 148.001, 'you know, this kind of Byzantine, uh, order. And most renters I''ve spoken to don''t even know it exists.', '以一种拜占庭式的顺序排列。我接触过的大多数租房者甚至不知道它的存在。', '', '<span>you</span> <span>know,</span> <span>this</span> <span>kind</span> <span>of</span> <span>Byzantine,</span> <span>uh,</span> <span>order.</span> <span>And</span> <span>most</span> <span>renters</span> <span>I''ve</span> <span>spoken</span> <span>to</span> <span>don''t</span> <span>even</span> <span>know</span> <span>it</span> <span>exists.</span>'
FROM episodes e WHERE e.video_id = '7wO304w7y7rT6wM';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 34, 148.08, 153.061, 'And so I thought, like, you know, there''s no way This is the best, best way to find a rent stabilized apartments.', '所以我想，这不可能是找到租金稳定公寓的最佳方式。', '', '<span>And</span> <span>so</span> <span>I</span> <span>thought,</span> <span>like,</span> <span>you</span> <span>know,</span> <span>there''s</span> <span>no</span> <span>way</span> <span>This</span> <span>is</span> <span>the</span> <span>best,</span> <span>best</span> <span>way</span> <span>to</span> <span>find</span> <span>a</span> <span>rent</span> <span>stabilized</span> <span>apartments.</span>'
FROM episodes e WHERE e.video_id = '7wO304w7y7rT6wM';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 35, 153.062, 154.301, 'Like, let''s try to make this easier.', '让我们试着让它更容易。', '', '<span>Like,</span> <span>let''s</span> <span>try</span> <span>to</span> <span>make</span> <span>this</span> <span>easier.</span>'
FROM episodes e WHERE e.video_id = '7wO304w7y7rT6wM';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 36, 154.302, 159.741, 'And so we built real estate to cross reference every single listing, you know, on the market in New York City right now', '所以我们建立了这个网站，交叉引用纽约市市场上每一个房源', '', '<span>And</span> <span>so</span> <span>we</span> <span>built</span> <span>real</span> <span>estate</span> <span>to</span> <span>cross</span> <span>reference</span> <span>every</span> <span>single</span> <span>listing,</span> <span>you</span> <span>know,</span> <span>on</span> <span>the</span> <span>market</span> <span>in</span> <span>New</span> <span>York</span> <span>City</span> <span>right</span> <span>now</span>'
FROM episodes e WHERE e.video_id = '7wO304w7y7rT6wM';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 37, 159.742, 165.921, 'with this rent stabilized building list so you can know what listings are rent stabilized and have a little bit more information in the market.', '与这个租金稳定建筑列表，这样你就能知道哪些房源是租金稳定的，并在市场上获得更多信息。', '', '<span>with</span> <span>this</span> <span>rent</span> <span>stabilized</span> <span>building</span> <span>list</span> <span>so</span> <span>you</span> <span>can</span> <span>know</span> <span>what</span> <span>listings</span> <span>are</span> <span>rent</span> <span>stabilized</span> <span>and</span> <span>have</span> <span>a</span> <span>little</span> <span>bit</span> <span>more</span> <span>information</span> <span>in</span> <span>the</span> <span>market.</span>'
FROM episodes e WHERE e.video_id = '7wO304w7y7rT6wM';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 38, 165.98, 168.5, 'Okay. And you had to teach yourself coding too?', '好的。你们还自学了编程？', '', '<span>Okay.</span> <span>And</span> <span>you</span> <span>had</span> <span>to</span> <span>teach</span> <span>yourself</span> <span>coding</span> <span>too?</span>'
FROM episodes e WHERE e.video_id = '7wO304w7y7rT6wM';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 39, 168.501, 169.221, 'You did? Yeah.', '你们自学了？是的。', '', '<span>You</span> <span>did?</span> <span>Yeah.</span>'
FROM episodes e WHERE e.video_id = '7wO304w7y7rT6wM';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 40, 169.222, 179.441, 'So over the summer, me and Becca were just starting from small tank scrappy tools, where we taught ourselves how to software,', '所以整个夏天，我和贝卡从小型坦克刮刀工具开始，我们自学了如何编程，', '', '<span>So</span> <span>over</span> <span>the</span> <span>summer,</span> <span>me</span> <span>and</span> <span>Becca</span> <span>were</span> <span>just</span> <span>starting</span> <span>from</span> <span>small</span> <span>tank</span> <span>scrappy</span> <span>tools,</span> <span>where</span> <span>we</span> <span>taught</span> <span>ourselves</span> <span>how</span> <span>to</span> <span>software,</span>'
FROM episodes e WHERE e.video_id = '7wO304w7y7rT6wM';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 41, 179.58, 187.721, 'software develop. And we first built a, uh, a kind of tool to help us with math, uh, cause we had a midterm coming up', '软件开发。我们首先构建了一个，呃，一个帮助我们学习数学的工具，呃，因为我们要期中考试了', '', '<span>software</span> <span>develop.</span> <span>And</span> <span>we</span> <span>first</span> <span>built</span> <span>a,</span> <span>uh,</span> <span>a</span> <span>kind</span> <span>of</span> <span>tool</span> <span>to</span> <span>help</span> <span>us</span> <span>with</span> <span>math,</span> <span>uh,</span> <span>cause</span> <span>we</span> <span>had</span> <span>a</span> <span>midterm</span> <span>coming</span> <span>up</span>'
FROM episodes e WHERE e.video_id = '7wO304w7y7rT6wM';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 42, 187.722, 189.821, 'and that really kind of helped us early on.', '这确实在早期帮了我们很多。', '', '<span>and</span> <span>that</span> <span>really</span> <span>kind</span> <span>of</span> <span>helped</span> <span>us</span> <span>early</span> <span>on.</span>'
FROM episodes e WHERE e.video_id = '7wO304w7y7rT6wM';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 43, 189.822, 199.061, 'And when we kind of got more involved, uh, educated ourselves about the affordable housing crisis from our economics class, that''s when I started to ask myself, well,', '当我们更加投入，呃，从经济学课上了解到经济适用房危机后，我开始问自己，嗯，', '', '<span>And</span> <span>when</span> <span>we</span> <span>kind</span> <span>of</span> <span>got</span> <span>more</span> <span>involved,</span> <span>uh,</span> <span>educated</span> <span>ourselves</span> <span>about</span> <span>the</span> <span>affordable</span> <span>housing</span> <span>crisis</span> <span>from</span> <span>our</span> <span>economics</span> <span>class,</span> <span>that''s</span> <span>when</span> <span>I</span> <span>started</span> <span>to</span> <span>ask</span> <span>myself,</span> <span>well,</span>'
FROM episodes e WHERE e.video_id = '7wO304w7y7rT6wM';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 44, 199.062, 203.921, 'how can we start helping renters before they even get into the real estate market?', '我们如何在租户进入房地产市场之前就开始帮助他们？', '', '<span>how</span> <span>can</span> <span>we</span> <span>start</span> <span>helping</span> <span>renters</span> <span>before</span> <span>they</span> <span>even</span> <span>get</span> <span>into</span> <span>the</span> <span>real</span> <span>estate</span> <span>market?</span>'
FROM episodes e WHERE e.video_id = '7wO304w7y7rT6wM';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 45, 203.922, 211.541, 'Because it''s so lacking transparency, uh, we look towards, uh, public data and resources that people know about', '因为市场缺乏透明度，呃，我们转向了，呃，人们知道但无法消化的公共数据和资源。', '', '<span>Because</span> <span>it''s</span> <span>so</span> <span>lacking</span> <span>transparency,</span> <span>uh,</span> <span>we</span> <span>look</span> <span>towards,</span> <span>uh,</span> <span>public</span> <span>data</span> <span>and</span> <span>resources</span> <span>that</span> <span>people</span> <span>know</span> <span>about</span>'
FROM episodes e WHERE e.video_id = '7wO304w7y7rT6wM';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 46, 211.542, 213.841, 'but aren''t really able to digest.', '但人们无法真正消化这些信息。', '', '<span>but</span> <span>aren''t</span> <span>really</span> <span>able</span> <span>to</span> <span>digest.</span>'
FROM episodes e WHERE e.video_id = '7wO304w7y7rT6wM';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 47, 213.86, 222.66, 'And our site is able to really, uh, help with, help a lot of people in New York City, uh, you know, supplying the information about, uh,', '我们的网站能够真正帮助，呃，帮助纽约市的很多人，呃，你知道，提供关于，呃，', '', '<span>And</span> <span>our</span> <span>site</span> <span>is</span> <span>able</span> <span>to</span> <span>really,</span> <span>uh,</span> <span>help</span> <span>with,</span> <span>help</span> <span>a</span> <span>lot</span> <span>of</span> <span>people</span> <span>in</span> <span>New</span> <span>York</span> <span>City,</span> <span>uh,</span> <span>you</span> <span>know,</span> <span>supplying</span> <span>the</span> <span>information</span> <span>about,</span> <span>uh,</span>'
FROM episodes e WHERE e.video_id = '7wO304w7y7rT6wM';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 48, 222.661, 227.941, 'you know, affordable, below market value of homes that they wouldn''t know anywhere else.', '你知道，经济适用房、低于市场价的房屋信息，这些信息在其他地方找不到。', '', '<span>you</span> <span>know,</span> <span>affordable,</span> <span>below</span> <span>market</span> <span>value</span> <span>of</span> <span>homes</span> <span>that</span> <span>they</span> <span>wouldn''t</span> <span>know</span> <span>anywhere</span> <span>else.</span>'
FROM episodes e WHERE e.video_id = '7wO304w7y7rT6wM';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 49, 227.942, 234.781, 'And we kind of focus more on that accessibility, Of information to really help people navigate the affordable housing crisis', '我们更注重信息的可获取性，以真正帮助人们应对经济适用房危机', '', '<span>And</span> <span>we</span> <span>kind</span> <span>of</span> <span>focus</span> <span>more</span> <span>on</span> <span>that</span> <span>accessibility,</span> <span>Of</span> <span>information</span> <span>to</span> <span>really</span> <span>help</span> <span>people</span> <span>navigate</span> <span>the</span> <span>affordable</span> <span>housing</span> <span>crisis</span>'
FROM episodes e WHERE e.video_id = '7wO304w7y7rT6wM';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 50, 234.782, 236.281, 'right now at this stage.', '在当前这个阶段。', '', '<span>right</span> <span>now</span> <span>at</span> <span>this</span> <span>stage.</span>'
FROM episodes e WHERE e.video_id = '7wO304w7y7rT6wM';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 51, 237.26, 239.02, 'Brilliant, right? Right?', '太棒了，对吧？对吧？', '', '<span>Brilliant,</span> <span>right?</span> <span>Right?</span>'
FROM episodes e WHERE e.video_id = '7wO304w7y7rT6wM';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 52, 239.021, 240.061, 'I know. Innovative.', '我知道。很有创新性。', '', '<span>I</span> <span>know.</span> <span>Innovative.</span>'
FROM episodes e WHERE e.video_id = '7wO304w7y7rT6wM';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 53, 240.062, 242.821, 'They were like, wow, no adults done this. We''re gonna do this.', '他们就像，哇，没有成年人做过这个。我们要做这个。', '', '<span>They</span> <span>were</span> <span>like,</span> <span>wow,</span> <span>no</span> <span>adults</span> <span>done</span> <span>this.</span> <span>We''re</span> <span>gonna</span> <span>do</span> <span>this.</span>'
FROM episodes e WHERE e.video_id = '7wO304w7y7rT6wM';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 54, 242.822, 244.981, 'I asked them, have you ever had a job?', '我问他们，你们打过工吗？', '', '<span>I</span> <span>asked</span> <span>them,</span> <span>have</span> <span>you</span> <span>ever</span> <span>had</span> <span>a</span> <span>job?</span>'
FROM episodes e WHERE e.video_id = '7wO304w7y7rT6wM';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 55, 244.982, 247.841, 'No. I mean, they''re 17. Yeah, um. Haha.', '没有。我是说，他们才17岁。是啊，嗯。哈哈。', '', '<span>No.</span> <span>I</span> <span>mean,</span> <span>they''re</span> <span>17.</span> <span>Yeah,</span> <span>um.</span> <span>Haha.</span>'
FROM episodes e WHERE e.video_id = '7wO304w7y7rT6wM';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 56, 248.14, 250.34, 'Have you ever paid rent? No. Um.', '你们付过房租吗？没有。嗯。', '', '<span>Have</span> <span>you</span> <span>ever</span> <span>paid</span> <span>rent?</span> <span>No.</span> <span>Um.</span>'
FROM episodes e WHERE e.video_id = '7wO304w7y7rT6wM';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 57, 250.341, 256.541, 'And they''ve never had allowance, so, you know, you know, 17 years old, I was still trying to figure out how I was gonna ask my parents', '而且他们从来没有零花钱，所以，你知道，你知道，17岁的时候，我还在想怎么问我父母', '', '<span>And</span> <span>they''ve</span> <span>never</span> <span>had</span> <span>allowance,</span> <span>so,</span> <span>you</span> <span>know,</span> <span>you</span> <span>know,</span> <span>17</span> <span>years</span> <span>old,</span> <span>I</span> <span>was</span> <span>still</span> <span>trying</span> <span>to</span> <span>figure</span> <span>out</span> <span>how</span> <span>I</span> <span>was</span> <span>gonna</span> <span>ask</span> <span>my</span> <span>parents</span>'
FROM episodes e WHERE e.video_id = '7wO304w7y7rT6wM';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 58, 256.542, 257.701, 'to go to the party across town.', '能不能去城那边的派对。', '', '<span>to</span> <span>go</span> <span>to</span> <span>the</span> <span>party</span> <span>across</span> <span>town.</span>'
FROM episodes e WHERE e.video_id = '7wO304w7y7rT6wM';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 59, 257.702, 258.541, 'All of us. All of us.', '我们所有人。我们所有人。', '', '<span>All</span> <span>of</span> <span>us.</span> <span>All</span> <span>of</span> <span>us.</span>'
FROM episodes e WHERE e.video_id = '7wO304w7y7rT6wM';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 60, 258.542, 260.401, 'And listen to these guys. Good job, guys.', '听听这些家伙。干得好，伙计们。', '', '<span>And</span> <span>listen</span> <span>to</span> <span>these</span> <span>guys.</span> <span>Good</span> <span>job,</span> <span>guys.</span>'
FROM episodes e WHERE e.video_id = '7wO304w7y7rT6wM';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 61, 260.62, 262.898, 'What an honor to be. Well done. Well done.', '多么荣幸。做得好。做得好。', '', '<span>What</span> <span>an</span> <span>honor</span> <span>to</span> <span>be.</span> <span>Well</span> <span>done.</span> <span>Well</span> <span>done.</span>'
FROM episodes e WHERE e.video_id = '7wO304w7y7rT6wM';

-- episode 0: 7cDe7KDz5VDVJ9s
INSERT INTO episodes (
  index, video_id, short_title, summary, remark, stars, voca_size,
  subtitle_count, clip_length, cover, video_url, audio_url, thumbnail_url,
  original_video_url, author_id, submitted_by_user_id, rejection_reason,
  created_at, is_demo, status, published_at
) VALUES (
  0, '7cDe7KDz5VDVJ9s', '父母是最好的榜样：家庭教育影响一生',
  '父母永远都是最好的榜样 一个好的家庭教育真的会影响一个人的一生', '用户投稿 (user #1)',
  4, 18, 8,
  54.128, 'http://oss.sxakgs.com/en/7655018263562243359/cover.webp',
  'http://oss.sxakgs.com/en/7655018263562243359/video.mp4', 'http://oss.sxakgs.com/en/7655018263562243359/audio.mp3',
  'http://oss.sxakgs.com/en/7655018263562243359/cover.webp', 'https://www.tiktok.com/@user2171291792157/video/7655018263562243359',
  (SELECT id FROM authors WHERE name = 'user2171291792157' AND accent = '美国' LIMIT 1),
  NULL, NULL,
  '2026-06-25 19:56:54'::timestamp,
  FALSE, 'published',
  '2026-06-25 19:56:54'::timestamp
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
  SELECT s.id FROM subtitles s JOIN episodes e ON s.episode_id = e.id WHERE e.video_id = '7cDe7KDz5VDVJ9s'
);
DELETE FROM subtitles WHERE episode_id = (SELECT id FROM episodes WHERE video_id = '7cDe7KDz5VDVJ9s');
DELETE FROM episode_tags WHERE episode_id = (SELECT id FROM episodes WHERE video_id = '7cDe7KDz5VDVJ9s');

INSERT INTO episode_tags (episode_id, tag_id)
SELECT e.id, t.id FROM episodes e, tags t
WHERE e.video_id = '7cDe7KDz5VDVJ9s' AND t.name = '新闻'
ON CONFLICT DO NOTHING;
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 0, 0.02, 7.02, 'My mom didn''t even know how to speak English, but it didn''t stop her from every single day teaching us English.', '我妈妈甚至不会说英语，但这并没有阻止她每天教我们英语。', '/maɪ mɑm ˈdɪdənt ˈiːvən noʊ haʊ tə spiːk ˈɪŋɡlɪʃ bət ɪt ˈdɪdənt ˈstɑp hər frəm ˈɛvri ˈsɪŋɡəl deɪ ˈtitʃɪŋ əs ˈɪŋɡlɪʃ/', '<span>My</span><span>mom</span><span>didn''t</span><span>even</span><span>know</span><span>how</span><span>to</span><span>speak</span><span>English</span><span>,</span><span>but</span><span>it</span><span>didn''t</span><span>stop</span><span>her</span><span>from</span><span pid="501" class="highlight highlight-i">every single day</span><span>teaching</span><span>us</span><span>English</span><span>.</span>'
FROM episodes e WHERE e.video_id = '7cDe7KDz5VDVJ9s';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 1, 7.021, 12.001, 'I mean, how, how is it possible that somebody who has no clue of English be teaching us English?', '我的意思是，一个完全不懂英语的人怎么可能教我们英语呢？', '/aɪ min haʊ haʊ ɪz ɪt ˈpɑsəbəl ðət ˈsʌmbədi hu hæz noʊ kluː əv ˈɪŋɡlɪʃ bi ˈtitʃɪŋ əs ˈɪŋɡlɪʃ/', '<span>I</span><span>mean</span><span>,</span><span>how</span><span>,</span><span>how</span><span>is</span><span>it</span><span>possible</span><span>that</span><span>somebody</span><span>who</span><span>has</span><span pid="502" class="highlight highlight-i">no clue of</span><span>English</span><span>be</span><span>teaching</span><span>us</span><span>English</span><span>?</span>'
FROM episodes e WHERE e.video_id = '7cDe7KDz5VDVJ9s';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 2, 12.3, 15.761, 'And my mom didn''t even graduate from high school, I don''t think. Okay.', '而且我妈妈甚至没有高中毕业，我觉得。好吧。', '/ənd maɪ mɑm ˈdɪdənt ˈiːvən ˈɡrædʒuˌeɪt frəm haɪ skuːl aɪ doʊnt θɪŋk oʊˈkeɪ/', '<span>And</span><span>my</span><span>mom</span><span>didn''t</span><span>even</span><span>graduate</span><span>from</span><span>high school</span><span>,</span><span>I</span><span>don''t</span><span>think</span><span>.</span><span>Okay</span><span>.</span>'
FROM episodes e WHERE e.video_id = '7cDe7KDz5VDVJ9s';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 3, 15.82, 26.061, 'And, and, um, and so she just bought a Webster''s dictionary and, and, uh, you know, wrote, wrote the English word. She Learned how just by looking at the patterns,', '然后，她就买了一本韦氏词典，然后，呃，你知道，写下英语单词。她只是通过看模式学会了。', '/ənd ənd maɪ mɑm ˈdɪdənt ˈiːvən ˈɡrædʒuˌeɪt frəm haɪ skuːl aɪ doʊnt θɪŋk oʊˈkeɪ/', '<span>And</span><span>,</span><span>and</span><span>,</span><span>um</span><span>,</span><span>and</span><span>so</span><span>she</span><span>just</span><span>bought</span><span>a</span><span>Webster''s dictionary</span><span>and</span><span>,</span><span>and</span><span>,</span><span>uh</span><span>,</span><span pid="503" class="highlight highlight-i">you know</span><span>,</span><span>wrote</span><span>,</span><span>wrote</span><span>the</span><span>English</span><span>word</span><span>.</span><span>She</span><span>Learned</span><span>how</span><span>just</span><span>by</span><span pid="504" class="highlight highlight-d">looking at</span><span>the</span><span>patterns</span><span>,</span>'
FROM episodes e WHERE e.video_id = '7cDe7KDz5VDVJ9s';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 4, 26.062, 33.641, 'wrote the word and wrote the Chinese translation, folded a piece of paper in half and, and then made, made us, uh,', '写下单词和中文翻译，把一张纸对折，然后让我们，呃，', '/roʊt ðə wɜːrd ənd roʊt ðə ˈtʃaɪˈniːz trænsˈleɪʃən foʊld ə piːs əv ˈpeɪpər ɪn hælf ənd ənd meɪd mʌs ə/', '<span>wrote</span><span>the</span><span>word</span><span>and</span><span>wrote</span><span>the</span><span>Chinese</span><span>translation</span><span>,</span><span>folded</span><span>a</span><span>piece of paper</span><span pid="505" class="highlight highlight-c">in half</span><span>and</span><span>,</span><span>and</span><span>then</span><span>made</span><span>,</span><span>made</span><span>us</span><span>,</span><span>uh</span><span>,</span>'
FROM episodes e WHERE e.video_id = '7cDe7KDz5VDVJ9s';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 5, 33.78, 43.161, 'you know, memorize all these words and, um, I don''t know if we''re pronouncing it right. And, but anyhow, that, that,', '你知道，记住所有这些单词，呃，我不知道我们发音是否正确。但不管怎样，那，那，', '/jə noʊ ˈmɛməraɪz ɔːl ðiːz wɜːrdz ənd əm aɪ doʊnt noʊ ɪf wiːr prəˈnaʊnsɪŋ ɪt raɪt ənd bət ˈɛniˌhaʊ ðæt ðæt/', '<span pid="506" class="highlight highlight-i">you know</span><span>,</span><span tid="50001" class="highlight highlight-a">memorize</span><span>all</span><span>these</span><span>words</span><span>and</span><span>,</span><span>um</span><span>,</span><span>I</span><span>don''t</span><span>know</span><span>if</span><span>we''re</span><span tid="50002" class="highlight highlight-a">pronouncing</span><span>it</span><span>right</span><span>.</span><span>And</span><span>,</span><span>but</span><span>anyhow</span><span>,</span><span>that</span><span>,</span><span>that</span><span>,</span>'
FROM episodes e WHERE e.video_id = '7cDe7KDz5VDVJ9s';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 6, 43.26, 50.361, 'that taught me something about, about someone with, with incredible will that even if you don''t know how to do something,', '那教会了我一些关于，关于一个有着不可思议意志力的人，即使你不知道怎么做某事，', '/ðæt tɔːt mi ˈsʌmθɪŋ əˈbaʊt əˈbaʊt ˈsʌmwʌn wɪð wɪð ɪnˈkrɛdəbəl wɪl ðət ˈiːvən ɪf juː doʊnt noʊ haʊ tə duː ˈsʌmθɪŋ/', '<span>that</span><span>taught</span><span>me</span><span>something</span><span>about</span><span>,</span><span>about</span><span>someone</span><span>with</span><span>,</span><span>with</span><span tid="50003" class="highlight highlight-a">incredible</span><span>will</span><span>that</span><span>even</span><span>if</span><span>you</span><span>don''t</span><span>know</span><span>how</span><span>to</span><span>do</span><span>something</span><span>,</span>'
FROM episodes e WHERE e.video_id = '7cDe7KDz5VDVJ9s';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 7, 51.42, 54.128, 'it shouldn''t stop you. You know, how hard can it be?', '它也不应该阻止你。你知道，能有多难呢？', '/ɪt ˈʃʊdənt stɑp juː jə noʊ haʊ hɑːrd kæn ɪt biː/', '<span>it</span><span>shouldn''t</span><span>stop</span><span>you</span><span>.</span><span>You</span><span>know</span><span>,</span><span>how</span><span>hard</span><span>can</span><span>it</span><span>be</span><span>?</span>'
FROM episodes e WHERE e.video_id = '7cDe7KDz5VDVJ9s';

-- episode 0: A2lf_e3bIcXxIJY
INSERT INTO episodes (
  index, video_id, short_title, summary, remark, stars, voca_size,
  subtitle_count, clip_length, cover, video_url, audio_url, thumbnail_url,
  original_video_url, author_id, submitted_by_user_id, rejection_reason,
  created_at, is_demo, status, published_at
) VALUES (
  0, 'A2lf_e3bIcXxIJY', '黄仁勋的第一次爱情故事',
  '有时候遇到一个人会改变我们的人生 让我们听听黄仁勋第一次遇到爱情', '',
  3, 15, 0,
  0.0, 'http://oss.sxakgs.com/en/7656512012335336734/cover.webp',
  'http://oss.sxakgs.com/en/7656512012335336734/video.mp4', 'http://oss.sxakgs.com/en/7656512012335336734/audio.mp3',
  'http://oss.sxakgs.com/en/7656512012335336734/cover.webp', 'https://www.tiktok.com/@chen971031/video/7656512012335336734',
  (SELECT id FROM authors WHERE name = 'chen971031' AND accent = '美国' LIMIT 1),
  NULL, NULL,
  '2026-06-29 12:00:01'::timestamp,
  FALSE, 'published',
  '2026-06-29 12:00:01'::timestamp
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
  SELECT s.id FROM subtitles s JOIN episodes e ON s.episode_id = e.id WHERE e.video_id = 'A2lf_e3bIcXxIJY'
);
DELETE FROM subtitles WHERE episode_id = (SELECT id FROM episodes WHERE video_id = 'A2lf_e3bIcXxIJY');
DELETE FROM episode_tags WHERE episode_id = (SELECT id FROM episodes WHERE video_id = 'A2lf_e3bIcXxIJY');

INSERT INTO episode_tags (episode_id, tag_id)
SELECT e.id, t.id FROM episodes e, tags t
WHERE e.video_id = 'A2lf_e3bIcXxIJY' AND t.name = '演讲'
ON CONFLICT DO NOTHING;

-- episode 0: LgYY-X3UwLxRpx4
INSERT INTO episodes (
  index, video_id, short_title, summary, remark, stars, voca_size,
  subtitle_count, clip_length, cover, video_url, audio_url, thumbnail_url,
  original_video_url, author_id, submitted_by_user_id, rejection_reason,
  created_at, is_demo, status, published_at
) VALUES (
  0, 'LgYY-X3UwLxRpx4', '纽约夏日城市探索Vlog',
  '我最喜欢的纽约Vlog；和我一起探索吧😊 Insta → https://www.instagram.com/taykbell/ 🐢
由本人撰写、拍摄和剪辑。免费订阅，别忘了猛戳点赞按钮，我会永远爱你。
加入我的邮件列表，了解即将到来的精彩活动！https://forms.gle/wNHxBpKmFEn4TKT17
👥 在LinkedIn上关注我：https://tinyurl.com/5n6ddrnv
TikTok：https://tinyurl.com/a2k9vxmd
视频中展示/提到的物品：
我的咖啡机：https://amzn.to/3Z9Se9S
CEO日记播客/YouTube频道：
✨ 我使用的拍摄设备 ✨
➢ 相机（也就是我的手机）：iPhone 15 Pro Max
➢ Rode Wireless Go II麦克风系统：https://amzn.to/3Le5RMV
➢ 迷你领夹麦克风：https://amzn.to/3LhZyI3
➢ 坐姿拍摄麦克风：https://amzn.to/3prIXGU
➢ 坐姿拍摄柔光箱套件：https://amzn.to/3MxJyWh
➢ 手机手持Vlog稳定器：https://amzn.to/3pzDT36
➢ 降噪耳机：https://amzn.to/3bmx4Nt
➢ 三脚架环形灯：https://amzn.to/2ZtGO2L
🎵 音乐
➢ Epidemic Sound → 使用链接免费试用 https://www.epidemicsound.com/referral/lv6f1q
➢ iSaintJames → https://soundcloud.com/isaintjames
➢ GurtyBeats → https://soundcloud.com/gurtybeats
🎧 在Spotify上关注我：https://open.spotify.com/user/iamteebell?si=99ab8ae2a05c487a
💪🏼 健身课程：使用我的推荐码注册Class Pass（我们都能获得积分！）https://classpass.com/refer/PEEA1TMA29
标签：nyc vlog, day in the life, exploring nyc, running around the city, taylor bell, nyc vlog day in my life, life in nyc vlog, east village nyc, east village nyc, downtown manhattan, nyc soho, nyc subway, going out in nyc, walking around nyc, living in nyc vlog, a day in nyc vlog, nyc day in my life, creator in nyc, realistic life in nyc, nyc in my 20s, life in nyc alone, exploring nyc alone, honest day in the life, taykbell, exploring manhattan, nyc vlogger
FTC：本视频未受赞助。以上部分链接可能是联盟链接，意味着我可能获得一小部分销售额...', '',
  4, 254, 532,
  0.0, 'http://oss.sxakgs.com/en/OHE1Rtoy1_k/cover.webp',
  'http://oss.sxakgs.com/en/OHE1Rtoy1_k/video.mp4', 'http://oss.sxakgs.com/en/OHE1Rtoy1_k/audio.mp3',
  'http://oss.sxakgs.com/en/OHE1Rtoy1_k/cover.webp', 'https://www.youtube.com/watch?v=OHE1Rtoy1_k',
  (SELECT id FROM authors WHERE name = 'Taylor Bell' AND accent = '美国' LIMIT 1),
  NULL, NULL,
  '2026-06-29 12:59:41'::timestamp,
  FALSE, 'published',
  '2026-06-29 12:59:41'::timestamp
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
  SELECT s.id FROM subtitles s JOIN episodes e ON s.episode_id = e.id WHERE e.video_id = 'LgYY-X3UwLxRpx4'
);
DELETE FROM subtitles WHERE episode_id = (SELECT id FROM episodes WHERE video_id = 'LgYY-X3UwLxRpx4');
DELETE FROM episode_tags WHERE episode_id = (SELECT id FROM episodes WHERE video_id = 'LgYY-X3UwLxRpx4');

INSERT INTO episode_tags (episode_id, tag_id)
SELECT e.id, t.id FROM episodes e, tags t
WHERE e.video_id = 'LgYY-X3UwLxRpx4' AND t.name = '生活'
ON CONFLICT DO NOTHING;
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 0, 22.39, 0.0, '[Music]', '', '', '<span>[Music]</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 1, 22.4, 0.0, '[Music] something', '', '', '<span>[Music]</span><span>something</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 2, 36.03, 0.0, 'oh hello there it is yet another', '', '', '<span>oh</span><span>hello</span><span>there</span><span>it</span><span>is</span><span>yet</span><span>another</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 3, 36.04, 0.0, 'oh hello there it is yet another blistering<00:00:36.680><c> 92</c><00:00:37.239><c> degree</c><00:00:37.600><c> day</c><00:00:37.760><c> here</c><00:00:37.960><c> in</c><00:00:38.079><c> New</c>', '', '', '<span>oh</span><span>hello</span><span>there</span><span>it</span><span>is</span><span>yet</span><span>another</span><span>blistering<00:00:36.680><c></span><span>92</c><00:00:37.239><c></span><span>degree</c><00:00:37.600><c></span><span>day</c><00:00:37.760><c></span><span>here</c><00:00:37.960><c></span><span>in</c><00:00:38.079><c></span><span>New</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 4, 38.19, 0.0, 'blistering 92 degree day here in New', '', '', '<span tid="50001" class="highlight highlight-a">blistering</span><span>92</span><span>degree</span><span>day</span><span>here</span><span>in</span><span>New</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 5, 38.2, 0.0, 'blistering 92 degree day here in New York<00:00:38.399><c> City</c><00:00:38.840><c> and</c><00:00:39.000><c> mind</c><00:00:39.160><c> you</c><00:00:39.320><c> that''s</c><00:00:39.440><c> with</c>', '', '', '<span>blistering</span><span>92</span><span>degree</span><span>day</span><span>here</span><span>in</span><span>New</span><span>York<00:00:38.399><c></span><span>City</c><00:00:38.840><c></span><span>and</c><00:00:39.000><c></span><span>mind</c><00:00:39.160><c></span><span>you</c><00:00:39.320><c></span><span>that''s</c><00:00:39.440><c></span><span>with</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 6, 39.59, 0.0, 'York City and mind you that''s with', '', '', '<span>York</span><span>City</span><span>and</span><span>mind</span><span>you</span><span>that''s</span><span>with</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 7, 39.6, 0.0, 'York City and mind you that''s with humidity<00:00:39.960><c> so</c><00:00:40.079><c> it</c><00:00:40.160><c> feels</c><00:00:40.440><c> closer</c><00:00:40.719><c> to</c><00:00:41.039><c> 100</c><00:00:41.440><c> it</c>', '', '', '<span>York</span><span>City</span><span>and</span><span>mind</span><span>you</span><span>that''s</span><span>with</span><span>humidity<00:00:39.960><c></span><span>so</c><00:00:40.079><c></span><span>it</c><00:00:40.160><c></span><span>feels</c><00:00:40.440><c></span><span>closer</c><00:00:40.719><c></span><span>to</c><00:00:41.039><c></span><span>100</c><00:00:41.440><c></span><span>it</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 8, 41.549, 0.0, 'humidity so it feels closer to 100 it', '', '', '<span tid="50002" class="highlight highlight-a">humidity</span><span>so</span><span>it</span><span>feels</span><span>closer</span><span>to</span><span>100</span><span>it</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 9, 41.559, 0.0, 'humidity so it feels closer to 100 it has<00:00:41.800><c> actually</c><00:00:42.120><c> been</c><00:00:42.520><c> insane</c><00:00:43.000><c> and</c><00:00:43.160><c> honestly</c>', '', '', '<span>humidity</span><span>so</span><span>it</span><span>feels</span><span>closer</span><span>to</span><span>100</span><span>it</span><span>has<00:00:41.800><c></span><span>actually</c><00:00:42.120><c></span><span>been</c><00:00:42.520><c></span><span>insane</c><00:00:43.000><c></span><span>and</c><00:00:43.160><c></span><span>honestly</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 10, 43.549, 0.0, 'has actually been insane and honestly', '', '', '<span>has</span><span>actually</span><span>been</span><span tid="50003" class="highlight highlight-a">insane</span><span>and</span><span>honestly</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 11, 43.559, 0.0, 'has actually been insane and honestly has<00:00:43.800><c> made</c><00:00:43.960><c> me</c><00:00:44.079><c> feel</c><00:00:44.280><c> a</c><00:00:44.360><c> little</c><00:00:44.559><c> less</c><00:00:44.760><c> inclined</c>', '', '', '<span>has</span><span>actually</span><span>been</span><span>insane</span><span>and</span><span>honestly</span><span>has<00:00:43.800><c></span><span>made</c><00:00:43.960><c></span><span>me</c><00:00:44.079><c></span><span>feel</c><00:00:44.280><c></span><span>a</c><00:00:44.360><c></span><span>little</c><00:00:44.559><c></span><span>less</c><00:00:44.760><c></span><span>inclined</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 12, 45.19, 0.0, 'has made me feel a little less inclined', '', '', '<span>has</span><span>made</span><span>me</span><span>feel</span><span>a</span><span>little</span><span>less</span><span tid="50004" class="highlight highlight-a">inclined</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 13, 45.2, 0.0, 'has made me feel a little less inclined to<00:00:45.320><c> film</c><00:00:45.640><c> myself</c><00:00:46.039><c> bopping</c><00:00:46.440><c> around</c><00:00:46.840><c> City</c><00:00:47.320><c> cuz</c><00:00:47.440><c> I</c>', '', '', '<span>has</span><span>made</span><span>me</span><span>feel</span><span>a</span><span>little</span><span>less</span><span>inclined</span><span>to<00:00:45.320><c></span><span>film</c><00:00:45.640><c></span><span>myself</c><00:00:46.039><c></span><span>bopping</c><00:00:46.440><c></span><span>around</c><00:00:46.840><c></span><span>City</c><00:00:47.320><c></span><span>cuz</c><00:00:47.440><c></span><span>I</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 14, 47.549, 0.0, 'to film myself bopping around City cuz I', '', '', '<span>to</span><span>film</span><span>myself</span><span tid="50005" class="highlight highlight-a">bopping</span><span>around</span><span>City</span><span>cuz</span><span>I</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 15, 47.559, 0.0, 'to film myself bopping around City cuz I look<00:00:47.760><c> like</c><00:00:47.920><c> this</c><00:00:48.120><c> most</c><00:00:48.280><c> of</c><00:00:48.360><c> the</c><00:00:48.480><c> time</c><00:00:48.800><c> okay</c>', '', '', '<span>to</span><span>film</span><span>myself</span><span>bopping</span><span>around</span><span>City</span><span>cuz</span><span>I</span><span>look<00:00:47.760><c></span><span>like</c><00:00:47.920><c></span><span>this</c><00:00:48.120><c></span><span>most</c><00:00:48.280><c></span><span>of</c><00:00:48.360><c></span><span>the</c><00:00:48.480><c></span><span>time</c><00:00:48.800><c></span><span>okay</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 16, 48.95, 0.0, 'look like this most of the time okay', '', '', '<span pid="501" class="highlight highlight-d">look like</span><span>this</span><span pid="502" class="highlight highlight-c">most of the time</span><span>okay</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 17, 48.96, 0.0, 'look like this most of the time okay yeah<00:00:49.079><c> that''s</c><00:00:49.239><c> me</c><00:00:49.360><c> after</c><00:00:49.520><c> a</c><00:00:49.680><c> workout</c><00:00:50.000><c> but</c>', '', '', '<span>look</span><span>like</span><span>this</span><span>most</span><span>of</span><span>the</span><span>time</span><span>okay</span><span>yeah<00:00:49.079><c></span><span>that''s</c><00:00:49.239><c></span><span>me</c><00:00:49.360><c></span><span>after</c><00:00:49.520><c></span><span>a</c><00:00:49.680><c></span><span>workout</c><00:00:50.000><c></span><span>but</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 18, 50.11, 0.0, 'yeah that''s me after a workout but', '', '', '<span>yeah</span><span>that''s</span><span>me</span><span>after</span><span>a</span><span tid="50006" class="highlight highlight-a">workout</span><span>but</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 19, 50.12, 0.0, 'yeah that''s me after a workout but honestly<00:00:50.559><c> not</c><00:00:50.760><c> that</c><00:00:50.879><c> far</c><00:00:51.079><c> off</c><00:00:51.239><c> in</c><00:00:51.399><c> this</c>', '', '', '<span>yeah</span><span>that''s</span><span>me</span><span>after</span><span>a</span><span>workout</span><span>but</span><span>honestly<00:00:50.559><c></span><span>not</c><00:00:50.760><c></span><span>that</c><00:00:50.879><c></span><span>far</c><00:00:51.079><c></span><span>off</c><00:00:51.239><c></span><span>in</c><00:00:51.399><c></span><span>this</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 20, 51.549, 0.0, 'honestly not that far off in this', '', '', '<span>honestly</span><span>not</span><span>that</span><span pid="503" class="highlight highlight-c">far off</span><span>in</span><span>this</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 21, 51.559, 0.0, 'honestly not that far off in this weather<00:00:52.199><c> alas</c><00:00:52.879><c> we''re</c><00:00:53.079><c> doing</c><00:00:53.359><c> the</c><00:00:53.520><c> damn</c><00:00:53.800><c> thing</c>', '', '', '<span>honestly</span><span>not</span><span>that</span><span>far</span><span>off</span><span>in</span><span>this</span><span>weather<00:00:52.199><c></span><span>alas</c><00:00:52.879><c></span><span>we''re</c><00:00:53.079><c></span><span>doing</c><00:00:53.359><c></span><span>the</c><00:00:53.520><c></span><span>damn</c><00:00:53.800><c></span><span>thing</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 22, 54.069, 0.0, 'weather alas we''re doing the damn thing', '', '', '<span>weather</span><span tid="50007" class="highlight highlight-a">alas</span><span>we''re</span><span>doing</span><span>the</span><span>damn</span><span>thing</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 23, 54.079, 0.0, 'weather alas we''re doing the damn thing and<00:00:54.199><c> you''re</c><00:00:54.399><c> coming</c><00:00:54.680><c> with</c><00:00:54.800><c> me</c><00:00:55.199><c> Taylor</c><00:00:55.520><c> stay</c>', '', '', '<span>weather</span><span>alas</span><span>we''re</span><span>doing</span><span>the</span><span>damn</span><span>thing</span><span>and<00:00:54.199><c></span><span>you''re</c><00:00:54.399><c></span><span>coming</c><00:00:54.680><c></span><span>with</c><00:00:54.800><c></span><span>me</c><00:00:55.199><c></span><span>Taylor</c><00:00:55.520><c></span><span>stay</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 24, 55.67, 0.0, 'and you''re coming with me Taylor stay', '', '', '<span>and</span><span>you''re</span><span>coming</span><span>with</span><span>me</span><span>Taylor</span><span tid="50008" class="highlight highlight-a">stay</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 25, 55.68, 0.0, 'and you''re coming with me Taylor stay inside<00:00:55.960><c> where</c><00:00:56.079><c> it''s</c><00:00:56.239><c> cool</c><00:00:56.520><c> take</c><00:00:56.680><c> a</c><00:00:56.879><c> load</c><00:00:57.160><c> off</c>', '', '', '<span>and</span><span>you''re</span><span>coming</span><span>with</span><span>me</span><span>Taylor</span><span>stay</span><span>inside<00:00:55.960><c></span><span>where</c><00:00:56.079><c></span><span>it''s</c><00:00:56.239><c></span><span>cool</c><00:00:56.520><c></span><span>take</c><00:00:56.680><c></span><span>a</c><00:00:56.879><c></span><span>load</c><00:00:57.160><c></span><span>off</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 26, 57.389, 0.0, 'inside where it''s cool take a load off', '', '', '<span>inside</span><span>where</span><span>it''s</span><span>cool</span><span tid="50009" class="highlight highlight-d">take</span><span>a</span><span>load</span><span>off</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 27, 57.399, 0.0, 'inside where it''s cool take a load off make<00:00:57.480><c> a</c><00:00:57.600><c> nice</c><00:00:58.000><c> beverage</c><00:00:58.440><c> you</c><00:00:58.519><c> quit</c><00:00:58.719><c> that</c><00:00:58.960><c> we</c>', '', '', '<span>inside</span><span>where</span><span>it''s</span><span>cool</span><span>take</span><span>a</span><span>load</span><span>off</span><span>make<00:00:57.480><c></span><span>a</c><00:00:57.600><c></span><span>nice</c><00:00:58.000><c></span><span>beverage</c><00:00:58.440><c></span><span>you</c><00:00:58.519><c></span><span>quit</c><00:00:58.719><c></span><span>that</c><00:00:58.960><c></span><span>we</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 28, 59.069, 0.0, 'make a nice beverage you quit that we', '', '', '<span tid="50010" class="highlight highlight-a">make</span><span>a</span><span>nice</span><span tid="50011" class="highlight highlight-a">beverage</span><span>you</span><span tid="50012" class="highlight highlight-a">quit</span><span>that</span><span>we</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 29, 59.079, 0.0, 'make a nice beverage you quit that we are<00:00:59.199><c> doing</c><00:00:59.399><c> it</c><00:00:59.519><c> we''re</c><00:00:59.600><c> going</c><00:00:59.680><c> to</c><00:00:59.760><c> do</c><00:01:00.039><c> a</c><00:01:00.079><c> lot</c><00:01:00.199><c> of</c>', '', '', '<span>make</span><span>a</span><span>nice</span><span>beverage</span><span>you</span><span>quit</span><span>that</span><span>we</span><span>are<00:00:59.199><c></span><span>doing</c><00:00:59.399><c></span><span>it</c><00:00:59.519><c></span><span>we''re</c><00:00:59.600><c></span><span>going</c><00:00:59.680><c></span><span>to</c><00:00:59.760><c></span><span>do</c><00:01:00.039><c></span><span>a</c><00:01:00.079><c></span><span>lot</c><00:01:00.199><c></span><span>of</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 30, 60.27, 0.0, 'are doing it we''re going to do a lot of', '', '', '<span>are</span><span>doing</span><span>it</span><span>we''re</span><span>going</span><span>to</span><span>do</span><span>a</span><span>lot</span><span>of</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 31, 60.28, 0.0, 'are doing it we''re going to do a lot of exploring<00:01:00.680><c> I''m</c><00:01:00.760><c> going</c><00:01:00.840><c> to</c><00:01:00.920><c> show</c><00:01:01.039><c> you</c><00:01:01.120><c> some</c><00:01:01.239><c> of</c>', '', '', '<span>are</span><span>doing</span><span>it</span><span>we''re</span><span>going</span><span>to</span><span>do</span><span>a</span><span>lot</span><span>of</span><span>exploring<00:01:00.680><c></span><span>I''m</c><00:01:00.760><c></span><span>going</c><00:01:00.840><c></span><span>to</c><00:01:00.920><c></span><span>show</c><00:01:01.039><c></span><span>you</c><00:01:01.120><c></span><span>some</c><00:01:01.239><c></span><span>of</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 32, 61.31, 0.0, 'exploring I''m going to show you some of', '', '', '<span tid="50013" class="highlight highlight-a">exploring</span><span>I''m</span><span>going</span><span>to</span><span>show</span><span>you</span><span>some</span><span>of</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 33, 61.32, 0.0, 'exploring I''m going to show you some of my<00:01:01.440><c> favorite</c><00:01:01.719><c> local</c><00:01:02.079><c> spots</c><00:01:02.480><c> and</c><00:01:02.600><c> some</c><00:01:02.760><c> other</c>', '', '', '<span>exploring</span><span>I''m</span><span>going</span><span>to</span><span>show</span><span>you</span><span>some</span><span>of</span><span>my<00:01:01.440><c></span><span>favorite</c><00:01:01.719><c></span><span>local</c><00:01:02.079><c></span><span>spots</c><00:01:02.480><c></span><span>and</c><00:01:02.600><c></span><span>some</c><00:01:02.760><c></span><span>other</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 34, 62.95, 0.0, 'my favorite local spots and some other', '', '', '<span>my</span><span tid="50014" class="highlight highlight-a">favorite</span><span tid="50015" class="highlight highlight-a">local</span><span tid="50016" class="highlight highlight-a">spots</span><span>and</span><span>some</span><span>other</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 35, 62.96, 0.0, 'my favorite local spots and some other spots<00:01:03.239><c> that</c><00:01:03.320><c> you''ll</c><00:01:03.519><c> probably</c><00:01:03.800><c> recognize</c><00:01:04.239><c> so</c>', '', '', '<span>my</span><span>favorite</span><span>local</span><span>spots</span><span>and</span><span>some</span><span>other</span><span>spots<00:01:03.239><c></span><span>that</c><00:01:03.320><c></span><span>you''ll</c><00:01:03.519><c></span><span>probably</c><00:01:03.800><c></span><span>recognize</c><00:01:04.239><c></span><span>so</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 36, 64.549, 0.0, 'spots that you''ll probably recognize so', '', '', '<span tid="50017" class="highlight highlight-a">spots</span><span>that</span><span>you''ll</span><span>probably</span><span tid="50018" class="highlight highlight-a">recognize</span><span>so</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 37, 64.559, 0.0, 'spots that you''ll probably recognize so buckle', '', '', '<span tid="50019" class="highlight highlight-a">spots</span><span>that</span><span>you''ll</span><span>probably</span><span tid="50020" class="highlight highlight-a">recognize</span><span>so</span><span tid="50021" class="highlight highlight-a">buckle</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 38, 65.82, 0.0, 'buckle', '', '', '<span tid="50022" class="highlight highlight-a">buckle</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 39, 65.83, 0.0, 'buckle [Music]', '', '', '<span tid="50023" class="highlight highlight-a">buckle</span><span>[Music]</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 40, 75.749, 0.0, '[Music]', '', '', '<span>[Music]</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 41, 75.759, 0.0, '[Music] up<00:01:16.759><c> Taylor</c><00:01:17.119><c> where</c><00:01:17.240><c> you</c><00:01:17.439><c> going</c><00:01:17.920><c> oh</c><00:01:18.159><c> hey</c><00:01:18.400><c> buddy</c>', '', '', '<span>[Music]</span><span>up<00:01:16.759><c></span><span>Taylor</c><00:01:17.119><c></span><span>where</c><00:01:17.240><c></span><span>you</c><00:01:17.439><c></span><span>going</c><00:01:17.920><c></span><span>oh</c><00:01:18.159><c></span><span>hey</c><00:01:18.400><c></span><span>buddy</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 42, 79.03, 0.0, 'up Taylor where you going oh hey buddy', '', '', '<span>up</span><span>Taylor</span><span>where</span><span>you</span><span>going</span><span>oh</span><span>hey</span><span tid="50024" class="highlight highlight-a">buddy</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 43, 79.04, 0.0, 'up Taylor where you going oh hey buddy hey<00:01:19.600><c> you</c><00:01:19.720><c> know</c><00:01:19.840><c> you''re</c><00:01:20.000><c> my</c><00:01:20.200><c> favorite</c><00:01:20.600><c> but</c><00:01:20.759><c> hey</c>', '', '', '<span>up</span><span>Taylor</span><span>where</span><span>you</span><span>going</span><span>oh</span><span>hey</span><span>buddy</span><span>hey<00:01:19.600><c></span><span>you</c><00:01:19.720><c></span><span>know</c><00:01:19.840><c></span><span>you''re</c><00:01:20.000><c></span><span>my</c><00:01:20.200><c></span><span>favorite</c><00:01:20.600><c></span><span>but</c><00:01:20.759><c></span><span>hey</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 44, 80.87, 0.0, 'hey you know you''re my favorite but hey', '', '', '<span>hey</span><span>you</span><span>know</span><span>you''re</span><span>my</span><span tid="50025" class="highlight highlight-a">favorite</span><span>but</span><span>hey</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 45, 80.88, 0.0, 'hey you know you''re my favorite but hey for<00:01:21.040><c> the</c><00:01:21.159><c> sake</c><00:01:21.320><c> of</c><00:01:21.400><c> the</c><00:01:21.520><c> video</c><00:01:21.799><c> I</c><00:01:21.880><c> think</c><00:01:22.000><c> we''re</c>', '', '', '<span>hey</span><span>you</span><span>know</span><span>you''re</span><span>my</span><span>favorite</span><span>but</span><span>hey</span><span>for<00:01:21.040><c></span><span>the</c><00:01:21.159><c></span><span>sake</c><00:01:21.320><c></span><span>of</c><00:01:21.400><c></span><span>the</c><00:01:21.520><c></span><span>video</c><00:01:21.799><c></span><span>I</c><00:01:21.880><c></span><span>think</c><00:01:22.000><c></span><span>we''re</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 46, 82.149, 0.0, 'for the sake of the video I think we''re', '', '', '<span>for</span><span>the</span><span tid="50026" class="highlight highlight-a">sake</span><span>of</span><span>the</span><span>video</span><span>I</span><span>think</span><span>we''re</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 47, 82.159, 0.0, 'for the sake of the video I think we''re going<00:01:22.240><c> to</c><00:01:22.439><c> go</c><00:01:22.799><c> out</c><00:01:22.960><c> and</c><00:01:23.240><c> explore</c><00:01:23.560><c> and</c><00:01:23.680><c> find</c><00:01:23.840><c> a</c>', '', '', '<span>for</span><span>the</span><span>sake</span><span>of</span><span>the</span><span>video</span><span>I</span><span>think</span><span>we''re</span><span>going<00:01:22.240><c></span><span>to</c><00:01:22.439><c></span><span>go</c><00:01:22.799><c></span><span>out</c><00:01:22.960><c></span><span>and</c><00:01:23.240><c></span><span>explore</c><00:01:23.560><c></span><span>and</c><00:01:23.680><c></span><span>find</c><00:01:23.840><c></span><span>a</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 48, 83.95, 0.0, 'going to go out and explore and find a', '', '', '<span pid="504" class="highlight highlight-d">going to</span><span>go</span><span>out</span><span>and</span><span tid="50027" class="highlight highlight-a">explore</span><span>and</span><span>find</span><span>a</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 49, 83.96, 0.0, 'going to go out and explore and find a new<00:01:24.159><c> place</c><00:01:24.400><c> today</c><00:01:24.840><c> okay</c><00:01:25.320><c> okay</c><00:01:26.040><c> thanks</c><00:01:26.240><c> for</c>', '', '', '<span>going</span><span>to</span><span>go</span><span>out</span><span>and</span><span>explore</span><span>and</span><span>find</span><span>a</span><span>new<00:01:24.159><c></span><span>place</c><00:01:24.400><c></span><span>today</c><00:01:24.840><c></span><span>okay</c><00:01:25.320><c></span><span>okay</c><00:01:26.040><c></span><span>thanks</c><00:01:26.240><c></span><span>for</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 50, 86.39, 0.0, 'new place today okay okay thanks for', '', '', '<span>new</span><span>place</span><span>today</span><span>okay</span><span>okay</span><span>thanks</span><span>for</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 51, 86.4, 0.0, 'new place today okay okay thanks for being<00:01:26.560><c> so</c><00:01:27.000><c> understanding</c><00:01:27.280><c> I''ll</c><00:01:27.400><c> see</c><00:01:27.560><c> you</c><00:01:27.759><c> soon</c>', '', '', '<span>new</span><span>place</span><span>today</span><span>okay</span><span>okay</span><span>thanks</span><span>for</span><span>being<00:01:26.560><c></span><span>so</c><00:01:27.000><c></span><span>understanding</c><00:01:27.280><c></span><span>I''ll</c><00:01:27.400><c></span><span>see</c><00:01:27.560><c></span><span>you</c><00:01:27.759><c></span><span>soon</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 52, 88.749, 0.0, 'being so understanding I''ll see you soon', '', '', '<span>being</span><span>so</span><span tid="50028" class="highlight highlight-a">understanding</span><span>I''ll</span><span>see</span><span>you</span><span>soon</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 53, 88.759, 0.0, 'being so understanding I''ll see you soon have<00:01:28.880><c> a</c><00:01:29.000><c> good</c><00:01:29.200><c> day</c>', '', '', '<span>being</span><span>so</span><span>understanding</span><span>I''ll</span><span>see</span><span>you</span><span>soon</span><span>have<00:01:28.880><c></span><span>a</c><00:01:29.000><c></span><span>good</c><00:01:29.200><c></span><span>day</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 54, 98.83, 0.0, '[Music]', '', '', '<span>[Music]</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 55, 98.84, 0.0, '[Music] can<00:01:38.960><c> I</c><00:01:39.119><c> please</c><00:01:39.280><c> do</c><00:01:39.479><c> an</c><00:01:39.560><c> iced</c><00:01:39.880><c> Americo</c>', '', '', '<span>[Music]</span><span>can<00:01:38.960><c></span><span>I</c><00:01:39.119><c></span><span>please</c><00:01:39.280><c></span><span>do</c><00:01:39.479><c></span><span>an</c><00:01:39.560><c></span><span>iced</c><00:01:39.880><c></span><span>Americo</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 56, 100.71, 0.0, 'can I please do an iced Americo', '', '', '<span>can</span><span>I</span><span>please</span><span>do</span><span>an</span><span tid="50029" class="highlight highlight-a">iced</span><span tid="50030" class="highlight highlight-a">Americo</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 57, 100.72, 0.0, 'can I please do an iced Americo absolutely<00:01:41.399><c> thank</c><00:01:41.600><c> you</c><00:01:42.200><c> and</c><00:01:42.320><c> do</c><00:01:42.399><c> you</c><00:01:42.479><c> want</c><00:01:42.560><c> a</c>', '', '', '<span>can</span><span>I</span><span>please</span><span>do</span><span>an</span><span>iced</span><span>Americo</span><span>absolutely<00:01:41.399><c></span><span>thank</c><00:01:41.600><c></span><span>you</c><00:01:42.200><c></span><span>and</c><00:01:42.320><c></span><span>do</c><00:01:42.399><c></span><span>you</c><00:01:42.479><c></span><span>want</c><00:01:42.560><c></span><span>a</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 58, 102.67, 0.0, 'absolutely thank you and do you want a', '', '', '<span>absolutely</span><span>thank</span><span>you</span><span>and</span><span>do</span><span>you</span><span>want</span><span>a</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 59, 102.68, 0.0, 'absolutely thank you and do you want a delicious<00:01:43.040><c> chicken</c><00:01:43.320><c> and</c><00:01:43.520><c> banado</c><00:01:43.880><c> with</c><00:01:44.000><c> that</c>', '', '', '<span>absolutely</span><span>thank</span><span>you</span><span>and</span><span>do</span><span>you</span><span>want</span><span>a</span><span>delicious<00:01:43.040><c></span><span>chicken</c><00:01:43.320><c></span><span>and</c><00:01:43.520><c></span><span>banado</c><00:01:43.880><c></span><span>with</c><00:01:44.000><c></span><span>that</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 60, 104.149, 0.0, 'delicious chicken and banado with that', '', '', '<span tid="50031" class="highlight highlight-a">delicious</span><span>chicken</span><span>and</span><span tid="50032" class="highlight highlight-a">banado</span><span>with</span><span>that</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 61, 104.159, 0.0, 'delicious chicken and banado with that or<00:01:44.280><c> be</c><00:01:45.240><c> okay</c><00:01:45.520><c> thank</c><00:01:45.640><c> you</c><00:01:45.799><c> then</c><00:01:46.040><c> can</c><00:01:46.159><c> I</c><00:01:46.240><c> get</c><00:01:46.320><c> a</c>', '', '', '<span>delicious</span><span>chicken</span><span>and</span><span>banado</span><span>with</span><span>that</span><span>or<00:01:44.280><c></span><span>be</c><00:01:45.240><c></span><span>okay</c><00:01:45.520><c></span><span>thank</c><00:01:45.640><c></span><span>you</c><00:01:45.799><c></span><span>then</c><00:01:46.040><c></span><span>can</c><00:01:46.159><c></span><span>I</c><00:01:46.240><c></span><span>get</c><00:01:46.320><c></span><span>a</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 62, 106.429, 0.0, 'or be okay thank you then can I get a', '', '', '<span>or</span><span>be</span><span>okay</span><span>thank</span><span>you</span><span>then</span><span>can</span><span>I</span><span>get</span><span>a</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 63, 106.439, 0.0, 'or be okay thank you then can I get a name<00:01:46.560><c> for</c><00:01:46.680><c> this</c>', '', '', '<span>or</span><span>be</span><span>okay</span><span>thank</span><span>you</span><span>then</span><span>can</span><span>I</span><span>get</span><span>a</span><span>name<00:01:46.560><c></span><span>for</c><00:01:46.680><c></span><span>this</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 64, 107.51, 0.0, 'name for this', '', '', '<span tid="50033" class="highlight highlight-a">name</span><span>for</span><span>this</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 65, 107.52, 0.0, 'name for this Taylor<00:01:48.520><c> awesome</c><00:01:48.799><c> this</c><00:01:48.880><c> will</c><00:01:49.000><c> be</c><00:01:49.159><c> right</c><00:01:49.280><c> out</c>', '', '', '<span>name</span><span>for</span><span>this</span><span>Taylor<00:01:48.520><c></span><span>awesome</c><00:01:48.799><c></span><span>this</c><00:01:48.880><c></span><span>will</c><00:01:49.000><c></span><span>be</c><00:01:49.159><c></span><span>right</c><00:01:49.280><c></span><span>out</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 66, 109.429, 0.0, 'Taylor awesome this will be right out', '', '', '<span>Taylor</span><span tid="50034" class="highlight highlight-a">awesome</span><span>this</span><span>will</span><span>be</span><span>right</span><span>out</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 67, 109.439, 0.0, 'Taylor awesome this will be right out for<00:01:49.600><c> you</c><00:01:49.840><c> thank</c><00:01:49.960><c> you</c><00:01:50.079><c> so</c><00:01:50.200><c> much</c><00:01:50.840><c> ready</c><00:01:51.479><c> perfect</c>', '', '', '<span>Taylor</span><span>awesome</span><span>this</span><span>will</span><span>be</span><span>right</span><span>out</span><span>for<00:01:49.600><c></span><span>you</c><00:01:49.840><c></span><span>thank</c><00:01:49.960><c></span><span>you</c><00:01:50.079><c></span><span>so</c><00:01:50.200><c></span><span>much</c><00:01:50.840><c></span><span>ready</c><00:01:51.479><c></span><span>perfect</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 68, 112.469, 0.0, 'for you thank you so much ready perfect', '', '', '<span>for</span><span>you</span><span>thank</span><span>you</span><span>so</span><span>much</span><span tid="50035" class="highlight highlight-a">ready</span><span tid="50036" class="highlight highlight-a">perfect</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 69, 112.479, 0.0, 'for you thank you so much ready perfect genius<00:01:52.840><c> marketing</c><00:01:53.479><c> practical</c><00:01:54.399><c> not</c><00:01:54.640><c> really</c>', '', '', '<span>for</span><span>you</span><span>thank</span><span>you</span><span>so</span><span>much</span><span>ready</span><span>perfect</span><span>genius<00:01:52.840><c></span><span>marketing</c><00:01:53.479><c></span><span>practical</c><00:01:54.399><c></span><span>not</c><00:01:54.640><c></span><span>really</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 70, 115.109, 0.0, 'genius marketing practical not really', '', '', '<span tid="50037" class="highlight highlight-a">genius</span><span tid="50038" class="highlight highlight-a">marketing</span><span tid="50039" class="highlight highlight-a">practical</span><span>not</span><span>really</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 71, 115.119, 0.0, 'genius marketing practical not really but<00:01:55.479><c> gets</c><00:01:55.719><c> people</c><00:01:55.920><c> taking</c><00:01:56.200><c> pictures</c><00:01:56.600><c> gets</c>', '', '', '<span>genius</span><span>marketing</span><span>practical</span><span>not</span><span>really</span><span>but<00:01:55.479><c></span><span>gets</c><00:01:55.719><c></span><span>people</c><00:01:55.920><c></span><span>taking</c><00:01:56.200><c></span><span>pictures</c><00:01:56.600><c></span><span>gets</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 72, 116.83, 0.0, 'but gets people taking pictures gets', '', '', '<span>but</span><span>gets</span><span>people</span><span>taking</span><span>pictures</span><span>gets</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 73, 116.84, 0.0, 'but gets people taking pictures gets people<00:01:57.119><c> talking</c><00:01:57.840><c> sharing</c><00:01:58.840><c> genius</c><00:01:59.399><c> it''s</c><00:01:59.520><c> also</c>', '', '', '<span>but</span><span>gets</span><span>people</span><span>taking</span><span>pictures</span><span>gets</span><span>people<00:01:57.119><c></span><span>talking</c><00:01:57.840><c></span><span>sharing</c><00:01:58.840><c></span><span>genius</c><00:01:59.399><c></span><span>it''s</c><00:01:59.520><c></span><span>also</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 74, 119.95, 0.0, 'people talking sharing genius it''s also', '', '', '<span>people</span><span>talking</span><span>sharing</span><span tid="50040" class="highlight highlight-a">genius</span><span>it''s</span><span>also</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 75, 119.96, 0.0, 'people talking sharing genius it''s also really<00:02:00.119><c> good</c><00:02:00.240><c> so</c><00:02:00.360><c> that''s</c><00:02:00.479><c> 787</c><00:02:01.159><c> coffee</c><00:02:01.840><c> it''s</c>', '', '', '<span>people</span><span>talking</span><span>sharing</span><span>genius</span><span>it''s</span><span>also</span><span>really<00:02:00.119><c></span><span>good</c><00:02:00.240><c></span><span>so</c><00:02:00.360><c></span><span>that''s</c><00:02:00.479><c></span><span>787</c><00:02:01.159><c></span><span>coffee</c><00:02:01.840><c></span><span>it''s</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 76, 122.029, 0.0, 'really good so that''s 787 coffee it''s', '', '', '<span>really</span><span>good</span><span>so</span><span>that''s</span><span>787</span><span>coffee</span><span>it''s</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 77, 122.039, 0.0, 'really good so that''s 787 coffee it''s this<00:02:02.280><c> chain</c><00:02:02.600><c> of</c><00:02:02.759><c> Puerto</c><00:02:03.039><c> Rican</c><00:02:03.360><c> coffee</c><00:02:03.600><c> shops</c>', '', '', '<span>really</span><span>good</span><span>so</span><span>that''s</span><span>787</span><span>coffee</span><span>it''s</span><span>this<00:02:02.280><c></span><span>chain</c><00:02:02.600><c></span><span>of</c><00:02:02.759><c></span><span>Puerto</c><00:02:03.039><c></span><span>Rican</c><00:02:03.360><c></span><span>coffee</c><00:02:03.600><c></span><span>shops</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 78, 123.91, 0.0, 'this chain of Puerto Rican coffee shops', '', '', '<span>this</span><span tid="50041" class="highlight highlight-a">chain</span><span>of</span><span>Puerto</span><span>Rican</span><span>coffee</span><span>shops</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 79, 123.92, 0.0, 'this chain of Puerto Rican coffee shops that<00:02:04.039><c> I</c><00:02:04.320><c> absolutely</c><00:02:04.719><c> love</c><00:02:04.960><c> there''s</c><00:02:05.159><c> quite</c><00:02:05.280><c> a</c>', '', '', '<span>this</span><span>chain</span><span>of</span><span>Puerto</span><span>Rican</span><span>coffee</span><span>shops</span><span>that<00:02:04.039><c></span><span>I</c><00:02:04.320><c></span><span>absolutely</c><00:02:04.719><c></span><span>love</c><00:02:04.960><c></span><span>there''s</c><00:02:05.159><c></span><span>quite</c><00:02:05.280><c></span><span>a</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 80, 125.35, 0.0, 'that I absolutely love there''s quite a', '', '', '<span>that</span><span>I</span><span>absolutely</span><span>love</span><span>there''s</span><span>quite</span><span>a</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 81, 125.36, 0.0, 'that I absolutely love there''s quite a few<00:02:05.520><c> around</c><00:02:05.680><c> the</c><00:02:05.759><c> city</c><00:02:06.039><c> also</c><00:02:06.240><c> some</c><00:02:06.399><c> of</c><00:02:06.520><c> course</c>', '', '', '<span>that</span><span>I</span><span>absolutely</span><span>love</span><span>there''s</span><span>quite</span><span>a</span><span>few<00:02:05.520><c></span><span>around</c><00:02:05.680><c></span><span>the</c><00:02:05.759><c></span><span>city</c><00:02:06.039><c></span><span>also</c><00:02:06.240><c></span><span>some</c><00:02:06.399><c></span><span>of</c><00:02:06.520><c></span><span>course</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 82, 126.67, 0.0, 'few around the city also some of course', '', '', '<span>few</span><span>around</span><span>the</span><span tid="50042" class="highlight highlight-a">city</span><span>also</span><span>some</span><span>of</span><span tid="50043" class="highlight highlight-c">course</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 83, 126.68, 0.0, 'few around the city also some of course in<00:02:06.799><c> Puerto</c><00:02:07.079><c> Rico</c><00:02:07.360><c> I</c><00:02:07.439><c> have</c><00:02:07.520><c> brought</c><00:02:07.719><c> you</c><00:02:07.880><c> to</c>', '', '', '<span>few</span><span>around</span><span>the</span><span>city</span><span>also</span><span>some</span><span>of</span><span>course</span><span>in<00:02:06.799><c></span><span>Puerto</c><00:02:07.079><c></span><span>Rico</c><00:02:07.360><c></span><span>I</c><00:02:07.439><c></span><span>have</c><00:02:07.520><c></span><span>brought</c><00:02:07.719><c></span><span>you</c><00:02:07.880><c></span><span>to</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 84, 128.15, 0.0, 'in Puerto Rico I have brought you to', '', '', '<span>in</span><span tid="50044" class="highlight highlight-a">Puerto</span><span tid="50045" class="highlight highlight-a">Rico</span><span>I</span><span>have</span><span tid="50046" class="highlight highlight-d">brought</span><span>you</span><span>to</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 85, 128.16, 0.0, 'in Puerto Rico I have brought you to what<00:02:08.399><c> I</c><00:02:08.560><c> think</c><00:02:08.800><c> is</c><00:02:08.959><c> one</c><00:02:09.080><c> of</c><00:02:09.239><c> the</c><00:02:09.520><c> absolute</c><00:02:10.080><c> most</c>', '', '', '<span>in</span><span>Puerto</span><span>Rico</span><span>I</span><span>have</span><span>brought</span><span>you</span><span>to</span><span>what<00:02:08.399><c></span><span>I</c><00:02:08.560><c></span><span>think</c><00:02:08.800><c></span><span>is</c><00:02:08.959><c></span><span>one</c><00:02:09.080><c></span><span>of</c><00:02:09.239><c></span><span>the</c><00:02:09.520><c></span><span>absolute</c><00:02:10.080><c></span><span>most</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 86, 130.389, 0.0, 'what I think is one of the absolute most', '', '', '<span>what</span><span>I</span><span>think</span><span>is</span><span>one</span><span>of</span><span>the</span><span tid="50047" class="highlight highlight-a">absolute</span><span>most</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 87, 130.399, 0.0, 'what I think is one of the absolute most beautiful<00:02:10.840><c> corners</c><00:02:11.319><c> in</c><00:02:11.520><c> all</c><00:02:11.680><c> of</c><00:02:11.840><c> New</c><00:02:11.959><c> York</c>', '', '', '<span>what</span><span>I</span><span>think</span><span>is</span><span>one</span><span>of</span><span>the</span><span>absolute</span><span>most</span><span>beautiful<00:02:10.840><c></span><span>corners</c><00:02:11.319><c></span><span>in</c><00:02:11.520><c></span><span>all</c><00:02:11.680><c></span><span>of</c><00:02:11.840><c></span><span>New</c><00:02:11.959><c></span><span>York</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 88, 132.19, 0.0, 'beautiful corners in all of New York', '', '', '<span tid="50048" class="highlight highlight-a">beautiful</span><span>corners</span><span>in</span><span>all</span><span>of</span><span>New York</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 89, 132.2, 0.0, 'beautiful corners in all of New York City<00:02:12.920><c> and</c><00:02:13.160><c> the</c><00:02:13.280><c> most</c><00:02:13.440><c> beautiful</c><00:02:13.760><c> Corner</c><00:02:14.080><c> in</c>', '', '', '<span>beautiful</span><span>corners</span><span>in</span><span>all</span><span>of</span><span>New</span><span>York</span><span>City<00:02:12.920><c></span><span>and</c><00:02:13.160><c></span><span>the</c><00:02:13.280><c></span><span>most</c><00:02:13.440><c></span><span>beautiful</c><00:02:13.760><c></span><span>Corner</c><00:02:14.080><c></span><span>in</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 90, 134.229, 0.0, 'City and the most beautiful Corner in', '', '', '<span>City</span><span>and</span><span>the</span><span>most</span><span tid="50049" class="highlight highlight-a">beautiful</span><span>Corner</span><span>in</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 91, 134.239, 0.0, 'City and the most beautiful Corner in East<00:02:14.480><c> Village</c><00:02:14.879><c> I</c><00:02:15.000><c> think</c><00:02:15.480><c> this</c><00:02:15.680><c> is</c><00:02:16.000><c> the</c><00:02:16.120><c> corner</c>', '', '', '<span>City</span><span>and</span><span>the</span><span>most</span><span>beautiful</span><span>Corner</span><span>in</span><span>East<00:02:14.480><c></span><span>Village</c><00:02:14.879><c></span><span>I</c><00:02:15.000><c></span><span>think</c><00:02:15.480><c></span><span>this</c><00:02:15.680><c></span><span>is</c><00:02:16.000><c></span><span>the</c><00:02:16.120><c></span><span>corner</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 92, 136.43, 0.0, 'East Village I think this is the corner', '', '', '<span>East Village</span><span>I</span><span>think</span><span>this</span><span>is</span><span>the</span><span>corner</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 93, 136.44, 0.0, 'East Village I think this is the corner of<00:02:16.720><c> stent</c><00:02:17.319><c> and</c><00:02:17.480><c> East</c><00:02:17.680><c> 10th</c><00:02:18.000><c> Street</c><00:02:18.440><c> and</c><00:02:18.680><c> it</c><00:02:18.879><c> is</c>', '', '', '<span>East</span><span>Village</span><span>I</span><span>think</span><span>this</span><span>is</span><span>the</span><span>corner</span><span>of<00:02:16.720><c></span><span>stent</c><00:02:17.319><c></span><span>and</c><00:02:17.480><c></span><span>East</c><00:02:17.680><c></span><span>10th</c><00:02:18.000><c></span><span>Street</c><00:02:18.440><c></span><span>and</c><00:02:18.680><c></span><span>it</c><00:02:18.879><c></span><span>is</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 94, 139.27, 0.0, 'of stent and East 10th Street and it is', '', '', '<span>of</span><span tid="50050" class="highlight highlight-a">stent</span><span>and</span><span>East</span><span>10th</span><span>Street</span><span>and</span><span>it</span><span>is</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 95, 139.28, 0.0, 'of stent and East 10th Street and it is one<00:02:19.440><c> of</c><00:02:19.760><c> the</c><00:02:20.120><c> oldest</c><00:02:20.720><c> streets</c><00:02:21.239><c> in</c><00:02:21.440><c> all</c><00:02:21.599><c> of</c>', '', '', '<span>of</span><span>stent</span><span>and</span><span>East</span><span>10th</span><span>Street</span><span>and</span><span>it</span><span>is</span><span>one<00:02:19.440><c></span><span>of</c><00:02:19.760><c></span><span>the</c><00:02:20.120><c></span><span>oldest</c><00:02:20.720><c></span><span>streets</c><00:02:21.239><c></span><span>in</c><00:02:21.440><c></span><span>all</c><00:02:21.599><c></span><span>of</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 96, 141.79, 0.0, 'one of the oldest streets in all of', '', '', '<span pid="505" class="highlight highlight-c">one of</span><span>the</span><span tid="50051" class="highlight highlight-a">oldest</span><span tid="50052" class="highlight highlight-a">streets</span><span>in</span><span pid="506" class="highlight highlight-c">all of</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 97, 141.8, 0.0, 'one of the oldest streets in all of Manhattan<00:02:22.239><c> New</c><00:02:22.400><c> York</c><00:02:22.599><c> City</c><00:02:22.879><c> it</c><00:02:22.959><c> was</c><00:02:23.120><c> first</c>', '', '', '<span>one</span><span>of</span><span>the</span><span>oldest</span><span>streets</span><span>in</span><span>all</span><span>of</span><span>Manhattan<00:02:22.239><c></span><span>New</c><00:02:22.400><c></span><span>York</c><00:02:22.599><c></span><span>City</c><00:02:22.879><c></span><span>it</c><00:02:22.959><c></span><span>was</c><00:02:23.120><c></span><span>first</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 98, 143.39, 0.0, 'Manhattan New York City it was first', '', '', '<span>Manhattan</span><span>New York City</span><span>it</span><span>was</span><span>first</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 99, 143.4, 0.0, 'Manhattan New York City it was first laid<00:02:23.680><c> down</c><00:02:24.200><c> in</c>', '', '', '<span>Manhattan</span><span>New</span><span>York</span><span>City</span><span>it</span><span>was</span><span>first</span><span>laid<00:02:23.680><c></span><span>down</c><00:02:24.200><c></span><span>in</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 100, 145.35, 0.0, 'laid down in', '', '', '<span pid="507" class="highlight highlight-d">laid down</span><span>in</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 101, 145.36, 0.0, 'laid down in 1787<00:02:26.360><c> and</c><00:02:26.480><c> to</c><00:02:26.640><c> you</c><00:02:26.760><c> non-americans</c><00:02:27.560><c> watching</c>', '', '', '<span>laid</span><span>down</span><span>in</span><span>1787<00:02:26.360><c></span><span>and</c><00:02:26.480><c></span><span>to</c><00:02:26.640><c></span><span>you</c><00:02:26.760><c></span><span>non-americans</c><00:02:27.560><c></span><span>watching</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 102, 148.19, 0.0, '1787 and to you non-americans watching', '', '', '<span>1787</span><span>and</span><span>to</span><span>you</span><span tid="50053" class="highlight highlight-a">non-americans</span><span>watching</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 103, 148.2, 0.0, '1787 and to you non-americans watching that<00:02:28.319><c> might</c><00:02:28.480><c> not</c><00:02:28.599><c> sound</c><00:02:28.800><c> that</c><00:02:28.920><c> old</c><00:02:29.120><c> but</c><00:02:29.239><c> that''s</c>', '', '', '<span>1787</span><span>and</span><span>to</span><span>you</span><span>non-americans</span><span>watching</span><span>that<00:02:28.319><c></span><span>might</c><00:02:28.480><c></span><span>not</c><00:02:28.599><c></span><span>sound</c><00:02:28.800><c></span><span>that</c><00:02:28.920><c></span><span>old</c><00:02:29.120><c></span><span>but</c><00:02:29.239><c></span><span>that''s</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 104, 149.39, 0.0, 'that might not sound that old but that''s', '', '', '<span>that</span><span>might</span><span>not</span><span tid="50054" class="highlight highlight-a">sound</span><span>that</span><span>old</span><span>but</span><span>that''s</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 105, 149.4, 0.0, 'that might not sound that old but that''s what<00:02:29.560><c> 11</c><00:02:30.040><c> years</c><00:02:30.239><c> after</c><00:02:30.440><c> we</c><00:02:30.599><c> officially</c><00:02:30.920><c> became</c>', '', '', '<span>that</span><span>might</span><span>not</span><span>sound</span><span>that</span><span>old</span><span>but</span><span>that''s</span><span>what<00:02:29.560><c></span><span>11</c><00:02:30.040><c></span><span>years</c><00:02:30.239><c></span><span>after</c><00:02:30.440><c></span><span>we</c><00:02:30.599><c></span><span>officially</c><00:02:30.920><c></span><span>became</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 106, 151.15, 0.0, 'what 11 years after we officially became', '', '', '<span>what</span><span>11</span><span>years</span><span>after</span><span>we</span><span tid="50055" class="highlight highlight-a">officially</span><span>became</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 107, 151.16, 0.0, 'what 11 years after we officially became a<00:02:31.280><c> country</c><00:02:31.640><c> so</c><00:02:31.879><c> it''s</c><00:02:32.040><c> old</c><00:02:32.680><c> for</c><00:02:32.879><c> us</c><00:02:33.160><c> and</c><00:02:33.319><c> my</c>', '', '', '<span>what</span><span>11</span><span>years</span><span>after</span><span>we</span><span>officially</span><span>became</span><span>a<00:02:31.280><c></span><span>country</c><00:02:31.640><c></span><span>so</c><00:02:31.879><c></span><span>it''s</c><00:02:32.040><c></span><span>old</c><00:02:32.680><c></span><span>for</c><00:02:32.879><c></span><span>us</c><00:02:33.160><c></span><span>and</c><00:02:33.319><c></span><span>my</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 108, 153.509, 0.0, 'a country so it''s old for us and my', '', '', '<span>a</span><span>country</span><span>so</span><span>it''s</span><span>old</span><span>for</span><span>us</span><span>and</span><span>my</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 109, 153.519, 0.0, 'a country so it''s old for us and my favorite<00:02:33.879><c> fun</c><00:02:34.200><c> fact</c><00:02:34.440><c> about</c><00:02:34.680><c> this</c><00:02:34.840><c> corner</c><00:02:35.440><c> is</c>', '', '', '<span>a</span><span>country</span><span>so</span><span>it''s</span><span>old</span><span>for</span><span>us</span><span>and</span><span>my</span><span>favorite<00:02:33.879><c></span><span>fun</c><00:02:34.200><c></span><span>fact</c><00:02:34.440><c></span><span>about</c><00:02:34.680><c></span><span>this</c><00:02:34.840><c></span><span>corner</c><00:02:35.440><c></span><span>is</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 110, 155.63, 0.0, 'favorite fun fact about this corner is', '', '', '<span tid="50056" class="highlight highlight-a">favorite</span><span>fun</span><span>fact</span><span>about</span><span>this</span><span tid="50057" class="highlight highlight-a">corner</span><span>is</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 111, 155.64, 0.0, 'favorite fun fact about this corner is that<00:02:35.840><c> you</c><00:02:35.959><c> know</c><00:02:36.120><c> how</c><00:02:36.440><c> New</c><00:02:36.599><c> York</c><00:02:36.840><c> City</c><00:02:37.400><c> is</c><00:02:37.599><c> very</c>', '', '', '<span>favorite</span><span>fun</span><span>fact</span><span>about</span><span>this</span><span>corner</span><span>is</span><span>that<00:02:35.840><c></span><span>you</c><00:02:35.959><c></span><span>know</c><00:02:36.120><c></span><span>how</c><00:02:36.440><c></span><span>New</c><00:02:36.599><c></span><span>York</c><00:02:36.840><c></span><span>City</c><00:02:37.400><c></span><span>is</c><00:02:37.599><c></span><span>very</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 112, 157.91, 0.0, 'that you know how New York City is very', '', '', '<span>that</span><span>you</span><span>know</span><span>how</span><span>New York City</span><span>is</span><span>very</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 113, 157.92, 0.0, 'that you know how New York City is very famously<00:02:38.400><c> laid</c><00:02:38.680><c> out</c><00:02:38.920><c> as</c><00:02:39.120><c> like</c><00:02:39.239><c> a</c><00:02:39.360><c> grid</c><00:02:39.680><c> system</c>', '', '', '<span>that</span><span>you</span><span>know</span><span>how</span><span>New</span><span>York</span><span>City</span><span>is</span><span>very</span><span>famously<00:02:38.400><c></span><span>laid</c><00:02:38.680><c></span><span>out</c><00:02:38.920><c></span><span>as</c><00:02:39.120><c></span><span>like</c><00:02:39.239><c></span><span>a</c><00:02:39.360><c></span><span>grid</c><00:02:39.680><c></span><span>system</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 114, 160.19, 0.0, 'famously laid out as like a grid system', '', '', '<span tid="50058" class="highlight highlight-a">famously</span><span pid="508" class="highlight highlight-d">laid out</span><span>as</span><span>like</span><span>a</span><span pid="509" class="highlight highlight-a">grid system</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 115, 160.2, 0.0, 'famously laid out as like a grid system well<00:02:40.519><c> believe</c><00:02:40.760><c> it</c><00:02:40.879><c> or</c><00:02:41.080><c> not</c><00:02:41.519><c> the</c><00:02:41.720><c> grid</c><00:02:42.400><c> all</c><00:02:42.519><c> of</c>', '', '', '<span>famously</span><span>laid</span><span>out</span><span>as</span><span>like</span><span>a</span><span>grid</span><span>system</span><span>well<00:02:40.519><c></span><span>believe</c><00:02:40.760><c></span><span>it</c><00:02:40.879><c></span><span>or</c><00:02:41.080><c></span><span>not</c><00:02:41.519><c></span><span>the</c><00:02:41.720><c></span><span>grid</c><00:02:42.400><c></span><span>all</c><00:02:42.519><c></span><span>of</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 116, 162.71, 0.0, 'well believe it or not the grid all of', '', '', '<span>well</span><span pid="510" class="highlight highlight-i">believe it or not</span><span>the</span><span tid="50059" class="highlight highlight-a">grid</span><span>all of</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 117, 162.72, 0.0, 'well believe it or not the grid all of those<00:02:43.440><c> straight</c><00:02:43.840><c> lines</c><00:02:44.480><c> are</c><00:02:44.760><c> actually</c><00:02:45.519><c> 30°</c><00:02:46.519><c> a</c>', '', '', '<span>well</span><span>believe</span><span>it</span><span>or</span><span>not</span><span>the</span><span>grid</span><span>all</span><span>of</span><span>those<00:02:43.440><c></span><span>straight</c><00:02:43.840><c></span><span>lines</c><00:02:44.480><c></span><span>are</c><00:02:44.760><c></span><span>actually</c><00:02:45.519><c></span><span>30°</c><00:02:46.519><c></span><span>a</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 118, 166.75, 0.0, 'those straight lines are actually 30° a', '', '', '<span>those</span><span pid="511" class="highlight highlight-a">straight lines</span><span>are</span><span>actually</span><span>30°</span><span>a</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 119, 166.76, 0.0, 'those straight lines are actually 30° a skew<00:02:47.080><c> from</c><00:02:47.280><c> due</c><00:02:47.560><c> north</c><00:02:47.959><c> and</c><00:02:48.080><c> that''s</c><00:02:48.200><c> so</c><00:02:48.319><c> it</c>', '', '', '<span>those</span><span>straight</span><span>lines</span><span>are</span><span>actually</span><span>30°</span><span>a</span><span>skew<00:02:47.080><c></span><span>from</c><00:02:47.280><c></span><span>due</c><00:02:47.560><c></span><span>north</c><00:02:47.959><c></span><span>and</c><00:02:48.080><c></span><span>that''s</c><00:02:48.200><c></span><span>so</c><00:02:48.319><c></span><span>it</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 120, 168.43, 0.0, 'skew from due north and that''s so it', '', '', '<span tid="50060" class="highlight highlight-a">skew</span><span>from</span><span>due</span><span>north</span><span>and</span><span>that''s</span><span>so</span><span>it</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 121, 168.44, 0.0, 'skew from due north and that''s so it could<00:02:48.560><c> fit</c><00:02:48.800><c> the</c><00:02:48.959><c> shape</c><00:02:49.239><c> of</c><00:02:49.400><c> Manhattan</c><00:02:49.920><c> rather</c>', '', '', '<span>skew</span><span>from</span><span>due</span><span>north</span><span>and</span><span>that''s</span><span>so</span><span>it</span><span>could<00:02:48.560><c></span><span>fit</c><00:02:48.800><c></span><span>the</c><00:02:48.959><c></span><span>shape</c><00:02:49.239><c></span><span>of</c><00:02:49.400><c></span><span>Manhattan</c><00:02:49.920><c></span><span>rather</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 122, 170.11, 0.0, 'could fit the shape of Manhattan rather', '', '', '<span>could</span><span tid="50061" class="highlight highlight-a">fit</span><span>the</span><span tid="50062" class="highlight highlight-a">shape</span><span>of</span><span>Manhattan</span><span>rather</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 123, 170.12, 0.0, 'could fit the shape of Manhattan rather than<00:02:50.280><c> being</c><00:02:50.560><c> like</c><00:02:50.760><c> diagonal</c><00:02:51.200><c> you</c><00:02:51.319><c> know</c><00:02:51.400><c> what</c><00:02:51.480><c> I</c>', '', '', '<span>could</span><span>fit</span><span>the</span><span>shape</span><span>of</span><span>Manhattan</span><span>rather</span><span>than<00:02:50.280><c></span><span>being</c><00:02:50.560><c></span><span>like</c><00:02:50.760><c></span><span>diagonal</c><00:02:51.200><c></span><span>you</c><00:02:51.319><c></span><span>know</c><00:02:51.400><c></span><span>what</c><00:02:51.480><c></span><span>I</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 124, 171.55, 0.0, 'than being like diagonal you know what I', '', '', '<span>than</span><span>being</span><span>like</span><span tid="50063" class="highlight highlight-a">diagonal</span><span pid="512" class="highlight highlight-i">you know</span><span>what</span><span>I</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 125, 171.56, 0.0, 'than being like diagonal you know what I mean<00:02:51.800><c> it''s</c><00:02:51.959><c> also</c><00:02:52.200><c> that</c><00:02:52.360><c> 30°</c><00:02:53.200><c> es</c><00:02:53.440><c> skew</c><00:02:53.680><c> angle</c>', '', '', '<span>than</span><span>being</span><span>like</span><span>diagonal</span><span>you</span><span>know</span><span>what</span><span>I</span><span>mean<00:02:51.800><c></span><span>it''s</c><00:02:51.959><c></span><span>also</c><00:02:52.200><c></span><span>that</c><00:02:52.360><c></span><span>30°</c><00:02:53.200><c></span><span>es</c><00:02:53.440><c></span><span>skew</c><00:02:53.680><c></span><span>angle</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 126, 174.03, 0.0, 'mean it''s also that 30° es skew angle', '', '', '<span>mean</span><span>it''s</span><span>also</span><span>that</span><span>30°</span><span>es</span><span tid="50064" class="highlight highlight-a">skew</span><span tid="50065" class="highlight highlight-a">angle</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 127, 174.04, 0.0, 'mean it''s also that 30° es skew angle that<00:02:54.200><c> gives</c><00:02:54.440><c> us</c><00:02:54.680><c> the</c><00:02:55.120><c> sunset</c><00:02:55.599><c> phenomenon</c>', '', '', '<span>mean</span><span>it''s</span><span>also</span><span>that</span><span>30°</span><span>es</span><span>skew</span><span>angle</span><span>that<00:02:54.200><c></span><span>gives</c><00:02:54.440><c></span><span>us</c><00:02:54.680><c></span><span>the</c><00:02:55.120><c></span><span>sunset</c><00:02:55.599><c></span><span>phenomenon</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 128, 176.07, 0.0, 'that gives us the sunset phenomenon', '', '', '<span>that</span><span>gives</span><span>us</span><span>the</span><span tid="50066" class="highlight highlight-a">sunset</span><span tid="50067" class="highlight highlight-a">phenomenon</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 129, 176.08, 0.0, 'that gives us the sunset phenomenon known<00:02:56.319><c> as</c><00:02:56.519><c> Manhattan</c><00:02:57.200><c> henge</c><00:02:58.000><c> Manhattan</c><00:02:58.640><c> henge</c>', '', '', '<span>that</span><span>gives</span><span>us</span><span>the</span><span>sunset</span><span>phenomenon</span><span>known<00:02:56.319><c></span><span>as</c><00:02:56.519><c></span><span>Manhattan</c><00:02:57.200><c></span><span>henge</c><00:02:58.000><c></span><span>Manhattan</c><00:02:58.640><c></span><span>henge</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 130, 179.11, 0.0, 'known as Manhattan henge Manhattan henge', '', '', '<span tid="50068" class="highlight highlight-a">known</span><span>as</span><span tid="50069" class="highlight highlight-a">Manhattan</span><span tid="50070" class="highlight highlight-a">henge</span><span tid="50071" class="highlight highlight-a">Manhattan</span><span tid="50072" class="highlight highlight-a">henge</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 131, 179.12, 0.0, 'known as Manhattan henge Manhattan henge like<00:02:59.239><c> Stonehenge</c><00:02:59.840><c> so</c><00:02:59.959><c> yeah</c><00:03:00.080><c> Manhattan</c><00:03:00.440><c> henge</c>', '', '', '<span>known</span><span>as</span><span>Manhattan</span><span>henge</span><span>Manhattan</span><span>henge</span><span>like<00:02:59.239><c></span><span>Stonehenge</c><00:02:59.840><c></span><span>so</c><00:02:59.959><c></span><span>yeah</c><00:03:00.080><c></span><span>Manhattan</c><00:03:00.440><c></span><span>henge</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 132, 181.229, 0.0, 'like Stonehenge so yeah Manhattan henge', '', '', '<span>like</span><span tid="50073" class="highlight highlight-a">Stonehenge</span><span>so</span><span>yeah</span><span tid="50074" class="highlight highlight-a">Manhattan</span><span tid="50075" class="highlight highlight-a">henge</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 133, 181.239, 0.0, 'like Stonehenge so yeah Manhattan henge twice<00:03:01.480><c> a</c><00:03:01.640><c> year</c><00:03:01.959><c> pretty</c><00:03:02.200><c> cool</c><00:03:02.640><c> but</c><00:03:03.000><c> guess</c><00:03:03.280><c> what</c>', '', '', '<span>like</span><span>Stonehenge</span><span>so</span><span>yeah</span><span>Manhattan</span><span>henge</span><span>twice<00:03:01.480><c></span><span>a</c><00:03:01.640><c></span><span>year</c><00:03:01.959><c></span><span>pretty</c><00:03:02.200><c></span><span>cool</c><00:03:02.640><c></span><span>but</c><00:03:03.000><c></span><span>guess</c><00:03:03.280><c></span><span>what</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 134, 183.509, 0.0, 'twice a year pretty cool but guess what', '', '', '<span tid="50076" class="highlight highlight-a">twice</span><span>a</span><span>year</span><span>pretty</span><span tid="50077" class="highlight highlight-a">cool</span><span>but</span><span>guess</span><span>what</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 135, 183.519, 0.0, 'twice a year pretty cool but guess what the<00:03:03.640><c> only</c><00:03:03.879><c> Street</c><00:03:04.159><c> in</c><00:03:04.280><c> Manhattan</c><00:03:04.680><c> is</c><00:03:04.840><c> that</c>', '', '', '<span>twice</span><span>a</span><span>year</span><span>pretty</span><span>cool</span><span>but</span><span>guess</span><span>what</span><span>the<00:03:03.640><c></span><span>only</c><00:03:03.879><c></span><span>Street</c><00:03:04.159><c></span><span>in</c><00:03:04.280><c></span><span>Manhattan</c><00:03:04.680><c></span><span>is</c><00:03:04.840><c></span><span>that</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 136, 185.07, 0.0, 'the only Street in Manhattan is that', '', '', '<span>the</span> <span>only</span> <span>Street</span> <span>in</span> <span>Manhattan</span> <span>is</span> <span>that</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 137, 185.08, 0.0, 'the only Street in Manhattan is that actually<00:03:05.319><c> runs</c><00:03:05.640><c> a</c><00:03:05.840><c> true</c><00:03:06.159><c> East</c><00:03:06.519><c> West</c><00:03:07.080><c> be</c><00:03:07.239><c> crazy</c>', '', '', '<span>the</span> <span>only</span> <span>Street</span> <span>in</span> <span>Manhattan</span> <span>is</span> <span>that</span> <span>actually<00:03:05.319><c></span> <span>runs</c><00:03:05.640><c></span> <span>a</c><00:03:05.840><c></span> <span>true</c><00:03:06.159><c></span> <span>East</c><00:03:06.519><c></span> <span>West</c><00:03:07.080><c></span> <span>be</c><00:03:07.239><c></span> <span>crazy</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 138, 187.509, 0.0, 'actually runs a true East West be crazy', '', '', '<span>actually</span> <span>runs</span> <span>a</span> <span>true</span> <span>East</span> <span>West</span> <span>be</span> <span>crazy</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 139, 187.519, 0.0, 'actually runs a true East West be crazy if<00:03:07.599><c> it</c><00:03:07.720><c> wasn''t</c><00:03:08.080><c> that</c>', '', '', '<span>actually</span> <span>runs</span> <span>a</span> <span>true</span> <span>East</span> <span>West</span> <span>be</span> <span>crazy</span> <span>if<00:03:07.599><c></span> <span>it</c><00:03:07.720><c></span> <span>wasn''t</c><00:03:08.080><c></span> <span>that</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 140, 188.869, 0.0, 'if it wasn''t that', '', '', '<span>if</span> <span>it</span> <span>wasn''t</span> <span>that</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 141, 188.879, 0.0, 'if it wasn''t that one<00:03:09.879><c> it</c><00:03:10.000><c> is</c><00:03:10.200><c> that</c><00:03:10.360><c> one</c><00:03:10.640><c> if</c><00:03:10.840><c> by</c><00:03:10.959><c> the</c><00:03:11.040><c> way</c><00:03:11.159><c> you''re</c>', '', '', '<span>if</span> <span>it</span> <span>wasn''t</span> <span>that</span> <span>one<00:03:09.879><c></span> <span>it</c><00:03:10.000><c></span> <span>is</c><00:03:10.200><c></span> <span>that</c><00:03:10.360><c></span> <span>one</c><00:03:10.640><c></span> <span>if</c><00:03:10.840><c></span> <span>by</c><00:03:10.959><c></span> <span>the</c><00:03:11.040><c></span> <span>way</c><00:03:11.159><c></span> <span>you''re</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 142, 191.27, 0.0, 'one it is that one if by the way you''re', '', '', '<span>one</span> <span>it</span> <span>is</span> <span>that</span> <span>one</span> <span>if</span> <span>by</span> <span>the</span> <span>way</span> <span>you''re</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 143, 191.28, 0.0, 'one it is that one if by the way you''re feeling<00:03:11.519><c> fomo</c><00:03:11.959><c> for</c><00:03:12.080><c> not</c><00:03:12.200><c> living</c><00:03:12.400><c> in</c><00:03:12.519><c> a</c>', '', '', '<span>one</span> <span>it</span> <span>is</span> <span>that</span> <span>one</span> <span>if</span> <span>by</span> <span>the</span> <span>way</span> <span>you''re</span> <span>feeling<00:03:11.519><c></span> <span>fomo</c><00:03:11.959><c></span> <span>for</c><00:03:12.080><c></span> <span>not</c><00:03:12.200><c></span> <span>living</c><00:03:12.400><c></span> <span>in</c><00:03:12.519><c></span> <span>a</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 144, 192.71, 0.0, 'feeling fomo for not living in a', '', '', '<span>feeling</span> <span>fomo</span> <span>for</span> <span>not</span> <span>living</span> <span>in</span> <span>a</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 145, 192.72, 0.0, 'feeling fomo for not living in a beautiful<00:03:13.640><c> Ivy</c><00:03:14.000><c> covered</c><00:03:14.319><c> townhouse</c><00:03:14.879><c> in</c><00:03:15.040><c> New</c>', '', '', '<span>feeling</span> <span>fomo</span> <span>for</span> <span>not</span> <span>living</span> <span>in</span> <span>a</span> <span>beautiful<00:03:13.640><c></span> <span>Ivy</c><00:03:14.000><c></span> <span>covered</c><00:03:14.319><c></span> <span>townhouse</c><00:03:14.879><c></span> <span>in</c><00:03:15.040><c></span> <span>New</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 146, 195.19, 0.0, 'beautiful Ivy covered townhouse in New', '', '', '<span>beautiful</span> <span>Ivy</span> <span>covered</span> <span>townhouse</span> <span>in</span> <span>New</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 147, 195.2, 0.0, 'beautiful Ivy covered townhouse in New York<00:03:15.519><c> I</c><00:03:15.640><c> also</c><00:03:16.040><c> read</c><00:03:16.400><c> that</c><00:03:16.840><c> Ivy</c><00:03:17.200><c> apparently</c>', '', '', '<span>beautiful</span> <span>Ivy</span> <span>covered</span> <span>townhouse</span> <span>in</span> <span>New</span> <span>York<00:03:15.519><c></span> <span>I</c><00:03:15.640><c></span> <span>also</c><00:03:16.040><c></span> <span>read</c><00:03:16.400><c></span> <span>that</c><00:03:16.840><c></span> <span>Ivy</c><00:03:17.200><c></span> <span>apparently</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 148, 197.589, 0.0, 'York I also read that Ivy apparently', '', '', '<span>York</span> <span>I</span> <span>also</span> <span>read</span> <span>that</span> <span>Ivy</span> <span>apparently</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 149, 197.599, 0.0, 'York I also read that Ivy apparently attracts<00:03:18.360><c> a</c><00:03:18.519><c> lot</c><00:03:18.680><c> of</c><00:03:19.000><c> bugs</c><00:03:20.000><c> so</c><00:03:20.440><c> pros</c><00:03:20.680><c> and</c><00:03:20.799><c> cons</c>', '', '', '<span>York</span> <span>I</span> <span>also</span> <span>read</span> <span>that</span> <span>Ivy</span> <span>apparently</span> <span>attracts<00:03:18.360><c></span> <span>a</c><00:03:18.519><c></span> <span>lot</c><00:03:18.680><c></span> <span>of</c><00:03:19.000><c></span> <span>bugs</c><00:03:20.000><c></span> <span>so</c><00:03:20.440><c></span> <span>pros</c><00:03:20.680><c></span> <span>and</c><00:03:20.799><c></span> <span>cons</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 150, 201.509, 0.0, 'attracts a lot of bugs so pros and cons', '', '', '<span>attracts</span> <span>a</span> <span>lot</span> <span>of</span> <span>bugs</span> <span>so</span> <span>pros</span> <span>and</span> <span>cons</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 151, 201.519, 0.0, 'attracts a lot of bugs so pros and cons anyways<00:03:21.920><c> now</c><00:03:22.040><c> let''s</c><00:03:22.200><c> go</c><00:03:22.319><c> to</c><00:03:22.560><c> our</c><00:03:22.879><c> next</c>', '', '', '<span>attracts</span> <span>a</span> <span>lot</span> <span>of</span> <span>bugs</span> <span>so</span> <span>pros</span> <span>and</span> <span>cons</span> <span>anyways<00:03:21.920><c></span> <span>now</c><00:03:22.040><c></span> <span>let''s</c><00:03:22.200><c></span> <span>go</c><00:03:22.319><c></span> <span>to</c><00:03:22.560><c></span> <span>our</c><00:03:22.879><c></span> <span>next</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 152, 204.88, 0.0, 'anyways now let''s go to our next', '', '', '<span>anyways</span> <span>now</span> <span>let''s</span> <span>go</span> <span>to</span> <span>our</span> <span>next</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 153, 204.89, 0.0, 'anyways now let''s go to our next [Music]', '', '', '<span>anyways</span> <span>now</span> <span>let''s</span> <span>go</span> <span>to</span> <span>our</span> <span>next</span> <span>[Music]</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 154, 206.309, 0.0, '[Music]', '', '', '<span>[Music]</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 155, 206.319, 0.0, '[Music] location<00:03:27.319><c> which</c><00:03:27.440><c> is</c><00:03:27.599><c> pretty</c><00:03:27.840><c> iconic</c>', '', '', '<span>[Music]</span> <span>location<00:03:27.319><c></span> <span>which</c><00:03:27.440><c></span> <span>is</c><00:03:27.599><c></span> <span>pretty</c><00:03:27.840><c></span> <span>iconic</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 156, 218.39, 0.0, '[Music]', '', '', '<span>[Music]</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 157, 218.4, 0.0, '[Music] all<00:03:38.519><c> right</c><00:03:38.879><c> just</c><00:03:39.159><c> moments</c><00:03:39.560><c> ago</c><00:03:39.959><c> I</c><00:03:40.080><c> wrote</c><00:03:40.920><c> this</c>', '', '', '<span>[Music]</span> <span>all<00:03:38.519><c></span> <span>right</c><00:03:38.879><c></span> <span>just</c><00:03:39.159><c></span> <span>moments</c><00:03:39.560><c></span> <span>ago</c><00:03:39.959><c></span> <span>I</c><00:03:40.080><c></span> <span>wrote</c><00:03:40.920><c></span> <span>this</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 158, 221.309, 0.0, 'all right just moments ago I wrote this', '', '', '<span>all</span> <span>right</span> <span>just</span> <span>moments</span> <span>ago</span> <span>I</span> <span>wrote</span> <span>this</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 159, 221.319, 0.0, 'all right just moments ago I wrote this bag<00:03:41.680><c> off</c><00:03:41.920><c> as</c><00:03:42.239><c> a</c><00:03:42.360><c> pretty</c><00:03:42.599><c> impractical</c><00:03:43.319><c> design</c>', '', '', '<span>all</span> <span>right</span> <span>just</span> <span>moments</span> <span>ago</span> <span>I</span> <span>wrote</span> <span>this</span> <span>bag<00:03:41.680><c></span> <span>off</c><00:03:41.920><c></span> <span>as</c><00:03:42.239><c></span> <span>a</c><00:03:42.360><c></span> <span>pretty</c><00:03:42.599><c></span> <span>impractical</c><00:03:43.319><c></span> <span>design</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 160, 223.91, 0.0, 'bag off as a pretty impractical design', '', '', '<span>bag</span> <span>off</span> <span>as</span> <span>a</span> <span>pretty</span> <span>impractical</span> <span>design</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 161, 223.92, 0.0, 'bag off as a pretty impractical design but<00:03:44.040><c> a</c><00:03:44.200><c> smart</c><00:03:44.439><c> marketing</c><00:03:44.920><c> tactic</c><00:03:45.360><c> I</c><00:03:45.480><c> got</c><00:03:45.599><c> to</c>', '', '', '<span>bag</span> <span>off</span> <span>as</span> <span>a</span> <span>pretty</span> <span>impractical</span> <span>design</span> <span>but<00:03:44.040><c></span> <span>a</c><00:03:44.200><c></span> <span>smart</c><00:03:44.439><c></span> <span>marketing</c><00:03:44.920><c></span> <span>tactic</c><00:03:45.360><c></span> <span>I</c><00:03:45.480><c></span> <span>got</c><00:03:45.599><c></span> <span>to</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 162, 225.83, 0.0, 'but a smart marketing tactic I got to', '', '', '<span>but</span> <span>a</span> <span>smart</span> <span>marketing</span> <span>tactic</span> <span>I</span> <span>got</span> <span>to</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 163, 225.84, 0.0, 'but a smart marketing tactic I got to say<00:03:46.560><c> kind</c><00:03:46.680><c> of</c><00:03:46.840><c> convenient</c><00:03:47.360><c> to</c><00:03:47.560><c> just</c><00:03:47.680><c> hold</c><00:03:47.920><c> it</c>', '', '', '<span>but</span> <span>a</span> <span>smart</span> <span>marketing</span> <span>tactic</span> <span>I</span> <span>got</span> <span>to</span> <span>say<00:03:46.560><c></span> <span>kind</c><00:03:46.680><c></span> <span>of</c><00:03:46.840><c></span> <span>convenient</c><00:03:47.360><c></span> <span>to</c><00:03:47.560><c></span> <span>just</c><00:03:47.680><c></span> <span>hold</c><00:03:47.920><c></span> <span>it</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 164, 228.07, 0.0, 'say kind of convenient to just hold it', '', '', '<span>say</span> <span>kind</span> <span>of</span> <span>convenient</span> <span>to</span> <span>just</span> <span>hold</span> <span>it</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 165, 228.08, 0.0, 'say kind of convenient to just hold it like<00:03:48.400><c> that</c><00:03:49.400><c> maybe</c><00:03:49.640><c> it''s</c><00:03:49.879><c> practical</c><00:03:50.400><c> too</c>', '', '', '<span>say</span> <span>kind</span> <span>of</span> <span>convenient</span> <span>to</span> <span>just</span> <span>hold</span> <span>it</span> <span>like<00:03:48.400><c></span> <span>that</c><00:03:49.400><c></span> <span>maybe</c><00:03:49.640><c></span> <span>it''s</c><00:03:49.879><c></span> <span>practical</c><00:03:50.400><c></span> <span>too</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 166, 241.869, 0.0, 'so interesting they have a muse here I', '', '', '<span>so</span> <span>interesting</span> <span>they</span> <span>have</span> <span>a</span> <span>muse</span> <span>here</span> <span>I</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 167, 241.879, 0.0, 'so interesting they have a muse here I mean<00:04:02.079><c> I''ve</c><00:04:02.239><c> walked</c><00:04:02.519><c> up</c><00:04:02.640><c> and</c><00:04:02.760><c> down</c><00:04:03.000><c> this</c><00:04:03.120><c> but</c><00:04:03.239><c> I</c>', '', '', '<span>so</span> <span>interesting</span> <span>they</span> <span>have</span> <span>a</span> <span>muse</span> <span>here</span> <span>I</span> <span>mean<00:04:02.079><c></span> <span>I''ve</c><00:04:02.239><c></span> <span>walked</c><00:04:02.519><c></span> <span>up</c><00:04:02.640><c></span> <span>and</c><00:04:02.760><c></span> <span>down</c><00:04:03.000><c></span> <span>this</c><00:04:03.120><c></span> <span>but</c><00:04:03.239><c></span> <span>I</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 168, 243.309, 0.0, 'mean I''ve walked up and down this but I', '', '', '<span>mean</span> <span>I''ve</span> <span>walked</span> <span>up</span> <span>and</span> <span>down</span> <span>this</span> <span>but</span> <span>I</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 169, 243.319, 0.0, 'mean I''ve walked up and down this but I didn''t<00:04:03.439><c> know</c><00:04:03.560><c> what</c><00:04:03.640><c> a</c><00:04:03.760><c> muse</c><00:04:04.239><c> was</c><00:04:05.040><c> until</c><00:04:05.360><c> I</c><00:04:05.480><c> went</c>', '', '', '<span>mean</span> <span>I''ve</span> <span>walked</span> <span>up</span> <span>and</span> <span>down</span> <span>this</span> <span>but</span> <span>I</span> <span>didn''t<00:04:03.439><c></span> <span>know</c><00:04:03.560><c></span> <span>what</c><00:04:03.640><c></span> <span>a</c><00:04:03.760><c></span> <span>muse</c><00:04:04.239><c></span> <span>was</c><00:04:05.040><c></span> <span>until</c><00:04:05.360><c></span> <span>I</c><00:04:05.480><c></span> <span>went</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 170, 245.589, 0.0, 'didn''t know what a muse was until I went', '', '', '<span>didn''t</span> <span>know</span> <span>what</span> <span>a</span> <span>muse</span> <span>was</span> <span>until</span> <span>I</span> <span>went</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 171, 245.599, 0.0, 'didn''t know what a muse was until I went to<00:04:05.720><c> London</c><00:04:06.000><c> and</c><00:04:06.159><c> my</c><00:04:06.319><c> friend</c><00:04:06.760><c> educated</c><00:04:07.280><c> me</c><00:04:07.840><c> it''s</c>', '', '', '<span>didn''t</span> <span>know</span> <span>what</span> <span>a</span> <span>muse</span> <span>was</span> <span>until</span> <span>I</span> <span>went</span> <span>to<00:04:05.720><c></span> <span>London</c><00:04:06.000><c></span> <span>and</c><00:04:06.159><c></span> <span>my</c><00:04:06.319><c></span> <span>friend</c><00:04:06.760><c></span> <span>educated</c><00:04:07.280><c></span> <span>me</c><00:04:07.840><c></span> <span>it''s</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 172, 248.03, 0.0, 'to London and my friend educated me it''s', '', '', '<span>to</span> <span>London</span> <span>and</span> <span>my</span> <span>friend</span> <span>educated</span> <span>me</span> <span>it''s</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 173, 248.04, 0.0, 'to London and my friend educated me it''s basically<00:04:08.439><c> those</c><00:04:08.640><c> little</c><00:04:08.840><c> back</c><00:04:09.079><c> Alleyways</c>', '', '', '<span>to</span> <span>London</span> <span>and</span> <span>my</span> <span>friend</span> <span>educated</span> <span>me</span> <span>it''s</span> <span>basically<00:04:08.439><c></span> <span>those</c><00:04:08.640><c></span> <span>little</c><00:04:08.840><c></span> <span>back</c><00:04:09.079><c></span> <span>Alleyways</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 174, 249.75, 0.0, 'basically those little back Alleyways', '', '', '<span>basically</span> <span>those</span> <span>little</span> <span>back</span> <span>Alleyways</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 175, 249.76, 0.0, 'basically those little back Alleyways behind<00:04:10.239><c> the</c><00:04:10.400><c> main</c><00:04:10.879><c> quarters</c><00:04:11.879><c> where</c><00:04:12.519><c> they</c><00:04:12.680><c> kept</c>', '', '', '<span>basically</span> <span>those</span> <span>little</span> <span>back</span> <span>Alleyways</span> <span>behind<00:04:10.239><c></span> <span>the</c><00:04:10.400><c></span> <span>main</c><00:04:10.879><c></span> <span>quarters</c><00:04:11.879><c></span> <span>where</c><00:04:12.519><c></span> <span>they</c><00:04:12.680><c></span> <span>kept</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 176, 253.03, 0.0, 'behind the main quarters where they kept', '', '', '<span>behind</span> <span>the</span> <span>main</span> <span>quarters</span> <span>where</span> <span>they</span> <span>kept</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 177, 253.04, 0.0, 'behind the main quarters where they kept the<00:04:13.200><c> horses</c><00:04:13.599><c> and</c><00:04:13.760><c> the</c><00:04:13.879><c> stables</c><00:04:14.480><c> and</c><00:04:14.640><c> I</c><00:04:14.720><c> think</c>', '', '', '<span>behind</span> <span>the</span> <span>main</span> <span>quarters</span> <span>where</span> <span>they</span> <span>kept</span> <span>the<00:04:13.200><c></span> <span>horses</c><00:04:13.599><c></span> <span>and</c><00:04:13.760><c></span> <span>the</c><00:04:13.879><c></span> <span>stables</c><00:04:14.480><c></span> <span>and</c><00:04:14.640><c></span> <span>I</c><00:04:14.720><c></span> <span>think</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 178, 254.869, 0.0, 'the horses and the stables and I think', '', '', '<span>the</span> <span>horses</span> <span>and</span> <span>the</span> <span>stables</span> <span>and</span> <span>I</span> <span>think</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 179, 254.879, 0.0, 'the horses and the stables and I think it<00:04:14.959><c> was</c><00:04:15.120><c> like</c><00:04:15.239><c> the</c><00:04:15.319><c> servants</c><00:04:15.799><c> quarters</c><00:04:16.280><c> too</c>', '', '', '<span>the</span> <span>horses</span> <span>and</span> <span>the</span> <span>stables</span> <span>and</span> <span>I</span> <span>think</span> <span>it<00:04:14.959><c></span> <span>was</c><00:04:15.120><c></span> <span>like</c><00:04:15.239><c></span> <span>the</c><00:04:15.319><c></span> <span>servants</c><00:04:15.799><c></span> <span>quarters</c><00:04:16.280><c></span> <span>too</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 180, 256.749, 0.0, 'it was like the servants quarters too', '', '', '<span>it</span> <span>was</span> <span>like</span> <span>the</span> <span>servants</span> <span>quarters</span> <span>too</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 181, 256.759, 0.0, 'it was like the servants quarters too now<00:04:16.919><c> they''re</c><00:04:17.160><c> like</c><00:04:17.359><c> obviously</c><00:04:17.680><c> repurposed</c>', '', '', '<span>it</span> <span>was</span> <span>like</span> <span>the</span> <span>servants</span> <span>quarters</span> <span>too</span> <span>now<00:04:16.919><c></span> <span>they''re</c><00:04:17.160><c></span> <span>like</c><00:04:17.359><c></span> <span>obviously</c><00:04:17.680><c></span> <span>repurposed</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 182, 258.31, 0.0, 'now they''re like obviously repurposed', '', '', '<span>now</span> <span>they''re</span> <span>like</span> <span>obviously</span> <span>repurposed</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 183, 258.32, 0.0, 'now they''re like obviously repurposed into<00:04:19.040><c> really</c><00:04:19.320><c> really</c><00:04:19.519><c> beautiful</c><00:04:20.120><c> little</c><00:04:20.560><c> town</c>', '', '', '<span>now</span> <span>they''re</span> <span>like</span> <span>obviously</span> <span>repurposed</span> <span>into<00:04:19.040><c></span> <span>really</c><00:04:19.320><c></span> <span>really</c><00:04:19.519><c></span> <span>beautiful</c><00:04:20.120><c></span> <span>little</c><00:04:20.560><c></span> <span>town</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 184, 260.83, 0.0, 'into really really beautiful little town', '', '', '<span>into</span> <span>really</span> <span>really</span> <span>beautiful</span> <span>little</span> <span>town</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 185, 260.84, 0.0, 'into really really beautiful little town homes<00:04:21.199><c> as</c><00:04:21.359><c> well</c><00:04:21.759><c> at</c><00:04:21.880><c> least</c><00:04:22.040><c> in</c><00:04:22.160><c> London</c><00:04:22.479><c> and</c><00:04:22.600><c> it</c>', '', '', '<span>into</span> <span>really</span> <span>really</span> <span>beautiful</span> <span>little</span> <span>town</span> <span>homes<00:04:21.199><c></span> <span>as</c><00:04:21.359><c></span> <span>well</c><00:04:21.759><c></span> <span>at</c><00:04:21.880><c></span> <span>least</c><00:04:22.040><c></span> <span>in</c><00:04:22.160><c></span> <span>London</c><00:04:22.479><c></span> <span>and</c><00:04:22.600><c></span> <span>it</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 186, 262.67, 0.0, 'homes as well at least in London and it', '', '', '<span>homes</span> <span>as</span> <span>well</span> <span>at</span> <span>least</span> <span>in</span> <span>London</span> <span>and</span> <span>it</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 187, 262.68, 0.0, 'homes as well at least in London and it looks<00:04:22.919><c> like</c><00:04:23.360><c> that''s</c><00:04:23.600><c> University</c><00:04:24.600><c> for</c><00:04:24.800><c> NYU</c>', '', '', '<span>homes</span> <span>as</span> <span>well</span> <span>at</span> <span>least</span> <span>in</span> <span>London</span> <span>and</span> <span>it</span> <span>looks<00:04:22.919><c></span> <span>like</c><00:04:23.360><c></span> <span>that''s</c><00:04:23.600><c></span> <span>University</c><00:04:24.600><c></span> <span>for</c><00:04:24.800><c></span> <span>NYU</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 188, 265.59, 0.0, 'looks like that''s University for NYU', '', '', '<span>looks</span> <span>like</span> <span>that''s</span> <span>University</span> <span>for</span> <span>NYU</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 189, 265.6, 0.0, 'looks like that''s University for NYU property<00:04:26.000><c> but</c><00:04:26.199><c> pretty</c><00:04:26.440><c> cool</c>', '', '', '<span>looks</span> <span>like</span> <span>that''s</span> <span>University</span> <span>for</span> <span>NYU</span> <span>property<00:04:26.000><c></span> <span>but</c><00:04:26.199><c></span> <span>pretty</c><00:04:26.440><c></span> <span>cool</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 190, 276.629, 0.0, 'you might have noticed we haven''t eaten', '', '', '<span>you</span> <span>might</span> <span>have</span> <span>noticed</span> <span>we</span> <span>haven''t</span> <span>eaten</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 191, 276.639, 0.0, 'you might have noticed we haven''t eaten yet<00:04:36.960><c> today</c><00:04:37.960><c> and</c><00:04:38.080><c> I''m</c><00:04:38.199><c> getting</c><00:04:38.400><c> hungry</c><00:04:38.960><c> so</c><00:04:39.600><c> as</c>', '', '', '<span>you</span> <span>might</span> <span>have</span> <span>noticed</span> <span>we</span> <span>haven''t</span> <span>eaten</span> <span>yet<00:04:36.960><c></span> <span>today</c><00:04:37.960><c></span> <span>and</c><00:04:38.080><c></span> <span>I''m</c><00:04:38.199><c></span> <span>getting</c><00:04:38.400><c></span> <span>hungry</c><00:04:38.960><c></span> <span>so</c><00:04:39.600><c></span> <span>as</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 192, 279.79, 0.0, 'yet today and I''m getting hungry so as', '', '', '<span>yet</span> <span>today</span> <span>and</span> <span>I''m</span> <span>getting</span> <span>hungry</span> <span>so</span> <span>as</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 193, 279.8, 0.0, 'yet today and I''m getting hungry so as always<00:04:40.120><c> I''m</c><00:04:40.240><c> taking</c><00:04:40.479><c> you</c><00:04:40.639><c> to</c><00:04:41.240><c> a</c><00:04:41.440><c> New</c><00:04:41.600><c> York</c><00:04:41.919><c> spot</c>', '', '', '<span>yet</span> <span>today</span> <span>and</span> <span>I''m</span> <span>getting</span> <span>hungry</span> <span>so</span> <span>as</span> <span>always<00:04:40.120><c></span> <span>I''m</c><00:04:40.240><c></span> <span>taking</c><00:04:40.479><c></span> <span>you</c><00:04:40.639><c></span> <span>to</c><00:04:41.240><c></span> <span>a</c><00:04:41.440><c></span> <span>New</c><00:04:41.600><c></span> <span>York</c><00:04:41.919><c></span> <span>spot</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 194, 282.469, 0.0, 'always I''m taking you to a New York spot', '', '', '<span>always</span> <span>I''m</span> <span>taking</span> <span>you</span> <span>to</span> <span>a</span> <span>New</span> <span>York</span> <span>spot</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 195, 282.479, 0.0, 'always I''m taking you to a New York spot all<00:04:42.680><c> right</c><00:04:43.039><c> we</c><00:04:43.199><c> are</c>', '', '', '<span>always</span> <span>I''m</span> <span>taking</span> <span>you</span> <span>to</span> <span>a</span> <span>New</span> <span>York</span> <span>spot</span> <span>all<00:04:42.680><c></span> <span>right</c><00:04:43.039><c></span> <span>we</c><00:04:43.199><c></span> <span>are</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 196, 288.43, 0.0, 'here just kidding New Yorkers will get', '', '', '<span>here</span> <span>just</span> <span>kidding</span> <span>New</span> <span>Yorkers</span> <span>will</span> <span>get</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 197, 288.44, 0.0, 'here just kidding New Yorkers will get that<00:04:48.560><c> one</c><00:04:48.840><c> that</c><00:04:49.000><c> this</c><00:04:49.120><c> is</c><00:04:49.280><c> like</c><00:04:49.440><c> the</c><00:04:49.520><c> most</c>', '', '', '<span>here</span> <span>just</span> <span>kidding</span> <span>New</span> <span>Yorkers</span> <span>will</span> <span>get</span> <span>that<00:04:48.560><c></span> <span>one</c><00:04:48.840><c></span> <span>that</c><00:04:49.000><c></span> <span>this</c><00:04:49.120><c></span> <span>is</c><00:04:49.280><c></span> <span>like</c><00:04:49.440><c></span> <span>the</c><00:04:49.520><c></span> <span>most</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 198, 289.749, 0.0, 'that one that this is like the most', '', '', '<span>that</span> <span>one</span> <span>that</span> <span>this</span> <span>is</span> <span>like</span> <span>the</span> <span>most</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 199, 289.759, 0.0, 'that one that this is like the most famous<00:04:50.039><c> restaurant</c><00:04:50.440><c> in</c><00:04:50.520><c> the</c><00:04:50.600><c> whole</c><00:04:50.720><c> entire</c>', '', '', '<span>that</span> <span>one</span> <span>that</span> <span>this</span> <span>is</span> <span>like</span> <span>the</span> <span>most</span> <span>famous<00:04:50.039><c></span> <span>restaurant</c><00:04:50.440><c></span> <span>in</c><00:04:50.520><c></span> <span>the</c><00:04:50.600><c></span> <span>whole</c><00:04:50.720><c></span> <span>entire</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 200, 290.99, 0.0, 'famous restaurant in the whole entire', '', '', '<span>famous</span> <span>restaurant</span> <span>in</span> <span>the</span> <span>whole</span> <span>entire</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 201, 291.0, 0.0, 'famous restaurant in the whole entire city<00:04:51.400><c> and</c><00:04:51.520><c> I''ve</c><00:04:51.680><c> never</c><00:04:51.880><c> been</c><00:04:52.720><c> but</c><00:04:52.919><c> where</c><00:04:53.080><c> we</c>', '', '', '<span>famous</span> <span>restaurant</span> <span>in</span> <span>the</span> <span>whole</span> <span>entire</span> <span>city<00:04:51.400><c></span> <span>and</c><00:04:51.520><c></span> <span>I''ve</c><00:04:51.680><c></span> <span>never</c><00:04:51.880><c></span> <span>been</c><00:04:52.720><c></span> <span>but</c><00:04:52.919><c></span> <span>where</c><00:04:53.080><c></span> <span>we</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 202, 293.189, 0.0, 'city and I''ve never been but where we', '', '', '<span>city</span> <span>and</span> <span>I''ve</span> <span>never</span> <span>been</span> <span>but</span> <span>where</span> <span>we</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 203, 293.199, 0.0, 'city and I''ve never been but where we are<00:04:53.360><c> going</c><00:04:53.680><c> is</c><00:04:53.840><c> right</c><00:04:54.000><c> next</c><00:04:54.199><c> to</c>', '', '', '<span>city</span> <span>and</span> <span>I''ve</span> <span>never</span> <span>been</span> <span>but</span> <span>where</span> <span>we</span> <span>are<00:04:53.360><c></span> <span>going</c><00:04:53.680><c></span> <span>is</c><00:04:53.840><c></span> <span>right</c><00:04:54.000><c></span> <span>next</c><00:04:54.199><c></span> <span>to</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 204, 300.95, 0.0, 'it they closed was an hour', '', '', '<span>it</span> <span>they</span> <span>closed</span> <span>was</span> <span>an</span> <span>hour</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 205, 300.96, 0.0, 'it they closed was an hour ago', '', '', '<span>it</span> <span>they</span> <span>closed</span> <span>was</span> <span>an</span> <span>hour</span> <span>ago</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 206, 302.88, 0.0, 'ago', '', '', '<span>ago</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 207, 302.89, 0.0, 'ago [Music]', '', '', '<span>ago</span> <span>[Music]</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 208, 304.31, 0.0, '[Music]', '', '', '<span>[Music]</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 209, 304.32, 0.0, '[Music] awesome<00:05:05.320><c> oh</c><00:05:06.039><c> glowy</c><00:05:06.840><c> okay</c><00:05:07.360><c> I</c><00:05:07.520><c> pleas</c><00:05:07.720><c> you</c><00:05:07.880><c> the</c>', '', '', '<span>[Music]</span> <span>awesome<00:05:05.320><c></span> <span>oh</c><00:05:06.039><c></span> <span>glowy</c><00:05:06.840><c></span> <span>okay</c><00:05:07.360><c></span> <span>I</c><00:05:07.520><c></span> <span>pleas</c><00:05:07.720><c></span> <span>you</c><00:05:07.880><c></span> <span>the</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 210, 307.95, 0.0, 'awesome oh glowy okay I pleas you the', '', '', '<span>awesome</span> <span>oh</span> <span>glowy</span> <span>okay</span> <span>I</span> <span>pleas</span> <span>you</span> <span>the</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 211, 307.96, 0.0, 'awesome oh glowy okay I pleas you the kale<00:05:08.199><c> Caesar</c><00:05:08.560><c> salad</c><00:05:09.039><c> with</c><00:05:09.240><c> chicken</c><00:05:10.120><c> thank</c><00:05:10.280><c> you</c>', '', '', '<span>awesome</span> <span>oh</span> <span>glowy</span> <span>okay</span> <span>I</span> <span>pleas</span> <span>you</span> <span>the</span> <span>kale<00:05:08.199><c></span> <span>Caesar</c><00:05:08.560><c></span> <span>salad</c><00:05:09.039><c></span> <span>with</c><00:05:09.240><c></span> <span>chicken</c><00:05:10.120><c></span> <span>thank</c><00:05:10.280><c></span> <span>you</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 212, 310.43, 0.0, 'kale Caesar salad with chicken thank you', '', '', '<span>kale</span> <span>Caesar</span> <span>salad</span> <span>with</span> <span>chicken</span> <span>thank</span> <span>you</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 213, 310.44, 0.0, 'kale Caesar salad with chicken thank you so<00:05:10.639><c> much</c><00:05:11.120><c> all</c><00:05:11.240><c> right</c><00:05:11.360><c> this</c><00:05:11.440><c> is</c><00:05:11.520><c> a</c><00:05:11.639><c> spot</c><00:05:11.800><c> I''ve</c>', '', '', '<span>kale</span> <span>Caesar</span> <span>salad</span> <span>with</span> <span>chicken</span> <span>thank</span> <span>you</span> <span>so<00:05:10.639><c></span> <span>much</c><00:05:11.120><c></span> <span>all</c><00:05:11.240><c></span> <span>right</c><00:05:11.360><c></span> <span>this</c><00:05:11.440><c></span> <span>is</c><00:05:11.520><c></span> <span>a</c><00:05:11.639><c></span> <span>spot</c><00:05:11.800><c></span> <span>I''ve</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 214, 311.95, 0.0, 'so much all right this is a spot I''ve', '', '', '<span>so</span> <span>much</span> <span>all</span> <span>right</span> <span>this</span> <span>is</span> <span>a</span> <span>spot</span> <span>I''ve</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 215, 311.96, 0.0, 'so much all right this is a spot I''ve been<00:05:12.080><c> to</c><00:05:12.320><c> a</c><00:05:12.440><c> couple</c><00:05:12.759><c> times</c><00:05:13.000><c> it''s</c><00:05:13.199><c> actually</c>', '', '', '<span>so</span> <span>much</span> <span>all</span> <span>right</span> <span>this</span> <span>is</span> <span>a</span> <span>spot</span> <span>I''ve</span> <span>been<00:05:12.080><c></span> <span>to</c><00:05:12.320><c></span> <span>a</c><00:05:12.440><c></span> <span>couple</c><00:05:12.759><c></span> <span>times</c><00:05:13.000><c></span> <span>it''s</c><00:05:13.199><c></span> <span>actually</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 216, 313.43, 0.0, 'been to a couple times it''s actually', '', '', '<span>been</span> <span>to</span> <span>a</span> <span>couple</span> <span>times</span> <span>it''s</span> <span>actually</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 217, 313.44, 0.0, 'been to a couple times it''s actually just<00:05:13.560><c> a</c><00:05:13.759><c> great</c><00:05:13.960><c> like</c><00:05:14.120><c> layover</c><00:05:14.600><c> spot</c><00:05:14.840><c> to</c><00:05:14.960><c> come</c>', '', '', '<span>been</span> <span>to</span> <span>a</span> <span>couple</span> <span>times</span> <span>it''s</span> <span>actually</span> <span>just<00:05:13.560><c></span> <span>a</c><00:05:13.759><c></span> <span>great</c><00:05:13.960><c></span> <span>like</c><00:05:14.120><c></span> <span>layover</c><00:05:14.600><c></span> <span>spot</c><00:05:14.840><c></span> <span>to</c><00:05:14.960><c></span> <span>come</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 218, 315.11, 0.0, 'just a great like layover spot to come', '', '', '<span>just</span> <span>a</span> <span>great</span> <span>like</span> <span>layover</span> <span>spot</span> <span>to</span> <span>come</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 219, 315.12, 0.0, 'just a great like layover spot to come and<00:05:15.280><c> do</c><00:05:15.400><c> some</c><00:05:15.560><c> work</c><00:05:15.800><c> cuz</c><00:05:15.960><c> you</c><00:05:16.039><c> can</c><00:05:16.160><c> take</c><00:05:16.280><c> your</c>', '', '', '<span>just</span> <span>a</span> <span>great</span> <span>like</span> <span>layover</span> <span>spot</span> <span>to</span> <span>come</span> <span>and<00:05:15.280><c></span> <span>do</c><00:05:15.400><c></span> <span>some</c><00:05:15.560><c></span> <span>work</c><00:05:15.800><c></span> <span>cuz</c><00:05:15.960><c></span> <span>you</c><00:05:16.039><c></span> <span>can</c><00:05:16.160><c></span> <span>take</c><00:05:16.280><c></span> <span>your</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 220, 316.43, 0.0, 'and do some work cuz you can take your', '', '', '<span>and</span> <span>do</span> <span>some</span> <span>work</span> <span>cuz</span> <span>you</span> <span>can</span> <span>take</span> <span>your</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 221, 316.44, 0.0, 'and do some work cuz you can take your laptop<00:05:16.840><c> out</c><00:05:17.320><c> also</c><00:05:17.560><c> pretty</c><00:05:17.759><c> good</c><00:05:17.919><c> food</c><00:05:18.479><c> took</c>', '', '', '<span>and</span> <span>do</span> <span>some</span> <span>work</span> <span>cuz</span> <span>you</span> <span>can</span> <span>take</span> <span>your</span> <span>laptop<00:05:16.840><c></span> <span>out</c><00:05:17.320><c></span> <span>also</c><00:05:17.560><c></span> <span>pretty</c><00:05:17.759><c></span> <span>good</c><00:05:17.919><c></span> <span>food</c><00:05:18.479><c></span> <span>took</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 222, 318.71, 0.0, 'laptop out also pretty good food took', '', '', '<span>laptop</span> <span>out</span> <span>also</span> <span>pretty</span> <span>good</span> <span>food</span> <span>took</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 223, 318.72, 0.0, 'laptop out also pretty good food took this<00:05:18.840><c> as</c><00:05:19.000><c> a</c><00:05:19.280><c> very</c><00:05:19.520><c> welcome</c><00:05:19.840><c> break</c><00:05:20.039><c> to</c><00:05:20.199><c> cool</c><00:05:20.440><c> off</c>', '', '', '<span>laptop</span> <span>out</span> <span>also</span> <span>pretty</span> <span>good</span> <span>food</span> <span>took</span> <span>this<00:05:18.840><c></span> <span>as</c><00:05:19.000><c></span> <span>a</c><00:05:19.280><c></span> <span>very</c><00:05:19.520><c></span> <span>welcome</c><00:05:19.840><c></span> <span>break</c><00:05:20.039><c></span> <span>to</c><00:05:20.199><c></span> <span>cool</c><00:05:20.440><c></span> <span>off</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 224, 320.71, 0.0, 'this as a very welcome break to cool off', '', '', '<span>this</span> <span>as</span> <span>a</span> <span>very</span> <span>welcome</span> <span>break</span> <span>to</span> <span>cool</span> <span>off</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 225, 320.72, 0.0, 'this as a very welcome break to cool off responded<00:05:21.039><c> to</c><00:05:21.120><c> some</c><00:05:21.240><c> emails</c><00:05:21.600><c> as</c><00:05:21.759><c> it</c><00:05:21.919><c> was</c><00:05:22.080><c> a</c>', '', '', '<span>this</span> <span>as</span> <span>a</span> <span>very</span> <span>welcome</span> <span>break</span> <span>to</span> <span>cool</span> <span>off</span> <span>responded<00:05:21.039><c></span> <span>to</c><00:05:21.120><c></span> <span>some</c><00:05:21.240><c></span> <span>emails</c><00:05:21.600><c></span> <span>as</c><00:05:21.759><c></span> <span>it</c><00:05:21.919><c></span> <span>was</c><00:05:22.080><c></span> <span>a</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 226, 322.23, 0.0, 'responded to some emails as it was a', '', '', '<span>responded</span> <span>to</span> <span>some</span> <span>emails</span> <span>as</span> <span>it</span> <span>was</span> <span>a</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 227, 322.24, 0.0, 'responded to some emails as it was a workday<00:05:22.680><c> after</c><00:05:22.880><c> all</c><00:05:23.160><c> did</c><00:05:23.280><c> some</c><00:05:23.440><c> budgeting</c><00:05:23.880><c> and</c>', '', '', '<span>responded</span> <span>to</span> <span>some</span> <span>emails</span> <span>as</span> <span>it</span> <span>was</span> <span>a</span> <span>workday<00:05:22.680><c></span> <span>after</c><00:05:22.880><c></span> <span>all</c><00:05:23.160><c></span> <span>did</c><00:05:23.280><c></span> <span>some</c><00:05:23.440><c></span> <span>budgeting</c><00:05:23.880><c></span> <span>and</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 228, 323.99, 0.0, 'workday after all did some budgeting and', '', '', '<span>workday</span> <span>after</span> <span>all</span> <span>did</span> <span>some</span> <span>budgeting</span> <span>and</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 229, 324.0, 0.0, 'workday after all did some budgeting and then<00:05:24.120><c> wrote</c><00:05:24.319><c> down</c><00:05:24.440><c> a</c><00:05:24.520><c> few</c><00:05:24.720><c> video</c><00:05:24.960><c> ideas</c><00:05:25.280><c> that</c>', '', '', '<span>workday</span> <span>after</span> <span>all</span> <span>did</span> <span>some</span> <span>budgeting</span> <span>and</span> <span>then<00:05:24.120><c></span> <span>wrote</c><00:05:24.319><c></span> <span>down</c><00:05:24.440><c></span> <span>a</c><00:05:24.520><c></span> <span>few</c><00:05:24.720><c></span> <span>video</c><00:05:24.960><c></span> <span>ideas</c><00:05:25.280><c></span> <span>that</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 230, 325.39, 0.0, 'then wrote down a few video ideas that', '', '', '<span>then</span> <span>wrote</span> <span>down</span> <span>a</span> <span>few</span> <span>video</span> <span>ideas</span> <span>that</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 231, 325.4, 0.0, 'then wrote down a few video ideas that came<00:05:25.560><c> to</c><00:05:25.680><c> mind</c><00:05:25.880><c> during</c><00:05:26.080><c> the</c><00:05:26.240><c> day</c><00:05:26.560><c> which</c>', '', '', '<span>then</span> <span>wrote</span> <span>down</span> <span>a</span> <span>few</span> <span>video</span> <span>ideas</span> <span>that</span> <span>came<00:05:25.560><c></span> <span>to</c><00:05:25.680><c></span> <span>mind</c><00:05:25.880><c></span> <span>during</c><00:05:26.080><c></span> <span>the</c><00:05:26.240><c></span> <span>day</c><00:05:26.560><c></span> <span>which</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 232, 326.909, 0.0, 'came to mind during the day which', '', '', '<span>came</span> <span>to</span> <span>mind</span> <span>during</span> <span>the</span> <span>day</span> <span>which</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 233, 326.919, 0.0, 'came to mind during the day which actually<00:05:27.160><c> included</c><00:05:27.639><c> the</c><00:05:27.800><c> way</c><00:05:28.080><c> that</c><00:05:28.240><c> I</c><00:05:28.319><c> wanted</c>', '', '', '<span>came</span> <span>to</span> <span>mind</span> <span>during</span> <span>the</span> <span>day</span> <span>which</span> <span>actually<00:05:27.160><c></span> <span>included</c><00:05:27.639><c></span> <span>the</c><00:05:27.800><c></span> <span>way</c><00:05:28.080><c></span> <span>that</c><00:05:28.240><c></span> <span>I</c><00:05:28.319><c></span> <span>wanted</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 234, 328.55, 0.0, 'actually included the way that I wanted', '', '', '<span>actually</span> <span>included</span> <span>the</span> <span>way</span> <span>that</span> <span>I</span> <span>wanted</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 235, 328.56, 0.0, 'actually included the way that I wanted to<00:05:28.680><c> finish</c><00:05:29.120><c> this</c><00:05:29.280><c> exact</c><00:05:29.759><c> video</c><00:05:30.160><c> and</c><00:05:30.319><c> I</c><00:05:30.400><c> think</c>', '', '', '<span>actually</span> <span>included</span> <span>the</span> <span>way</span> <span>that</span> <span>I</span> <span>wanted</span> <span>to<00:05:28.680><c></span> <span>finish</c><00:05:29.120><c></span> <span>this</c><00:05:29.280><c></span> <span>exact</c><00:05:29.759><c></span> <span>video</c><00:05:30.160><c></span> <span>and</c><00:05:30.319><c></span> <span>I</c><00:05:30.400><c></span> <span>think</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 236, 330.51, 0.0, 'to finish this exact video and I think', '', '', '<span>to</span> <span>finish</span> <span>this</span> <span>exact</span> <span>video</span> <span>and</span> <span>I</span> <span>think</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 237, 330.52, 0.0, 'to finish this exact video and I think it''s<00:05:30.680><c> pretty</c><00:05:30.880><c> cool</c><00:05:31.120><c> so</c><00:05:31.319><c> stay</c><00:05:31.479><c> tuned</c><00:05:31.720><c> to</c><00:05:31.840><c> the</c>', '', '', '<span>to</span> <span>finish</span> <span>this</span> <span>exact</span> <span>video</span> <span>and</span> <span>I</span> <span>think</span> <span>it''s<00:05:30.680><c></span> <span>pretty</c><00:05:30.880><c></span> <span>cool</c><00:05:31.120><c></span> <span>so</c><00:05:31.319><c></span> <span>stay</c><00:05:31.479><c></span> <span>tuned</c><00:05:31.720><c></span> <span>to</c><00:05:31.840><c></span> <span>the</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 238, 331.95, 0.0, 'it''s pretty cool so stay tuned to the', '', '', '<span>it''s</span> <span>pretty</span> <span>cool</span> <span>so</span> <span>stay</span> <span>tuned</span> <span>to</span> <span>the</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 239, 331.96, 0.0, 'it''s pretty cool so stay tuned to the end<00:05:32.240><c> and</c><00:05:32.440><c> met</c><00:05:32.639><c> a</c><00:05:32.759><c> really</c><00:05:32.960><c> cool</c><00:05:33.160><c> subscriber</c><00:05:34.000><c> I''m</c>', '', '', '<span>it''s</span> <span>pretty</span> <span>cool</span> <span>so</span> <span>stay</span> <span>tuned</span> <span>to</span> <span>the</span> <span>end<00:05:32.240><c></span> <span>and</c><00:05:32.440><c></span> <span>met</c><00:05:32.639><c></span> <span>a</c><00:05:32.759><c></span> <span>really</c><00:05:32.960><c></span> <span>cool</c><00:05:33.160><c></span> <span>subscriber</c><00:05:34.000><c></span> <span>I''m</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 240, 334.15, 0.0, 'end and met a really cool subscriber I''m', '', '', '<span>end</span> <span>and</span> <span>met</span> <span>a</span> <span>really</span> <span>cool</span> <span>subscriber</span> <span>I''m</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 241, 334.16, 0.0, 'end and met a really cool subscriber I''m filming<00:05:34.520><c> now</c><00:05:34.680><c> if</c><00:05:34.759><c> you</c><00:05:34.840><c> want</c><00:05:34.960><c> to</c><00:05:35.039><c> say</c><00:05:35.240><c> hi</c><00:05:35.360><c> in</c><00:05:35.479><c> the</c>', '', '', '<span>end</span> <span>and</span> <span>met</span> <span>a</span> <span>really</span> <span>cool</span> <span>subscriber</span> <span>I''m</span> <span>filming<00:05:34.520><c></span> <span>now</c><00:05:34.680><c></span> <span>if</c><00:05:34.759><c></span> <span>you</c><00:05:34.840><c></span> <span>want</c><00:05:34.960><c></span> <span>to</c><00:05:35.039><c></span> <span>say</c><00:05:35.240><c></span> <span>hi</c><00:05:35.360><c></span> <span>in</c><00:05:35.479><c></span> <span>the</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 242, 335.629, 0.0, 'filming now if you want to say hi in the', '', '', '<span>filming</span> <span>now</span> <span>if</span> <span>you</span> <span>want</span> <span>to</span> <span>say</span> <span>hi</span> <span>in</span> <span>the</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 243, 335.639, 0.0, 'filming now if you want to say hi in the video', '', '', '<span>filming</span> <span>now</span> <span>if</span> <span>you</span> <span>want</span> <span>to</span> <span>say</span> <span>hi</span> <span>in</span> <span>the</span> <span>video</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 244, 342.43, 0.0, 'yeah I''m glad you said', '', '', '<span>yeah</span> <span>I''m</span> <span>glad</span> <span>you</span> <span>said</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 245, 342.44, 0.0, 'yeah I''m glad you said hi<00:05:43.440><c> oh</c><00:05:43.759><c> that</c><00:05:43.840><c> was</c><00:05:44.000><c> really</c><00:05:44.240><c> cute</c><00:05:44.560><c> the</c><00:05:44.720><c> guy</c>', '', '', '<span>yeah</span> <span>I''m</span> <span>glad</span> <span>you</span> <span>said</span> <span>hi<00:05:43.440><c></span> <span>oh</c><00:05:43.759><c></span> <span>that</c><00:05:43.840><c></span> <span>was</c><00:05:44.000><c></span> <span>really</c><00:05:44.240><c></span> <span>cute</c><00:05:44.560><c></span> <span>the</c><00:05:44.720><c></span> <span>guy</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 246, 344.87, 0.0, 'hi oh that was really cute the guy', '', '', '<span>hi</span> <span>oh</span> <span>that</span> <span>was</span> <span>really</span> <span>cute</span> <span>the</span> <span>guy</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 247, 344.88, 0.0, 'hi oh that was really cute the guy sitting<00:05:45.160><c> next</c><00:05:45.360><c> to</c><00:05:45.479><c> me</c><00:05:45.800><c> has</c><00:05:45.960><c> watched</c><00:05:46.199><c> my</c><00:05:46.400><c> videos</c>', '', '', '<span>hi</span> <span>oh</span> <span>that</span> <span>was</span> <span>really</span> <span>cute</span> <span>the</span> <span>guy</span> <span>sitting<00:05:45.160><c></span> <span>next</c><00:05:45.360><c></span> <span>to</c><00:05:45.479><c></span> <span>me</c><00:05:45.800><c></span> <span>has</c><00:05:45.960><c></span> <span>watched</c><00:05:46.199><c></span> <span>my</c><00:05:46.400><c></span> <span>videos</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 248, 346.83, 0.0, 'sitting next to me has watched my videos', '', '', '<span>sitting</span> <span>next</span> <span>to</span> <span>me</span> <span>has</span> <span>watched</span> <span>my</span> <span>videos</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 249, 346.84, 0.0, 'sitting next to me has watched my videos and<00:05:47.160><c> and</c><00:05:47.280><c> stopped</c><00:05:47.560><c> in</c><00:05:47.639><c> there</c><00:05:47.759><c> to</c><00:05:47.880><c> say</c><00:05:48.080><c> hi</c><00:05:48.280><c> had</c><00:05:48.400><c> a</c>', '', '', '<span>sitting</span> <span>next</span> <span>to</span> <span>me</span> <span>has</span> <span>watched</span> <span>my</span> <span>videos</span> <span>and<00:05:47.160><c></span> <span>and</c><00:05:47.280><c></span> <span>stopped</c><00:05:47.560><c></span> <span>in</c><00:05:47.639><c></span> <span>there</c><00:05:47.759><c></span> <span>to</c><00:05:47.880><c></span> <span>say</c><00:05:48.080><c></span> <span>hi</c><00:05:48.280><c></span> <span>had</c><00:05:48.400><c></span> <span>a</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 250, 348.469, 0.0, 'and and stopped in there to say hi had a', '', '', '<span>and</span> <span>and</span> <span>stopped</span> <span>in</span> <span>there</span> <span>to</span> <span>say</span> <span>hi</span> <span>had</span> <span>a</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 251, 348.479, 0.0, 'and and stopped in there to say hi had a nice<00:05:48.680><c> little</c><00:05:48.919><c> conversation</c><00:05:49.680><c> so</c><00:05:49.960><c> I''m</c><00:05:50.160><c> glad</c><00:05:50.479><c> we</c>', '', '', '<span>and</span> <span>and</span> <span>stopped</span> <span>in</span> <span>there</span> <span>to</span> <span>say</span> <span>hi</span> <span>had</span> <span>a</span> <span>nice<00:05:48.680><c></span> <span>little</c><00:05:48.919><c></span> <span>conversation</c><00:05:49.680><c></span> <span>so</c><00:05:49.960><c></span> <span>I''m</c><00:05:50.160><c></span> <span>glad</c><00:05:50.479><c></span> <span>we</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 252, 350.59, 0.0, 'nice little conversation so I''m glad we', '', '', '<span>nice</span> <span>little</span> <span>conversation</span> <span>so</span> <span>I''m</span> <span>glad</span> <span>we</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 253, 350.6, 0.0, 'nice little conversation so I''m glad we ended<00:05:50.919><c> up</c><00:05:51.160><c> there</c><00:05:51.319><c> instead</c><00:05:51.639><c> of</c><00:05:52.160><c> Papa</c><00:05:52.720><c> Bagels</c>', '', '', '<span>nice</span> <span>little</span> <span>conversation</span> <span>so</span> <span>I''m</span> <span>glad</span> <span>we</span> <span>ended<00:05:50.919><c></span> <span>up</c><00:05:51.160><c></span> <span>there</c><00:05:51.319><c></span> <span>instead</c><00:05:51.639><c></span> <span>of</c><00:05:52.160><c></span> <span>Papa</c><00:05:52.720><c></span> <span>Bagels</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 254, 353.71, 0.0, 'ended up there instead of Papa Bagels', '', '', '<span>ended</span> <span>up</span> <span>there</span> <span>instead</span> <span>of</span> <span>Papa</span> <span>Bagels</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 255, 353.72, 0.0, 'ended up there instead of Papa Bagels anyways<00:05:54.160><c> to</c><00:05:54.360><c> our</c><00:05:54.600><c> next</c><00:05:54.880><c> location</c><00:05:55.600><c> it''s</c><00:05:55.720><c> a</c>', '', '', '<span>ended</span> <span>up</span> <span>there</span> <span>instead</span> <span>of</span> <span>Papa</span> <span>Bagels</span> <span>anyways<00:05:54.160><c></span> <span>to</c><00:05:54.360><c></span> <span>our</c><00:05:54.600><c></span> <span>next</c><00:05:54.880><c></span> <span>location</c><00:05:55.600><c></span> <span>it''s</c><00:05:55.720><c></span> <span>a</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 256, 357.99, 0.0, 'anyways to our next location it''s a', '', '', '<span>anyways</span> <span>to</span> <span>our</span> <span>next</span> <span>location</span> <span>it''s</span> <span>a</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 257, 358.0, 0.0, 'anyways to our next location it''s a [Music]', '', '', '<span>anyways</span> <span>to</span> <span>our</span> <span>next</span> <span>location</span> <span>it''s</span> <span>a</span> <span>[Music]</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 258, 364.99, 0.0, '[Music]', '', '', '<span>[Music]</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 259, 365.0, 0.0, '[Music] all<00:06:05.080><c> right</c><00:06:05.240><c> y''all</c><00:06:05.479><c> here</c><00:06:05.600><c> we</c><00:06:05.840><c> are</c><00:06:06.199><c> in</c><00:06:06.599><c> SoHo</c>', '', '', '<span>[Music]</span> <span>all<00:06:05.080><c></span> <span>right</c><00:06:05.240><c></span> <span>y''all</c><00:06:05.479><c></span> <span>here</c><00:06:05.600><c></span> <span>we</c><00:06:05.840><c></span> <span>are</c><00:06:06.199><c></span> <span>in</c><00:06:06.599><c></span> <span>SoHo</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 260, 367.23, 0.0, 'all right y''all here we are in SoHo', '', '', '<span>all</span> <span>right</span> <span>y''all</span> <span>here</span> <span>we</span> <span>are</span> <span>in</span> <span>SoHo</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 261, 367.24, 0.0, 'all right y''all here we are in SoHo which<00:06:07.360><c> means</c><00:06:07.840><c> south</c><00:06:08.080><c> of</c><00:06:08.240><c> hon</c><00:06:08.960><c> hon</c><00:06:09.400><c> is</c>', '', '', '<span>all</span> <span>right</span> <span>y''all</span> <span>here</span> <span>we</span> <span>are</span> <span>in</span> <span>SoHo</span> <span>which<00:06:07.360><c></span> <span>means</c><00:06:07.840><c></span> <span>south</c><00:06:08.080><c></span> <span>of</c><00:06:08.240><c></span> <span>hon</c><00:06:08.960><c></span> <span>hon</c><00:06:09.400><c></span> <span>is</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 262, 369.55, 0.0, 'which means south of hon hon is', '', '', '<span>which</span> <span>means</span> <span>south</span> <span>of</span> <span>hon</span> <span>hon</span> <span>is</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 263, 369.56, 0.0, 'which means south of hon hon is literally<00:06:09.919><c> right</c><00:06:10.039><c> there</c><00:06:10.199><c> and</c><00:06:10.360><c> we''re</c><00:06:10.599><c> south</c><00:06:10.759><c> of</c>', '', '', '<span>which</span> <span>means</span> <span>south</span> <span>of</span> <span>hon</span> <span>hon</span> <span>is</span> <span>literally<00:06:09.919><c></span> <span>right</c><00:06:10.039><c></span> <span>there</c><00:06:10.199><c></span> <span>and</c><00:06:10.360><c></span> <span>we''re</c><00:06:10.599><c></span> <span>south</c><00:06:10.759><c></span> <span>of</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 264, 370.87, 0.0, 'literally right there and we''re south of', '', '', '<span>literally</span> <span>right</span> <span>there</span> <span>and</span> <span>we''re</span> <span>south</span> <span>of</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 265, 370.88, 0.0, 'literally right there and we''re south of it<00:06:11.199><c> I</c><00:06:11.440><c> find</c><00:06:11.840><c> this</c><00:06:12.000><c> style</c><00:06:12.240><c> of</c><00:06:12.400><c> architecture</c><00:06:12.960><c> in</c>', '', '', '<span>literally</span> <span>right</span> <span>there</span> <span>and</span> <span>we''re</span> <span>south</span> <span>of</span> <span>it<00:06:11.199><c></span> <span>I</c><00:06:11.440><c></span> <span>find</c><00:06:11.840><c></span> <span>this</c><00:06:12.000><c></span> <span>style</c><00:06:12.240><c></span> <span>of</c><00:06:12.400><c></span> <span>architecture</c><00:06:12.960><c></span> <span>in</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 266, 373.07, 0.0, 'it I find this style of architecture in', '', '', '<span>it</span> <span>I</span> <span>find</span> <span>this</span> <span>style</span> <span>of</span> <span>architecture</span> <span>in</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 267, 373.08, 0.0, 'it I find this style of architecture in New<00:06:13.240><c> York</c><00:06:13.520><c> to</c><00:06:13.680><c> be</c><00:06:14.360><c> particularly</c><00:06:15.039><c> beautiful</c>', '', '', '<span>it</span> <span>I</span> <span>find</span> <span>this</span> <span>style</span> <span>of</span> <span>architecture</span> <span>in</span> <span>New<00:06:13.240><c></span> <span>York</c><00:06:13.520><c></span> <span>to</c><00:06:13.680><c></span> <span>be</c><00:06:14.360><c></span> <span>particularly</c><00:06:15.039><c></span> <span>beautiful</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 268, 375.51, 0.0, 'New York to be particularly beautiful', '', '', '<span>New</span> <span>York</span> <span>to</span> <span>be</span> <span>particularly</span> <span>beautiful</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 269, 375.52, 0.0, 'New York to be particularly beautiful the<00:06:15.680><c> crown</c><00:06:16.000><c> molding</c><00:06:16.880><c> the</c><00:06:17.080><c> high</c><00:06:17.240><c> ceilings</c><00:06:18.080><c> I</c>', '', '', '<span>New</span> <span>York</span> <span>to</span> <span>be</span> <span>particularly</span> <span>beautiful</span> <span>the<00:06:15.680><c></span> <span>crown</c><00:06:16.000><c></span> <span>molding</c><00:06:16.880><c></span> <span>the</c><00:06:17.080><c></span> <span>high</c><00:06:17.240><c></span> <span>ceilings</c><00:06:18.080><c></span> <span>I</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 270, 378.15, 0.0, 'the crown molding the high ceilings I', '', '', '<span>the</span> <span>crown</span> <span>molding</span> <span>the</span> <span>high</span> <span>ceilings</span> <span>I</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 271, 378.16, 0.0, 'the crown molding the high ceilings I can<00:06:18.280><c> only</c><00:06:18.479><c> imagine</c><00:06:18.759><c> how</c><00:06:18.880><c> much</c><00:06:19.039><c> natural</c><00:06:19.360><c> light</c>', '', '', '<span>the</span> <span>crown</span> <span>molding</span> <span>the</span> <span>high</span> <span>ceilings</span> <span>I</span> <span>can<00:06:18.280><c></span> <span>only</c><00:06:18.479><c></span> <span>imagine</c><00:06:18.759><c></span> <span>how</c><00:06:18.880><c></span> <span>much</c><00:06:19.039><c></span> <span>natural</c><00:06:19.360><c></span> <span>light</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 272, 379.55, 0.0, 'can only imagine how much natural light', '', '', '<span>can</span> <span>only</span> <span>imagine</span> <span>how</span> <span>much</span> <span>natural</span> <span>light</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 273, 379.56, 0.0, 'can only imagine how much natural light comes<00:06:19.720><c> in</c><00:06:19.840><c> those</c><00:06:20.000><c> puppies</c><00:06:20.599><c> and</c><00:06:20.919><c> it</c><00:06:21.080><c> is</c><00:06:21.360><c> usually</c>', '', '', '<span>can</span> <span>only</span> <span>imagine</span> <span>how</span> <span>much</span> <span>natural</span> <span>light</span> <span>comes<00:06:19.720><c></span> <span>in</c><00:06:19.840><c></span> <span>those</c><00:06:20.000><c></span> <span>puppies</c><00:06:20.599><c></span> <span>and</c><00:06:20.919><c></span> <span>it</c><00:06:21.080><c></span> <span>is</c><00:06:21.360><c></span> <span>usually</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 274, 381.629, 0.0, 'comes in those puppies and it is usually', '', '', '<span>comes</span> <span>in</span> <span>those</span> <span>puppies</span> <span>and</span> <span>it</span> <span>is</span> <span>usually</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 275, 381.639, 0.0, 'comes in those puppies and it is usually flooded<00:06:22.160><c> with</c><00:06:22.319><c> tourists</c><00:06:22.759><c> there''s</c><00:06:22.919><c> a</c><00:06:23.039><c> lot</c><00:06:23.160><c> of</c>', '', '', '<span>comes</span> <span>in</span> <span>those</span> <span>puppies</span> <span>and</span> <span>it</span> <span>is</span> <span>usually</span> <span>flooded<00:06:22.160><c></span> <span>with</c><00:06:22.319><c></span> <span>tourists</c><00:06:22.759><c></span> <span>there''s</c><00:06:22.919><c></span> <span>a</c><00:06:23.039><c></span> <span>lot</c><00:06:23.160><c></span> <span>of</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 276, 383.309, 0.0, 'flooded with tourists there''s a lot of', '', '', '<span>flooded</span> <span>with</span> <span>tourists</span> <span>there''s</span> <span>a</span> <span>lot</span> <span>of</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 277, 383.319, 0.0, 'flooded with tourists there''s a lot of it''s<00:06:23.440><c> like</c><00:06:23.599><c> the</c><00:06:23.680><c> biggest</c><00:06:24.000><c> shopping</c><00:06:24.400><c> area</c><00:06:24.800><c> in</c>', '', '', '<span>flooded</span> <span>with</span> <span>tourists</span> <span>there''s</span> <span>a</span> <span>lot</span> <span>of</span> <span>it''s<00:06:23.440><c></span> <span>like</c><00:06:23.599><c></span> <span>the</c><00:06:23.680><c></span> <span>biggest</c><00:06:24.000><c></span> <span>shopping</c><00:06:24.400><c></span> <span>area</c><00:06:24.800><c></span> <span>in</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 278, 384.99, 0.0, 'it''s like the biggest shopping area in', '', '', '<span>it''s</span> <span>like</span> <span>the</span> <span>biggest</span> <span>shopping</span> <span>area</span> <span>in</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 279, 385.0, 0.0, 'it''s like the biggest shopping area in Manhattan<00:06:25.560><c> but</c><00:06:25.680><c> there</c><00:06:25.800><c> are</c><00:06:26.000><c> some</c><00:06:26.199><c> side</c>', '', '', '<span>it''s</span> <span>like</span> <span>the</span> <span>biggest</span> <span>shopping</span> <span>area</span> <span>in</span> <span>Manhattan<00:06:25.560><c></span> <span>but</c><00:06:25.680><c></span> <span>there</c><00:06:25.800><c></span> <span>are</c><00:06:26.000><c></span> <span>some</c><00:06:26.199><c></span> <span>side</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 280, 386.39, 0.0, 'Manhattan but there are some side', '', '', '<span>Manhattan</span> <span>but</span> <span>there</span> <span>are</span> <span>some</span> <span>side</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 281, 386.4, 0.0, 'Manhattan but there are some side streets<00:06:26.759><c> that</c><00:06:26.840><c> are</c><00:06:27.000><c> a</c><00:06:27.120><c> little</c><00:06:27.479><c> lesser</c><00:06:27.800><c> known</c>', '', '', '<span>Manhattan</span> <span>but</span> <span>there</span> <span>are</span> <span>some</span> <span>side</span> <span>streets<00:06:26.759><c></span> <span>that</c><00:06:26.840><c></span> <span>are</c><00:06:27.000><c></span> <span>a</c><00:06:27.120><c></span> <span>little</c><00:06:27.479><c></span> <span>lesser</c><00:06:27.800><c></span> <span>known</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 282, 388.71, 0.0, 'streets that are a little lesser known', '', '', '<span>streets</span> <span>that</span> <span>are</span> <span>a</span> <span>little</span> <span>lesser</span> <span>known</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 283, 388.72, 0.0, 'streets that are a little lesser known either<00:06:28.960><c> way</c><00:06:29.160><c> there''s</c><00:06:29.319><c> a</c><00:06:29.599><c> lot</c><00:06:29.720><c> of</c><00:06:29.800><c> people</c><00:06:30.000><c> like</c>', '', '', '<span>streets</span> <span>that</span> <span>are</span> <span>a</span> <span>little</span> <span>lesser</span> <span>known</span> <span>either<00:06:28.960><c></span> <span>way</c><00:06:29.160><c></span> <span>there''s</c><00:06:29.319><c></span> <span>a</c><00:06:29.599><c></span> <span>lot</c><00:06:29.720><c></span> <span>of</c><00:06:29.800><c></span> <span>people</c><00:06:30.000><c></span> <span>like</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 284, 390.15, 0.0, 'either way there''s a lot of people like', '', '', '<span>either</span> <span>way</span> <span>there''s</span> <span>a</span> <span>lot</span> <span>of</span> <span>people</span> <span>like</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 285, 390.16, 0.0, 'either way there''s a lot of people like me<00:06:30.520><c> either</c><00:06:30.759><c> out</c><00:06:30.919><c> here</c><00:06:31.080><c> videoing</c><00:06:31.479><c> or</c><00:06:31.639><c> taking</c><00:06:31.840><c> a</c>', '', '', '<span>either</span> <span>way</span> <span>there''s</span> <span>a</span> <span>lot</span> <span>of</span> <span>people</span> <span>like</span> <span>me<00:06:30.520><c></span> <span>either</c><00:06:30.759><c></span> <span>out</c><00:06:30.919><c></span> <span>here</c><00:06:31.080><c></span> <span>videoing</c><00:06:31.479><c></span> <span>or</c><00:06:31.639><c></span> <span>taking</c><00:06:31.840><c></span> <span>a</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 286, 391.909, 0.0, 'me either out here videoing or taking a', '', '', '<span>me</span> <span>either</span> <span>out</span> <span>here</span> <span>videoing</span> <span>or</span> <span>taking</span> <span>a</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 287, 391.919, 0.0, 'me either out here videoing or taking a lot<00:06:32.039><c> of</c><00:06:32.160><c> pictures</c><00:06:32.639><c> a</c><00:06:32.759><c> little</c><00:06:32.919><c> bit</c><00:06:33.039><c> of</c><00:06:33.199><c> History</c>', '', '', '<span>me</span> <span>either</span> <span>out</span> <span>here</span> <span>videoing</span> <span>or</span> <span>taking</span> <span>a</span> <span>lot<00:06:32.039><c></span> <span>of</c><00:06:32.160><c></span> <span>pictures</c><00:06:32.639><c></span> <span>a</c><00:06:32.759><c></span> <span>little</c><00:06:32.919><c></span> <span>bit</c><00:06:33.039><c></span> <span>of</c><00:06:33.199><c></span> <span>History</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 288, 393.589, 0.0, 'lot of pictures a little bit of History', '', '', '<span>lot</span> <span>of</span> <span>pictures</span> <span>a</span> <span>little</span> <span>bit</span> <span>of</span> <span>History</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 289, 393.599, 0.0, 'lot of pictures a little bit of History though<00:06:33.960><c> these</c><00:06:34.160><c> spaces</c><00:06:34.639><c> attracted</c><00:06:35.160><c> a</c><00:06:35.280><c> ton</c><00:06:35.479><c> of</c>', '', '', '<span>lot</span> <span>of</span> <span>pictures</span> <span>a</span> <span>little</span> <span>bit</span> <span>of</span> <span>History</span> <span>though<00:06:33.960><c></span> <span>these</c><00:06:34.160><c></span> <span>spaces</c><00:06:34.639><c></span> <span>attracted</c><00:06:35.160><c></span> <span>a</c><00:06:35.280><c></span> <span>ton</c><00:06:35.479><c></span> <span>of</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 290, 395.629, 0.0, 'though these spaces attracted a ton of', '', '', '<span>though</span> <span>these</span> <span>spaces</span> <span>attracted</span> <span>a</span> <span>ton</span> <span>of</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 291, 395.639, 0.0, 'though these spaces attracted a ton of artists<00:06:36.039><c> in</c><00:06:36.160><c> the</c><00:06:36.280><c> 1960s</c><00:06:37.080><c> and70s</c><00:06:37.560><c> because</c><00:06:38.039><c> of</c>', '', '', '<span>though</span> <span>these</span> <span>spaces</span> <span>attracted</span> <span>a</span> <span>ton</span> <span>of</span> <span>artists<00:06:36.039><c></span> <span>in</c><00:06:36.160><c></span> <span>the</c><00:06:36.280><c></span> <span>1960s</c><00:06:37.080><c></span> <span>and70s</c><00:06:37.560><c></span> <span>because</c><00:06:38.039><c></span> <span>of</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 292, 398.189, 0.0, 'artists in the 1960s and70s because of', '', '', '<span>artists</span> <span>in</span> <span>the</span> <span>1960s</span> <span>and70s</span> <span>because</span> <span>of</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 293, 398.199, 0.0, 'artists in the 1960s and70s because of the<00:06:38.319><c> high</c><00:06:38.520><c> ceilings</c><00:06:39.080><c> the</c><00:06:39.199><c> natural</c><00:06:39.560><c> light</c><00:06:39.800><c> that</c>', '', '', '<span>artists</span> <span>in</span> <span>the</span> <span>1960s</span> <span>and70s</span> <span>because</span> <span>of</span> <span>the<00:06:38.319><c></span> <span>high</c><00:06:38.520><c></span> <span>ceilings</c><00:06:39.080><c></span> <span>the</c><00:06:39.199><c></span> <span>natural</c><00:06:39.560><c></span> <span>light</c><00:06:39.800><c></span> <span>that</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 294, 399.95, 0.0, 'the high ceilings the natural light that', '', '', '<span>the</span> <span>high</span> <span>ceilings</span> <span>the</span> <span>natural</span> <span>light</span> <span>that</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 295, 399.96, 0.0, 'the high ceilings the natural light that came<00:06:40.120><c> in</c><00:06:40.720><c> and</c><00:06:40.960><c> at</c><00:06:41.080><c> the</c><00:06:41.280><c> time</c><00:06:41.639><c> cheap</c><00:06:41.960><c> rent</c>', '', '', '<span>the</span> <span>high</span> <span>ceilings</span> <span>the</span> <span>natural</span> <span>light</span> <span>that</span> <span>came<00:06:40.120><c></span> <span>in</c><00:06:40.720><c></span> <span>and</c><00:06:40.960><c></span> <span>at</c><00:06:41.080><c></span> <span>the</c><00:06:41.280><c></span> <span>time</c><00:06:41.639><c></span> <span>cheap</c><00:06:41.960><c></span> <span>rent</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 296, 402.309, 0.0, 'came in and at the time cheap rent', '', '', '<span>came</span> <span>in</span> <span>and</span> <span>at</span> <span>the</span> <span>time</span> <span>cheap</span> <span>rent</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 297, 402.319, 0.0, 'came in and at the time cheap rent because<00:06:42.560><c> they</c><00:06:42.639><c> were</c><00:06:42.840><c> actually</c><00:06:43.120><c> abandoned</c>', '', '', '<span>came</span> <span>in</span> <span>and</span> <span>at</span> <span>the</span> <span>time</span> <span>cheap</span> <span>rent</span> <span>because<00:06:42.560><c></span> <span>they</c><00:06:42.639><c></span> <span>were</c><00:06:42.840><c></span> <span>actually</c><00:06:43.120><c></span> <span>abandoned</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 298, 403.589, 0.0, 'because they were actually abandoned', '', '', '<span>because</span> <span>they</span> <span>were</span> <span>actually</span> <span>abandoned</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 299, 403.599, 0.0, 'because they were actually abandoned manufacturing<00:06:44.199><c> plants</c><00:06:44.800><c> so</c><00:06:45.039><c> pretty</c><00:06:45.280><c> cool</c><00:06:45.759><c> this</c>', '', '', '<span>because</span> <span>they</span> <span>were</span> <span>actually</span> <span>abandoned</span> <span>manufacturing<00:06:44.199><c></span> <span>plants</c><00:06:44.800><c></span> <span>so</c><00:06:45.039><c></span> <span>pretty</c><00:06:45.280><c></span> <span>cool</c><00:06:45.759><c></span> <span>this</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 300, 405.87, 0.0, 'manufacturing plants so pretty cool this', '', '', '<span>manufacturing</span> <span>plants</span> <span>so</span> <span>pretty</span> <span>cool</span> <span>this</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 301, 405.88, 0.0, 'manufacturing plants so pretty cool this was<00:06:46.120><c> like</c><00:06:46.440><c> the</c><00:06:46.639><c> space</c><00:06:46.880><c> for</c><00:06:47.080><c> artists</c><00:06:47.880><c> if</c><00:06:48.000><c> you</c>', '', '', '<span>manufacturing</span> <span>plants</span> <span>so</span> <span>pretty</span> <span>cool</span> <span>this</span> <span>was<00:06:46.120><c></span> <span>like</c><00:06:46.440><c></span> <span>the</c><00:06:46.639><c></span> <span>space</c><00:06:46.880><c></span> <span>for</c><00:06:47.080><c></span> <span>artists</c><00:06:47.880><c></span> <span>if</c><00:06:48.000><c></span> <span>you</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 302, 408.11, 0.0, 'was like the space for artists if you', '', '', '<span>was</span> <span>like</span> <span>the</span> <span>space</span> <span>for</span> <span>artists</span> <span>if</span> <span>you</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 303, 408.12, 0.0, 'was like the space for artists if you guys<00:06:48.240><c> are</c><00:06:48.400><c> into</c><00:06:49.240><c> if</c><00:06:49.319><c> you''re</c><00:06:49.440><c> into</c><00:06:49.639><c> film</c><00:06:49.919><c> at</c><00:06:50.080><c> all</c>', '', '', '<span>was</span> <span>like</span> <span>the</span> <span>space</span> <span>for</span> <span>artists</span> <span>if</span> <span>you</span> <span>guys<00:06:48.240><c></span> <span>are</c><00:06:48.400><c></span> <span>into</c><00:06:49.240><c></span> <span>if</c><00:06:49.319><c></span> <span>you''re</c><00:06:49.440><c></span> <span>into</c><00:06:49.639><c></span> <span>film</c><00:06:49.919><c></span> <span>at</c><00:06:50.080><c></span> <span>all</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 304, 410.27, 0.0, 'guys are into if you''re into film at all', '', '', '<span>guys</span> <span>are</span> <span>into</span> <span>if</span> <span>you''re</span> <span>into</span> <span>film</span> <span>at</span> <span>all</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 305, 410.28, 0.0, 'guys are into if you''re into film at all no<00:06:50.440><c> but</c><00:06:50.560><c> I</c><00:06:50.639><c> recently</c><00:06:50.960><c> watched</c><00:06:51.199><c> one</c><00:06:51.280><c> of</c><00:06:51.360><c> scors</c>', '', '', '<span>guys</span> <span>are</span> <span>into</span> <span>if</span> <span>you''re</span> <span>into</span> <span>film</span> <span>at</span> <span>all</span> <span>no<00:06:50.440><c></span> <span>but</c><00:06:50.560><c></span> <span>I</c><00:06:50.639><c></span> <span>recently</c><00:06:50.960><c></span> <span>watched</c><00:06:51.199><c></span> <span>one</c><00:06:51.280><c></span> <span>of</c><00:06:51.360><c></span> <span>scors</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 306, 411.629, 0.0, 'no but I recently watched one of scors', '', '', '<span>no</span> <span>but</span> <span>I</span> <span>recently</span> <span>watched</span> <span>one</span> <span>of</span> <span>scors</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 307, 411.639, 0.0, 'no but I recently watched one of scors Daisy''s<00:06:52.039><c> old</c><00:06:52.440><c> movies</c><00:06:52.960><c> called</c><00:06:53.360><c> after</c><00:06:53.720><c> hours</c><00:06:54.280><c> if</c>', '', '', '<span>no</span> <span>but</span> <span>I</span> <span>recently</span> <span>watched</span> <span>one</span> <span>of</span> <span>scors</span> <span>Daisy''s<00:06:52.039><c></span> <span>old</c><00:06:52.440><c></span> <span>movies</c><00:06:52.960><c></span> <span>called</c><00:06:53.360><c></span> <span>after</c><00:06:53.720><c></span> <span>hours</c><00:06:54.280><c></span> <span>if</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 308, 414.39, 0.0, 'Daisy''s old movies called after hours if', '', '', '<span>Daisy''s</span> <span>old</span> <span>movies</span> <span>called</span> <span>after</span> <span>hours</span> <span>if</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 309, 414.4, 0.0, 'Daisy''s old movies called after hours if you<00:06:54.520><c> guys</c><00:06:54.639><c> have</c><00:06:54.759><c> seen</c><00:06:55.000><c> that</c><00:06:55.160><c> it''s</c><00:06:55.360><c> like</c><00:06:55.520><c> New</c>', '', '', '<span>Daisy''s</span> <span>old</span> <span>movies</span> <span>called</span> <span>after</span> <span>hours</span> <span>if</span> <span>you<00:06:54.520><c></span> <span>guys</c><00:06:54.639><c></span> <span>have</c><00:06:54.759><c></span> <span>seen</c><00:06:55.000><c></span> <span>that</c><00:06:55.160><c></span> <span>it''s</c><00:06:55.360><c></span> <span>like</c><00:06:55.520><c></span> <span>New</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 310, 415.67, 0.0, 'you guys have seen that it''s like New', '', '', '<span>you</span> <span>guys</span> <span>have</span> <span>seen</span> <span>that</span> <span>it''s</span> <span>like</span> <span>New</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 311, 415.68, 0.0, 'you guys have seen that it''s like New York<00:06:55.879><c> porn</c><00:06:56.599><c> and</c><00:06:56.680><c> it</c><00:06:56.800><c> takes</c><00:06:57.160><c> place</c><00:06:57.520><c> in</c><00:06:57.759><c> SoHo</c>', '', '', '<span>you</span> <span>guys</span> <span>have</span> <span>seen</span> <span>that</span> <span>it''s</span> <span>like</span> <span>New</span> <span>York<00:06:55.879><c></span> <span>porn</c><00:06:56.599><c></span> <span>and</c><00:06:56.680><c></span> <span>it</c><00:06:56.800><c></span> <span>takes</c><00:06:57.160><c></span> <span>place</c><00:06:57.520><c></span> <span>in</c><00:06:57.759><c></span> <span>SoHo</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 312, 418.309, 0.0, 'York porn and it takes place in SoHo', '', '', '<span>York</span> <span>porn</span> <span>and</span> <span>it</span> <span>takes</span> <span>place</span> <span>in</span> <span>SoHo</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 313, 418.319, 0.0, 'York porn and it takes place in SoHo like<00:06:58.479><c> around</c><00:06:58.759><c> that</c><00:06:58.919><c> time</c><00:06:59.080><c> so</c><00:06:59.240><c> anyway</c><00:06:59.840><c> would</c>', '', '', '<span>York</span> <span>porn</span> <span>and</span> <span>it</span> <span>takes</span> <span>place</span> <span>in</span> <span>SoHo</span> <span>like<00:06:58.479><c></span> <span>around</c><00:06:58.759><c></span> <span>that</c><00:06:58.919><c></span> <span>time</c><00:06:59.080><c></span> <span>so</c><00:06:59.240><c></span> <span>anyway</c><00:06:59.840><c></span> <span>would</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 314, 419.95, 0.0, 'like around that time so anyway would', '', '', '<span>like</span> <span>around</span> <span>that</span> <span>time</span> <span>so</span> <span>anyway</span> <span>would</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 315, 419.96, 0.0, 'like around that time so anyway would highly<00:07:00.160><c> recommend</c><00:07:00.520><c> that</c><00:07:00.599><c> movie</c><00:07:00.919><c> some</c><00:07:01.160><c> really</c>', '', '', '<span>like</span> <span>around</span> <span>that</span> <span>time</span> <span>so</span> <span>anyway</span> <span>would</span> <span>highly<00:07:00.160><c></span> <span>recommend</c><00:07:00.520><c></span> <span>that</c><00:07:00.599><c></span> <span>movie</c><00:07:00.919><c></span> <span>some</c><00:07:01.160><c></span> <span>really</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 316, 421.35, 0.0, 'highly recommend that movie some really', '', '', '<span>highly</span> <span>recommend</span> <span>that</span> <span>movie</span> <span>some</span> <span>really</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 317, 421.36, 0.0, 'highly recommend that movie some really really<00:07:01.520><c> cool</c><00:07:01.680><c> shots</c><00:07:01.960><c> in</c><00:07:02.080><c> it</c><00:07:02.240><c> and</c><00:07:02.360><c> just</c><00:07:02.520><c> like</c>', '', '', '<span>highly</span> <span>recommend</span> <span>that</span> <span>movie</span> <span>some</span> <span>really</span> <span>really<00:07:01.520><c></span> <span>cool</c><00:07:01.680><c></span> <span>shots</c><00:07:01.960><c></span> <span>in</c><00:07:02.080><c></span> <span>it</c><00:07:02.240><c></span> <span>and</c><00:07:02.360><c></span> <span>just</c><00:07:02.520><c></span> <span>like</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 318, 422.67, 0.0, 'really cool shots in it and just like', '', '', '<span>really</span> <span>cool</span> <span>shots</span> <span>in</span> <span>it</span> <span>and</span> <span>just</span> <span>like</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 319, 422.68, 0.0, 'really cool shots in it and just like New<00:07:02.800><c> York</c><00:07:03.039><c> Nostalgia</c><00:07:03.599><c> anyways</c><00:07:03.879><c> let</c><00:07:03.960><c> me</c><00:07:04.039><c> show</c>', '', '', '<span>really</span> <span>cool</span> <span>shots</span> <span>in</span> <span>it</span> <span>and</span> <span>just</span> <span>like</span> <span>New<00:07:02.800><c></span> <span>York</c><00:07:03.039><c></span> <span>Nostalgia</c><00:07:03.599><c></span> <span>anyways</c><00:07:03.879><c></span> <span>let</c><00:07:03.960><c></span> <span>me</c><00:07:04.039><c></span> <span>show</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 320, 424.15, 0.0, 'New York Nostalgia anyways let me show', '', '', '<span>New</span> <span>York</span> <span>Nostalgia</span> <span>anyways</span> <span>let</span> <span>me</span> <span>show</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 321, 424.16, 0.0, 'New York Nostalgia anyways let me show you<00:07:04.280><c> more</c><00:07:04.400><c> of</c>', '', '', '<span>New</span> <span>York</span> <span>Nostalgia</span> <span>anyways</span> <span>let</span> <span>me</span> <span>show</span> <span>you<00:07:04.280><c></span> <span>more</c><00:07:04.400><c></span> <span>of</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 322, 426.03, 0.0, 'you more of', '', '', '<span>you</span> <span>more</span> <span>of</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 323, 426.04, 0.0, 'you more of [Music]', '', '', '<span>you</span> <span>more</span> <span>of</span> <span>[Music]</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 324, 436.35, 0.0, 'Soho I''ll see you guys probably can''t', '', '', '<span>Soho</span> <span>I''ll</span> <span>see</span> <span>you</span> <span>guys</span> <span>probably</span> <span>can''t</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 325, 436.36, 0.0, 'Soho I''ll see you guys probably can''t tell<00:07:16.720><c> cuz</c><00:07:16.879><c> it</c><00:07:17.000><c> looks</c><00:07:17.199><c> like</c><00:07:17.440><c> just</c><00:07:17.599><c> a</c><00:07:17.800><c> nice</c>', '', '', '<span>Soho</span> <span>I''ll</span> <span>see</span> <span>you</span> <span>guys</span> <span>probably</span> <span>can''t</span> <span>tell<00:07:16.720><c></span> <span>cuz</c><00:07:16.879><c></span> <span>it</c><00:07:17.000><c></span> <span>looks</c><00:07:17.199><c></span> <span>like</c><00:07:17.440><c></span> <span>just</c><00:07:17.599><c></span> <span>a</c><00:07:17.800><c></span> <span>nice</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 326, 438.27, 0.0, 'tell cuz it looks like just a nice', '', '', '<span>tell</span> <span>cuz</span> <span>it</span> <span>looks</span> <span>like</span> <span>just</span> <span>a</span> <span>nice</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 327, 438.28, 0.0, 'tell cuz it looks like just a nice regular<00:07:19.280><c> mild</c><00:07:19.759><c> day</c><00:07:19.960><c> doesn''t</c><00:07:20.160><c> it</c><00:07:20.360><c> here''s</c><00:07:20.560><c> my</c>', '', '', '<span>tell</span> <span>cuz</span> <span>it</span> <span>looks</span> <span>like</span> <span>just</span> <span>a</span> <span>nice</span> <span>regular<00:07:19.280><c></span> <span>mild</c><00:07:19.759><c></span> <span>day</c><00:07:19.960><c></span> <span>doesn''t</c><00:07:20.160><c></span> <span>it</c><00:07:20.360><c></span> <span>here''s</c><00:07:20.560><c></span> <span>my</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 328, 440.71, 0.0, 'regular mild day doesn''t it here''s my', '', '', '<span>regular</span> <span>mild</span> <span>day</span> <span>doesn''t</span> <span>it</span> <span>here''s</span> <span>my</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 329, 440.72, 0.0, 'regular mild day doesn''t it here''s my hand<00:07:21.160><c> going</c><00:07:22.160><c> down</c><00:07:22.400><c> my</c>', '', '', '<span>regular</span> <span>mild</span> <span>day</span> <span>doesn''t</span> <span>it</span> <span>here''s</span> <span>my</span> <span>hand<00:07:21.160><c></span> <span>going</c><00:07:22.160><c></span> <span>down</c><00:07:22.400><c></span> <span>my</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 330, 443.83, 0.0, 'hand going down my', '', '', '<span>hand</span> <span>going</span> <span>down</span> <span>my</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 331, 443.84, 0.0, 'hand going down my back<00:07:24.840><c> ew</c><00:07:25.199><c> sorry</c><00:07:26.039><c> not</c><00:07:26.240><c> sorry</c><00:07:26.479><c> I''m</c><00:07:26.560><c> going</c><00:07:26.680><c> to</c>', '', '', '<span>hand</span> <span>going</span> <span>down</span> <span>my</span> <span>back<00:07:24.840><c></span> <span>ew</c><00:07:25.199><c></span> <span>sorry</c><00:07:26.039><c></span> <span>not</c><00:07:26.240><c></span> <span>sorry</c><00:07:26.479><c></span> <span>I''m</c><00:07:26.560><c></span> <span>going</c><00:07:26.680><c></span> <span>to</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 332, 446.749, 0.0, 'back ew sorry not sorry I''m going to', '', '', '<span>back</span> <span>ew</span> <span>sorry</span> <span>not</span> <span>sorry</span> <span>I''m</span> <span>going</span> <span>to</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 333, 446.759, 0.0, 'back ew sorry not sorry I''m going to leave<00:07:26.919><c> that</c><00:07:27.080><c> in</c>', '', '', '<span>back</span> <span>ew</span> <span>sorry</span> <span>not</span> <span>sorry</span> <span>I''m</span> <span>going</span> <span>to</span> <span>leave<00:07:26.919><c></span> <span>that</c><00:07:27.080><c></span> <span>in</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 334, 448.46, 0.0, 'leave that in', '', '', '<span>leave</span> <span>that</span> <span>in</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 335, 448.47, 0.0, 'leave that in [Music]', '', '', '<span>leave</span> <span>that</span> <span>in</span> <span>[Music]</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 336, 454.79, 0.0, '[Music]', '', '', '<span>[Music]</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 337, 454.8, 0.0, '[Music] I<00:07:34.960><c> bet</c><00:07:35.080><c> you''d</c><00:07:35.400><c> never</c><00:07:35.680><c> guess</c><00:07:35.879><c> what</c><00:07:36.000><c> I''m</c><00:07:36.120><c> trying</c>', '', '', '<span>[Music]</span> <span>I<00:07:34.960><c></span> <span>bet</c><00:07:35.080><c></span> <span>you''d</c><00:07:35.400><c></span> <span>never</c><00:07:35.680><c></span> <span>guess</c><00:07:35.879><c></span> <span>what</c><00:07:36.000><c></span> <span>I''m</c><00:07:36.120><c></span> <span>trying</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 338, 456.39, 0.0, 'I bet you''d never guess what I''m trying', '', '', '<span>I</span> <span>bet</span> <span>you''d</span> <span>never</span> <span>guess</span> <span>what</span> <span>I''m</span> <span>trying</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 339, 456.4, 0.0, 'I bet you''d never guess what I''m trying on<00:07:36.639><c> right</c>', '', '', '<span>I</span> <span>bet</span> <span>you''d</span> <span>never</span> <span>guess</span> <span>what</span> <span>I''m</span> <span>trying</span> <span>on<00:07:36.639><c></span> <span>right</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 340, 471.07, 0.0, 'T-shirt this is so', '', '', '<span>T-shirt</span> <span>this</span> <span>is</span> <span>so</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 341, 471.08, 0.0, 'T-shirt this is so iconic<00:07:52.080><c> all</c><00:07:52.199><c> right</c><00:07:52.319><c> I</c><00:07:52.400><c> didn''t</c><00:07:52.639><c> buy</c><00:07:52.840><c> anything</c>', '', '', '<span>T-shirt</span> <span>this</span> <span>is</span> <span>so</span> <span>iconic<00:07:52.080><c></span> <span>all</c><00:07:52.199><c></span> <span>right</c><00:07:52.319><c></span> <span>I</c><00:07:52.400><c></span> <span>didn''t</c><00:07:52.639><c></span> <span>buy</c><00:07:52.840><c></span> <span>anything</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 342, 473.309, 0.0, 'iconic all right I didn''t buy anything', '', '', '<span>iconic</span> <span>all</span> <span>right</span> <span>I</span> <span>didn''t</span> <span>buy</span> <span>anything</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 343, 473.319, 0.0, 'iconic all right I didn''t buy anything but<00:07:53.639><c> I</c><00:07:53.759><c> tried</c><00:07:54.400><c> I</c><00:07:54.520><c> tried</c><00:07:54.759><c> on</c><00:07:54.879><c> some</c><00:07:55.120><c> stuff</c><00:07:55.599><c> proud</c>', '', '', '<span>iconic</span> <span>all</span> <span>right</span> <span>I</span> <span>didn''t</span> <span>buy</span> <span>anything</span> <span>but<00:07:53.639><c></span> <span>I</c><00:07:53.759><c></span> <span>tried</c><00:07:54.400><c></span> <span>I</c><00:07:54.520><c></span> <span>tried</c><00:07:54.759><c></span> <span>on</c><00:07:54.879><c></span> <span>some</c><00:07:55.120><c></span> <span>stuff</c><00:07:55.599><c></span> <span>proud</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 344, 475.869, 0.0, 'but I tried I tried on some stuff proud', '', '', '<span>but</span> <span>I</span> <span>tried</span> <span>I</span> <span>tried</span> <span>on</span> <span>some</span> <span>stuff</span> <span>proud</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 345, 475.879, 0.0, 'but I tried I tried on some stuff proud of<00:07:56.000><c> myself</c><00:07:56.440><c> now</c><00:07:56.520><c> we''re</c><00:07:56.680><c> going</c><00:07:56.840><c> to</c><00:07:57.000><c> one</c><00:07:57.120><c> of</c><00:07:57.199><c> my</c>', '', '', '<span>but</span> <span>I</span> <span>tried</span> <span>I</span> <span>tried</span> <span>on</span> <span>some</span> <span>stuff</span> <span>proud</span> <span>of<00:07:56.000><c></span> <span>myself</c><00:07:56.440><c></span> <span>now</c><00:07:56.520><c></span> <span>we''re</c><00:07:56.680><c></span> <span>going</c><00:07:56.840><c></span> <span>to</c><00:07:57.000><c></span> <span>one</c><00:07:57.120><c></span> <span>of</c><00:07:57.199><c></span> <span>my</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 346, 477.309, 0.0, 'of myself now we''re going to one of my', '', '', '<span>of</span> <span>myself</span> <span>now</span> <span>we''re</span> <span>going</span> <span>to</span> <span>one</span> <span>of</span> <span>my</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 347, 477.319, 0.0, 'of myself now we''re going to one of my favorite<00:07:57.680><c> places</c><00:07:58.440><c> of</c><00:07:58.560><c> all</c><00:07:58.759><c> time</c><00:07:59.039><c> in</c><00:07:59.199><c> the</c>', '', '', '<span>of</span> <span>myself</span> <span>now</span> <span>we''re</span> <span>going</span> <span>to</span> <span>one</span> <span>of</span> <span>my</span> <span>favorite<00:07:57.680><c></span> <span>places</c><00:07:58.440><c></span> <span>of</c><00:07:58.560><c></span> <span>all</c><00:07:58.759><c></span> <span>time</c><00:07:59.039><c></span> <span>in</c><00:07:59.199><c></span> <span>the</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 348, 481.04, 0.0, 'favorite places of all time in the', '', '', '<span>favorite</span> <span>places</span> <span>of</span> <span>all</span> <span>time</span> <span>in</span> <span>the</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 349, 481.05, 0.0, 'favorite places of all time in the [Music]', '', '', '<span>favorite</span> <span>places</span> <span>of</span> <span>all</span> <span>time</span> <span>in</span> <span>the</span> <span>[Music]</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 350, 493.029, 0.0, 'please well can be a Lon', '', '', '<span>please</span> <span>well</span> <span>can</span> <span>be</span> <span>a</span> <span>Lon</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 351, 493.039, 0.0, 'please well can be a Lon Place<00:08:14.039><c> baby</c><00:08:14.560><c> I''m</c><00:08:14.759><c> so</c>', '', '', '<span>please</span> <span>well</span> <span>can</span> <span>be</span> <span>a</span> <span>Lon</span> <span>Place<00:08:14.039><c></span> <span>baby</c><00:08:14.560><c></span> <span>I''m</c><00:08:14.759><c></span> <span>so</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 352, 499.99, 0.0, 'glad', '', '', '<span>glad</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 353, 500.0, 0.0, 'glad I<00:08:21.400><c> embra</c><00:08:22.400><c> you</c><00:08:22.520><c> know</c><00:08:22.919><c> fairly</c><00:08:23.560><c> often</c><00:08:24.080><c> do</c><00:08:24.280><c> I</c><00:08:24.560><c> have</c>', '', '', '<span>glad</span> <span>I<00:08:21.400><c></span> <span>embra</c><00:08:22.400><c></span> <span>you</c><00:08:22.520><c></span> <span>know</c><00:08:22.919><c></span> <span>fairly</c><00:08:23.560><c></span> <span>often</c><00:08:24.080><c></span> <span>do</c><00:08:24.280><c></span> <span>I</c><00:08:24.560><c></span> <span>have</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 354, 504.95, 0.0, 'I embra you know fairly often do I have', '', '', '<span>I</span> <span>embra</span> <span>you</span> <span>know</span> <span>fairly</span> <span>often</span> <span>do</span> <span>I</span> <span>have</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 355, 504.96, 0.0, 'I embra you know fairly often do I have moments<00:08:25.840><c> in</c><00:08:26.000><c> New</c><00:08:26.159><c> York</c><00:08:26.560><c> where</c><00:08:26.879><c> I</c><00:08:27.039><c> realize</c><00:08:27.479><c> that</c>', '', '', '<span>I</span> <span>embra</span> <span>you</span> <span>know</span> <span>fairly</span> <span>often</span> <span>do</span> <span>I</span> <span>have</span> <span>moments<00:08:25.840><c></span> <span>in</c><00:08:26.000><c></span> <span>New</c><00:08:26.159><c></span> <span>York</c><00:08:26.560><c></span> <span>where</c><00:08:26.879><c></span> <span>I</c><00:08:27.039><c></span> <span>realize</c><00:08:27.479><c></span> <span>that</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 356, 507.629, 0.0, 'moments in New York where I realize that', '', '', '<span>moments</span> <span>in</span> <span>New</span> <span>York</span> <span>where</span> <span>I</span> <span>realize</span> <span>that</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 357, 507.639, 0.0, 'moments in New York where I realize that I''m<00:08:27.919><c> currently</c><00:08:28.440><c> living</c><00:08:28.800><c> in</c><00:08:28.919><c> a</c><00:08:29.039><c> memorable</c>', '', '', '<span>moments</span> <span>in</span> <span>New</span> <span>York</span> <span>where</span> <span>I</span> <span>realize</span> <span>that</span> <span>I''m<00:08:27.919><c></span> <span>currently</c><00:08:28.440><c></span> <span>living</c><00:08:28.800><c></span> <span>in</c><00:08:28.919><c></span> <span>a</c><00:08:29.039><c></span> <span>memorable</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 358, 509.629, 0.0, 'I''m currently living in a memorable', '', '', '<span>I''m</span> <span>currently</span> <span>living</span> <span>in</span> <span>a</span> <span>memorable</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 359, 509.639, 0.0, 'I''m currently living in a memorable moment<00:08:29.960><c> do</c><00:08:30.039><c> you</c><00:08:30.159><c> ever</c><00:08:30.400><c> get</c><00:08:30.560><c> that</c><00:08:30.800><c> like</c><00:08:30.919><c> where</c><00:08:31.039><c> a</c>', '', '', '<span>I''m</span> <span>currently</span> <span>living</span> <span>in</span> <span>a</span> <span>memorable</span> <span>moment<00:08:29.960><c></span> <span>do</c><00:08:30.039><c></span> <span>you</c><00:08:30.159><c></span> <span>ever</c><00:08:30.400><c></span> <span>get</c><00:08:30.560><c></span> <span>that</c><00:08:30.800><c></span> <span>like</c><00:08:30.919><c></span> <span>where</c><00:08:31.039><c></span> <span>a</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 360, 511.149, 0.0, 'moment do you ever get that like where a', '', '', '<span>moment</span> <span>do</span> <span>you</span> <span>ever</span> <span>get</span> <span>that</span> <span>like</span> <span>where</span> <span>a</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 361, 511.159, 0.0, 'moment do you ever get that like where a moment<00:08:31.400><c> is</c><00:08:31.560><c> so</c><00:08:31.879><c> special</c><00:08:32.440><c> or</c><00:08:32.719><c> unique</c><00:08:33.120><c> in</c><00:08:33.279><c> some</c>', '', '', '<span>moment</span> <span>do</span> <span>you</span> <span>ever</span> <span>get</span> <span>that</span> <span>like</span> <span>where</span> <span>a</span> <span>moment<00:08:31.400><c></span> <span>is</c><00:08:31.560><c></span> <span>so</c><00:08:31.879><c></span> <span>special</c><00:08:32.440><c></span> <span>or</c><00:08:32.719><c></span> <span>unique</c><00:08:33.120><c></span> <span>in</c><00:08:33.279><c></span> <span>some</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 362, 513.509, 0.0, 'moment is so special or unique in some', '', '', '<span>moment</span> <span>is</span> <span>so</span> <span>special</span> <span>or</span> <span>unique</span> <span>in</span> <span>some</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 363, 513.519, 0.0, 'moment is so special or unique in some way<00:08:33.719><c> even</c><00:08:33.880><c> if</c><00:08:34.000><c> it''s</c><00:08:34.120><c> the</c><00:08:34.240><c> mundane</c><00:08:34.800><c> that</c><00:08:34.959><c> can</c><00:08:35.080><c> be</c>', '', '', '<span>moment</span> <span>is</span> <span>so</span> <span>special</span> <span>or</span> <span>unique</span> <span>in</span> <span>some</span> <span>way<00:08:33.719><c></span> <span>even</c><00:08:33.880><c></span> <span>if</c><00:08:34.000><c></span> <span>it''s</c><00:08:34.120><c></span> <span>the</c><00:08:34.240><c></span> <span>mundane</c><00:08:34.800><c></span> <span>that</c><00:08:34.959><c></span> <span>can</c><00:08:35.080><c></span> <span>be</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 364, 515.23, 0.0, 'way even if it''s the mundane that can be', '', '', '<span>way</span> <span>even</span> <span>if</span> <span>it''s</span> <span>the</span> <span>mundane</span> <span>that</span> <span>can</span> <span>be</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 365, 515.24, 0.0, 'way even if it''s the mundane that can be special<00:08:35.560><c> all</c><00:08:35.760><c> the</c><00:08:35.880><c> same</c><00:08:36.519><c> but</c><00:08:36.640><c> to</c><00:08:36.800><c> the</c><00:08:36.959><c> point</c>', '', '', '<span>way</span> <span>even</span> <span>if</span> <span>it''s</span> <span>the</span> <span>mundane</span> <span>that</span> <span>can</span> <span>be</span> <span>special<00:08:35.560><c></span> <span>all</c><00:08:35.760><c></span> <span>the</c><00:08:35.880><c></span> <span>same</c><00:08:36.519><c></span> <span>but</c><00:08:36.640><c></span> <span>to</c><00:08:36.800><c></span> <span>the</c><00:08:36.959><c></span> <span>point</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 366, 517.149, 0.0, 'special all the same but to the point', '', '', '<span>special</span> <span>all</span> <span>the</span> <span>same</span> <span>but</span> <span>to</span> <span>the</span> <span>point</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 367, 517.159, 0.0, 'special all the same but to the point where<00:08:37.279><c> you</c><00:08:37.599><c> realize</c><00:08:37.919><c> it</c><00:08:38.080><c> while</c><00:08:38.279><c> it''s</c>', '', '', '<span>special</span> <span>all</span> <span>the</span> <span>same</span> <span>but</span> <span>to</span> <span>the</span> <span>point</span> <span>where<00:08:37.279><c></span> <span>you</c><00:08:37.599><c></span> <span>realize</c><00:08:37.919><c></span> <span>it</c><00:08:38.080><c></span> <span>while</c><00:08:38.279><c></span> <span>it''s</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 368, 518.469, 0.0, 'where you realize it while it''s', '', '', '<span>where</span> <span>you</span> <span>realize</span> <span>it</span> <span>while</span> <span>it''s</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 369, 518.479, 0.0, 'where you realize it while it''s happening<00:08:38.919><c> anyway</c><00:08:39.240><c> I</c><00:08:39.320><c> have</c><00:08:39.479><c> those</c><00:08:39.640><c> here</c><00:08:39.839><c> a</c><00:08:39.959><c> lot</c>', '', '', '<span>where</span> <span>you</span> <span>realize</span> <span>it</span> <span>while</span> <span>it''s</span> <span>happening<00:08:38.919><c></span> <span>anyway</c><00:08:39.240><c></span> <span>I</c><00:08:39.320><c></span> <span>have</c><00:08:39.479><c></span> <span>those</c><00:08:39.640><c></span> <span>here</c><00:08:39.839><c></span> <span>a</c><00:08:39.959><c></span> <span>lot</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 370, 520.149, 0.0, 'happening anyway I have those here a lot', '', '', '<span>happening</span> <span>anyway</span> <span>I</span> <span>have</span> <span>those</span> <span>here</span> <span>a</span> <span>lot</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 371, 520.159, 0.0, 'happening anyway I have those here a lot and<00:08:40.279><c> I</c><00:08:40.399><c> think</c><00:08:40.560><c> that</c><00:08:40.719><c> that</c><00:08:40.839><c> speaks</c><00:08:41.279><c> volumes</c><00:08:41.680><c> to</c>', '', '', '<span>happening</span> <span>anyway</span> <span>I</span> <span>have</span> <span>those</span> <span>here</span> <span>a</span> <span>lot</span> <span>and<00:08:40.279><c></span> <span>I</c><00:08:40.399><c></span> <span>think</c><00:08:40.560><c></span> <span>that</c><00:08:40.719><c></span> <span>that</c><00:08:40.839><c></span> <span>speaks</c><00:08:41.279><c></span> <span>volumes</c><00:08:41.680><c></span> <span>to</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 372, 521.909, 0.0, 'and I think that that speaks volumes to', '', '', '<span>and</span> <span>I</span> <span>think</span> <span>that</span> <span>that</span> <span>speaks</span> <span>volumes</span> <span>to</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 373, 521.919, 0.0, 'and I think that that speaks volumes to how<00:08:42.200><c> special</c><00:08:42.599><c> this</c><00:08:42.800><c> place</c><00:08:43.039><c> is</c><00:08:43.680><c> it</c><00:08:43.760><c> is</c><00:08:43.919><c> not</c><00:08:44.080><c> for</c>', '', '', '<span>and</span> <span>I</span> <span>think</span> <span>that</span> <span>that</span> <span>speaks</span> <span>volumes</span> <span>to</span> <span>how<00:08:42.200><c></span> <span>special</c><00:08:42.599><c></span> <span>this</c><00:08:42.800><c></span> <span>place</c><00:08:43.039><c></span> <span>is</c><00:08:43.680><c></span> <span>it</c><00:08:43.760><c></span> <span>is</c><00:08:43.919><c></span> <span>not</c><00:08:44.080><c></span> <span>for</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 374, 524.269, 0.0, 'how special this place is it is not for', '', '', '<span>how</span> <span>special</span> <span>this</span> <span>place</span> <span>is</span> <span>it</span> <span>is</span> <span>not</span> <span>for</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 375, 524.279, 0.0, 'how special this place is it is not for everyone<00:08:44.880><c> it''s</c><00:08:45.080><c> really</c><00:08:45.320><c> not</c><00:08:45.800><c> but</c><00:08:46.279><c> it</c><00:08:46.399><c> is</c><00:08:46.560><c> for</c>', '', '', '<span>how</span> <span>special</span> <span>this</span> <span>place</span> <span>is</span> <span>it</span> <span>is</span> <span>not</span> <span>for</span> <span>everyone<00:08:44.880><c></span> <span>it''s</c><00:08:45.080><c></span> <span>really</c><00:08:45.320><c></span> <span>not</c><00:08:45.800><c></span> <span>but</c><00:08:46.279><c></span> <span>it</c><00:08:46.399><c></span> <span>is</c><00:08:46.560><c></span> <span>for</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 376, 526.75, 0.0, 'everyone it''s really not but it is for', '', '', '<span>everyone</span> <span>it''s</span> <span>really</span> <span>not</span> <span>but</span> <span>it</span> <span>is</span> <span>for</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 377, 526.76, 0.0, 'everyone it''s really not but it is for me<00:08:47.399><c> and</c><00:08:47.560><c> when</c><00:08:47.680><c> I</c><00:08:47.800><c> sto</c><00:08:48.040><c> to</c><00:08:48.200><c> think</c><00:08:48.360><c> about</c><00:08:48.600><c> it</c><00:08:48.959><c> you</c>', '', '', '<span>everyone</span> <span>it''s</span> <span>really</span> <span>not</span> <span>but</span> <span>it</span> <span>is</span> <span>for</span> <span>me<00:08:47.399><c></span> <span>and</c><00:08:47.560><c></span> <span>when</c><00:08:47.680><c></span> <span>I</c><00:08:47.800><c></span> <span>sto</c><00:08:48.040><c></span> <span>to</c><00:08:48.200><c></span> <span>think</c><00:08:48.360><c></span> <span>about</c><00:08:48.600><c></span> <span>it</c><00:08:48.959><c></span> <span>you</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 378, 529.03, 0.0, 'me and when I sto to think about it you', '', '', '<span>me</span> <span>and</span> <span>when</span> <span>I</span> <span>sto</span> <span>to</span> <span>think</span> <span>about</span> <span>it</span> <span>you</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 379, 529.04, 0.0, 'me and when I sto to think about it you know<00:08:49.160><c> I''ve</c><00:08:49.279><c> lived</c><00:08:49.519><c> here</c><00:08:49.640><c> for</c><00:08:49.839><c> only</c><00:08:50.120><c> 3</c><00:08:50.399><c> years</c>', '', '', '<span>me</span> <span>and</span> <span>when</span> <span>I</span> <span>sto</span> <span>to</span> <span>think</span> <span>about</span> <span>it</span> <span>you</span> <span>know<00:08:49.160><c></span> <span>I''ve</c><00:08:49.279><c></span> <span>lived</c><00:08:49.519><c></span> <span>here</c><00:08:49.640><c></span> <span>for</c><00:08:49.839><c></span> <span>only</c><00:08:50.120><c></span> <span>3</c><00:08:50.399><c></span> <span>years</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 380, 530.949, 0.0, 'know I''ve lived here for only 3 years', '', '', '<span>know</span> <span>I''ve</span> <span>lived</span> <span>here</span> <span>for</span> <span>only</span> <span>3</span> <span>years</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 381, 530.959, 0.0, 'know I''ve lived here for only 3 years tack<00:08:51.240><c> on</c><00:08:51.399><c> another</c><00:08:51.680><c> 6</c><00:08:51.880><c> months</c><00:08:52.120><c> if</c><00:08:52.200><c> you</c><00:08:52.279><c> want</c><00:08:52.360><c> to</c>', '', '', '<span>know</span> <span>I''ve</span> <span>lived</span> <span>here</span> <span>for</span> <span>only</span> <span>3</span> <span>years</span> <span>tack<00:08:51.240><c></span> <span>on</c><00:08:51.399><c></span> <span>another</c><00:08:51.680><c></span> <span>6</c><00:08:51.880><c></span> <span>months</c><00:08:52.120><c></span> <span>if</c><00:08:52.200><c></span> <span>you</c><00:08:52.279><c></span> <span>want</c><00:08:52.360><c></span> <span>to</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 382, 532.47, 0.0, 'tack on another 6 months if you want to', '', '', '<span>tack</span> <span>on</span> <span>another</span> <span>6</span> <span>months</span> <span>if</span> <span>you</span> <span>want</span> <span>to</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 383, 532.48, 0.0, 'tack on another 6 months if you want to count<00:08:52.680><c> the</c><00:08:52.839><c> internships</c><00:08:53.279><c> during</c><00:08:53.600><c> college</c>', '', '', '<span>tack</span> <span>on</span> <span>another</span> <span>6</span> <span>months</span> <span>if</span> <span>you</span> <span>want</span> <span>to</span> <span>count<00:08:52.680><c></span> <span>the</c><00:08:52.839><c></span> <span>internships</c><00:08:53.279><c></span> <span>during</c><00:08:53.600><c></span> <span>college</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 384, 534.07, 0.0, 'count the internships during college', '', '', '<span>count</span> <span>the</span> <span>internships</span> <span>during</span> <span>college</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 385, 534.08, 0.0, 'count the internships during college it''s<00:08:54.240><c> called</c><00:08:54.440><c> 3</c><00:08:54.560><c> and</c><00:08:54.680><c> a/2</c><00:08:54.959><c> years</c><00:08:55.760><c> that''s</c>', '', '', '<span>count</span> <span>the</span> <span>internships</span> <span>during</span> <span>college</span> <span>it''s<00:08:54.240><c></span> <span>called</c><00:08:54.440><c></span> <span>3</c><00:08:54.560><c></span> <span>and</c><00:08:54.680><c></span> <span>a/2</c><00:08:54.959><c></span> <span>years</c><00:08:55.760><c></span> <span>that''s</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 386, 535.949, 0.0, 'it''s called 3 and a/2 years that''s', '', '', '<span>it''s</span> <span>called</span> <span>3</span> <span>and</span> <span>a/2</span> <span>years</span> <span>that''s</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 387, 535.959, 0.0, 'it''s called 3 and a/2 years that''s nothing<00:08:56.440><c> like</c><00:08:56.560><c> not</c><00:08:56.760><c> really</c><00:08:57.080><c> you</c><00:08:57.200><c> know</c><00:08:57.360><c> that''s</c>', '', '', '<span>it''s</span> <span>called</span> <span>3</span> <span>and</span> <span>a/2</span> <span>years</span> <span>that''s</span> <span>nothing<00:08:56.440><c></span> <span>like</c><00:08:56.560><c></span> <span>not</c><00:08:56.760><c></span> <span>really</c><00:08:57.080><c></span> <span>you</c><00:08:57.200><c></span> <span>know</c><00:08:57.360><c></span> <span>that''s</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 388, 537.59, 0.0, 'nothing like not really you know that''s', '', '', '<span>nothing</span> <span>like</span> <span>not</span> <span>really</span> <span>you</span> <span>know</span> <span>that''s</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 389, 537.6, 0.0, 'nothing like not really you know that''s last<00:08:57.800><c> time</c><00:08:57.920><c> than</c><00:08:58.040><c> I</c><00:08:58.120><c> was</c><00:08:58.240><c> in</c><00:08:58.440><c> college</c><00:08:59.000><c> yet</c><00:08:59.200><c> I</c>', '', '', '<span>nothing</span> <span>like</span> <span>not</span> <span>really</span> <span>you</span> <span>know</span> <span>that''s</span> <span>last<00:08:57.800><c></span> <span>time</c><00:08:57.920><c></span> <span>than</c><00:08:58.040><c></span> <span>I</c><00:08:58.120><c></span> <span>was</c><00:08:58.240><c></span> <span>in</c><00:08:58.440><c></span> <span>college</c><00:08:59.000><c></span> <span>yet</c><00:08:59.200><c></span> <span>I</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 390, 539.47, 0.0, 'last time than I was in college yet I', '', '', '<span>last</span> <span>time</span> <span>than</span> <span>I</span> <span>was</span> <span>in</span> <span>college</span> <span>yet</span> <span>I</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 391, 539.48, 0.0, 'last time than I was in college yet I feel<00:08:59.680><c> like</c><00:08:59.920><c> I</c><00:09:00.040><c> have</c><00:09:00.200><c> lived</c><00:09:00.760><c> three</c><00:09:01.399><c> lifetimes</c>', '', '', '<span>last</span> <span>time</span> <span>than</span> <span>I</span> <span>was</span> <span>in</span> <span>college</span> <span>yet</span> <span>I</span> <span>feel<00:08:59.680><c></span> <span>like</c><00:08:59.920><c></span> <span>I</c><00:09:00.040><c></span> <span>have</c><00:09:00.200><c></span> <span>lived</c><00:09:00.760><c></span> <span>three</c><00:09:01.399><c></span> <span>lifetimes</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 392, 542.069, 0.0, 'feel like I have lived three lifetimes', '', '', '<span>feel</span> <span>like</span> <span>I</span> <span>have</span> <span>lived</span> <span>three</span> <span>lifetimes</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 393, 542.079, 0.0, 'feel like I have lived three lifetimes since<00:09:02.279><c> I</c><00:09:02.399><c> moved</c><00:09:02.720><c> here</c><00:09:03.000><c> the</c><00:09:03.120><c> person</c><00:09:03.399><c> I</c><00:09:03.519><c> was</c><00:09:03.720><c> when</c>', '', '', '<span>feel</span> <span>like</span> <span>I</span> <span>have</span> <span>lived</span> <span>three</span> <span>lifetimes</span> <span>since<00:09:02.279><c></span> <span>I</c><00:09:02.399><c></span> <span>moved</c><00:09:02.720><c></span> <span>here</c><00:09:03.000><c></span> <span>the</c><00:09:03.120><c></span> <span>person</c><00:09:03.399><c></span> <span>I</c><00:09:03.519><c></span> <span>was</c><00:09:03.720><c></span> <span>when</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 394, 543.87, 0.0, 'since I moved here the person I was when', '', '', '<span>since</span> <span>I</span> <span>moved</span> <span>here</span> <span>the</span> <span>person</span> <span>I</span> <span>was</span> <span>when</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 395, 543.88, 0.0, 'since I moved here the person I was when I<00:09:04.240><c> first</c><00:09:04.440><c> moved</c><00:09:04.720><c> here</c><00:09:04.839><c> is</c><00:09:04.959><c> just</c><00:09:05.079><c> so</c><00:09:05.320><c> different</c>', '', '', '<span>since</span> <span>I</span> <span>moved</span> <span>here</span> <span>the</span> <span>person</span> <span>I</span> <span>was</span> <span>when</span> <span>I<00:09:04.240><c></span> <span>first</c><00:09:04.440><c></span> <span>moved</c><00:09:04.720><c></span> <span>here</c><00:09:04.839><c></span> <span>is</c><00:09:04.959><c></span> <span>just</c><00:09:05.079><c></span> <span>so</c><00:09:05.320><c></span> <span>different</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 396, 545.63, 0.0, 'I first moved here is just so different', '', '', '<span>I</span> <span>first</span> <span>moved</span> <span>here</span> <span>is</span> <span>just</span> <span>so</span> <span>different</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 397, 545.64, 0.0, 'I first moved here is just so different than<00:09:05.800><c> who</c><00:09:05.920><c> I</c><00:09:06.040><c> am</c><00:09:06.160><c> today</c><00:09:06.560><c> and</c><00:09:06.959><c> you</c><00:09:07.079><c> know</c><00:09:07.160><c> it''s</c><00:09:07.240><c> a</c>', '', '', '<span>I</span> <span>first</span> <span>moved</span> <span>here</span> <span>is</span> <span>just</span> <span>so</span> <span>different</span> <span>than<00:09:05.800><c></span> <span>who</c><00:09:05.920><c></span> <span>I</c><00:09:06.040><c></span> <span>am</c><00:09:06.160><c></span> <span>today</c><00:09:06.560><c></span> <span>and</c><00:09:06.959><c></span> <span>you</c><00:09:07.079><c></span> <span>know</c><00:09:07.160><c></span> <span>it''s</c><00:09:07.240><c></span> <span>a</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 398, 547.43, 0.0, 'than who I am today and you know it''s a', '', '', '<span>than</span> <span>who</span> <span>I</span> <span>am</span> <span>today</span> <span>and</span> <span>you</span> <span>know</span> <span>it''s</span> <span>a</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 399, 547.44, 0.0, 'than who I am today and you know it''s a good<00:09:07.600><c> thing</c><00:09:07.800><c> I</c><00:09:07.880><c> think</c><00:09:08.000><c> we</c><00:09:08.079><c> should</c><00:09:08.279><c> always</c><00:09:08.519><c> be</c>', '', '', '<span>than</span> <span>who</span> <span>I</span> <span>am</span> <span>today</span> <span>and</span> <span>you</span> <span>know</span> <span>it''s</span> <span>a</span> <span>good<00:09:07.600><c></span> <span>thing</c><00:09:07.800><c></span> <span>I</c><00:09:07.880><c></span> <span>think</c><00:09:08.000><c></span> <span>we</c><00:09:08.079><c></span> <span>should</c><00:09:08.279><c></span> <span>always</c><00:09:08.519><c></span> <span>be</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 400, 549.03, 0.0, 'good thing I think we should always be', '', '', '<span>good</span> <span>thing</span> <span>I</span> <span>think</span> <span>we</span> <span>should</span> <span>always</span> <span>be</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 401, 549.04, 0.0, 'good thing I think we should always be changing<00:09:09.519><c> and</c><00:09:09.640><c> growing</c><00:09:10.079><c> and</c><00:09:10.480><c> all</c><00:09:10.680><c> those</c><00:09:11.040><c> good</c>', '', '', '<span>good</span> <span>thing</span> <span>I</span> <span>think</span> <span>we</span> <span>should</span> <span>always</span> <span>be</span> <span>changing<00:09:09.519><c></span> <span>and</c><00:09:09.640><c></span> <span>growing</c><00:09:10.079><c></span> <span>and</c><00:09:10.480><c></span> <span>all</c><00:09:10.680><c></span> <span>those</c><00:09:11.040><c></span> <span>good</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 402, 551.19, 0.0, 'changing and growing and all those good', '', '', '<span>changing</span> <span>and</span> <span>growing</span> <span>and</span> <span>all</span> <span>those</span> <span>good</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 403, 551.2, 0.0, 'changing and growing and all those good things<00:09:11.480><c> but</c><00:09:11.600><c> I</c><00:09:11.720><c> just</c><00:09:11.839><c> think</c><00:09:11.959><c> it''s</c><00:09:12.120><c> so</c><00:09:12.399><c> true</c>', '', '', '<span>changing</span> <span>and</span> <span>growing</span> <span>and</span> <span>all</span> <span>those</span> <span>good</span> <span>things<00:09:11.480><c></span> <span>but</c><00:09:11.600><c></span> <span>I</c><00:09:11.720><c></span> <span>just</c><00:09:11.839><c></span> <span>think</c><00:09:11.959><c></span> <span>it''s</c><00:09:12.120><c></span> <span>so</c><00:09:12.399><c></span> <span>true</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 404, 552.75, 0.0, 'things but I just think it''s so true', '', '', '<span>things</span> <span>but</span> <span>I</span> <span>just</span> <span>think</span> <span>it''s</span> <span>so</span> <span>true</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 405, 552.76, 0.0, 'things but I just think it''s so true that<00:09:12.920><c> New</c><00:09:13.079><c> York</c><00:09:13.399><c> forces</c><00:09:13.839><c> you</c><00:09:13.959><c> to</c><00:09:14.160><c> pack</c><00:09:14.519><c> so</c><00:09:14.680><c> much</c>', '', '', '<span>things</span> <span>but</span> <span>I</span> <span>just</span> <span>think</span> <span>it''s</span> <span>so</span> <span>true</span> <span>that<00:09:12.920><c></span> <span>New</c><00:09:13.079><c></span> <span>York</c><00:09:13.399><c></span> <span>forces</c><00:09:13.839><c></span> <span>you</c><00:09:13.959><c></span> <span>to</c><00:09:14.160><c></span> <span>pack</c><00:09:14.519><c></span> <span>so</c><00:09:14.680><c></span> <span>much</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 406, 554.99, 0.0, 'that New York forces you to pack so much', '', '', '<span>that</span> <span>New</span> <span>York</span> <span>forces</span> <span>you</span> <span>to</span> <span>pack</span> <span>so</span> <span>much</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 407, 555.0, 0.0, 'that New York forces you to pack so much life<00:09:15.680><c> into</c><00:09:16.160><c> a</c><00:09:16.320><c> short</c><00:09:16.640><c> amount</c><00:09:16.839><c> of</c><00:09:17.040><c> time</c>', '', '', '<span>that</span> <span>New</span> <span>York</span> <span>forces</span> <span>you</span> <span>to</span> <span>pack</span> <span>so</span> <span>much</span> <span>life<00:09:15.680><c></span> <span>into</c><00:09:16.160><c></span> <span>a</c><00:09:16.320><c></span> <span>short</c><00:09:16.640><c></span> <span>amount</c><00:09:16.839><c></span> <span>of</c><00:09:17.040><c></span> <span>time</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 408, 557.55, 0.0, 'life into a short amount of time', '', '', '<span>life</span> <span>into</span> <span>a</span> <span>short</span> <span>amount</span> <span>of</span> <span>time</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 409, 557.56, 0.0, 'life into a short amount of time sometimes<00:09:17.720><c> to</c><00:09:17.880><c> an</c><00:09:18.000><c> overwhelming</c><00:09:18.560><c> Point</c>', '', '', '<span>life</span> <span>into</span> <span>a</span> <span>short</span> <span>amount</span> <span>of</span> <span>time</span> <span>sometimes<00:09:17.720><c></span> <span>to</c><00:09:17.880><c></span> <span>an</c><00:09:18.000><c></span> <span>overwhelming</c><00:09:18.560><c></span> <span>Point</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 410, 558.87, 0.0, 'sometimes to an overwhelming Point', '', '', '<span>sometimes</span> <span>to</span> <span>an</span> <span>overwhelming</span> <span>Point</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 411, 558.88, 0.0, 'sometimes to an overwhelming Point honestly<00:09:19.560><c> where</c><00:09:19.800><c> the</c><00:09:19.959><c> default</c><00:09:20.399><c> is</c><00:09:20.560><c> that</c><00:09:20.800><c> so</c>', '', '', '<span>sometimes</span> <span>to</span> <span>an</span> <span>overwhelming</span> <span>Point</span> <span>honestly<00:09:19.560><c></span> <span>where</c><00:09:19.800><c></span> <span>the</c><00:09:19.959><c></span> <span>default</c><00:09:20.399><c></span> <span>is</c><00:09:20.560><c></span> <span>that</c><00:09:20.800><c></span> <span>so</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 412, 561.03, 0.0, 'honestly where the default is that so', '', '', '<span>honestly</span> <span>where</span> <span>the</span> <span>default</span> <span>is</span> <span>that</span> <span>so</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 413, 561.04, 0.0, 'honestly where the default is that so much<00:09:21.240><c> around</c><00:09:21.480><c> you</c><00:09:21.600><c> is</c><00:09:21.800><c> happening</c><00:09:22.240><c> and</c><00:09:22.320><c> you</c>', '', '', '<span>honestly</span> <span>where</span> <span>the</span> <span>default</span> <span>is</span> <span>that</span> <span>so</span> <span>much<00:09:21.240><c></span> <span>around</c><00:09:21.480><c></span> <span>you</c><00:09:21.600><c></span> <span>is</c><00:09:21.800><c></span> <span>happening</c><00:09:22.240><c></span> <span>and</c><00:09:22.320><c></span> <span>you</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 414, 562.47, 0.0, 'much around you is happening and you', '', '', '<span>much</span> <span>around</span> <span>you</span> <span>is</span> <span>happening</span> <span>and</span> <span>you</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 415, 562.48, 0.0, 'much around you is happening and you have<00:09:22.600><c> to</c><00:09:23.079><c> make</c><00:09:23.240><c> an</c><00:09:23.480><c> effort</c><00:09:23.760><c> to</c><00:09:23.959><c> carve</c><00:09:24.200><c> out</c><00:09:24.399><c> your</c>', '', '', '<span>much</span> <span>around</span> <span>you</span> <span>is</span> <span>happening</span> <span>and</span> <span>you</span> <span>have<00:09:22.600><c></span> <span>to</c><00:09:23.079><c></span> <span>make</c><00:09:23.240><c></span> <span>an</c><00:09:23.480><c></span> <span>effort</c><00:09:23.760><c></span> <span>to</c><00:09:23.959><c></span> <span>carve</c><00:09:24.200><c></span> <span>out</c><00:09:24.399><c></span> <span>your</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 416, 564.55, 0.0, 'have to make an effort to carve out your', '', '', '<span>have</span> <span>to</span> <span>make</span> <span>an</span> <span>effort</span> <span>to</span> <span>carve</span> <span>out</span> <span>your</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 417, 564.56, 0.0, 'have to make an effort to carve out your own<00:09:24.800><c> free</c><00:09:25.040><c> time</c><00:09:25.320><c> otherwise</c><00:09:25.680><c> you</c><00:09:25.760><c> will</c><00:09:25.959><c> not</c><00:09:26.200><c> get</c>', '', '', '<span>have</span> <span>to</span> <span>make</span> <span>an</span> <span>effort</span> <span>to</span> <span>carve</span> <span>out</span> <span>your</span> <span>own<00:09:24.800><c></span> <span>free</c><00:09:25.040><c></span> <span>time</c><00:09:25.320><c></span> <span>otherwise</c><00:09:25.680><c></span> <span>you</c><00:09:25.760><c></span> <span>will</c><00:09:25.959><c></span> <span>not</c><00:09:26.200><c></span> <span>get</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 418, 566.31, 0.0, 'own free time otherwise you will not get', '', '', '<span>own</span> <span>free</span> <span>time</span> <span>otherwise</span> <span>you</span> <span>will</span> <span>not</span> <span>get</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 419, 566.32, 0.0, 'own free time otherwise you will not get it<00:09:26.839><c> and</c><00:09:26.959><c> the</c><00:09:27.120><c> opposite</c><00:09:27.480><c> of</c><00:09:27.640><c> that</c><00:09:27.800><c> is</c><00:09:27.959><c> true</c><00:09:28.240><c> for</c>', '', '', '<span>own</span> <span>free</span> <span>time</span> <span>otherwise</span> <span>you</span> <span>will</span> <span>not</span> <span>get</span> <span>it<00:09:26.839><c></span> <span>and</c><00:09:26.959><c></span> <span>the</c><00:09:27.120><c></span> <span>opposite</c><00:09:27.480><c></span> <span>of</c><00:09:27.640><c></span> <span>that</c><00:09:27.800><c></span> <span>is</c><00:09:27.959><c></span> <span>true</c><00:09:28.240><c></span> <span>for</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 420, 568.67, 0.0, 'it and the opposite of that is true for', '', '', '<span>it</span> <span>and</span> <span>the</span> <span>opposite</span> <span>of</span> <span>that</span> <span>is</span> <span>true</span> <span>for</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 421, 568.68, 0.0, 'it and the opposite of that is true for many<00:09:28.880><c> many</c><00:09:29.079><c> other</c><00:09:29.399><c> places</c><00:09:30.040><c> so</c><00:09:30.360><c> anyways</c><00:09:30.640><c> I</c><00:09:30.720><c> was</c>', '', '', '<span>it</span> <span>and</span> <span>the</span> <span>opposite</span> <span>of</span> <span>that</span> <span>is</span> <span>true</span> <span>for</span> <span>many<00:09:28.880><c></span> <span>many</c><00:09:29.079><c></span> <span>other</c><00:09:29.399><c></span> <span>places</c><00:09:30.040><c></span> <span>so</c><00:09:30.360><c></span> <span>anyways</c><00:09:30.640><c></span> <span>I</c><00:09:30.720><c></span> <span>was</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 422, 570.829, 0.0, 'many many other places so anyways I was', '', '', '<span>many</span> <span>many</span> <span>other</span> <span>places</span> <span>so</span> <span>anyways</span> <span>I</span> <span>was</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 423, 570.839, 0.0, 'many many other places so anyways I was listening<00:09:31.200><c> to</c><00:09:31.440><c> a</c><00:09:31.640><c> podcast</c><00:09:32.320><c> Diary</c><00:09:32.640><c> of</c><00:09:32.720><c> CEO</c>', '', '', '<span>many</span> <span>many</span> <span>other</span> <span>places</span> <span>so</span> <span>anyways</span> <span>I</span> <span>was</span> <span>listening<00:09:31.200><c></span> <span>to</c><00:09:31.440><c></span> <span>a</c><00:09:31.640><c></span> <span>podcast</c><00:09:32.320><c></span> <span>Diary</c><00:09:32.640><c></span> <span>of</c><00:09:32.720><c></span> <span>CEO</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 424, 573.23, 0.0, 'listening to a podcast Diary of CEO', '', '', '<span>listening</span> <span>to</span> <span>a</span> <span>podcast</span> <span>Diary</span> <span>of</span> <span>CEO</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 425, 573.24, 0.0, 'listening to a podcast Diary of CEO which<00:09:33.320><c> is</c><00:09:33.440><c> my</c><00:09:33.640><c> favorite</c><00:09:34.040><c> podcast</c><00:09:34.600><c> it''s</c><00:09:34.760><c> hosted</c>', '', '', '<span>listening</span> <span>to</span> <span>a</span> <span>podcast</span> <span>Diary</span> <span>of</span> <span>CEO</span> <span>which<00:09:33.320><c></span> <span>is</c><00:09:33.440><c></span> <span>my</c><00:09:33.640><c></span> <span>favorite</c><00:09:34.040><c></span> <span>podcast</c><00:09:34.600><c></span> <span>it''s</c><00:09:34.760><c></span> <span>hosted</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 426, 575.03, 0.0, 'which is my favorite podcast it''s hosted', '', '', '<span>which</span> <span>is</span> <span>my</span> <span>favorite</span> <span>podcast</span> <span>it''s</span> <span>hosted</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 427, 575.04, 0.0, 'which is my favorite podcast it''s hosted by<00:09:35.160><c> stepen</c><00:09:35.519><c> Bartlett</c><00:09:36.000><c> who</c><00:09:36.279><c> is</c><00:09:36.600><c> a</c><00:09:36.800><c> angel</c>', '', '', '<span>which</span> <span>is</span> <span>my</span> <span>favorite</span> <span>podcast</span> <span>it''s</span> <span>hosted</span> <span>by<00:09:35.160><c></span> <span>stepen</c><00:09:35.519><c></span> <span>Bartlett</c><00:09:36.000><c></span> <span>who</c><00:09:36.279><c></span> <span>is</c><00:09:36.600><c></span> <span>a</c><00:09:36.800><c></span> <span>angel</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 428, 577.11, 0.0, 'by stepen Bartlett who is a angel', '', '', '<span>by</span> <span>stepen</span> <span>Bartlett</span> <span>who</span> <span>is</span> <span>a</span> <span>angel</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 429, 577.12, 0.0, 'by stepen Bartlett who is a angel investor<00:09:37.680><c> and</c><00:09:37.839><c> entrepreneur</c><00:09:38.440><c> based</c><00:09:38.640><c> out</c><00:09:38.760><c> of</c>', '', '', '<span>by</span> <span>stepen</span> <span>Bartlett</span> <span>who</span> <span>is</span> <span>a</span> <span>angel</span> <span>investor<00:09:37.680><c></span> <span>and</c><00:09:37.839><c></span> <span>entrepreneur</c><00:09:38.440><c></span> <span>based</c><00:09:38.640><c></span> <span>out</c><00:09:38.760><c></span> <span>of</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 430, 578.829, 0.0, 'investor and entrepreneur based out of', '', '', '<span>investor</span> <span>and</span> <span>entrepreneur</span> <span>based</span> <span>out</span> <span>of</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 431, 578.839, 0.0, 'investor and entrepreneur based out of the<00:09:38.920><c> UK</c><00:09:39.200><c> he</c><00:09:39.320><c> had</c><00:09:39.440><c> on</c><00:09:39.680><c> Scott</c><00:09:40.120><c> Galloway</c><00:09:40.640><c> I</c>', '', '', '<span>investor</span> <span>and</span> <span>entrepreneur</span> <span>based</span> <span>out</span> <span>of</span> <span>the<00:09:38.920><c></span> <span>UK</c><00:09:39.200><c></span> <span>he</c><00:09:39.320><c></span> <span>had</c><00:09:39.440><c></span> <span>on</c><00:09:39.680><c></span> <span>Scott</c><00:09:40.120><c></span> <span>Galloway</c><00:09:40.640><c></span> <span>I</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 432, 580.71, 0.0, 'the UK he had on Scott Galloway I', '', '', '<span>the</span> <span>UK</span> <span>he</span> <span>had</span> <span>on</span> <span>Scott</span> <span>Galloway</span> <span>I</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 433, 580.72, 0.0, 'the UK he had on Scott Galloway I watched<00:09:41.000><c> their</c><00:09:41.200><c> episode</c><00:09:41.680><c> together</c><00:09:42.040><c> and</c><00:09:42.640><c> Scott</c>', '', '', '<span>the</span> <span>UK</span> <span>he</span> <span>had</span> <span>on</span> <span>Scott</span> <span>Galloway</span> <span>I</span> <span>watched<00:09:41.000><c></span> <span>their</c><00:09:41.200><c></span> <span>episode</c><00:09:41.680><c></span> <span>together</c><00:09:42.040><c></span> <span>and</c><00:09:42.640><c></span> <span>Scott</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 434, 582.91, 0.0, 'watched their episode together and Scott', '', '', '<span>watched</span> <span>their</span> <span>episode</span> <span>together</span> <span>and</span> <span>Scott</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 435, 582.92, 0.0, 'watched their episode together and Scott Galloway<00:09:43.320><c> made</c><00:09:43.480><c> the</c><00:09:43.640><c> point</c><00:09:43.880><c> that</c><00:09:44.000><c> I</c><00:09:44.120><c> thought</c>', '', '', '<span>watched</span> <span>their</span> <span>episode</span> <span>together</span> <span>and</span> <span>Scott</span> <span>Galloway<00:09:43.320><c></span> <span>made</c><00:09:43.480><c></span> <span>the</c><00:09:43.640><c></span> <span>point</c><00:09:43.880><c></span> <span>that</c><00:09:44.000><c></span> <span>I</c><00:09:44.120><c></span> <span>thought</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 436, 584.269, 0.0, 'Galloway made the point that I thought', '', '', '<span>Galloway</span> <span>made</span> <span>the</span> <span>point</span> <span>that</span> <span>I</span> <span>thought</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 437, 584.279, 0.0, 'Galloway made the point that I thought was<00:09:44.440><c> amazing</c><00:09:45.079><c> that</c><00:09:45.360><c> you</c><00:09:45.440><c> know</c><00:09:45.560><c> one</c><00:09:45.720><c> day</c><00:09:45.839><c> he</c><00:09:45.959><c> was</c>', '', '', '<span>Galloway</span> <span>made</span> <span>the</span> <span>point</span> <span>that</span> <span>I</span> <span>thought</span> <span>was<00:09:44.440><c></span> <span>amazing</c><00:09:45.079><c></span> <span>that</c><00:09:45.360><c></span> <span>you</c><00:09:45.440><c></span> <span>know</c><00:09:45.560><c></span> <span>one</c><00:09:45.720><c></span> <span>day</c><00:09:45.839><c></span> <span>he</c><00:09:45.959><c></span> <span>was</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 438, 586.11, 0.0, 'was amazing that you know one day he was', '', '', '<span>was</span> <span>amazing</span> <span>that</span> <span>you</span> <span>know</span> <span>one</span> <span>day</span> <span>he</span> <span>was</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 439, 586.12, 0.0, 'was amazing that you know one day he was skiing<00:09:46.480><c> in</c><00:09:46.680><c> Aspen</c><00:09:47.160><c> I</c><00:09:47.240><c> think</c><00:09:47.360><c> it</c><00:09:47.519><c> was</c><00:09:47.839><c> and</c><00:09:48.000><c> he''s</c>', '', '', '<span>was</span> <span>amazing</span> <span>that</span> <span>you</span> <span>know</span> <span>one</span> <span>day</span> <span>he</span> <span>was</span> <span>skiing<00:09:46.480><c></span> <span>in</c><00:09:46.680><c></span> <span>Aspen</c><00:09:47.160><c></span> <span>I</c><00:09:47.240><c></span> <span>think</c><00:09:47.360><c></span> <span>it</c><00:09:47.519><c></span> <span>was</c><00:09:47.839><c></span> <span>and</c><00:09:48.000><c></span> <span>he''s</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 440, 588.19, 0.0, 'skiing in Aspen I think it was and he''s', '', '', '<span>skiing</span> <span>in</span> <span>Aspen</span> <span>I</span> <span>think</span> <span>it</span> <span>was</span> <span>and</span> <span>he''s</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 441, 588.2, 0.0, 'skiing in Aspen I think it was and he''s like<00:09:48.399><c> damn</c><00:09:48.640><c> I''m</c><00:09:48.760><c> a</c><00:09:48.880><c> good</c><00:09:49.040><c> skier</c><00:09:49.640><c> and</c><00:09:49.760><c> then</c><00:09:49.920><c> he</c>', '', '', '<span>skiing</span> <span>in</span> <span>Aspen</span> <span>I</span> <span>think</span> <span>it</span> <span>was</span> <span>and</span> <span>he''s</span> <span>like<00:09:48.399><c></span> <span>damn</c><00:09:48.640><c></span> <span>I''m</c><00:09:48.760><c></span> <span>a</c><00:09:48.880><c></span> <span>good</c><00:09:49.040><c></span> <span>skier</c><00:09:49.640><c></span> <span>and</c><00:09:49.760><c></span> <span>then</c><00:09:49.920><c></span> <span>he</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 442, 590.069, 0.0, 'like damn I''m a good skier and then he', '', '', '<span>like</span> <span>damn</span> <span>I''m</span> <span>a</span> <span>good</span> <span>skier</span> <span>and</span> <span>then</span> <span>he</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 443, 590.079, 0.0, 'like damn I''m a good skier and then he realized<00:09:50.839><c> no</c><00:09:51.079><c> the</c><00:09:51.200><c> snow</c><00:09:51.480><c> and</c><00:09:51.600><c> the</c><00:09:51.680><c> powder</c><00:09:51.959><c> is</c>', '', '', '<span>like</span> <span>damn</span> <span>I''m</span> <span>a</span> <span>good</span> <span>skier</span> <span>and</span> <span>then</span> <span>he</span> <span>realized<00:09:50.839><c></span> <span>no</c><00:09:51.079><c></span> <span>the</c><00:09:51.200><c></span> <span>snow</c><00:09:51.480><c></span> <span>and</c><00:09:51.600><c></span> <span>the</c><00:09:51.680><c></span> <span>powder</c><00:09:51.959><c></span> <span>is</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 444, 592.069, 0.0, 'realized no the snow and the powder is', '', '', '<span>realized</span> <span>no</span> <span>the</span> <span>snow</span> <span>and</span> <span>the</span> <span>powder</span> <span>is</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 445, 592.079, 0.0, 'realized no the snow and the powder is just<00:09:52.279><c> incredible</c><00:09:52.839><c> of</c><00:09:52.959><c> course</c><00:09:53.160><c> I</c><00:09:53.360><c> feel</c><00:09:53.480><c> like</c><00:09:53.600><c> a</c>', '', '', '<span>realized</span> <span>no</span> <span>the</span> <span>snow</span> <span>and</span> <span>the</span> <span>powder</span> <span>is</span> <span>just<00:09:52.279><c></span> <span>incredible</c><00:09:52.839><c></span> <span>of</c><00:09:52.959><c></span> <span>course</c><00:09:53.160><c></span> <span>I</c><00:09:53.360><c></span> <span>feel</c><00:09:53.480><c></span> <span>like</c><00:09:53.600><c></span> <span>a</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 446, 593.67, 0.0, 'just incredible of course I feel like a', '', '', '<span>just</span> <span>incredible</span> <span>of</span> <span>course</span> <span>I</span> <span>feel</span> <span>like</span> <span>a</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 447, 593.68, 0.0, 'just incredible of course I feel like a good<00:09:53.800><c> skier</c><00:09:54.480><c> and</c><00:09:54.680><c> when</c><00:09:54.800><c> you</c><00:09:54.920><c> play</c><00:09:55.160><c> tennis</c>', '', '', '<span>just</span> <span>incredible</span> <span>of</span> <span>course</span> <span>I</span> <span>feel</span> <span>like</span> <span>a</span> <span>good<00:09:53.800><c></span> <span>skier</c><00:09:54.480><c></span> <span>and</c><00:09:54.680><c></span> <span>when</c><00:09:54.800><c></span> <span>you</c><00:09:54.920><c></span> <span>play</c><00:09:55.160><c></span> <span>tennis</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 448, 595.47, 0.0, 'good skier and when you play tennis', '', '', '<span>good</span> <span>skier</span> <span>and</span> <span>when</span> <span>you</span> <span>play</span> <span>tennis</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 449, 595.48, 0.0, 'good skier and when you play tennis against<00:09:55.720><c> someone</c><00:09:55.920><c> who''s</c><00:09:56.079><c> better</c><00:09:56.279><c> than</c><00:09:56.440><c> you</c><00:09:56.560><c> it</c>', '', '', '<span>good</span> <span>skier</span> <span>and</span> <span>when</span> <span>you</span> <span>play</span> <span>tennis</span> <span>against<00:09:55.720><c></span> <span>someone</c><00:09:55.920><c></span> <span>who''s</c><00:09:56.079><c></span> <span>better</c><00:09:56.279><c></span> <span>than</c><00:09:56.440><c></span> <span>you</c><00:09:56.560><c></span> <span>it</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 450, 596.71, 0.0, 'against someone who''s better than you it', '', '', '<span>against</span> <span>someone</span> <span>who''s</span> <span>better</span> <span>than</span> <span>you</span> <span>it</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 451, 596.72, 0.0, 'against someone who''s better than you it like<00:09:56.920><c> elevates</c><00:09:57.360><c> your</c><00:09:57.560><c> game</c><00:09:58.040><c> and</c><00:09:58.160><c> So</c><00:09:58.480><c> He</c>', '', '', '<span>against</span> <span>someone</span> <span>who''s</span> <span>better</span> <span>than</span> <span>you</span> <span>it</span> <span>like<00:09:56.920><c></span> <span>elevates</c><00:09:57.360><c></span> <span>your</c><00:09:57.560><c></span> <span>game</c><00:09:58.040><c></span> <span>and</c><00:09:58.160><c></span> <span>So</c><00:09:58.480><c></span> <span>He</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 452, 598.67, 0.0, 'like elevates your game and So He', '', '', '<span>like</span> <span>elevates</span> <span>your</span> <span>game</span> <span>and</span> <span>So</span> <span>He</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 453, 598.68, 0.0, 'like elevates your game and So He suggests<00:09:59.480><c> if</c><00:09:59.600><c> you</c><00:09:59.760><c> can</c><00:10:00.160><c> to</c><00:10:00.920><c> move</c><00:10:01.240><c> to</c><00:10:01.519><c> the</c>', '', '', '<span>like</span> <span>elevates</span> <span>your</span> <span>game</span> <span>and</span> <span>So</span> <span>He</span> <span>suggests<00:09:59.480><c></span> <span>if</c><00:09:59.600><c></span> <span>you</c><00:09:59.760><c></span> <span>can</c><00:10:00.160><c></span> <span>to</c><00:10:00.920><c></span> <span>move</c><00:10:01.240><c></span> <span>to</c><00:10:01.519><c></span> <span>the</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 454, 601.71, 0.0, 'suggests if you can to move to the', '', '', '<span>suggests</span> <span>if</span> <span>you</span> <span>can</span> <span>to</span> <span>move</span> <span>to</span> <span>the</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 455, 601.72, 0.0, 'suggests if you can to move to the Aspens<00:10:02.240><c> of</c><00:10:02.360><c> the</c><00:10:02.440><c> world</c><00:10:02.720><c> not</c><00:10:03.000><c> actually</c><00:10:03.279><c> Aspen</c>', '', '', '<span>suggests</span> <span>if</span> <span>you</span> <span>can</span> <span>to</span> <span>move</span> <span>to</span> <span>the</span> <span>Aspens<00:10:02.240><c></span> <span>of</c><00:10:02.360><c></span> <span>the</c><00:10:02.440><c></span> <span>world</c><00:10:02.720><c></span> <span>not</c><00:10:03.000><c></span> <span>actually</c><00:10:03.279><c></span> <span>Aspen</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 456, 603.949, 0.0, 'Aspens of the world not actually Aspen', '', '', '<span>Aspens</span> <span>of</span> <span>the</span> <span>world</span> <span>not</span> <span>actually</span> <span>Aspen</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 457, 603.959, 0.0, 'Aspens of the world not actually Aspen but<00:10:04.240><c> you</c><00:10:04.360><c> know</c><00:10:04.720><c> the</c><00:10:04.920><c> places</c><00:10:05.519><c> where</c><00:10:05.800><c> you</c><00:10:05.920><c> were</c>', '', '', '<span>Aspens</span> <span>of</span> <span>the</span> <span>world</span> <span>not</span> <span>actually</span> <span>Aspen</span> <span>but<00:10:04.240><c></span> <span>you</c><00:10:04.360><c></span> <span>know</c><00:10:04.720><c></span> <span>the</c><00:10:04.920><c></span> <span>places</c><00:10:05.519><c></span> <span>where</c><00:10:05.800><c></span> <span>you</c><00:10:05.920><c></span> <span>were</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 458, 606.069, 0.0, 'but you know the places where you were', '', '', '<span>but</span> <span>you</span> <span>know</span> <span>the</span> <span>places</span> <span>where</span> <span>you</span> <span>were</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 459, 606.079, 0.0, 'but you know the places where you were forced<00:10:06.399><c> to</c><00:10:06.560><c> elevate</c><00:10:06.880><c> your</c><00:10:07.079><c> game</c><00:10:07.399><c> or</c><00:10:07.560><c> where</c><00:10:07.680><c> it</c>', '', '', '<span>but</span> <span>you</span> <span>know</span> <span>the</span> <span>places</span> <span>where</span> <span>you</span> <span>were</span> <span>forced<00:10:06.399><c></span> <span>to</c><00:10:06.560><c></span> <span>elevate</c><00:10:06.880><c></span> <span>your</c><00:10:07.079><c></span> <span>game</c><00:10:07.399><c></span> <span>or</c><00:10:07.560><c></span> <span>where</c><00:10:07.680><c></span> <span>it</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 460, 607.79, 0.0, 'forced to elevate your game or where it', '', '', '<span>forced</span> <span>to</span> <span>elevate</span> <span>your</span> <span>game</span> <span>or</span> <span>where</span> <span>it</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 461, 607.8, 0.0, 'forced to elevate your game or where it gives<00:10:08.000><c> you</c><00:10:08.120><c> the</c><00:10:08.279><c> opportunity</c><00:10:08.760><c> to</c><00:10:08.920><c> do</c><00:10:09.079><c> so</c><00:10:09.360><c> and</c>', '', '', '<span>forced</span> <span>to</span> <span>elevate</span> <span>your</span> <span>game</span> <span>or</span> <span>where</span> <span>it</span> <span>gives<00:10:08.000><c></span> <span>you</c><00:10:08.120><c></span> <span>the</c><00:10:08.279><c></span> <span>opportunity</c><00:10:08.760><c></span> <span>to</c><00:10:08.920><c></span> <span>do</c><00:10:09.079><c></span> <span>so</c><00:10:09.360><c></span> <span>and</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 462, 609.43, 0.0, 'gives you the opportunity to do so and', '', '', '<span>gives</span> <span>you</span> <span>the</span> <span>opportunity</span> <span>to</span> <span>do</span> <span>so</span> <span>and</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 463, 609.44, 0.0, 'gives you the opportunity to do so and he<00:10:09.519><c> says</c><00:10:09.720><c> a</c><00:10:09.920><c> place</c><00:10:10.079><c> like</c><00:10:10.240><c> New</c><00:10:10.399><c> York</c><00:10:10.680><c> is</c><00:10:10.839><c> where</c>', '', '', '<span>gives</span> <span>you</span> <span>the</span> <span>opportunity</span> <span>to</span> <span>do</span> <span>so</span> <span>and</span> <span>he<00:10:09.519><c></span> <span>says</c><00:10:09.720><c></span> <span>a</c><00:10:09.920><c></span> <span>place</c><00:10:10.079><c></span> <span>like</c><00:10:10.240><c></span> <span>New</c><00:10:10.399><c></span> <span>York</c><00:10:10.680><c></span> <span>is</c><00:10:10.839><c></span> <span>where</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 464, 610.99, 0.0, 'he says a place like New York is where', '', '', '<span>he</span> <span>says</span> <span>a</span> <span>place</span> <span>like</span> <span>New</span> <span>York</span> <span>is</span> <span>where</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 465, 611.0, 0.0, 'he says a place like New York is where you''re<00:10:11.240><c> playing</c><00:10:11.560><c> against</c><00:10:11.800><c> Serena</c><00:10:12.240><c> Williams</c>', '', '', '<span>he</span> <span>says</span> <span>a</span> <span>place</span> <span>like</span> <span>New</span> <span>York</span> <span>is</span> <span>where</span> <span>you''re<00:10:11.240><c></span> <span>playing</c><00:10:11.560><c></span> <span>against</c><00:10:11.800><c></span> <span>Serena</c><00:10:12.240><c></span> <span>Williams</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 466, 612.91, 0.0, 'you''re playing against Serena Williams', '', '', '<span>you''re</span> <span>playing</span> <span>against</span> <span>Serena</span> <span>Williams</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 467, 612.92, 0.0, 'you''re playing against Serena Williams all<00:10:13.079><c> the</c><00:10:13.279><c> time</c><00:10:14.279><c> very</c><00:10:14.480><c> metaphorical</c><00:10:15.040><c> here</c><00:10:15.160><c> but</c>', '', '', '<span>you''re</span> <span>playing</span> <span>against</span> <span>Serena</span> <span>Williams</span> <span>all<00:10:13.079><c></span> <span>the</c><00:10:13.279><c></span> <span>time</c><00:10:14.279><c></span> <span>very</c><00:10:14.480><c></span> <span>metaphorical</c><00:10:15.040><c></span> <span>here</c><00:10:15.160><c></span> <span>but</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 468, 615.35, 0.0, 'all the time very metaphorical here but', '', '', '<span>all</span> <span>the</span> <span>time</span> <span>very</span> <span>metaphorical</span> <span>here</span> <span>but</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 469, 615.36, 0.0, 'all the time very metaphorical here but the<00:10:15.480><c> point</c><00:10:15.800><c> is</c><00:10:16.160><c> we</c><00:10:16.279><c> are</c><00:10:16.519><c> surrounded</c><00:10:17.040><c> all</c><00:10:17.279><c> day</c>', '', '', '<span>all</span> <span>the</span> <span>time</span> <span>very</span> <span>metaphorical</span> <span>here</span> <span>but</span> <span>the<00:10:15.480><c></span> <span>point</c><00:10:15.800><c></span> <span>is</c><00:10:16.160><c></span> <span>we</c><00:10:16.279><c></span> <span>are</c><00:10:16.519><c></span> <span>surrounded</c><00:10:17.040><c></span> <span>all</c><00:10:17.279><c></span> <span>day</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 470, 617.67, 0.0, 'the point is we are surrounded all day', '', '', '<span>the</span> <span>point</span> <span>is</span> <span>we</span> <span>are</span> <span>surrounded</span> <span>all</span> <span>day</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 471, 617.68, 0.0, 'the point is we are surrounded all day by<00:10:17.880><c> people</c><00:10:18.160><c> who</c><00:10:18.320><c> are</c><00:10:18.480><c> taking</c><00:10:18.760><c> risks</c><00:10:19.120><c> or</c>', '', '', '<span>the</span> <span>point</span> <span>is</span> <span>we</span> <span>are</span> <span>surrounded</span> <span>all</span> <span>day</span> <span>by<00:10:17.880><c></span> <span>people</c><00:10:18.160><c></span> <span>who</c><00:10:18.320><c></span> <span>are</c><00:10:18.480><c></span> <span>taking</c><00:10:18.760><c></span> <span>risks</c><00:10:19.120><c></span> <span>or</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 472, 619.31, 0.0, 'by people who are taking risks or', '', '', '<span>by</span> <span>people</span> <span>who</span> <span>are</span> <span>taking</span> <span>risks</span> <span>or</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 473, 619.32, 0.0, 'by people who are taking risks or working<00:10:19.640><c> hard</c><00:10:19.959><c> or</c><00:10:20.120><c> who</c><00:10:20.279><c> are</c><00:10:20.519><c> smart</c><00:10:21.040><c> that</c><00:10:21.160><c> just</c>', '', '', '<span>by</span> <span>people</span> <span>who</span> <span>are</span> <span>taking</span> <span>risks</span> <span>or</span> <span>working<00:10:19.640><c></span> <span>hard</c><00:10:19.959><c></span> <span>or</c><00:10:20.120><c></span> <span>who</c><00:10:20.279><c></span> <span>are</c><00:10:20.519><c></span> <span>smart</c><00:10:21.040><c></span> <span>that</c><00:10:21.160><c></span> <span>just</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 474, 621.35, 0.0, 'working hard or who are smart that just', '', '', '<span>working</span> <span>hard</span> <span>or</span> <span>who</span> <span>are</span> <span>smart</span> <span>that</span> <span>just</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 475, 621.36, 0.0, 'working hard or who are smart that just rubs<00:10:21.760><c> off</c><00:10:21.920><c> on</c><00:10:22.079><c> you</c><00:10:22.240><c> whether</c><00:10:22.440><c> you</c><00:10:22.560><c> realize</c><00:10:22.880><c> it</c>', '', '', '<span>working</span> <span>hard</span> <span>or</span> <span>who</span> <span>are</span> <span>smart</span> <span>that</span> <span>just</span> <span>rubs<00:10:21.760><c></span> <span>off</c><00:10:21.920><c></span> <span>on</c><00:10:22.079><c></span> <span>you</c><00:10:22.240><c></span> <span>whether</c><00:10:22.440><c></span> <span>you</c><00:10:22.560><c></span> <span>realize</c><00:10:22.880><c></span> <span>it</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 476, 622.99, 0.0, 'rubs off on you whether you realize it', '', '', '<span>rubs</span> <span>off</span> <span>on</span> <span>you</span> <span>whether</span> <span>you</span> <span>realize</span> <span>it</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 477, 623.0, 0.0, 'rubs off on you whether you realize it or<00:10:23.120><c> not</c><00:10:23.519><c> and</c><00:10:23.839><c> yeah</c><00:10:24.000><c> I</c><00:10:24.120><c> just</c><00:10:24.240><c> don''t</c><00:10:24.480><c> think</c><00:10:24.680><c> that</c>', '', '', '<span>rubs</span> <span>off</span> <span>on</span> <span>you</span> <span>whether</span> <span>you</span> <span>realize</span> <span>it</span> <span>or<00:10:23.120><c></span> <span>not</c><00:10:23.519><c></span> <span>and</c><00:10:23.839><c></span> <span>yeah</c><00:10:24.000><c></span> <span>I</c><00:10:24.120><c></span> <span>just</c><00:10:24.240><c></span> <span>don''t</c><00:10:24.480><c></span> <span>think</c><00:10:24.680><c></span> <span>that</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 478, 624.829, 0.0, 'or not and yeah I just don''t think that', '', '', '<span>or</span> <span>not</span> <span>and</span> <span>yeah</span> <span>I</span> <span>just</span> <span>don''t</span> <span>think</span> <span>that</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 479, 624.839, 0.0, 'or not and yeah I just don''t think that there<00:10:25.200><c> is</c><00:10:25.560><c> a</c><00:10:25.720><c> substitute</c><00:10:26.360><c> for</c><00:10:26.720><c> the</c>', '', '', '<span>or</span> <span>not</span> <span>and</span> <span>yeah</span> <span>I</span> <span>just</span> <span>don''t</span> <span>think</span> <span>that</span> <span>there<00:10:25.200><c></span> <span>is</c><00:10:25.560><c></span> <span>a</c><00:10:25.720><c></span> <span>substitute</c><00:10:26.360><c></span> <span>for</c><00:10:26.720><c></span> <span>the</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 480, 626.829, 0.0, 'there is a substitute for the', '', '', '<span>there</span> <span>is</span> <span>a</span> <span>substitute</span> <span>for</span> <span>the</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 481, 626.839, 0.0, 'there is a substitute for the connections<00:10:27.320><c> and</c><00:10:27.560><c> opportunities</c><00:10:28.200><c> and</c><00:10:28.440><c> energy</c>', '', '', '<span>there</span> <span>is</span> <span>a</span> <span>substitute</span> <span>for</span> <span>the</span> <span>connections<00:10:27.320><c></span> <span>and</c><00:10:27.560><c></span> <span>opportunities</c><00:10:28.200><c></span> <span>and</c><00:10:28.440><c></span> <span>energy</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 482, 628.79, 0.0, 'connections and opportunities and energy', '', '', '<span>connections</span> <span>and</span> <span>opportunities</span> <span>and</span> <span>energy</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 483, 628.8, 0.0, 'connections and opportunities and energy that<00:10:28.880><c> you</c><00:10:29.000><c> get</c><00:10:29.360><c> from</c><00:10:29.920><c> living</c><00:10:30.279><c> here</c><00:10:30.519><c> in</c><00:10:30.640><c> your</c>', '', '', '<span>connections</span> <span>and</span> <span>opportunities</span> <span>and</span> <span>energy</span> <span>that<00:10:28.880><c></span> <span>you</c><00:10:29.000><c></span> <span>get</c><00:10:29.360><c></span> <span>from</c><00:10:29.920><c></span> <span>living</c><00:10:30.279><c></span> <span>here</c><00:10:30.519><c></span> <span>in</c><00:10:30.640><c></span> <span>your</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 484, 630.79, 0.0, 'that you get from living here in your', '', '', '<span>that</span> <span>you</span> <span>get</span> <span>from</span> <span>living</span> <span>here</span> <span>in</span> <span>your</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 485, 630.8, 0.0, 'that you get from living here in your 20s<00:10:31.399><c> and</c><00:10:31.519><c> of</c><00:10:31.680><c> course</c><00:10:31.880><c> I</c><00:10:32.000><c> think</c><00:10:32.120><c> you</c><00:10:32.200><c> can</c><00:10:32.360><c> Thrive</c>', '', '', '<span>that</span> <span>you</span> <span>get</span> <span>from</span> <span>living</span> <span>here</span> <span>in</span> <span>your</span> <span>20s<00:10:31.399><c></span> <span>and</c><00:10:31.519><c></span> <span>of</c><00:10:31.680><c></span> <span>course</c><00:10:31.880><c></span> <span>I</c><00:10:32.000><c></span> <span>think</c><00:10:32.120><c></span> <span>you</c><00:10:32.200><c></span> <span>can</c><00:10:32.360><c></span> <span>Thrive</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 486, 632.75, 0.0, '20s and of course I think you can Thrive', '', '', '<span>20s</span> <span>and</span> <span>of</span> <span>course</span> <span>I</span> <span>think</span> <span>you</span> <span>can</span> <span>Thrive</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 487, 632.76, 0.0, '20s and of course I think you can Thrive here<00:10:33.000><c> at</c><00:10:33.200><c> any</c><00:10:33.519><c> age</c><00:10:33.800><c> you</c><00:10:33.920><c> know</c><00:10:34.640><c> it</c><00:10:34.760><c> feels</c><00:10:35.040><c> kind</c>', '', '', '<span>20s</span> <span>and</span> <span>of</span> <span>course</span> <span>I</span> <span>think</span> <span>you</span> <span>can</span> <span>Thrive</span> <span>here<00:10:33.000><c></span> <span>at</c><00:10:33.200><c></span> <span>any</c><00:10:33.519><c></span> <span>age</c><00:10:33.800><c></span> <span>you</c><00:10:33.920><c></span> <span>know</c><00:10:34.640><c></span> <span>it</c><00:10:34.760><c></span> <span>feels</c><00:10:35.040><c></span> <span>kind</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 488, 635.15, 0.0, 'here at any age you know it feels kind', '', '', '<span>here</span> <span>at</span> <span>any</span> <span>age</span> <span>you</span> <span>know</span> <span>it</span> <span>feels</span> <span>kind</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 489, 635.16, 0.0, 'here at any age you know it feels kind of<00:10:35.279><c> agis</c><00:10:35.760><c> to</c><00:10:36.079><c> say</c><00:10:36.480><c> in</c><00:10:36.600><c> your</c><00:10:36.720><c> 20s</c><00:10:37.040><c> all</c><00:10:37.160><c> the</c><00:10:37.360><c> time</c>', '', '', '<span>here</span> <span>at</span> <span>any</span> <span>age</span> <span>you</span> <span>know</span> <span>it</span> <span>feels</span> <span>kind</span> <span>of<00:10:35.279><c></span> <span>agis</c><00:10:35.760><c></span> <span>to</c><00:10:36.079><c></span> <span>say</c><00:10:36.480><c></span> <span>in</c><00:10:36.600><c></span> <span>your</c><00:10:36.720><c></span> <span>20s</c><00:10:37.040><c></span> <span>all</c><00:10:37.160><c></span> <span>the</c><00:10:37.360><c></span> <span>time</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 490, 637.67, 0.0, 'of agis to say in your 20s all the time', '', '', '<span>of</span> <span>agis</span> <span>to</span> <span>say</span> <span>in</span> <span>your</span> <span>20s</span> <span>all</span> <span>the</span> <span>time</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 491, 637.68, 0.0, 'of agis to say in your 20s all the time but<00:10:37.920><c> at</c><00:10:38.040><c> the</c><00:10:38.120><c> same</c><00:10:38.279><c> time</c><00:10:38.440><c> it</c><00:10:38.560><c> is</c><00:10:38.800><c> probably</c><00:10:39.079><c> in</c>', '', '', '<span>of</span> <span>agis</span> <span>to</span> <span>say</span> <span>in</span> <span>your</span> <span>20s</span> <span>all</span> <span>the</span> <span>time</span> <span>but<00:10:37.920><c></span> <span>at</c><00:10:38.040><c></span> <span>the</c><00:10:38.120><c></span> <span>same</c><00:10:38.279><c></span> <span>time</c><00:10:38.440><c></span> <span>it</c><00:10:38.560><c></span> <span>is</c><00:10:38.800><c></span> <span>probably</c><00:10:39.079><c></span> <span>in</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 492, 639.19, 0.0, 'but at the same time it is probably in', '', '', '<span>but</span> <span>at</span> <span>the</span> <span>same</span> <span>time</span> <span>it</span> <span>is</span> <span>probably</span> <span>in</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 493, 639.2, 0.0, 'but at the same time it is probably in your<00:10:39.320><c> 20s</c><00:10:39.839><c> before</c><00:10:40.040><c> you</c><00:10:40.120><c> have</c><00:10:40.240><c> a</c><00:10:40.360><c> family</c><00:10:40.680><c> that</c>', '', '', '<span>but</span> <span>at</span> <span>the</span> <span>same</span> <span>time</span> <span>it</span> <span>is</span> <span>probably</span> <span>in</span> <span>your<00:10:39.320><c></span> <span>20s</c><00:10:39.839><c></span> <span>before</c><00:10:40.040><c></span> <span>you</c><00:10:40.120><c></span> <span>have</c><00:10:40.240><c></span> <span>a</c><00:10:40.360><c></span> <span>family</c><00:10:40.680><c></span> <span>that</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 494, 640.79, 0.0, 'your 20s before you have a family that', '', '', '<span>your</span> <span>20s</span> <span>before</span> <span>you</span> <span>have</span> <span>a</span> <span>family</span> <span>that</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 495, 640.8, 0.0, 'your 20s before you have a family that you''re<00:10:40.959><c> down</c><00:10:41.120><c> to</c><00:10:41.240><c> live</c><00:10:41.360><c> in</c><00:10:41.440><c> a</c><00:10:41.519><c> 400t</c><00:10:42.360><c> apartment</c>', '', '', '<span>your</span> <span>20s</span> <span>before</span> <span>you</span> <span>have</span> <span>a</span> <span>family</span> <span>that</span> <span>you''re<00:10:40.959><c></span> <span>down</c><00:10:41.120><c></span> <span>to</c><00:10:41.240><c></span> <span>live</c><00:10:41.360><c></span> <span>in</c><00:10:41.440><c></span> <span>a</c><00:10:41.519><c></span> <span>400t</c><00:10:42.360><c></span> <span>apartment</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 496, 642.87, 0.0, 'you''re down to live in a 400t apartment', '', '', '<span>you''re</span> <span>down</span> <span>to</span> <span>live</span> <span>in</span> <span>a</span> <span>400t</span> <span>apartment</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 497, 642.88, 0.0, 'you''re down to live in a 400t apartment and<00:10:43.279><c> you</c><00:10:43.399><c> know</c><00:10:43.519><c> things</c><00:10:43.720><c> get</c><00:10:43.920><c> expensive</c><00:10:44.320><c> when</c>', '', '', '<span>you''re</span> <span>down</span> <span>to</span> <span>live</span> <span>in</span> <span>a</span> <span>400t</span> <span>apartment</span> <span>and<00:10:43.279><c></span> <span>you</c><00:10:43.399><c></span> <span>know</c><00:10:43.519><c></span> <span>things</c><00:10:43.720><c></span> <span>get</c><00:10:43.920><c></span> <span>expensive</c><00:10:44.320><c></span> <span>when</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 498, 644.43, 0.0, 'and you know things get expensive when', '', '', '<span>and</span> <span>you</span> <span>know</span> <span>things</span> <span>get</span> <span>expensive</span> <span>when</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 499, 644.44, 0.0, 'and you know things get expensive when you<00:10:44.519><c> start</c><00:10:44.720><c> feeding</c><00:10:45.079><c> a</c><00:10:45.160><c> couple</c><00:10:45.440><c> more</c><00:10:45.560><c> mouths</c>', '', '', '<span>and</span> <span>you</span> <span>know</span> <span>things</span> <span>get</span> <span>expensive</span> <span>when</span> <span>you<00:10:44.519><c></span> <span>start</c><00:10:44.720><c></span> <span>feeding</c><00:10:45.079><c></span> <span>a</c><00:10:45.160><c></span> <span>couple</c><00:10:45.440><c></span> <span>more</c><00:10:45.560><c></span> <span>mouths</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 500, 646.11, 0.0, 'you start feeding a couple more mouths', '', '', '<span>you</span> <span>start</span> <span>feeding</span> <span>a</span> <span>couple</span> <span>more</span> <span>mouths</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 501, 646.12, 0.0, 'you start feeding a couple more mouths so<00:10:46.639><c> that''s</c><00:10:46.760><c> why</c><00:10:46.880><c> I</c><00:10:46.959><c> say</c><00:10:47.120><c> 20s</c><00:10:47.600><c> anyways</c><00:10:47.920><c> I</c><00:10:48.000><c> will</c>', '', '', '<span>you</span> <span>start</span> <span>feeding</span> <span>a</span> <span>couple</span> <span>more</span> <span>mouths</span> <span>so<00:10:46.639><c></span> <span>that''s</c><00:10:46.760><c></span> <span>why</c><00:10:46.880><c></span> <span>I</c><00:10:46.959><c></span> <span>say</c><00:10:47.120><c></span> <span>20s</c><00:10:47.600><c></span> <span>anyways</c><00:10:47.920><c></span> <span>I</c><00:10:48.000><c></span> <span>will</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 502, 648.15, 0.0, 'so that''s why I say 20s anyways I will', '', '', '<span>so</span> <span>that''s</span> <span>why</span> <span>I</span> <span>say</span> <span>20s</span> <span>anyways</span> <span>I</span> <span>will</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 503, 648.16, 0.0, 'so that''s why I say 20s anyways I will get<00:10:48.279><c> off</c><00:10:48.399><c> my</c><00:10:48.480><c> soap</c><00:10:48.800><c> box</c><00:10:49.000><c> I</c><00:10:49.079><c> feel</c><00:10:49.240><c> like</c><00:10:49.519><c> I</c>', '', '', '<span>so</span> <span>that''s</span> <span>why</span> <span>I</span> <span>say</span> <span>20s</span> <span>anyways</span> <span>I</span> <span>will</span> <span>get<00:10:48.279><c></span> <span>off</c><00:10:48.399><c></span> <span>my</c><00:10:48.480><c></span> <span>soap</c><00:10:48.800><c></span> <span>box</c><00:10:49.000><c></span> <span>I</c><00:10:49.079><c></span> <span>feel</c><00:10:49.240><c></span> <span>like</c><00:10:49.519><c></span> <span>I</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 504, 650.03, 0.0, 'get off my soap box I feel like I', '', '', '<span>get</span> <span>off</span> <span>my</span> <span>soap</span> <span>box</span> <span>I</span> <span>feel</span> <span>like</span> <span>I</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 505, 650.04, 0.0, 'get off my soap box I feel like I deliver<00:10:50.440><c> some</c><00:10:50.639><c> Grand</c><00:10:50.959><c> Soliloquy</c><00:10:51.800><c> professing</c>', '', '', '<span>get</span> <span>off</span> <span>my</span> <span>soap</span> <span>box</span> <span>I</span> <span>feel</span> <span>like</span> <span>I</span> <span>deliver<00:10:50.440><c></span> <span>some</c><00:10:50.639><c></span> <span>Grand</c><00:10:50.959><c></span> <span>Soliloquy</c><00:10:51.800><c></span> <span>professing</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 506, 652.269, 0.0, 'deliver some Grand Soliloquy professing', '', '', '<span>deliver</span> <span>some</span> <span>Grand</span> <span>Soliloquy</span> <span>professing</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 507, 652.279, 0.0, 'deliver some Grand Soliloquy professing my<00:10:52.440><c> love</c><00:10:52.639><c> for</c><00:10:52.800><c> New</c><00:10:52.959><c> York</c><00:10:53.160><c> in</c><00:10:53.320><c> every</c><00:10:53.480><c> single</c>', '', '', '<span>deliver</span> <span>some</span> <span>Grand</span> <span>Soliloquy</span> <span>professing</span> <span>my<00:10:52.440><c></span> <span>love</c><00:10:52.639><c></span> <span>for</c><00:10:52.800><c></span> <span>New</c><00:10:52.959><c></span> <span>York</c><00:10:53.160><c></span> <span>in</c><00:10:53.320><c></span> <span>every</c><00:10:53.480><c></span> <span>single</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 508, 653.79, 0.0, 'my love for New York in every single', '', '', '<span>my</span> <span>love</span> <span>for</span> <span>New</span> <span>York</span> <span>in</span> <span>every</span> <span>single</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 509, 653.8, 0.0, 'my love for New York in every single video<00:10:54.240><c> but</c><00:10:55.000><c> it''s</c><00:10:55.320><c> how</c><00:10:55.440><c> I</c><00:10:55.560><c> feel</c>', '', '', '<span>my</span> <span>love</span> <span>for</span> <span>New</span> <span>York</span> <span>in</span> <span>every</span> <span>single</span> <span>video<00:10:54.240><c></span> <span>but</c><00:10:55.000><c></span> <span>it''s</c><00:10:55.320><c></span> <span>how</c><00:10:55.440><c></span> <span>I</c><00:10:55.560><c></span> <span>feel</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 510, 669.629, 0.0, 'got a dopam rush got a major leag Crush', '', '', '<span>got</span> <span>a</span> <span>dopam</span> <span>rush</span> <span>got</span> <span>a</span> <span>major</span> <span>leag</span> <span>Crush</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 511, 669.639, 0.0, 'got a dopam rush got a major leag Crush when<00:11:09.800><c> you''re</c><00:11:10.079><c> next</c><00:11:10.279><c> to</c>', '', '', '<span>got</span> <span>a</span> <span>dopam</span> <span>rush</span> <span>got</span> <span>a</span> <span>major</span> <span>leag</span> <span>Crush</span> <span>when<00:11:09.800><c></span> <span>you''re</c><00:11:10.079><c></span> <span>next</c><00:11:10.279><c></span> <span>to</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 512, 672.269, 0.0, 'when you''re next to', '', '', '<span>when</span> <span>you''re</span> <span>next</span> <span>to</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 513, 672.279, 0.0, 'when you''re next to me<00:11:13.279><c> got</c><00:11:13.480><c> my</c><00:11:13.680><c> heart</c><00:11:13.959><c> up</c><00:11:14.160><c> on</c><00:11:14.399><c> my</c><00:11:14.560><c> sleeve</c><00:11:15.120><c> can</c><00:11:15.279><c> I</c>', '', '', '<span>when</span> <span>you''re</span> <span>next</span> <span>to</span> <span>me<00:11:13.279><c></span> <span>got</c><00:11:13.480><c></span> <span>my</c><00:11:13.680><c></span> <span>heart</c><00:11:13.959><c></span> <span>up</c><00:11:14.160><c></span> <span>on</c><00:11:14.399><c></span> <span>my</c><00:11:14.560><c></span> <span>sleeve</c><00:11:15.120><c></span> <span>can</c><00:11:15.279><c></span> <span>I</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 514, 675.59, 0.0, 'me got my heart up on my sleeve can I', '', '', '<span>me</span> <span>got</span> <span>my</span> <span>heart</span> <span>up</span> <span>on</span> <span>my</span> <span>sleeve</span> <span>can</span> <span>I</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 515, 675.6, 0.0, 'me got my heart up on my sleeve can I hide<00:11:15.920><c> the</c><00:11:16.079><c> way</c><00:11:16.279><c> I</c><00:11:16.480><c> feel</c><00:11:16.959><c> when</c><00:11:17.079><c> you''re</c><00:11:17.360><c> next</c><00:11:17.560><c> to</c>', '', '', '<span>me</span> <span>got</span> <span>my</span> <span>heart</span> <span>up</span> <span>on</span> <span>my</span> <span>sleeve</span> <span>can</span> <span>I</span> <span>hide<00:11:15.920><c></span> <span>the</c><00:11:16.079><c></span> <span>way</c><00:11:16.279><c></span> <span>I</c><00:11:16.480><c></span> <span>feel</c><00:11:16.959><c></span> <span>when</c><00:11:17.079><c></span> <span>you''re</c><00:11:17.360><c></span> <span>next</c><00:11:17.560><c></span> <span>to</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 516, 677.79, 0.0, 'hide the way I feel when you''re next to', '', '', '<span>hide</span> <span>the</span> <span>way</span> <span>I</span> <span>feel</span> <span>when</span> <span>you''re</span> <span>next</span> <span>to</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 517, 677.8, 0.0, 'hide the way I feel when you''re next to me', '', '', '<span>hide</span> <span>the</span> <span>way</span> <span>I</span> <span>feel</span> <span>when</span> <span>you''re</span> <span>next</span> <span>to</span> <span>me</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 518, 679.509, 0.0, 'me', '', '', '<span>me</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 519, 679.519, 0.0, 'me girl<00:11:20.519><c> that</c><00:11:20.639><c> was</c><00:11:20.760><c> a</c><00:11:20.920><c> proper</c><00:11:21.240><c> main</c><00:11:21.480><c> character</c>', '', '', '<span>me</span> <span>girl<00:11:20.519><c></span> <span>that</c><00:11:20.639><c></span> <span>was</c><00:11:20.760><c></span> <span>a</c><00:11:20.920><c></span> <span>proper</c><00:11:21.240><c></span> <span>main</c><00:11:21.480><c></span> <span>character</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 520, 681.829, 0.0, 'girl that was a proper main character', '', '', '<span>girl</span> <span>that</span> <span>was</span> <span>a</span> <span>proper</span> <span>main</span> <span>character</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 521, 681.839, 0.0, 'girl that was a proper main character moment<00:11:22.639><c> that''s</c><00:11:22.839><c> where</c><00:11:22.959><c> we</c><00:11:23.120><c> got</c><00:11:23.279><c> to</c><00:11:23.399><c> end</c><00:11:23.839><c> like</c>', '', '', '<span>girl</span> <span>that</span> <span>was</span> <span>a</span> <span>proper</span> <span>main</span> <span>character</span> <span>moment<00:11:22.639><c></span> <span>that''s</c><00:11:22.839><c></span> <span>where</c><00:11:22.959><c></span> <span>we</c><00:11:23.120><c></span> <span>got</c><00:11:23.279><c></span> <span>to</c><00:11:23.399><c></span> <span>end</c><00:11:23.839><c></span> <span>like</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 522, 683.99, 0.0, 'moment that''s where we got to end like', '', '', '<span>moment</span> <span>that''s</span> <span>where</span> <span>we</span> <span>got</span> <span>to</span> <span>end</span> <span>like</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 523, 684.0, 0.0, 'moment that''s where we got to end like And<00:11:24.200><c> subscribe</c><00:11:24.600><c> for</c><00:11:24.720><c> $0</c><00:11:25.399><c> and</c><00:11:25.560><c> until</c><00:11:25.880><c> next</c><00:11:26.079><c> time</c>', '', '', '<span>moment</span> <span>that''s</span> <span>where</span> <span>we</span> <span>got</span> <span>to</span> <span>end</span> <span>like</span> <span>And<00:11:24.200><c></span> <span>subscribe</c><00:11:24.600><c></span> <span>for</c><00:11:24.720><c></span> <span>$0</c><00:11:25.399><c></span> <span>and</c><00:11:25.560><c></span> <span>until</c><00:11:25.880><c></span> <span>next</c><00:11:26.079><c></span> <span>time</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 524, 686.31, 0.0, 'And subscribe for $0 and until next time', '', '', '<span>And</span> <span>subscribe</span> <span>for</span> <span>$0</span> <span>and</span> <span>until</span> <span>next</span> <span>time</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 525, 686.32, 0.0, 'And subscribe for $0 and until next time turtle', '', '', '<span>And</span> <span>subscribe</span> <span>for</span> <span>$0</span> <span>and</span> <span>until</span> <span>next</span> <span>time</span> <span>turtle</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 526, 688.069, 0.0, 'turtle', '', '', '<span>turtle</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 527, 688.079, 0.0, 'turtle out<00:11:29.079><c> guys</c>', '', '', '<span>turtle</span> <span>out<00:11:29.079><c></span> <span>guys</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 528, 707.269, 0.0, '[Music]', '', '', '<span>[Music]</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 529, 707.279, 0.0, '[Music] York<00:11:48.279><c> cheers</c>', '', '', '<span>[Music]</span> <span>York<00:11:48.279><c></span> <span>cheers</c></span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 530, 709.87, 0.0, 'York cheers', '', '', '<span>York</span> <span>cheers</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 531, 709.88, 0.0, 'York cheers [Music]', '', '', '<span>York</span> <span>cheers</span> <span>[Music]</span>'
FROM episodes e WHERE e.video_id = 'LgYY-X3UwLxRpx4';

-- episode 130: 130mCl4CJRRAC9Q
INSERT INTO episodes (
  index, video_id, short_title, summary, remark, stars, voca_size,
  subtitle_count, clip_length, cover, video_url, audio_url, thumbnail_url,
  original_video_url, author_id, submitted_by_user_id, rejection_reason,
  created_at, is_demo, status, published_at
) VALUES (
  130, '130mCl4CJRRAC9Q', '分享5条人生经验（29岁前必看）',
  'Miki在29岁生日之际分享的五条感悟：主张活在当下，告别匮乏感并拥抱丰盈心态；强调除努力外更需主动争取机会与人脉；鼓励勇敢开口请求；并提醒审慎对待他人的建议与批评。', '不是毒鸡汤，请放心食用',
  3, 174, 77,
  207.92, 'http://oss.sxakgs.com/en/130mCl4CJRRAC9Q/cover.webp',
  'http://oss.sxakgs.com/en/130mCl4CJRRAC9Q/video.mp4', 'http://oss.sxakgs.com/en/130mCl4CJRRAC9Q/audio.mp3',
  'http://oss.sxakgs.com/en/130mCl4CJRRAC9Q/cover.webp', 'https://www.youtube.com/watch?v=KyYfiPCgaOk',
  (SELECT id FROM authors WHERE name = 'Miki Rai' AND accent = '美国' LIMIT 1),
  NULL, NULL,
  '2026-06-30 14:57:30'::timestamp,
  FALSE, 'published',
  '2026-06-30 14:57:30'::timestamp
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
  SELECT s.id FROM subtitles s JOIN episodes e ON s.episode_id = e.id WHERE e.video_id = '130mCl4CJRRAC9Q'
);
DELETE FROM subtitles WHERE episode_id = (SELECT id FROM episodes WHERE video_id = '130mCl4CJRRAC9Q');
DELETE FROM episode_tags WHERE episode_id = (SELECT id FROM episodes WHERE video_id = '130mCl4CJRRAC9Q');

INSERT INTO episode_tags (episode_id, tag_id)
SELECT e.id, t.id FROM episodes e, tags t
WHERE e.video_id = '130mCl4CJRRAC9Q' AND t.name = '建议'
ON CONFLICT DO NOTHING;
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 1, 0.0, 1.1400000000000001, 'Today is my birthday.', '今天是我的生日。', '/tədeɪ ɪz maɪ bɜːθdeɪ./', '<span tid="283">Today</span><span>is</span><span>my</span><span tid="286">birthday.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 2, 1.1400000000000001, 3.54, 'It is December 19th, my actual birthday.', '12月19日，我真正的出生日。', '/ɪɾ ɪz dᵻsɛmbɚ naɪntiːnθ, maɪ æktʃuːəl bɜːθdeɪ./', '<span>It</span><span>is</span><span tid="289">December</span><span tid="290">19th,</span><span>my</span><span tid="292">actual</span><span tid="293">birthday.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 3, 3.54, 6.7, 'Because I have a December birthday, it is towards the end of the year.', '因为我的生日在12月，刚好是在年底。', '/bɪkʌz aɪ hæv ɐ dᵻsɛmbɚ bɜːθdeɪ, ɪɾ ɪz təwɔːɹdz ðɪ ɛnd ʌvðə jɪɹ./', '<span>Because</span><span>I</span><span>have</span><span>a</span><span tid="298">December</span><span tid="299">birthday,</span><span>it</span><span>is</span><span tid="302">towards</span><span>the</span><span tid="304">end</span><span>of</span><span>the</span><span tid="307">year.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 4, 6.7, 9.02, 'And that is when I like to do a lot of my reflections.', '这也是我喜欢进行大量反思总结的时候。', '/ænd ðæt ɪz wɛn aɪ laɪk tə duː ɐ lɑːt ʌv maɪ ɹᵻflɛkʃənz./', '<span>And</span><span>that</span><span>is</span><span>when</span><span>I</span><span>like</span><span>to</span><span>do</span><span>a</span><span tid="317">lot</span><span>of</span><span>my</span><span tid="320" class="highlight highlight-a">reflections.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 5, 9.02, 12.3, 'I actually wrote down 29 lessons that I learned before 29.', '我特地写下了在29岁之前学到的29条人生经验。', '/aɪ æktʃuːəli ɹoʊt daʊn twɛnti naɪn lɛsənz ðæt aɪ lɜːnd bᵻfɔːɹ twɛnti naɪn./', '<span>I</span><span tid="322">actually</span><span pid="909" class="highlight highlight-d">wrote down</span><span>29</span><span tid="326" class="highlight highlight-a">lessons</span><span>that</span><span>I</span><span tid="329">learned</span><span tid="330">before</span><span>29.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 6, 12.3, 14.7, 'It''s just going to be a very raw, honest video.', '这将会是一段非常真实、坦诚的视频。', '/ɪts dʒʌst ɡoʊɪŋ təbi ɐ vɛɹi ɹɔː, ɑːnɪst vɪdɪoʊ./', '<span>It''s</span><span>just</span><span>going</span><span>to</span><span>be</span><span>a</span><span>very</span><span tid="339" class="highlight highlight-a">raw,</span><span tid="340">honest</span><span tid="341">video.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 7, 14.7, 16.3, 'I have it just on a Google Doc.', '我就把它记录在了一份谷歌文档里。', '/aɪ hæv ɪt dʒʌst ɔn ɐ ɡuːɡəl dɑːk./', '<span>I</span><span>have</span><span>it</span><span>just</span><span>on</span><span>a</span><span tid="348">Google</span><span tid="349">Doc.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 8, 16.3, 18.22, 'I just wanted to share these lessons with you.', '我只是想和你们分享这些心得。', '/aɪ dʒʌst wɔntᵻd tə ʃɛɹ ðiːz lɛsənz wɪð juː./', '<span>I</span><span>just</span><span>wanted</span><span>to</span><span tid="354" class="highlight highlight-a">share</span><span>these</span><span tid="356" class="highlight highlight-a">lessons</span><span>with</span><span>you.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 9, 18.22, 20.94, 'In case maybe you''re learning the same things that I am.', '以防万一你们也正在经历和我一样的成长。', '/ɪn keɪs meɪbiː jʊɹ lɜːnɪŋ ðə seɪm θɪŋz ðæt aɪæm./', '<span>In</span><span tid="360" class="highlight highlight-a">case</span><span tid="361">maybe</span><span>you''re</span><span tid="363">learning</span><span>the</span><span tid="365">same</span><span>things</span><span>that</span><span>I</span><span>am.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 10, 20.94, 24.18, 'Perhaps some of these lessons can save you from some of the pain that I went through.', '也许其中的某些经验能让你少走弯路，少吃我吃过的苦。', '/pɚhæps sʌm ʌv ðiːz lɛsənz kæn seɪv juː fɹʌm sʌm ʌvðə peɪn ðæt aɪ wɛnt θɹuː./', '<span tid="370" class="highlight highlight-a">Perhaps</span><span>some</span><span>of</span><span>these</span><span tid="374" class="highlight highlight-a">lessons</span><span>can</span><span tid="376">save</span><span>you</span><span>from</span><span>some</span><span>of</span><span>the</span><span tid="382">pain</span><span>that</span><span>I</span><span pid="908" class="highlight highlight-d">went through.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 11, 24.18, 26.84, 'If you want to wish me a happy birthday, I''d really appreciate it.', '如果你想祝我生日快乐，我会非常感激。', '/ɪf juː wɔnt tə wɪʃ miː ɐ hæpi bɜːθdeɪ, aɪd ɹiəli ɐpɹiːʃɪeɪt ɪt./', '<span>If</span><span>you</span><span>want</span><span>to</span><span tid="391">wish</span><span>me</span><span>a</span><span tid="394">happy</span><span tid="395">birthday,</span><span>I''d</span><span tid="397">really</span><span tid="398" class="highlight highlight-a">appreciate</span><span>it.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 12, 26.84, 29.42, 'If you gave this video a thumbs up, but here are the lessons.', '也希望你能给这段视频点个赞，下面就是我要分享的经验。', '/ɪf juː ɡeɪv ðɪs vɪdɪoʊ ɐ θʌmz ʌp, bʌt hɪɹ ɑːɹ ðə lɛsənz./', '<span>If</span><span>you</span><span pid="915" class="highlight highlight-f">gave this video a thumbs up,</span><span>but</span><span>here</span><span>are</span><span>the</span><span tid="412" class="highlight highlight-a">lessons.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 13, 29.42, 30.58, 'Let''s jump right into it.', '让我们直接进入正题。', '/lɛts dʒʌmp ɹaɪt ɪntʊ ɪt./', '<span>Let''s</span><span tid="414">jump</span><span tid="415" class="highlight highlight-a">right</span><span tid="416" class="highlight highlight-a">into</span><span>it.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 14, 30.58, 33.56, 'Number one, stop saving everything for a special occasion.', '第一条，别再把好东西都留到“特殊场合”了。', '/nʌmbɚ wʌn, stɑːp seɪvɪŋ ɛvɹɪθɪŋ fɚɹə spɛʃəl əkeɪʒən./', '<span tid="418">Number</span><span>one,</span><span tid="420">stop</span><span tid="421">saving</span><span tid="422">everything</span><span>for</span><span>a</span><span pid="916" class="highlight highlight-c">special occasion.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 15, 33.56, 36.72, 'Do you remember being a kid and having those sticker books?', '你还记得小时候收集的那些贴纸本吗？', '/duː juː ɹᵻmɛmbɚ biːɪŋ ɐ kɪd ænd hævɪŋ ðoʊz stɪkɚ bʊks?/', '<span>Do</span><span>you</span><span tid="429">remember</span><span>being</span><span>a</span><span tid="432">kid</span><span>and</span><span>having</span><span>those</span><span tid="436" class="highlight highlight-a">sticker</span><span tid="437">books?</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 16, 36.72, 38.84, 'Where you would save all of your favorite stickers.', '你总是把最喜欢的贴纸藏着不舍得用。', '/wɛɹ juː wʊd seɪv ɔːl ʌv jʊɹ feɪvɚɹᵻt stɪkɚz./', '<span>Where</span><span>you</span><span>would</span><span tid="441">save</span><span>all</span><span>of</span><span>your</span><span tid="445">favorite</span><span tid="446" class="highlight highlight-a">stickers.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 17, 38.84, 40.78, 'I recently went back to my parents'' house.', '最近我回了趟父母家。', '/aɪ ɹiːsəntli wɛnt bæk tə maɪ pɛɹənts haʊs./', '<span>I</span><span tid="448">recently</span><span>went</span><span tid="450" class="highlight highlight-a">back</span><span>to</span><span>my</span><span tid="453">parents''</span><span tid="454">house.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 18, 40.78, 45.76, 'And I saw all of those unused stickers that I was saving for some special occasion.', '看到那些为了所谓“特殊场合”攒下的贴纸，至今都没派上用场。', '/ænd aɪ sɔː ɔːl ʌv ðoʊz ʌnjuːzd stɪkɚz ðæt aɪ wʌz seɪvɪŋ fɔːɹ sʌm spɛʃəl əkeɪʒən./', '<span>And</span><span>I</span><span tid="457">saw</span><span>all</span><span>of</span><span>those</span><span tid="461" class="highlight highlight-a">unused</span><span tid="462" class="highlight highlight-a">stickers</span><span>that</span><span>I</span><span>was</span><span tid="466">saving</span><span>for</span><span>some</span><span pid="917" class="highlight highlight-c">special occasion.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 19, 45.76, 50.62, 'But I always felt too scared to just enjoy the thing and use it in that moment.', '但我当时总是太害怕，不敢直接享受并用掉它。', '/bʌt aɪ ɔːlweɪz fɛlt tuː skɛɹd tə dʒʌst ɛndʒɔɪ ðə θɪŋ ænd juːs ɪɾ ɪn ðæt moʊmənt./', '<span>But</span><span>I</span><span tid="473">always</span><span tid="474">felt</span><span>too</span><span tid="476">scared</span><span>to</span><span>just</span><span tid="479">enjoy</span><span>the</span><span>thing</span><span>and</span><span tid="483">use</span><span>it</span><span>in</span><span>that</span><span tid="487" class="highlight highlight-a">moment.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 20, 50.62, 54.36, 'Like I personally am guilty of holding on to my special matcha powder.', '就像我个人也会犯这种错，总把特级的抹茶粉存着。', '/laɪk aɪ pɜːsənəli ɐm ɡɪlti ʌv hoʊldɪŋ ɔn tə maɪ spɛʃəl mætʃə paʊdɚ./', '<span>Like</span><span>I</span><span tid="490" class="highlight highlight-a">personally</span><span>am</span><span pid="918" class="highlight highlight-c">guilty of</span><span tid="494">holding</span><span>on</span><span>to</span><span>my</span><span tid="498">special</span><span tid="499" class="highlight highlight-a">matcha</span><span tid="500" class="highlight highlight-a">powder.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 21, 54.36, 58.94, 'And I realized that some of the special ones I''ve been hoarding are actually expired now.', '结果我意识到，那些我一直囤着的宝贝其实已经过期了。', '/ænd aɪ ɹiːəlaɪzd ðæt sʌm ʌvðə spɛʃəl wʌnz aɪv bɪn hɔːɹdɪŋ ɑːɹ æktʃuːəli ɛkspaɪɚd naʊ./', '<span>And</span><span>I</span><span tid="503" class="highlight highlight-a">realized</span><span>that</span><span>some</span><span>of</span><span>the</span><span tid="508">special</span><span>ones</span><span>I''ve</span><span>been</span><span tid="512">hoarding</span><span>are</span><span tid="514">actually</span><span tid="515" class="highlight highlight-a">expired</span><span tid="516">now.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 22, 58.94, 62.24, 'Because I was so scared to just run out of it and not have it anymore.', '就因为我太害怕用完它，害怕以后没有了。', '/bɪkʌz aɪ wʌz soʊ skɛɹd tə dʒʌst ɹʌn aʊɾəv ɪt ænd nɑːɾɐv ɪɾ ɛnɪmɔːɹ./', '<span>Because</span><span>I</span><span>was</span><span>so</span><span tid="521">scared</span><span>to</span><span>just</span><span pid="907" class="highlight highlight-d">run out of</span><span>it</span><span>and</span><span>not</span><span>have</span><span>it</span><span tid="532">anymore.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 23, 62.24, 64.12, 'What I learned is that tomorrow is never promised.', '我学到的是，明天永远是未知的。', '/wʌt aɪ lɜːnd ɪz ðæt təmɑːɹoʊ ɪz nɛvɚ pɹɑːmɪst./', '<span>What</span><span>I</span><span tid="535">learned</span><span>is</span><span>that</span><span tid="538">tomorrow</span><span>is</span><span tid="540">never</span><span tid="541">promised.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 24, 64.12, 65.88, 'Just enjoy your life today.', '所以，今天就尽情享受你的生活。', '/dʒʌst ɛndʒɔɪ jʊɹ laɪf tədeɪ./', '<span>Just</span><span tid="543">enjoy</span><span>your</span><span tid="545">life</span><span tid="546">today.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 25, 65.88, 68.42, 'There will be very few instances where you regret that.', '你很少会因为享受当下而感到后悔。', '/ðɛɹ wɪl biː vɛɹi fjuː ɪnstənsᵻz wɛɹ juː ɹᵻɡɹɛt ðæt./', '<span>There</span><span>will</span><span>be</span><span>very</span><span tid="551">few</span><span tid="552">instances</span><span>where</span><span>you</span><span tid="555" class="highlight highlight-a">regret</span><span>that.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 26, 68.42, 71.0, 'Number two, learn to grow out of a scarcity mindset.', '第二条，学会摆脱“匮乏心态/稀缺思维”。', '/nʌmbɚ tuː, lɜːn tə ɡɹoʊ aʊɾəv ɐ skɛɹsᵻɾi maɪndsɛt./', '<span tid="557">Number</span><span>two,</span><span tid="559">learn</span><span>to</span><span pid="919" class="highlight highlight-d">grow out of</span><span>a</span><span pid="920" class="highlight highlight-c">scarcity mindset.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 27, 71.0, 72.84, 'And shift to an abundance mindset.', '并转变为“丰盛心态/富足思维”。', '/ænd ʃɪft tʊ ɐn ɐbʌndəns maɪndsɛt./', '<span>And</span><span tid="568" class="highlight highlight-a">shift</span><span>to</span><span>an</span><span pid="922" class="highlight highlight-c">abundance mindset.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 28, 72.84, 75.88, 'What you believe mentally manifests into your reality.', '你的潜意识信念会显化为你的现实。', '/wʌt juː bᵻliːv mɛntəli mænɪfɛsts ɪntʊ jʊɹ ɹɪælᵻɾi./', '<span>What</span><span>you</span><span tid="575">believe</span><span tid="576" class="highlight highlight-a">mentally</span><span tid="577" class="highlight highlight-a">manifests</span><span tid="578" class="highlight highlight-a">into</span><span>your</span><span tid="580">reality.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 29, 75.88, 77.94, 'So if you believe that you are not capable of something.', '所以如果你相信自己没能力做某事。', '/soʊ ɪf juː bᵻliːv ðæt juː ɑːɹ nɑːt keɪpəbəl ʌv sʌmθɪŋ./', '<span>So</span><span>if</span><span>you</span><span tid="584">believe</span><span>that</span><span>you</span><span>are</span><span>not</span><span pid="911" class="highlight highlight-c">capable of</span><span>something.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 30, 77.94, 80.52, 'Then you really do become incapable of that thing.', '那你真的会变得无法胜任那件事。', '/ðɛn juː ɹiəli duː bɪkʌm ɪŋkeɪpəbəl ʌv ðæt θɪŋ./', '<span>Then</span><span>you</span><span tid="594">really</span><span>do</span><span tid="596">become</span><span tid="597" class="highlight highlight-a">incapable</span><span>of</span><span>that</span><span>thing.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 31, 80.52, 82.66, 'People always say, delulu is the solulu.', '人们总说，敢于幻想就是成功的秘诀。', '/piːpəl ɔːlweɪz seɪ, dəːluːluː ɪz ɐ səluːluː./', '<span tid="601">People</span><span tid="602">always</span><span tid="603">say,</span><span pid="924" class="highlight highlight-i">delulu is the solulu.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 32, 82.66, 85.1, 'I don''t believe in being completely delusional.', '我不主张完全脱离现实。', '/aɪ doʊnt bᵻliːv ɪn biːɪŋ kəmpliːtli dᵻluːʒənəl./', '<span>I</span><span>don''t</span><span tid="610">believe</span><span>in</span><span>being</span><span tid="613" class="highlight highlight-a">completely</span><span tid="614" class="highlight highlight-a">delusional.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 33, 85.1, 86.7, 'Like I''m a very realistic person.', '因为我是一个非常务实的人。', '/laɪk aɪm ɐ vɛɹi ɹiːəlɪstɪk pɜːsən./', '<span>Like</span><span>I''m</span><span>a</span><span>very</span><span tid="619" class="highlight highlight-a">realistic</span><span tid="620">person.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 34, 86.7, 91.42, 'I do think there is some value in having more confidence and believing in yourself.', '但我确实认为，多一点自信、多相信自己是有价值的。', '/aɪ duː θɪŋk ðɛɹ ɪz sʌm væljuː ɪn hævɪŋ mɔːɹ kɑːnfɪdəns ænd bᵻliːvɪŋ ɪn jɔːɹsɛlf./', '<span>I</span><span>do</span><span>think</span><span>there</span><span>is</span><span>some</span><span tid="627">value</span><span>in</span><span>having</span><span>more</span><span tid="631">confidence</span><span>and</span><span tid="633">believing</span><span>in</span><span tid="635">yourself.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 35, 91.42, 95.52, 'Now, scarcity mindset, especially if you are coming from an immigrant family.', '说到匮乏心态，尤其是如果你来自移民家庭。', '/naʊ, skɛɹsᵻɾi maɪndsɛt, ɪspɛʃəli ɪf juː ɑːɹ kʌmɪŋ fɹʌm ɐn ɪmɪɡɹənt fæmɪli./', '<span tid="636">Now,</span><span pid="921" class="highlight highlight-c">scarcity mindset,</span><span tid="639" class="highlight highlight-a">especially</span><span>if</span><span>you</span><span>are</span><span tid="643">coming</span><span>from</span><span>an</span><span tid="646" class="highlight highlight-a">immigrant</span><span tid="647">family.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 36, 95.52, 98.52, 'I think we''re always taught to save, save, save.', '我觉得我们从小被教育要省、省、省。', '/aɪ θɪŋk wɪɹ ɔːlweɪz tɔːt tə seɪv, seɪv, seɪv./', '<span>I</span><span>think</span><span>we''re</span><span tid="651">always</span><span tid="652">taught</span><span>to</span><span tid="654">save,</span><span tid="655">save,</span><span tid="656">save.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 37, 98.52, 100.5, 'Stability is the most important thing.', '稳定才是最重要的。', '/stəbɪlᵻɾi ɪz ðə moʊst ɪmpɔːɹtənt θɪŋ./', '<span tid="657" class="highlight highlight-a">Stability</span><span>is</span><span>the</span><span tid="660">most</span><span tid="661">important</span><span>thing.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 38, 100.5, 103.26, 'And a lot of our beliefs are kind of centered around fear.', '所以我们的很多信念其实是围绕着“恐惧”建立的。', '/ænd ɐ lɑːt ʌv aʊɚ bᵻliːfs ɑːɹ kaɪnd ʌv sɛntɚd ɚɹaʊnd fɪɹ./', '<span>And</span><span>a</span><span tid="665">lot</span><span>of</span><span>our</span><span tid="668" class="highlight highlight-a">beliefs</span><span>are</span><span tid="670">kind</span><span>of</span><span tid="672">centered</span><span tid="673">around</span><span tid="674">fear.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 39, 103.26, 105.98, 'But what I''ve learned is that when you live in fear.', '但我学到的是，当你生活在恐惧中时。', '/bʌt wʌt aɪv lɜːnd ɪz ðæt wɛn juː lɪv ɪn fɪɹ./', '<span>But</span><span>what</span><span>I''ve</span><span tid="678">learned</span><span>is</span><span>that</span><span>when</span><span>you</span><span tid="683">live</span><span>in</span><span tid="685">fear.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 40, 105.98, 109.64, 'It often doesn''t allow these bigger, better things to come into your life.', '它往往会挡住那些更好、更大的机遇进入你的生活。', '/ɪɾ ɔfən dʌzənt ɐlaʊ ðiːz bɪɡɚ, bɛɾɚ θɪŋz tə kʌm ɪntʊ jʊɹ laɪf./', '<span>It</span><span tid="687">often</span><span>doesn''t</span><span tid="689">allow</span><span>these</span><span tid="691">bigger,</span><span tid="692">better</span><span>things</span><span>to</span><span tid="695">come</span><span tid="696" class="highlight highlight-a">into</span><span>your</span><span tid="698">life.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 41, 109.64, 112.4, 'So I highly encourage you to adopt an abundance mindset.', '所以我强烈建议你建立丰盛心态。', '/soʊ aɪ haɪli ɛŋkɜːɹɪdʒ juː tʊ ɐdɑːpt ɐn ɐbʌndəns maɪndsɛt./', '<span>So</span><span>I</span><span tid="701">highly</span><span tid="702">encourage</span><span>you</span><span>to</span><span tid="705" class="highlight highlight-a">adopt</span><span>an</span><span pid="923" class="highlight highlight-c">abundance mindset.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 42, 112.4, 114.9, 'And make room for those bigger things that you''ve been wanting.', '为那些你一直渴望的大事腾出空间。', '/ænd meɪk ɹuːm fɔːɹ ðoʊz bɪɡɚ θɪŋz ðæt juːv bɪn wɔntɪŋ./', '<span>And</span><span tid="710">make</span><span tid="711">room</span><span>for</span><span>those</span><span tid="714">bigger</span><span>things</span><span>that</span><span>you''ve</span><span>been</span><span>wanting.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 43, 114.9, 117.14, 'Number three, this is a hard truth that I learned.', '第三条，这是我学到的一个残酷事实。', '/nʌmbɚ θɹiː, ðɪs ɪz ɐ hɑːɹd tɹuːθ ðæt aɪ lɜːnd./', '<span tid="720">Number</span><span>three,</span><span>this</span><span>is</span><span>a</span><span pid="925" class="highlight highlight-c">hard truth</span><span>that</span><span>I</span><span tid="729">learned.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 44, 117.14, 120.42, 'Opportunity almost never goes to the most deserving person.', '机会几乎从不青睐那些“最应得”的人。', '/ɑːpɚtuːnᵻɾi ɔːlmoʊst nɛvɚ ɡoʊz tə ðə moʊst dɪzɜːvɪŋ pɜːsən./', '<span tid="730">Opportunity</span><span tid="731">almost</span><span tid="732">never</span><span>goes</span><span>to</span><span>the</span><span tid="736">most</span><span tid="737">deserving</span><span tid="738">person.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 45, 120.42, 124.4, 'Have you ever looked at a situation and felt like objectively you worked harder?', '你有没有遇到过这种情况：客观上你更努力？', '/hæv juː ɛvɚ lʊkt æɾə sɪtʃuːeɪʃən ænd fɛlt laɪk ɑːbdʒɛktɪvli juː wɜːkt hɑːɹdɚ?/', '<span>Have</span><span>you</span><span tid="741" class="highlight highlight-a">ever</span><span tid="742" class="highlight highlight-a">looked</span><span>at</span><span>a</span><span tid="745" class="highlight highlight-a">situation</span><span>and</span><span tid="747">felt</span><span>like</span><span tid="749" class="highlight highlight-a">objectively</span><span>you</span><span pid="926" class="highlight highlight-c">worked harder?</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 46, 124.4, 128.22, 'You put in more time, but that opportunity ended up going to someone else.', '你付出了更多时间，但机会最后却落到了别人头上。', '/juː pʊt ɪn mɔːɹ taɪm, bʌt ðæt ɑːpɚtuːnᵻɾi ɛndᵻd ʌp ɡoʊɪŋ tə sʌmwʌn ɛls./', '<span>You</span><span tid="754">put</span><span>in</span><span>more</span><span tid="757">time,</span><span>but</span><span>that</span><span tid="760">opportunity</span><span tid="761">ended</span><span>up</span><span>going</span><span>to</span><span tid="765">someone</span><span tid="766">else.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 47, 128.22, 131.0, 'I always thought that if I just put my head down and do the work.', '我以前总觉得，只要我埋头苦干。', '/aɪ ɔːlweɪz θɔːt ðæt ɪf aɪ dʒʌst pʊt maɪ hɛd daʊn ænd duː ðə wɜːk./', '<span>I</span><span tid="768">always</span><span>thought</span><span>that</span><span>if</span><span>I</span><span>just</span><span pid="927" class="highlight highlight-f">put my head down and do the work.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 48, 131.0, 132.56, 'Then it will speak for itself.', '成果自然会证明一切。', '/ðɛn ɪt wɪl spiːk fɔːɹ ɪtsɛlf./', '<span>Then</span><span>it</span><span>will</span><span pid="928" class="highlight highlight-f">speak for itself.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 49, 132.56, 135.92, 'And I will then become eligible to get whatever thing I''m aiming for.', '然后我自然就有资格得到我想要的东西。', '/ænd aɪ wɪl ðɛn bɪkʌm ɛlɪdʒəbəl tə ɡɛt wʌtɛvɚ θɪŋ aɪm eɪmɪŋ fɔːɹ./', '<span>And</span><span>I</span><span>will</span><span>then</span><span tid="792">become</span><span tid="793" class="highlight highlight-a">eligible</span><span>to</span><span>get</span><span tid="796" class="highlight highlight-a">whatever</span><span>thing</span><span>I''m</span><span pid="929" class="highlight highlight-d">aiming for.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 50, 135.92, 137.66, 'Society does not usually work like that.', '但社会通常不是这样运作的。', '/səsaɪəɾi dʌznɑːt juːʒuːəli wɜːk laɪk ðæt./', '<span tid="801">Society</span><span>does</span><span>not</span><span tid="804">usually</span><span tid="805">work</span><span>like</span><span>that.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 51, 137.66, 140.9, 'Humble work alone won''t really get you very far.', '只知道默默耕耘并不会让你走得很远。', '/hʌmbəl wɜːk ɐloʊn woʊnt ɹiəli ɡɛt juː vɛɹi fɑːɹ./', '<span tid="808" class="highlight highlight-a">Humble</span><span tid="809">work</span><span tid="810">alone</span><span>won''t</span><span tid="812">really</span><span>get</span><span>you</span><span>very</span><span tid="816">far.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 52, 140.9, 144.2, 'For a lot of us, it is not in our nature to talk about the things that we do.', '对我们很多人来说，宣扬自己做过的事并不符合天性。', '/fɚɹə lɑːt ʌv ʌs, ɪɾ ɪz nɑːt ɪn aʊɚ neɪtʃɚ tə tɔːk ɐbaʊt ðə θɪŋz ðæt wiː duː./', '<span>For</span><span>a</span><span tid="819">lot</span><span>of</span><span>us,</span><span>it</span><span>is</span><span>not</span><span>in</span><span>our</span><span tid="827">nature</span><span>to</span><span tid="829">talk</span><span>about</span><span>the</span><span>things</span><span>that</span><span>we</span><span>do.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 53, 144.2, 145.58, 'Or the things that we are contributing.', '或者不习惯展示我们贡献了什么。', '/ɔːɹ ðə θɪŋz ðæt wiː ɑːɹ kəntɹɪbjuːɾɪŋ./', '<span>Or</span><span>the</span><span>things</span><span>that</span><span>we</span><span>are</span><span tid="842">contributing.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 54, 145.58, 150.16, 'Because we want to assume that other people, our bosses, our coworkers, will just notice.', '因为我们总假设别人，比如老板、同事，会察觉到。', '/bɪkʌz wiː wɔnt tʊ ɐsuːm ðæt ʌðɚ piːpəl, aʊɚ bɔsᵻz, aʊɚ koʊwɜːkɚz, wɪl dʒʌst noʊɾɪs./', '<span>Because</span><span>we</span><span>want</span><span>to</span><span tid="847" class="highlight highlight-a">assume</span><span>that</span><span tid="849">other</span><span tid="850">people,</span><span>our</span><span tid="852">bosses,</span><span>our</span><span tid="854" class="highlight highlight-a">coworkers,</span><span>will</span><span>just</span><span tid="857" class="highlight highlight-a">notice.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 55, 150.16, 151.84, 'That we are going above and beyond.', '察觉到我们付出了超常的努力。', '/ðæt wiː ɑːɹ ɡoʊɪŋ əbʌv ænd bᵻjɔnd./', '<span>That</span><span>we</span><span>are</span><span>going</span><span tid="862">above</span><span>and</span><span tid="864" class="highlight highlight-a">beyond.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 56, 151.84, 154.6, 'And sometimes they do, but a lot of the times they don''t.', '有时候他们确实会注意到，但很多时候并不会。', '/ænd sʌmtaɪmz ðeɪ duː, bʌt ɐ lɑːt ʌvðə taɪmz ðeɪ doʊnt./', '<span>And</span><span tid="866">sometimes</span><span>they</span><span>do,</span><span>but</span><span>a</span><span tid="871">lot</span><span>of</span><span>the</span><span tid="874">times</span><span>they</span><span>don''t.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 57, 154.6, 156.74, 'Or they don''t even know half of the things that you''re doing.', '甚至他们连你做的一半工作都不知道。', '/ɔːɹ ðeɪ doʊnt iːvən noʊ hæf ʌvðə θɪŋz ðæt jʊɹ duːɪŋ./', '<span>Or</span><span>they</span><span>don''t</span><span tid="880">even</span><span>know</span><span tid="882">half</span><span>of</span><span>the</span><span>things</span><span>that</span><span>you''re</span><span>doing.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 58, 156.74, 161.74, 'So it''s really your responsibility to gently remind them of what you have done.', '所以，你有责任适时地提醒他们你所做的贡献。', '/soʊ ɪts ɹiəli jʊɹ ɹᵻspɑːnsəbɪlᵻɾi tə dʒɛntli ɹᵻmaɪnd ðɛm ʌv wʌt juː hæv dʌn./', '<span>So</span><span>it''s</span><span tid="891">really</span><span>your</span><span tid="893" class="highlight highlight-a">responsibility</span><span>to</span><span tid="895">gently</span><span tid="896" class="highlight highlight-a">remind</span><span>them</span><span>of</span><span>what</span><span>you</span><span>have</span><span>done.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 59, 161.74, 163.5, 'It''s not that they don''t want to notice.', '并不是他们不想关注你。', '/ɪts nɑːt ðæt ðeɪ doʊnt wɔnt tə noʊɾɪs./', '<span>It''s</span><span>not</span><span>that</span><span>they</span><span>don''t</span><span>want</span><span>to</span><span tid="910" class="highlight highlight-a">notice.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 60, 163.5, 167.22, 'But the truth is that everyone is very preoccupied with their own lives.', '事实是，每个人都忙于自己的生活。', '/bʌt ðə tɹuːθ ɪz ðæt ɛvɹɪwʌn ɪz vɛɹi pɹɪɑːkjʊpaɪd wɪð ðɛɹ oʊn laɪvz./', '<span>But</span><span pid="930" class="highlight highlight-i">the truth is that</span><span tid="916">everyone</span><span>is</span><span>very</span><span tid="919" class="highlight highlight-a">preoccupied</span><span>with</span><span>their</span><span tid="922" class="highlight highlight-a">own</span><span tid="923">lives.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 61, 167.22, 169.4, 'Their own deadlines and things that they''re working on.', '忙于自己的截止日期和手头的工作。', '/ðɛɹ oʊn dɛdlaɪnz ænd θɪŋz ðæt ðeɪɚ wɜːkɪŋ ɔn./', '<span>Their</span><span tid="925" class="highlight highlight-a">own</span><span tid="926" class="highlight highlight-a">deadlines</span><span>and</span><span>things</span><span>that</span><span>they''re</span><span tid="931">working</span><span>on.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 62, 169.4, 170.54, 'So it''s up to you to speak up.', '所以，必须由你自己主动发声。', '/soʊ ɪts ʌp tə juː tə spiːk ʌp./', '<span>So</span><span pid="913" class="highlight highlight-i">it''s up to you</span><span>to</span><span pid="910" class="highlight highlight-d">speak up.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 63, 170.54, 172.34, 'Also at the end of the day, we are human.', '而且归根结底，我们都是社会性动物。', '/ɔːlsoʊ æt ðɪ ɛnd ʌvðə deɪ, wiː ɑːɹ hjuːmən./', '<span>Also</span><span pid="914" class="highlight highlight-f">at the end of the day,</span><span>we</span><span>are</span><span tid="950">human.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 64, 172.34, 175.02, 'So who you know, how you know them, how you treat them.', '所以你认识谁、怎么认识的、你如何对待他们。', '/soʊ huː juː noʊ, haʊ juː noʊ ðɛm, haʊ juː tɹiːt ðɛm./', '<span>So</span><span>who</span><span>you</span><span>know,</span><span>how</span><span>you</span><span>know</span><span>them,</span><span>how</span><span>you</span><span tid="961" class="highlight highlight-a">treat</span><span>them.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 65, 175.02, 178.16, 'Will often be just as important as the work that you put in.', '这些往往和你付出的努力一样重要。', '/wɪl ɔfən biː dʒʌst æz ɪmpɔːɹtənt æz ðə wɜːk ðæt juː pʊt ɪn./', '<span>Will</span><span tid="964">often</span><span>be</span><span>just</span><span>as</span><span tid="968">important</span><span>as</span><span>the</span><span tid="971">work</span><span>that</span><span>you</span><span tid="974">put</span><span>in.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 66, 178.16, 179.94, 'Number four, it never hurts to ask.', '第四条，问一句总没坏处。', '/nʌmbɚ fɔːɹ, ɪt nɛvɚ hɜːts tʊ æsk./', '<span tid="976">Number</span><span>four,</span><span>it</span><span tid="979">never</span><span tid="980">hurts</span><span>to</span><span tid="982">ask.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 67, 179.94, 182.06, 'If you didn''t ask, the answer was already no.', '如果你不问，答案本来就是“不行”。', '/ɪf juː dɪdnt æsk, ðɪ ænsɚ wʌz ɔːlɹɛdi noʊ./', '<span>If</span><span>you</span><span>didn''t</span><span tid="986">ask,</span><span>the</span><span tid="988">answer</span><span>was</span><span tid="990">already</span><span>no.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 68, 182.06, 184.06, 'So you are losing nothing by asking.', '所以问一下你不会有任何损失。', '/soʊ juː ɑːɹ luːzɪŋ nʌθɪŋ baɪ æskɪŋ./', '<span>So</span><span>you</span><span>are</span><span tid="995">losing</span><span tid="996">nothing</span><span>by</span><span tid="998">asking.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 69, 184.06, 186.32, 'The outcome is the same even if they say no.', '就算被拒绝了，结果也没变得更糟。', '/ðɪ aʊtkʌm ɪz ðə seɪm iːvən ɪf ðeɪ seɪ noʊ./', '<span>The</span><span tid="1000" class="highlight highlight-a">outcome</span><span>is</span><span>the</span><span tid="1003">same</span><span tid="1004">even</span><span>if</span><span>they</span><span tid="1007">say</span><span>no.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 70, 186.32, 187.48, 'And don''t be afraid to get nos.', '不要害怕被拒绝。', '/ænd doʊnt biː ɐfɹeɪd tə ɡɛt nɑːs./', '<span>And</span><span>don''t</span><span>be</span><span tid="1012">afraid</span><span>to</span><span>get</span><span tid="1015">nos.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 71, 187.48, 191.56, 'I''ve gotten a lot of nos in my life, but also surprisingly a lot of yeses.', '我生命中听过很多“不行”，但出乎意料的是，也得到了很多“可以”。', '/aɪv ɡɑːʔn̩ ɐ lɑːt ʌv nɑːs ɪn maɪ laɪf, bʌt ɔːlsoʊ sɚpɹaɪzɪŋli ɐ lɑːt ʌv jɛsiːz./', '<span>I''ve</span><span>gotten</span><span>a</span><span tid="1019">lot</span><span>of</span><span tid="1021">nos</span><span>in</span><span>my</span><span tid="1024">life,</span><span>but</span><span>also</span><span tid="1027" class="highlight highlight-a">surprisingly</span><span>a</span><span tid="1029">lot</span><span>of</span><span>yeses.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 72, 191.56, 194.0, 'Number five, if you want to accept advice from someone.', '第五条，如果你想接受某人的建议。', '/nʌmbɚ faɪv, ɪf juː wɔnt tʊ ɐksɛpt ɐdvaɪs fɹʌm sʌmwʌn./', '<span tid="1032">Number</span><span>five,</span><span>if</span><span>you</span><span>want</span><span>to</span><span tid="1038">accept</span><span tid="1039">advice</span><span>from</span><span tid="1041">someone.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 73, 194.0, 196.26, 'Be cautious to also accept their criticism.', '请慎重决定是否也要接受他们的批评。', '/biː kɔːʃəs tʊ ɔːlsoʊ ɐksɛpt ðɛɹ kɹɪɾɪsɪzəm./', '<span>Be</span><span tid="1043">cautious</span><span>to</span><span>also</span><span tid="1046">accept</span><span>their</span><span tid="1048" class="highlight highlight-a">criticism.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 74, 196.26, 199.86, 'As the wise Taylor Swift said, think of your energy as expensive.', '就像睿智的泰勒·斯威夫特所说：要把你的能量看作昂贵的资产。', '/æz ðə waɪz teɪlɚ swɪft sɛd, θɪŋk ʌv jʊɹ ɛnɚdʒi æz ɛkspɛnsɪv./', '<span>As</span><span>the</span><span tid="1051" class="highlight highlight-a">wise</span><span tid="1052">Taylor</span><span tid="1053" class="highlight highlight-a">Swift</span><span tid="1054">said,</span><span>think</span><span>of</span><span>your</span><span tid="1058" class="highlight highlight-a">energy</span><span>as</span><span tid="1060">expensive.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 75, 199.86, 203.42, 'Not everyone has invested in you in order to be able to have the capital.', '不是每个人都对你投入了足够的精力和成本。', '/nɑːt ɛvɹɪwʌn hɐz ɪnvɛstᵻd ɪn juː ɪn ɔːɹdɚ təbi eɪbəl tə hæv ðə kæpɪɾəl./', '<span>Not</span><span tid="1062">everyone</span><span>has</span><span pid="931" class="highlight highlight-d">invested in</span><span>you</span><span>in</span><span tid="1068" class="highlight highlight-a">order</span><span>to</span><span>be</span><span tid="1071">able</span><span>to</span><span>have</span><span>the</span><span tid="1075">capital.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 76, 203.42, 205.44, 'For you to care about what they think.', '能让你去在意他们的看法。', '/fɔːɹ juː tə kɛɹ ɐbaʊt wʌt ðeɪ θɪŋk./', '<span>For</span><span>you</span><span>to</span><span tid="1079">care</span><span>about</span><span>what</span><span>they</span><span>think.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 77, 205.44, 207.92, 'I feel like I don''t even need to further explain that.', '我觉得这一条甚至不需要我再多做解释了。', '/aɪ fiːl laɪk aɪ doʊnt iːvən niːd tə fɜːðɚɹ ɛkspleɪn ðæt./', '<span>I</span><span tid="1085">feel</span><span>like</span><span>I</span><span>don''t</span><span tid="1089">even</span><span tid="1090">need</span><span>to</span><span tid="1092">further</span><span tid="1093" class="highlight highlight-a">explain</span><span>that.</span>'
FROM episodes e WHERE e.video_id = '130mCl4CJRRAC9Q';

-- episode 131: 131pRP2r5fuTOvP
INSERT INTO episodes (
  index, video_id, short_title, summary, remark, stars, voca_size,
  subtitle_count, clip_length, cover, video_url, audio_url, thumbnail_url,
  original_video_url, author_id, submitted_by_user_id, rejection_reason,
  created_at, is_demo, status, published_at
) VALUES (
  131, '131pRP2r5fuTOvP', '怎样活成自己的理想型',
  '用3%的小事去撬动97%的难事', '祝大家新的一年都能实现自己的目标',
  3, 107, 55,
  184.38, 'http://oss.sxakgs.com/en/131pRP2r5fuTOvP/cover.webp',
  'http://oss.sxakgs.com/en/131pRP2r5fuTOvP/video.mp4', 'http://oss.sxakgs.com/en/131pRP2r5fuTOvP/audio.mp3',
  'http://oss.sxakgs.com/en/131pRP2r5fuTOvP/cover.webp', 'https://www.youtube.com/watch?v=-clC6wopicA',
  (SELECT id FROM authors WHERE name = 'John Laurito' AND accent = '美国' LIMIT 1),
  NULL, NULL,
  '2026-06-30 15:00:39'::timestamp,
  FALSE, 'published',
  '2026-06-30 15:00:39'::timestamp
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
  SELECT s.id FROM subtitles s JOIN episodes e ON s.episode_id = e.id WHERE e.video_id = '131pRP2r5fuTOvP'
);
DELETE FROM subtitles WHERE episode_id = (SELECT id FROM episodes WHERE video_id = '131pRP2r5fuTOvP');
DELETE FROM episode_tags WHERE episode_id = (SELECT id FROM episodes WHERE video_id = '131pRP2r5fuTOvP');

INSERT INTO episode_tags (episode_id, tag_id)
SELECT e.id, t.id FROM episodes e, tags t
WHERE e.video_id = '131pRP2r5fuTOvP' AND t.name = '成长'
ON CONFLICT DO NOTHING;
INSERT INTO episode_tags (episode_id, tag_id)
SELECT e.id, t.id FROM episodes e, tags t
WHERE e.video_id = '131pRP2r5fuTOvP' AND t.name = '演讲'
ON CONFLICT DO NOTHING;
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 1, 0.0, 4.78, 'successful happy people focus on and think about the things that they can control.', '成功快乐的人会专注于并思考那些他们能够控制的事情。', '/səksɛsfəl hæpi piːpəl foʊkəs ɔn ænd θɪŋk ɐbaʊt ðə θɪŋz ðæt ðeɪ kæn kəntɹoʊl./', '<span tid="116329">successful</span><span tid="116330">happy</span><span tid="116331">people</span><span tid="116332">focus</span><span>on</span><span>and</span><span>think</span><span>about</span><span>the</span><span>things</span><span>that</span><span>they</span><span>can</span><span tid="116342">control.</span>'
FROM episodes e WHERE e.video_id = '131pRP2r5fuTOvP';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 2, 4.78, 8.58, 'The things that they can’t control and they can’t influence.', '那些他们无法控制或影响的事情，', '/ðə θɪŋz ðæt ðeɪ kænt kəntɹoʊl ænd ðeɪ kænt ɪnfluːəns./', '<span>The</span><span>things</span><span>that</span><span>they</span><span tid="116347">can’t</span><span tid="116348">control</span><span>and</span><span>they</span><span tid="116351">can’t</span><span tid="116352" class="highlight highlight-a">influence.</span>'
FROM episodes e WHERE e.video_id = '131pRP2r5fuTOvP';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 3, 8.58, 10.66, 'They don’t think about They don’t worry about.', '他们不会去思考，也不会为之担忧。', '/ðeɪ doʊnt θɪŋk ɐbaʊt ðeɪ doʊnt wʌɹi ɐbaʊt./', '<span>They</span><span>don’t</span><span>think</span><span>about</span><span>They</span><span>don’t</span><span tid="116359">worry</span><span>about.</span>'
FROM episodes e WHERE e.video_id = '131pRP2r5fuTOvP';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 4, 10.66, 12.72, 'They don’t spend any mental energy on it.', '他们不会在这些事情上花费任何精神能量。', '/ðeɪ doʊnt spɛnd ɛni mɛntəl ɛnɚdʒi ɔn ɪt./', '<span>They</span><span>don’t</span><span tid="116363">spend</span><span tid="116364">any</span><span pid="2954" class="highlight highlight-c">mental energy</span><span>on</span><span>it.</span>'
FROM episodes e WHERE e.video_id = '131pRP2r5fuTOvP';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 5, 12.72, 16.06, 'They spend 80 to 90 percent of the things they can control.', '他们会把80%到90%的精力投入到自己可以控制的事情上。', '/ðeɪ spɛnd eɪɾi tə naɪnti pɚsɛnt ʌvðə θɪŋz ðeɪ kæn kəntɹoʊl./', '<span>They</span><span tid="116370">spend</span><span>80</span><span>to</span><span>90</span><span tid="116374">percent</span><span>of</span><span>the</span><span>things</span><span>they</span><span>can</span><span tid="116380">control.</span>'
FROM episodes e WHERE e.video_id = '131pRP2r5fuTOvP';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 6, 16.06, 18.9, '10 to 20 percent on things they can influence.', '把10%到20%的精力用在可以影响的事情上。', '/tɛn tə twɛnti pɚsɛnt ɔn θɪŋz ðeɪ kæn ɪnfluːəns./', '<span>10</span><span>to</span><span>20</span><span tid="116384">percent</span><span>on</span><span>things</span><span>they</span><span>can</span><span tid="116389" class="highlight highlight-a">influence.</span>'
FROM episodes e WHERE e.video_id = '131pRP2r5fuTOvP';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 7, 18.9, 22.1, 'And zero on what they can’t influence or control.', '而对那些无法影响或控制的事情，精力为零。', '/ænd ziəɹoʊ ɔn wʌt ðeɪ kænt ɪnfluːəns ɔːɹ kəntɹoʊl./', '<span>And</span><span tid="116391">zero</span><span>on</span><span>what</span><span>they</span><span tid="116395">can’t</span><span tid="116396" class="highlight highlight-a">influence</span><span>or</span><span tid="116398">control.</span>'
FROM episodes e WHERE e.video_id = '131pRP2r5fuTOvP';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 8, 22.1, 26.24, 'So for me, I thought, okay, let me just ignore it.', '所以对我来说，我想，好吧，那就忽略它吧。', '/soʊ fɔːɹ miː, aɪ θɔːt, oʊkeɪ, lɛt miː dʒʌst ɪɡnɔːɹ ɪt./', '<span>So</span><span>for</span><span>me,</span><span>I</span><span>thought,</span><span>okay,</span><span>let</span><span>me</span><span>just</span><span tid="116408">ignore</span><span>it.</span>'
FROM episodes e WHERE e.video_id = '131pRP2r5fuTOvP';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 9, 26.24, 30.42, 'But there’s a flaw in that model There’s a flaw in that theory.', '但是这个模型有一个缺陷，这个理论有一个漏洞。', '/bʌt ðɛɹz ɐ flɔː ɪn ðæt mɑːdəl ðɛɹz ɐ flɔː ɪn ðæt θiəɹi./', '<span>But</span><span>there’s</span><span>a</span><span tid="116413" class="highlight highlight-a">flaw</span><span>in</span><span>that</span><span tid="116416" class="highlight highlight-a">model</span><span>There’s</span><span>a</span><span tid="116419" class="highlight highlight-a">flaw</span><span>in</span><span>that</span><span tid="116422">theory.</span>'
FROM episodes e WHERE e.video_id = '131pRP2r5fuTOvP';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 10, 30.42, 37.82, 'What if one of those things that’s in that third bucket is truly something that is preventing you from becoming your ideal self.', '如果第三类里的某件事情，恰恰阻碍了你成为理想的自己呢？', '/wʌt ɪf wʌn ʌv ðoʊz θɪŋz ðæts ɪn ðæt θɜːd bʌkɪt ɪz tɹuːli sʌmθɪŋ ðæt ɪz pɹɪvɛntɪŋ juː fɹʌm bᵻkʌmɪŋ jʊɹ aɪdiəl sɛlf./', '<span>What</span><span>if</span><span>one</span><span>of</span><span>those</span><span>things</span><span>that’s</span><span>in</span><span>that</span><span tid="116432">third</span><span tid="116433" class="highlight highlight-a">bucket</span><span>is</span><span tid="116435" class="highlight highlight-a">truly</span><span>something</span><span>that</span><span>is</span><span tid="116439" class="highlight highlight-a">preventing</span><span>you</span><span>from</span><span tid="116442">becoming</span><span>your</span><span pid="2955" class="highlight highlight-c">ideal self.</span>'
FROM episodes e WHERE e.video_id = '131pRP2r5fuTOvP';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 11, 37.82, 43.64, 'What if it is something that is preventing you from having the career you want to have.', '如果它阻碍了你获得想要的职业呢？', '/wʌt ɪf ɪɾ ɪz sʌmθɪŋ ðæt ɪz pɹɪvɛntɪŋ juː fɹʌm hævɪŋ ðə kɚɹɪɹ juː wɔnt tə hæv./', '<span>What</span><span>if</span><span>it</span><span>is</span><span>something</span><span>that</span><span>is</span><span tid="116453" class="highlight highlight-a">preventing</span><span>you</span><span>from</span><span>having</span><span>the</span><span tid="116458" class="highlight highlight-a">career</span><span>you</span><span>want</span><span>to</span><span>have.</span>'
FROM episodes e WHERE e.video_id = '131pRP2r5fuTOvP';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 12, 43.64, 46.2, 'From ultimately being the leader that you want to be.', '阻碍了你最终成为想成为的领导者呢？', '/fɹʌm ʌltᵻmətli biːɪŋ ðə liːdɚ ðæt juː wɔnt tə biː./', '<span>From</span><span tid="116464" class="highlight highlight-a">ultimately</span><span>being</span><span>the</span><span tid="116467">leader</span><span>that</span><span>you</span><span>want</span><span>to</span><span>be.</span>'
FROM episodes e WHERE e.video_id = '131pRP2r5fuTOvP';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 13, 46.2, 50.1, 'And ultimately having the self-esteem and the confidence that you want to have.', '阻碍了你最终拥有想要的自尊和自信呢？', '/ænd ʌltᵻmətli hævɪŋ ðə sɛlf ɛstiːm ænd ðə kɑːnfɪdəns ðæt juː wɔnt tə hæv./', '<span>And</span><span tid="116474" class="highlight highlight-a">ultimately</span><span>having</span><span>the</span><span tid="116477" class="highlight highlight-a">self-esteem</span><span>and</span><span>the</span><span tid="116480">confidence</span><span>that</span><span>you</span><span>want</span><span>to</span><span>have.</span>'
FROM episodes e WHERE e.video_id = '131pRP2r5fuTOvP';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 14, 50.1, 55.74, 'Well what I realized is you can actually move things from one bucket to another.', '我意识到，你实际上可以把事情从一个桶移动到另一个桶。', '/wɛl wʌt aɪ ɹiːəlaɪzd ɪz juː kæn æktʃuːəli muːv θɪŋz fɹʌm wʌn bʌkɪt tʊ ɐnʌðɚ./', '<span tid="116486">Well</span><span>what</span><span>I</span><span tid="116489" class="highlight highlight-a">realized</span><span>is</span><span>you</span><span>can</span><span tid="116493">actually</span><span tid="116494">move</span><span>things</span><span>from</span><span>one</span><span tid="116498" class="highlight highlight-a">bucket</span><span>to</span><span tid="116500">another.</span>'
FROM episodes e WHERE e.video_id = '131pRP2r5fuTOvP';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 15, 55.74, 59.88, 'You can take something that you have no influence on.', '你可以把那些你原本无法影响的事情，', '/juː kæn teɪk sʌmθɪŋ ðæt juː hæv noʊ ɪnfluːəns ɔn./', '<span>You</span><span>can</span><span tid="116503">take</span><span>something</span><span>that</span><span>you</span><span>have</span><span>no</span><span tid="116509" class="highlight highlight-a">influence</span><span>on.</span>'
FROM episodes e WHERE e.video_id = '131pRP2r5fuTOvP';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 16, 59.88, 65.3, 'and in many cases develop influence and actually change it.', '在很多情况下，发展影响力，实际上去改变它。', '/ænd ɪn mɛni keɪsᵻz dɪvɛləp ɪnfluːəns ænd æktʃuːəli tʃeɪndʒ ɪt./', '<span>and</span><span pid="2956" class="highlight highlight-i">in many cases</span><span tid="116515">develop</span><span tid="116516" class="highlight highlight-a">influence</span><span>and</span><span tid="116518">actually</span><span tid="116519">change</span><span>it.</span>'
FROM episodes e WHERE e.video_id = '131pRP2r5fuTOvP';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 17, 65.3, 71.12, 'You can then, once you have influence, change it to something that you have control over.', '一旦你有了影响力，你就可以把它变成自己可以控制的事情。', '/juː kæn ðɛn, wʌns juː hæv ɪnfluːəns, tʃeɪndʒ ɪt tə sʌmθɪŋ ðæt juː hæv kəntɹoʊl oʊvɚ./', '<span>You</span><span>can</span><span>then,</span><span tid="116524" class="highlight highlight-a">once</span><span>you</span><span>have</span><span tid="116527" class="highlight highlight-a">influence,</span><span tid="116528">change</span><span>it</span><span>to</span><span>something</span><span>that</span><span>you</span><span>have</span><span tid="116535">control</span><span tid="116536">over.</span>'
FROM episodes e WHERE e.video_id = '131pRP2r5fuTOvP';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 18, 71.12, 72.88, 'I learned that.', '我就是这么学到的。', '/aɪ lɜːnd ðæt./', '<span>I</span><span tid="116538">learned</span><span>that.</span>'
FROM episodes e WHERE e.video_id = '131pRP2r5fuTOvP';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 19, 72.88, 76.86, 'See, we have the power to influence much more than we realize.', '你看，我们拥有的影响力比自己意识到的要多得多。', '/siː, wiː hæv ðə paʊɚ tʊ ɪnfluːəns mʌtʃ mɔːɹ ðɐn wiː ɹiːəlaɪz./', '<span tid="116540">See,</span><span>we</span><span>have</span><span>the</span><span tid="116544">power</span><span>to</span><span tid="116546" class="highlight highlight-a">influence</span><span tid="116547">much</span><span>more</span><span tid="116549">than</span><span>we</span><span tid="116551" class="highlight highlight-a">realize.</span>'
FROM episodes e WHERE e.video_id = '131pRP2r5fuTOvP';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 20, 76.86, 79.38, 'And most of us never tap into that power.', '但我们大多数人从未真正利用这种力量。', '/ænd moʊst əv ʌs nɛvɚ tæp ɪntʊ ðæt paʊɚ./', '<span>And</span><span tid="116553">most</span><span>of</span><span>us</span><span tid="116556">never</span><span pid="2951" class="highlight highlight-d">tap into</span><span>that</span><span tid="116560">power.</span>'
FROM episodes e WHERE e.video_id = '131pRP2r5fuTOvP';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 21, 79.38, 83.48, 'We never tap into the power to influence ourselves and then other people.', '我们从未发挥出影响自己的能力，然后去影响他人。', '/wiː nɛvɚ tæp ɪntʊ ðə paʊɚ tʊ ɪnfluːəns aʊɚsɛlvz ænd ðɛn ʌðɚ piːpəl./', '<span>We</span><span tid="116562">never</span><span pid="2952" class="highlight highlight-d">tap into</span><span>the</span><span tid="116566">power</span><span>to</span><span tid="116568" class="highlight highlight-a">influence</span><span tid="116569">ourselves</span><span>and</span><span>then</span><span tid="116572">other</span><span tid="116573">people.</span>'
FROM episodes e WHERE e.video_id = '131pRP2r5fuTOvP';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 22, 83.48, 87.64, 'As humans, we tend to go down that path of least resistance.', '作为人类，我们往往选择阻力最小的路径。', '/æz hjuːmənz, wiː tɛnd tə ɡoʊ daʊn ðæt pæθ ʌv liːst ɹᵻsɪstəns./', '<span>As</span><span tid="116575">humans,</span><span>we</span><span pid="2945" class="highlight highlight-d">tend to</span><span>go</span><span tid="116580">down</span><span>that</span><span tid="116582">path</span><span>of</span><span tid="116584">least</span><span tid="116585" class="highlight highlight-a">resistance.</span>'
FROM episodes e WHERE e.video_id = '131pRP2r5fuTOvP';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 23, 87.64, 88.74, 'We like what’s easy.', '我们喜欢简单的事情。', '/wiː laɪk wʌts iːzi./', '<span>We</span><span>like</span><span>what’s</span><span tid="116589">easy.</span>'
FROM episodes e WHERE e.video_id = '131pRP2r5fuTOvP';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 24, 88.74, 90.38, 'We like what’s comfortable.', '我们喜欢舒适的状态。', '/wiː laɪk wʌts kʌmftəbəl./', '<span>We</span><span>like</span><span>what’s</span><span tid="116593">comfortable.</span>'
FROM episodes e WHERE e.video_id = '131pRP2r5fuTOvP';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 25, 90.38, 92.18, 'We like what’s pain-free.', '我们喜欢无痛的方式。', '/wiː laɪk wʌts peɪn fɹiː./', '<span>We</span><span>like</span><span>what’s</span><span tid="116597" class="highlight highlight-a">pain-free.</span>'
FROM episodes e WHERE e.video_id = '131pRP2r5fuTOvP';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 26, 92.18, 97.74, 'And sometimes changing what we’re doing in any way is uncomfortable.', '而有时候，做出任何改变都会让人感到不舒服。', '/ænd sʌmtaɪmz tʃeɪndʒɪŋ wʌt wɪɹ duːɪŋ ɪn ɛni weɪ ɪz ʌŋkʌmftəbəl./', '<span>And</span><span tid="116599">sometimes</span><span tid="116600">changing</span><span>what</span><span>we’re</span><span>doing</span><span pid="2953" class="highlight highlight-i">in any way</span><span>is</span><span tid="116608">uncomfortable.</span>'
FROM episodes e WHERE e.video_id = '131pRP2r5fuTOvP';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 27, 97.74, 107.7, 'What I realized is all I had to do was find the 3% that makes the other 97% happen.', '我意识到，我只需要找到那3%，就能让剩下的97%发生。', '/wʌt aɪ ɹiːəlaɪzd ɪz ɔːl aɪ hædtə duː wʌz faɪnd ðə θɹiː pɚsɛnt ðæt meɪks ðɪ ʌðɚ naɪnti sɛvən pɚsɛnt hæpən./', '<span>What</span><span>I</span><span tid="116611" class="highlight highlight-a">realized</span><span>is</span><span>all</span><span>I</span><span>had</span><span>to</span><span>do</span><span>was</span><span tid="116619">find</span><span>the</span><span>3%</span><span>that</span><span tid="116623">makes</span><span>the</span><span tid="116625">other</span><span>97%</span><span tid="116627">happen.</span>'
FROM episodes e WHERE e.video_id = '131pRP2r5fuTOvP';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 28, 107.7, 113.54, 'You see, I didn’t have to accomplish that big goal or control this big thing that I couldn’t control.', '你看，我不必去完成那个大目标，也不必去控制那些无法控制的大事。', '/juː siː, aɪ dɪdnt hæv tʊ ɐkɑːmplɪʃ ðæt bɪɡ ɡoʊl ɔːɹ kəntɹoʊl ðɪs bɪɡ θɪŋ ðæt aɪ kʊdənt kəntɹoʊl./', '<span>You</span><span tid="116629">see,</span><span>I</span><span>didn’t</span><span>have</span><span>to</span><span tid="116634" class="highlight highlight-a">accomplish</span><span>that</span><span tid="116636">big</span><span tid="116637">goal</span><span>or</span><span tid="116639">control</span><span>this</span><span tid="116641">big</span><span>thing</span><span>that</span><span>I</span><span>couldn’t</span><span tid="116646">control.</span>'
FROM episodes e WHERE e.video_id = '131pRP2r5fuTOvP';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 29, 113.54, 117.52, 'I just had to have and find the right 3%.', '我只需要拥有并找到正确的那3%。', '/aɪ dʒʌst hædtə hæv ænd faɪnd ðə ɹaɪt θɹiː pɚsɛnt./', '<span>I</span><span>just</span><span>had</span><span>to</span><span>have</span><span>and</span><span tid="116653">find</span><span>the</span><span tid="116655" class="highlight highlight-a">right</span><span>3%.</span>'
FROM episodes e WHERE e.video_id = '131pRP2r5fuTOvP';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 30, 117.52, 120.48, 'I had to find the 3 % that makes the other 97% happen.', '我必须找到那3%，让剩下的97%顺利发生。', '/aɪ hædtə faɪnd ðə θɹiː pɚsɛnt ðæt meɪks ðɪ ʌðɚ naɪnti sɛvən pɚsɛnt hæpən./', '<span>I</span><span>had</span><span>to</span><span tid="116660">find</span><span>the</span><span>3</span><span>%</span><span>that</span><span tid="116665">makes</span><span>the</span><span tid="116667">other</span><span>97%</span><span tid="116669">happen.</span>'
FROM episodes e WHERE e.video_id = '131pRP2r5fuTOvP';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 31, 120.48, 121.4, 'I’ll give you a great example.', '我给你举一个很好的例子。', '/aɪl ɡɪv juː ɐ ɡɹeɪt ɛɡzæmpəl./', '<span>I’ll</span><span tid="116671">give</span><span>you</span><span>a</span><span tid="116674">great</span><span tid="116675">example.</span>'
FROM episodes e WHERE e.video_id = '131pRP2r5fuTOvP';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 32, 121.4, 124.62, 'For me, I’ve always wanted to go to the gym in the morning.', '对我来说，我一直想早上去健身房锻炼。', '/fɔːɹ miː, aɪv ɔːlweɪz wɔntᵻd tə ɡoʊ tə ðə dʒɪm ɪnðə mɔːɹnɪŋ./', '<span>For</span><span>me,</span><span>I’ve</span><span tid="116679">always</span><span>wanted</span><span>to</span><span>go</span><span>to</span><span>the</span><span tid="116685" class="highlight highlight-a">gym</span><span>in</span><span>the</span><span tid="116688">morning.</span>'
FROM episodes e WHERE e.video_id = '131pRP2r5fuTOvP';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 33, 124.62, 126.84, 'I’ve kind of known that that’s a great way to start the day.', '我一直知道，这是开始一天的好方式。', '/aɪv kaɪnd ʌv noʊn ðæt ðæts ɐ ɡɹeɪt weɪ tə stɑːɹt ðə deɪ./', '<span>I’ve</span><span tid="116690">kind</span><span>of</span><span>known</span><span>that</span><span>that’s</span><span>a</span><span tid="116696">great</span><span tid="116697" class="highlight highlight-a">way</span><span>to</span><span tid="116699">start</span><span>the</span><span>day.</span>'
FROM episodes e WHERE e.video_id = '131pRP2r5fuTOvP';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 34, 126.84, 128.92, 'But I was working out at 8 or 9 at night.', '但我却总是在晚上八九点锻炼。', '/bʌt aɪ wʌz wɜːkɪŋ aʊt æɾ eɪt ɔːɹ naɪn æt naɪt./', '<span>But</span><span>I</span><span>was</span><span pid="2946" class="highlight highlight-d">working out</span><span>at</span><span>8</span><span>or</span><span>9</span><span>at</span><span tid="116712">night.</span>'
FROM episodes e WHERE e.video_id = '131pRP2r5fuTOvP';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 35, 128.92, 130.32, 'I’d be staying up late.', '我总是熬夜。', '/aɪd biː steɪɪŋ ʌp leɪt./', '<span>I’d</span><span>be</span><span pid="2957" class="highlight highlight-c">staying up late.</span>'
FROM episodes e WHERE e.video_id = '131pRP2r5fuTOvP';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 36, 130.32, 132.16, 'It was just a really bad cycle.', '这真的是一个很糟糕的循环。', '/ɪt wʌz dʒʌst ɐ ɹiəli bæd saɪkəl./', '<span>It</span><span>was</span><span>just</span><span>a</span><span tid="116722">really</span><span pid="2958" class="highlight highlight-c">bad cycle.</span>'
FROM episodes e WHERE e.video_id = '131pRP2r5fuTOvP';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 37, 132.16, 135.02, 'But for me, I’d set the alarm clock at 5 in the morning.', '但是对我来说，我会把闹钟定在早上五点。', '/bʌt fɔːɹ miː, aɪd sɛt ðɪ ɐlɑːɹm klɑːk æt faɪv ɪnðə mɔːɹnɪŋ./', '<span>But</span><span>for</span><span>me,</span><span>I’d</span><span tid="116729" class="highlight highlight-a">set</span><span>the</span><span pid="2949" class="highlight highlight-c">alarm clock</span><span>at</span><span>5</span><span>in</span><span>the</span><span tid="116737">morning.</span>'
FROM episodes e WHERE e.video_id = '131pRP2r5fuTOvP';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 38, 135.02, 137.62, 'It’d be dark out It would be cold.', '外面一片漆黑，还很冷。', '/ɪɾəd biː dɑːɹk aʊt ɪt wʊd biː koʊld./', '<span>It’d</span><span>be</span><span tid="116740">dark</span><span tid="116741">out</span><span>It</span><span>would</span><span>be</span><span tid="116745" class="highlight highlight-a">cold.</span>'
FROM episodes e WHERE e.video_id = '131pRP2r5fuTOvP';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 39, 137.62, 139.14, 'I wouldn’t want to get out of bed.', '我根本不想起床。', '/aɪ wʊdənt wɔnt tə ɡɛt aʊɾəv bɛd./', '<span>I</span><span>wouldn’t</span><span>want</span><span>to</span><span>get</span><span tid="116751">out</span><span>of</span><span tid="116753" class="highlight highlight-a">bed.</span>'
FROM episodes e WHERE e.video_id = '131pRP2r5fuTOvP';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 40, 139.14, 141.5, 'I’d hit the snooze button and I’d say, I’ll work out at night.', '我会按掉贪睡键，然后说，我晚上再锻炼吧。', '/aɪd hɪt ðə snuːz bʌʔn̩ ænd aɪd seɪ, aɪl wɜːk aʊt æt naɪt./', '<span>I’d</span><span tid="116755" class="highlight highlight-a">hit</span><span>the</span><span tid="116757" class="highlight highlight-a">snooze</span><span tid="116758" class="highlight highlight-a">button</span><span>and</span><span>I’d</span><span tid="116761">say,</span><span>I’ll</span><span pid="2947" class="highlight highlight-d">work out</span><span>at</span><span tid="116766">night.</span>'
FROM episodes e WHERE e.video_id = '131pRP2r5fuTOvP';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 41, 141.5, 143.54, 'For years it was like that.', '多年来一直是这样的。', '/fɔːɹ jɪɹz ɪt wʌz laɪk ðæt./', '<span>For</span><span tid="116768">years</span><span>it</span><span>was</span><span>like</span><span>that.</span>'
FROM episodes e WHERE e.video_id = '131pRP2r5fuTOvP';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 42, 143.54, 145.22, 'And then I realized, you know what.', '然后我意识到，你知道吗，', '/ænd ðɛn aɪ ɹiːəlaɪzd, juː noʊ wʌt./', '<span>And</span><span>then</span><span>I</span><span tid="116776" class="highlight highlight-a">realized,</span><span pid="2950" class="highlight highlight-i">you know what.</span>'
FROM episodes e WHERE e.video_id = '131pRP2r5fuTOvP';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 43, 145.22, 148.56, 'I don’t need to really go to the gym in the morning.', '我其实不需要早上去健身房。', '/aɪ doʊnt niːd tə ɹiəli ɡoʊ tə ðə dʒɪm ɪnðə mɔːɹnɪŋ./', '<span>I</span><span>don’t</span><span tid="116782">need</span><span>to</span><span tid="116784">really</span><span>go</span><span>to</span><span>the</span><span tid="116788" class="highlight highlight-a">gym</span><span>in</span><span>the</span><span tid="116791">morning.</span>'
FROM episodes e WHERE e.video_id = '131pRP2r5fuTOvP';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 44, 148.56, 151.98, 'The only thing I need to do is I need to get out of bed.', '我唯一需要做的就是起床。', '/ðɪ oʊnli θɪŋ aɪ niːd tə duː ɪz aɪ niːd tə ɡɛt aʊɾəv bɛd./', '<span>The</span><span tid="116793">only</span><span>thing</span><span>I</span><span tid="116796">need</span><span>to</span><span>do</span><span>is</span><span>I</span><span tid="116801">need</span><span>to</span><span>get</span><span tid="116804">out</span><span>of</span><span tid="116806" class="highlight highlight-a">bed.</span>'
FROM episodes e WHERE e.video_id = '131pRP2r5fuTOvP';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 45, 151.98, 153.96, 'and I need to put my gym clothes on.', '然后穿上我的健身服。', '/ænd aɪ niːd tə pʊt maɪ dʒɪm kloʊðz ɔn./', '<span>and</span><span>I</span><span tid="116809">need</span><span>to</span><span tid="116811">put</span><span>my</span><span tid="116813" class="highlight highlight-a">gym</span><span tid="116814">clothes</span><span>on.</span>'
FROM episodes e WHERE e.video_id = '131pRP2r5fuTOvP';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 46, 153.96, 155.14, 'That’s it.', '就是这样。', '/ðætsɪt./', '<span>That’s</span><span>it.</span>'
FROM episodes e WHERE e.video_id = '131pRP2r5fuTOvP';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 47, 155.14, 158.58, 'Because once I have my gym clothes on, I’m not going to go back into bed.', '因为一旦我穿上了健身服，我就不会再回到床上了。', '/bɪkʌz wʌns aɪ hæv maɪ dʒɪm kloʊðz ɔn, aɪm nɑːt ɡoʊɪŋ tə ɡoʊ bæk ɪntʊ bɛd./', '<span>Because</span><span tid="116819" class="highlight highlight-a">once</span><span>I</span><span>have</span><span>my</span><span tid="116823" class="highlight highlight-a">gym</span><span tid="116824">clothes</span><span>on,</span><span>I’m</span><span>not</span><span>going</span><span>to</span><span>go</span><span tid="116831" class="highlight highlight-a">back</span><span tid="116832" class="highlight highlight-a">into</span><span tid="116833" class="highlight highlight-a">bed.</span>'
FROM episodes e WHERE e.video_id = '131pRP2r5fuTOvP';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 48, 158.58, 160.56, 'And once I have my gym clothes on.', '一旦我穿上了健身服，', '/ænd wʌns aɪ hæv maɪ dʒɪm kloʊðz ɔn./', '<span>And</span><span tid="116835" class="highlight highlight-a">once</span><span>I</span><span>have</span><span>my</span><span tid="116839" class="highlight highlight-a">gym</span><span tid="116840">clothes</span><span>on.</span>'
FROM episodes e WHERE e.video_id = '131pRP2r5fuTOvP';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 49, 160.56, 164.64, 'I’m probably going to brush my teeth and grab my wallet and my keys and go into the car.', '我很可能会刷牙，拿上钱包和钥匙，走向车子。', '/aɪm pɹɑːbəbli ɡoʊɪŋ tə bɹʌʃ maɪ tiːθ ænd ɡɹæb maɪ wɔlɪt ænd maɪ kiːz ænd ɡoʊ ɪntʊ ðə kɑːɹ./', '<span>I’m</span><span tid="116843" class="highlight highlight-a">probably</span><span>going</span><span>to</span><span tid="116846">brush</span><span>my</span><span tid="116848">teeth</span><span>and</span><span tid="116850" class="highlight highlight-a">grab</span><span>my</span><span tid="116852" class="highlight highlight-a">wallet</span><span>and</span><span>my</span><span tid="116855" class="highlight highlight-a">keys</span><span>and</span><span>go</span><span tid="116858" class="highlight highlight-a">into</span><span>the</span><span tid="116860">car.</span>'
FROM episodes e WHERE e.video_id = '131pRP2r5fuTOvP';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 50, 164.64, 167.16, 'And then once I’m in the car, I’m going to drive to the gym.', '然后一旦我上了车，我就会开车去健身房。', '/ænd ðɛn wʌns aɪm ɪnðə kɑːɹ, aɪm ɡoʊɪŋ tə dɹaɪv tə ðə dʒɪm./', '<span>And</span><span>then</span><span tid="116863" class="highlight highlight-a">once</span><span>I’m</span><span>in</span><span>the</span><span tid="116867">car,</span><span>I’m</span><span>going</span><span>to</span><span tid="116871">drive</span><span>to</span><span>the</span><span tid="116874" class="highlight highlight-a">gym.</span>'
FROM episodes e WHERE e.video_id = '131pRP2r5fuTOvP';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 51, 167.16, 170.88, 'And once I’m at the gym, I’m going to go in and I’m going to work out.', '一旦到了健身房，我就会进去锻炼。', '/ænd wʌns aɪm æt ðə dʒɪm, aɪm ɡoʊɪŋ tə ɡoʊ ɪn ænd aɪm ɡoʊɪŋ tə wɜːk aʊt./', '<span>And</span><span tid="116876" class="highlight highlight-a">once</span><span>I’m</span><span>at</span><span>the</span><span tid="116880" class="highlight highlight-a">gym,</span><span>I’m</span><span>going</span><span>to</span><span>go</span><span>in</span><span>and</span><span>I’m</span><span>going</span><span>to</span><span pid="2948" class="highlight highlight-d">work out.</span>'
FROM episodes e WHERE e.video_id = '131pRP2r5fuTOvP';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 52, 170.88, 172.06, 'I’m not going to just sit there.', '我不会只是坐在那里。', '/aɪm nɑːt ɡoʊɪŋ tə dʒʌst sɪt ðɛɹ./', '<span>I’m</span><span>not</span><span>going</span><span>to</span><span>just</span><span tid="116897">sit</span><span>there.</span>'
FROM episodes e WHERE e.video_id = '131pRP2r5fuTOvP';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 53, 172.06, 176.1, 'So in reality, it’s not waking up in the morning to go to the gym.', '所以实际上，并不是早上起床去健身房才是关键。', '/soʊ ɪn ɹɪælᵻɾi, ɪts nɑːt weɪkɪŋ ʌp ɪnðə mɔːɹnɪŋ tə ɡoʊ tə ðə dʒɪm./', '<span>So</span><span>in</span><span tid="116901">reality,</span><span>it’s</span><span>not</span><span tid="116904">waking</span><span>up</span><span>in</span><span>the</span><span tid="116908">morning</span><span>to</span><span>go</span><span>to</span><span>the</span><span tid="116913" class="highlight highlight-a">gym.</span>'
FROM episodes e WHERE e.video_id = '131pRP2r5fuTOvP';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 54, 176.1, 183.1, 'The 3% that made the 97% happen was just getting out of bed and putting my gym clothes on.', '让剩下97%发生的那3%，就是起床并穿上健身服。', '/ðə θɹiː pɚsɛnt ðæt meɪd ðə naɪnti sɛvən pɚsɛnt hæpən wʌz dʒʌst ɡɛɾɪŋ aʊɾəv bɛd ænd pʊɾɪŋ maɪ dʒɪm kloʊðz ɔn./', '<span>The</span><span>3%</span><span>that</span><span tid="116917">made</span><span>the</span><span>97%</span><span tid="116920">happen</span><span>was</span><span>just</span><span>getting</span><span tid="116924">out</span><span>of</span><span tid="116926" class="highlight highlight-a">bed</span><span>and</span><span tid="116928">putting</span><span>my</span><span tid="116930" class="highlight highlight-a">gym</span><span tid="116931">clothes</span><span>on.</span>'
FROM episodes e WHERE e.video_id = '131pRP2r5fuTOvP';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 55, 183.1, 184.38, 'My goal changed.', '我的目标变了。', '/maɪ ɡoʊl tʃeɪndʒd./', '<span>My</span><span tid="116934">goal</span><span tid="116935">changed.</span>'
FROM episodes e WHERE e.video_id = '131pRP2r5fuTOvP';

-- episode 132: 1320cmtnAGaDO4R
INSERT INTO episodes (
  index, video_id, short_title, summary, remark, stars, voca_size,
  subtitle_count, clip_length, cover, video_url, audio_url, thumbnail_url,
  original_video_url, author_id, submitted_by_user_id, rejection_reason,
  created_at, is_demo, status, published_at
) VALUES (
  132, '1320cmtnAGaDO4R', '谷爱凌：体育背后的坚持和自我信任',
  '体育的力量是无可比拟的，因为它带来的是证据，而不是空洞的自我肯定', '好强的表达力',
  4, 75, 22,
  87.12, 'http://oss.sxakgs.com/en/1320cmtnAGaDO4R/cover.webp',
  'http://oss.sxakgs.com/en/1320cmtnAGaDO4R/video.mp4', 'http://oss.sxakgs.com/en/1320cmtnAGaDO4R/audio.mp3',
  'http://oss.sxakgs.com/en/1320cmtnAGaDO4R/cover.webp', 'https://www.youtube.com/watch?v=b-m2DntVdQU',
  (SELECT id FROM authors WHERE name = 'Gu Ailing' AND accent = '美国' LIMIT 1),
  NULL, NULL,
  '2026-06-30 14:56:50'::timestamp,
  FALSE, 'published',
  '2026-06-30 14:56:50'::timestamp
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
  SELECT s.id FROM subtitles s JOIN episodes e ON s.episode_id = e.id WHERE e.video_id = '1320cmtnAGaDO4R'
);
DELETE FROM subtitles WHERE episode_id = (SELECT id FROM episodes WHERE video_id = '1320cmtnAGaDO4R');
DELETE FROM episode_tags WHERE episode_id = (SELECT id FROM episodes WHERE video_id = '1320cmtnAGaDO4R');

INSERT INTO episode_tags (episode_id, tag_id)
SELECT e.id, t.id FROM episodes e, tags t
WHERE e.video_id = '1320cmtnAGaDO4R' AND t.name = '访谈'
ON CONFLICT DO NOTHING;
INSERT INTO episode_tags (episode_id, tag_id)
SELECT e.id, t.id FROM episodes e, tags t
WHERE e.video_id = '1320cmtnAGaDO4R' AND t.name = '运动'
ON CONFLICT DO NOTHING;
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 1, 0.0, 5.22, 'As young women, I think it is easy to doubt.', '作为年轻女性，我觉得我们很容易产生怀疑。', '/æz jʌŋ wɪmɪn, aɪ θɪŋk ɪɾ ɪz iːzi tə daʊt./', '<span>As</span><span tid="116937">young</span><span tid="116938">women,</span><span>I</span><span>think</span><span>it</span><span>is</span><span tid="116943">easy</span><span>to</span><span tid="116945" class="highlight highlight-a">doubt.</span>'
FROM episodes e WHERE e.video_id = '1320cmtnAGaDO4R';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 2, 5.22, 11.08, 'And I mean this as in, like, instilled, you know, self-instilled self-doubt.', '我的意思是，那种被灌输的、你知道的，自己内心产生的自我怀疑。', '/ænd aɪ miːn ðɪs æz ɪn, laɪk, ɪnstɪld, juː noʊ, sɛlf ɪnstɪld sɛlf daʊt./', '<span>And</span><span>I</span><span tid="116948">mean</span><span>this</span><span>as</span><span>in,</span><span>like,</span><span tid="116953" class="highlight highlight-a">instilled,</span><span>you</span><span>know,</span><span tid="116956">self-instilled</span><span tid="116957" class="highlight highlight-a">self-doubt.</span>'
FROM episodes e WHERE e.video_id = '1320cmtnAGaDO4R';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 3, 11.08, 17.74, 'but also maybe external subtleties and like little micro things that make you doubt yourself.', '但也可能来自外界一些微妙的影响，还有那些细微的小事，让你开始怀疑自己。', '/bʌt ɔːlsoʊ meɪbiː ɛkstɜːnəl sʌɾəlɾiz ænd laɪk lɪɾəl maɪkɹoʊ θɪŋz ðæt meɪk juː daʊt jɔːɹsɛlf./', '<span>but</span><span>also</span><span tid="116960">maybe</span><span tid="116961" class="highlight highlight-a">external</span><span tid="116962" class="highlight highlight-a">subtleties</span><span>and</span><span>like</span><span tid="116965">little</span><span tid="116966" class="highlight highlight-a">micro</span><span>things</span><span>that</span><span tid="116969">make</span><span>you</span><span tid="116971" class="highlight highlight-a">doubt</span><span tid="116972">yourself.</span>'
FROM episodes e WHERE e.video_id = '1320cmtnAGaDO4R';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 4, 17.74, 19.52, 'and over time make you afraid to try.', '久而久之，让你变得害怕去尝试。', '/ænd oʊvɚ taɪm meɪk juː ɐfɹeɪd tə tɹaɪ./', '<span>and</span><span pid="3206" class="highlight highlight-c">over time</span><span tid="116976">make</span><span>you</span><span tid="116978">afraid</span><span>to</span><span tid="116980">try.</span>'
FROM episodes e WHERE e.video_id = '1320cmtnAGaDO4R';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 5, 19.52, 25.54, 'That’s why we see rates of young women participating in sports drop off precipitously between the ages of 11 and 14.', '这就是为什么我们看到，年轻女性参与体育运动的比例在11到14岁之间急剧下降。', '/ðæts waɪ wiː siː ɹeɪts ʌv jʌŋ wɪmɪn pɑːɹtɪsᵻpeɪɾɪŋ ɪn spɔːɹts dɹɑːp ɔf pɹɪsɪpɪɾəsli bᵻtwiːn ðɪ eɪdʒᵻz ʌv ɪlɛvən ænd fɔːɹtiːn./', '<span>That’s</span><span>why</span><span>we</span><span tid="116984">see</span><span tid="116985" class="highlight highlight-a">rates</span><span>of</span><span tid="116987">young</span><span tid="116988">women</span><span tid="116989" class="highlight highlight-a">participating</span><span>in</span><span tid="116991">sports</span><span pid="3204" class="highlight highlight-d">drop off</span><span tid="116994" class="highlight highlight-a">precipitously</span><span tid="116995">between</span><span>the</span><span tid="116997" class="highlight highlight-a">ages</span><span>of</span><span>11</span><span>and</span><span>14.</span>'
FROM episodes e WHERE e.video_id = '1320cmtnAGaDO4R';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 6, 25.54, 28.64, 'And so as far as trusting yourself.', '所以说到信任自己这件事。', '/ænd soʊ æz fɑːɹ æz tɹʌstɪŋ jɔːɹsɛlf./', '<span>And</span><span>so</span><span pid="3207" class="highlight highlight-c">as far as</span><span tid="117007">trusting</span><span tid="117008">yourself.</span>'
FROM episodes e WHERE e.video_id = '1320cmtnAGaDO4R';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 7, 28.64, 34.94, 'the power of sport is unparalleled because it is evidence over affirmation.', '体育的力量是无可比拟的，因为它带来的是证据，而不是空洞的自我肯定。', '/ðə paʊɚɹ ʌv spɔːɹt ɪz ʌnpæɹəlɛld bɪkʌz ɪɾ ɪz ɛvɪdəns oʊvɚɹ æfɚmeɪʃən./', '<span>the</span><span tid="117010">power</span><span>of</span><span tid="117012">sport</span><span>is</span><span tid="117014" class="highlight highlight-a">unparalleled</span><span>because</span><span>it</span><span>is</span><span tid="117018" class="highlight highlight-a">evidence</span><span tid="117019">over</span><span tid="117020" class="highlight highlight-a">affirmation.</span>'
FROM episodes e WHERE e.video_id = '1320cmtnAGaDO4R';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 8, 34.94, 39.34, 'You don’t tell yourself, oh, I can handle the pressure, oh, I’m so great.', '你不是对自己说，哦，我能承受压力，哦，我很厉害。', '/juː doʊnt tɛl jɔːɹsɛlf, oʊ, aɪ kæn hændəl ðə pɹɛʃɚ, oʊ, aɪm soʊ ɡɹeɪt./', '<span>You</span><span>don’t</span><span tid="117023">tell</span><span tid="117024">yourself,</span><span>oh,</span><span>I</span><span>can</span><span tid="117028" class="highlight highlight-a">handle</span><span>the</span><span tid="117030" class="highlight highlight-a">pressure,</span><span>oh,</span><span>I’m</span><span>so</span><span tid="117034">great.</span>'
FROM episodes e WHERE e.video_id = '1320cmtnAGaDO4R';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 9, 39.34, 41.8, 'You do it time and again.', '而是你一次又一次真正去做到。', '/juː duː ɪt taɪm ænd ɐɡɛn./', '<span>You</span><span>do</span><span>it</span><span tid="117038">time</span><span>and</span><span tid="117040">again.</span>'
FROM episodes e WHERE e.video_id = '1320cmtnAGaDO4R';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 10, 41.8, 45.2, 'And another thing, you know, I said this earlier in an interview, I said.', '还有一点，你知道，我之前在一次采访中也说过。', '/ænd ɐnʌðɚ θɪŋ, juː noʊ, aɪ sɛd ðɪs ɜːlɪɚɹ ɪn ɐn ɪntɚvjuː, aɪ sɛd./', '<span>And</span><span tid="117042">another</span><span>thing,</span><span>you</span><span>know,</span><span>I</span><span tid="117047">said</span><span>this</span><span tid="117049">earlier</span><span>in</span><span>an</span><span tid="117052" class="highlight highlight-a">interview,</span><span>I</span><span tid="117054">said.</span>'
FROM episodes e WHERE e.video_id = '1320cmtnAGaDO4R';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 11, 45.2, 47.66, 'sports are really honest because you can’t lie to yourself.', '体育是非常诚实的，因为你无法欺骗自己。', '/spɔːɹts ɑːɹ ɹiəli ɑːnɪst bɪkʌz juː kænt laɪ tə jɔːɹsɛlf./', '<span tid="117055">sports</span><span>are</span><span tid="117057">really</span><span tid="117058">honest</span><span>because</span><span>you</span><span tid="117061">can’t</span><span tid="117062">lie</span><span>to</span><span tid="117064">yourself.</span>'
FROM episodes e WHERE e.video_id = '1320cmtnAGaDO4R';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 12, 47.66, 51.08, 'You know when you stayed late and other people weren’t there.', '你知道自己什么时候比别人更晚离开。', '/juː noʊ wɛn juː steɪd leɪt ænd ʌðɚ piːpəl wɜːnt ðɛɹ./', '<span>You</span><span>know</span><span>when</span><span>you</span><span pid="3208" class="highlight highlight-d">stayed late</span><span>and</span><span tid="117072">other</span><span tid="117073">people</span><span tid="117074">weren’t</span><span>there.</span>'
FROM episodes e WHERE e.video_id = '1320cmtnAGaDO4R';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 13, 51.08, 53.84, 'You know when you showed up early and other people weren’t there.', '你知道自己什么时候比别人更早到达。', '/juː noʊ wɛn juː ʃoʊd ʌp ɜːli ænd ʌðɚ piːpəl wɜːnt ðɛɹ./', '<span>You</span><span>know</span><span>when</span><span>you</span><span pid="3209" class="highlight highlight-d">showed up early</span><span>and</span><span tid="117084">other</span><span tid="117085">people</span><span tid="117086">weren’t</span><span>there.</span>'
FROM episodes e WHERE e.video_id = '1320cmtnAGaDO4R';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 14, 53.84, 56.32, 'You know when you gave 100% in training.', '你知道自己什么时候在训练中付出了百分之百。', '/juː noʊ wɛn juː ɡeɪv wʌnhʌndɹɪd pɚsɛnt ɪn tɹeɪnɪŋ./', '<span>You</span><span>know</span><span>when</span><span>you</span><span tid="117092">gave</span><span>100%</span><span>in</span><span tid="117095" class="highlight highlight-a">training.</span>'
FROM episodes e WHERE e.video_id = '1320cmtnAGaDO4R';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 15, 56.32, 58.98, 'day in day out for months, for months.', '日复一日，坚持了好几个月，好几个月。', '/deɪ ɪn deɪ aʊt fɔːɹ mʌnθs, fɔːɹ mʌnθs./', '<span pid="3210" class="highlight highlight-f">day in day out</span><span pid="3211" class="highlight highlight-c">for months,</span><span pid="3211" class="highlight highlight-c">for months.</span>'
FROM episodes e WHERE e.video_id = '1320cmtnAGaDO4R';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 16, 58.98, 64.44, 'And so it’s not about, you know, at the last second I tell myself a chipper little line and call it a day.', '所以这不是说，在最后一刻我对自己说一句轻松鼓劲的话就结束了。', '/ænd soʊ ɪts nɑːt ɐbaʊt, juː noʊ, æt ðə læst sɛkənd aɪ tɛl maɪsɛlf ɐ tʃɪpɚ lɪɾəl laɪn ænd kɔːl ɪɾ ɐ deɪ./', '<span>And</span><span>so</span><span>it’s</span><span>not</span><span>about,</span><span>you</span><span>know,</span><span>at</span><span>the</span><span tid="117113" class="highlight highlight-a">last</span><span tid="117114">second</span><span>I</span><span tid="117116">tell</span><span tid="117117">myself</span><span>a</span><span tid="117119" class="highlight highlight-a">chipper</span><span tid="117120">little</span><span tid="117121">line</span><span>and</span><span pid="3205" class="highlight highlight-f">call it a day.</span>'
FROM episodes e WHERE e.video_id = '1320cmtnAGaDO4R';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 17, 64.44, 67.46, 'It’s the fact that I look back on quite literally years.', '而是我回望过去那些，毫不夸张地说，整整多年的时间。', '/ɪts ðə fækt ðæt aɪ lʊk bæk ɔn kwaɪt lɪɾɚɹəli jɪɹz./', '<span>It’s</span><span>the</span><span tid="117129">fact</span><span>that</span><span>I</span><span tid="117132" class="highlight highlight-a">look</span><span tid="117133" class="highlight highlight-a">back</span><span>on</span><span tid="117135">quite</span><span tid="117136" class="highlight highlight-a">literally</span><span tid="117137">years.</span>'
FROM episodes e WHERE e.video_id = '1320cmtnAGaDO4R';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 18, 67.46, 72.2, 'like decade of hard work of pouring my heart and soul into this sport.', '甚至是十年，把我的全部热情和灵魂都倾注在这项运动中的努力。', '/laɪk dɛkeɪd ʌv hɑːɹd wɜːk ʌv pɔːɹɪŋ maɪ hɑːɹt ænd soʊl ɪntʊ ðɪs spɔːɹt./', '<span>like</span><span tid="117139" class="highlight highlight-a">decade</span><span>of</span><span pid="3212" class="highlight highlight-c">hard work</span><span>of</span><span tid="117144">pouring</span><span>my</span><span tid="117146" class="highlight highlight-a">heart</span><span>and</span><span tid="117148" class="highlight highlight-a">soul</span><span tid="117149" class="highlight highlight-a">into</span><span>this</span><span tid="117151">sport.</span>'
FROM episodes e WHERE e.video_id = '1320cmtnAGaDO4R';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 19, 72.2, 76.1, 'And so it’s, yeah, it’s trusting myself, but it’s building that trust every day.', '所以，是的，这是信任自己，但更是每天一点一滴建立这种信任。', '/ænd soʊ ɪts, jɛh, ɪts tɹʌstɪŋ maɪsɛlf, bʌt ɪts bɪldɪŋ ðæt tɹʌst ɛvɹi deɪ./', '<span>And</span><span>so</span><span>it’s,</span><span>yeah,</span><span>it’s</span><span tid="117157">trusting</span><span tid="117158">myself,</span><span>but</span><span>it’s</span><span tid="117161">building</span><span>that</span><span tid="117163">trust</span><span tid="117164">every</span><span>day.</span>'
FROM episodes e WHERE e.video_id = '1320cmtnAGaDO4R';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 20, 76.1, 79.64, 'And so that’s a big reason why I encourage more young girls to get into sports.', '这也是为什么我鼓励更多年轻女孩参与体育运动的重要原因之一。', '/ænd soʊ ðæts ɐ bɪɡ ɹiːzən waɪ aɪ ɛŋkɜːɹɪdʒ mɔːɹ jʌŋ ɡɜːlz tə ɡɛt ɪntʊ spɔːɹts./', '<span>And</span><span>so</span><span>that’s</span><span>a</span><span tid="117170">big</span><span tid="117171">reason</span><span>why</span><span>I</span><span tid="117174">encourage</span><span>more</span><span tid="117176">young</span><span tid="117177">girls</span><span>to</span><span>get</span><span tid="117180" class="highlight highlight-a">into</span><span tid="117181">sports.</span>'
FROM episodes e WHERE e.video_id = '1320cmtnAGaDO4R';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 21, 79.64, 83.98, 'because I think that the power it has to build and instill that confidence in people.', '因为我认为，体育所拥有的那种帮助人建立并植入自信的力量。', '/bɪkʌz aɪ θɪŋk ðætðə paʊɚɹ ɪt hɐz tə bɪld ænd ɪnstɪl ðæt kɑːnfɪdəns ɪn piːpəl./', '<span>because</span><span>I</span><span>think</span><span>that</span><span>the</span><span tid="117187">power</span><span>it</span><span>has</span><span>to</span><span tid="117191">build</span><span>and</span><span tid="117193" class="highlight highlight-a">instill</span><span>that</span><span tid="117195">confidence</span><span>in</span><span tid="117197">people.</span>'
FROM episodes e WHERE e.video_id = '1320cmtnAGaDO4R';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 22, 83.98, 87.12, 'is a really special and unique form.', '是一种非常特别且独一无二的形式。', '/ɪz ɐ ɹiəli spɛʃəl ænd juːniːk fɔːɹm./', '<span>is</span><span>a</span><span tid="117200">really</span><span tid="117201">special</span><span>and</span><span tid="117203" class="highlight highlight-a">unique</span><span tid="117204" class="highlight highlight-a">form.</span>'
FROM episodes e WHERE e.video_id = '1320cmtnAGaDO4R';

-- episode 134: 134DHRPZp2BKOEk
INSERT INTO episodes (
  index, video_id, short_title, summary, remark, stars, voca_size,
  subtitle_count, clip_length, cover, video_url, audio_url, thumbnail_url,
  original_video_url, author_id, submitted_by_user_id, rejection_reason,
  created_at, is_demo, status, published_at
) VALUES (
  134, '134DHRPZp2BKOEk', '纳瓦尔深度三小时访谈（开头）',
  '纳瓦尔指出幸福源于知足。他主张先获取物质成功以摆脱欲望，而非盲目禁欲。他强调应减少过程中的心理折磨，以平和心态享受人生旅程，认为真正的成功是在追求目标时保持内心清明，让行动变得更纯粹且高效。', '这视频质量太高做得好累',
  4, 284, 145,
  463.38, 'http://oss.sxakgs.com/en/134DHRPZp2BKOEk/cover.webp',
  'http://oss.sxakgs.com/en/134DHRPZp2BKOEk/video.mp4', 'http://oss.sxakgs.com/en/134DHRPZp2BKOEk/audio.mp3',
  'http://oss.sxakgs.com/en/134DHRPZp2BKOEk/cover.webp', 'https://www.youtube.com/watch?v=KyfUysrNaco',
  (SELECT id FROM authors WHERE name = 'Naval Ravikant' AND accent = '美国' LIMIT 1),
  NULL, NULL,
  '2026-06-30 14:58:24'::timestamp,
  FALSE, 'published',
  '2026-06-30 14:58:24'::timestamp
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
  SELECT s.id FROM subtitles s JOIN episodes e ON s.episode_id = e.id WHERE e.video_id = '134DHRPZp2BKOEk'
);
DELETE FROM subtitles WHERE episode_id = (SELECT id FROM episodes WHERE video_id = '134DHRPZp2BKOEk');
DELETE FROM episode_tags WHERE episode_id = (SELECT id FROM episodes WHERE video_id = '134DHRPZp2BKOEk');

INSERT INTO episode_tags (episode_id, tag_id)
SELECT e.id, t.id FROM episodes e, tags t
WHERE e.video_id = '134DHRPZp2BKOEk' AND t.name = '访谈'
ON CONFLICT DO NOTHING;
INSERT INTO episode_tags (episode_id, tag_id)
SELECT e.id, t.id FROM episodes e, tags t
WHERE e.video_id = '134DHRPZp2BKOEk' AND t.name = '人生'
ON CONFLICT DO NOTHING;
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 1, 0.0, 2.44, 'Happiness is being satisfied with what you have.', '幸福就是对自己拥有的一切感到满足。', '/hæpɪnəs ɪz biːɪŋ sæɾɪsfaɪd wɪð wʌt juː hæv./', '<span tid="117712">Happiness</span><span>is</span><span>being</span><span tid="117715" class="highlight highlight-a">satisfied</span><span>with</span><span>what</span><span>you</span><span>have.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 2, 2.44, 4.98, 'Success comes from dissatisfaction.', '成功源于不满足。', '/səksɛs kʌmz fɹʌm dɪsæɾɪsfækʃən./', '<span tid="117720">Success</span><span tid="117721">comes</span><span>from</span><span tid="117723" class="highlight highlight-a">dissatisfaction.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 3, 4.98, 7.7, 'Is success worth it then.', '那成功到底值不值得呢？', '/ɪz səksɛs wɜːθ ɪt ðɛn./', '<span>Is</span><span tid="117725">success</span><span pid="2102" class="highlight highlight-f">worth it</span><span>then.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 4, 7.7, 12.02, 'Oof I''m not sure that statement is true anymore.', '哎，现在我也不太确定那句话还对不对。', '/uːf aɪm nɑːt ʃʊɹ ðæt steɪtmənt ɪz tɹuː ɛnɪmɔːɹ./', '<span tid="117729">Oof</span><span>I''m</span><span>not</span><span tid="117732">sure</span><span>that</span><span tid="117734" class="highlight highlight-a">statement</span><span>is</span><span tid="117736">true</span><span tid="117737">anymore.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 5, 12.02, 14.18, 'Like I made that statement a long time ago.', '那其实是我很久以前说的一句话。', '/laɪk aɪ meɪd ðæt steɪtmənt ɐ lɔŋ taɪm ɐɡoʊ./', '<span>Like</span><span>I</span><span tid="117740">made</span><span>that</span><span tid="117742" class="highlight highlight-a">statement</span><span pid="2095" class="highlight highlight-c">a long time ago.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 6, 14.18, 17.66, 'and a lot of these things are just notes to myself and they''re highly contextual.', '而且这些很多都是我当时写给自己的随笔，语境非常具体。', '/ænd ɐ lɑːt ʌv ðiːz θɪŋz ɑːɹ dʒʌst noʊts tə maɪsɛlf ænd ðeɪɚ haɪli kəntɛkstʃuːəl./', '<span>and</span><span>a</span><span tid="117749">lot</span><span>of</span><span>these</span><span>things</span><span>are</span><span>just</span><span tid="117755">notes</span><span>to</span><span tid="117757">myself</span><span>and</span><span>they''re</span><span tid="117760">highly</span><span tid="117761" class="highlight highlight-a">contextual.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 7, 17.66, 19.68, 'They come in the moment They leave in the moment.', '它们在那个时刻产生，也在那个时刻消散。', '/ðeɪ kʌm ɪnðə moʊmənt ðeɪ liːv ɪnðə moʊmənt./', '<span>They</span><span tid="117763">come</span><span>in</span><span>the</span><span tid="117766" class="highlight highlight-a">moment</span><span>They</span><span tid="117768">leave</span><span>in</span><span>the</span><span tid="117771" class="highlight highlight-a">moment.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 8, 19.68, 24.22, 'Happiness Okay So very complicated topic.', '幸福——好吧，这是个非常复杂的话题。', '/hæpɪnəs oʊkeɪ soʊ vɛɹi kɑːmplᵻkeɪɾᵻd tɑːpɪk./', '<span tid="117772">Happiness</span><span>Okay</span><span>So</span><span>very</span><span tid="117776" class="highlight highlight-a">complicated</span><span tid="117777">topic.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 9, 24.22, 26.5, 'but I always like the Socrates story.', '不过我一直很喜欢苏格拉底的那个故事。', '/bʌt aɪ ɔːlweɪz laɪk ðə sɑːkɹɐtiːz stɔːɹi./', '<span>but</span><span>I</span><span tid="117780">always</span><span>like</span><span>the</span><span tid="117783">Socrates</span><span tid="117784">story.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 10, 26.5, 28.24, 'where he goes into the marketplace.', '他说有一次苏格拉底走进集市。', '/wɛɹ hiː ɡoʊz ɪntʊ ðə mɑːɹkɪtpleɪs./', '<span>where</span><span>he</span><span>goes</span><span tid="117788" class="highlight highlight-a">into</span><span>the</span><span tid="117790" class="highlight highlight-a">marketplace.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 11, 28.24, 30.58, 'and they show him all these luxuries and fineries.', '人们向他展示各种奢侈品和精美的东西。', '/ænd ðeɪ ʃoʊ hɪm ɔːl ðiːz lʌkʃɚɹiz ænd faɪnɚɹiz./', '<span>and</span><span>they</span><span tid="117793">show</span><span>him</span><span>all</span><span>these</span><span tid="117797" class="highlight highlight-a">luxuries</span><span>and</span><span tid="117799" class="highlight highlight-a">fineries.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 12, 30.58, 33.92, 'and he says, how many things there are in this world that I do not want.', '然后他说：这个世界上有这么多我不想要的东西。', '/ænd hiː sɛz, haʊ mɛni θɪŋz ðɛɹɑːɹ ɪn ðɪs wɜːld ðæt aɪ duːnɑːt wɔnt./', '<span>and</span><span>he</span><span tid="117802">says,</span><span>how</span><span>many</span><span>things</span><span>there</span><span>are</span><span>in</span><span>this</span><span tid="117810">world</span><span>that</span><span>I</span><span>do</span><span>not</span><span>want.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 13, 33.92, 35.52, 'And that''s a form of freedom.', '而那本身就是一种自由。', '/ænd ðæts ɐ fɔːɹm ʌv fɹiːdəm./', '<span>And</span><span>that''s</span><span>a</span><span tid="117819" class="highlight highlight-a">form</span><span>of</span><span tid="117821">freedom.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 14, 35.52, 38.48, 'So not wanting something is as good as having it.', '所以，不想要某样东西，其实和拥有它一样好。', '/soʊ nɑːt wɔntɪŋ sʌmθɪŋ ɪz æz ɡʊd æz hævɪŋ ɪt./', '<span>So</span><span>not</span><span>wanting</span><span>something</span><span>is</span><span>as</span><span>good</span><span>as</span><span>having</span><span>it.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 15, 38.48, 41.94, 'In the old story with Alexander Dionysius, right.', '还有一个关于亚历山大和第欧根尼的古老故事。', '/ɪnðɪ oʊld stɔːɹi wɪð ælɪɡzændɚ daɪənɪsɪəs, ɹaɪt./', '<span>In</span><span>the</span><span tid="117834">old</span><span tid="117835">story</span><span>with</span><span tid="117837">Alexander</span><span tid="117838">Dionysius,</span><span tid="117839" class="highlight highlight-a">right.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 16, 41.94, 45.36, 'Alexander''s goes out and conquers the world and he meets Dionysius who''s living in a barrel.', '亚历山大征服世界之后，遇见了住在木桶里的第欧根尼。', '/ælɪɡzændɚz ɡoʊz aʊt ænd kɑːŋkɚz ðə wɜːld ænd hiː miːts daɪənɪsɪəs huːz lɪvɪŋ ɪn ɐ bæɹəl./', '<span tid="117840">Alexander''s</span><span>goes</span><span tid="117842">out</span><span>and</span><span tid="117844" class="highlight highlight-a">conquers</span><span>the</span><span tid="117846">world</span><span>and</span><span>he</span><span tid="117849">meets</span><span tid="117850">Dionysius</span><span>who''s</span><span tid="117852">living</span><span>in</span><span>a</span><span tid="117855" class="highlight highlight-a">barrel.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 17, 45.36, 47.88, 'and Dionysius says, get out of the way, you''re blocking my son.', '第欧根尼对他说：让开点，你挡住我的阳光了。', '/ænd daɪənɪsɪəs sɛz, ɡɛt aʊɾəv ðə weɪ, jʊɹ blɑːkɪŋ maɪ sʌn./', '<span>and</span><span tid="117857">Dionysius</span><span tid="117858">says,</span><span>get</span><span tid="117860">out</span><span>of</span><span>the</span><span tid="117863" class="highlight highlight-a">way,</span><span>you''re</span><span tid="117865" class="highlight highlight-a">blocking</span><span>my</span><span tid="117867">son.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 18, 47.88, 52.72, 'And Alexander says, oh, how I wish I, you know, could be like Dionysius in the next life.', '亚历山大说：唉，我真希望下辈子能像第欧根尼那样生活。', '/ænd ælɪɡzændɚ sɛz, oʊ, haʊ aɪ wɪʃ aɪ, juː noʊ, kʊd biː laɪk daɪənɪsɪəs ɪnðə nɛkst laɪf./', '<span>And</span><span tid="117869">Alexander</span><span tid="117870">says,</span><span>oh,</span><span>how</span><span>I</span><span tid="117874">wish</span><span>I,</span><span>you</span><span>know,</span><span>could</span><span>be</span><span>like</span><span tid="117881">Dionysius</span><span>in</span><span>the</span><span tid="117884">next</span><span tid="117885">life.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 19, 52.72, 54.5, 'And Dionysius says, that''s the difference.', '第欧根尼说：这就是我们的区别。', '/ænd daɪənɪsɪəs sɛz, ðæts ðə dɪfɹəns./', '<span>And</span><span tid="117887">Dionysius</span><span tid="117888">says,</span><span>that''s</span><span>the</span><span tid="117891">difference.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 20, 54.5, 56.54, 'I don''t wish that I could, sorry, Diogenes.', '我并不会希望自己成为你——抱歉，是第欧根尼。', '/aɪ doʊnt wɪʃ ðæt aɪ kʊd, sɑːɹi, dɪoʊdʒiːnz./', '<span>I</span><span>don''t</span><span tid="117894">wish</span><span>that</span><span>I</span><span>could,</span><span tid="117898">sorry,</span><span tid="117899">Diogenes.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 21, 56.54, 59.8, 'Diogenes says, I don''t wish to be Alexander.', '第欧根尼说：我并不想成为亚历山大。', '/dɪoʊdʒiːnz sɛz, aɪ doʊnt wɪʃ təbi ælɪɡzændɚ./', '<span tid="117900">Diogenes</span><span tid="117901">says,</span><span>I</span><span>don''t</span><span tid="117904">wish</span><span>to</span><span>be</span><span tid="117907">Alexander.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 22, 59.8, 62.88, 'So two paths to happiness.', '所以通往幸福有两条路。', '/soʊ tuː pæθs tə hæpɪnəs./', '<span>So</span><span>two</span><span tid="117910">paths</span><span>to</span><span tid="117912">happiness.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 23, 62.88, 65.04, 'And one path is to success.', '一条路是走向成功。', '/ænd wʌn pæθ ɪz tə səksɛs./', '<span>And</span><span>one</span><span tid="117915">path</span><span>is</span><span>to</span><span tid="117918">success.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 24, 65.04, 65.96, 'You get what you want.', '得到你想要的东西。', '/juː ɡɛt wʌt juː wɔnt./', '<span>You</span><span>get</span><span>what</span><span>you</span><span>want.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 25, 65.96, 69.96, 'You satisfy your material needs or like Diogenes, you just don''t want it in the first place.', '满足你的物质需求；或者像第欧根尼那样，一开始就不想要这些。', '/juː sæɾɪsfaɪ jʊɹ mətɪɹiəl niːdz ɔːɹ laɪk dɪoʊdʒiːnz, juː dʒʌst doʊnt wɔnt ɪɾ ɪnðə fɜːst pleɪs./', '<span>You</span><span tid="117925">satisfy</span><span>your</span><span pid="2103" class="highlight highlight-c">material needs</span><span>or</span><span>like</span><span tid="117931">Diogenes,</span><span>you</span><span>just</span><span>don''t</span><span>want</span><span>it</span><span pid="2100" class="highlight highlight-i">in the first place.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 26, 69.96, 73.32, 'And I''m not sure which one is more valid.', '我也不确定哪一种更正确。', '/ænd aɪm nɑːt ʃʊɹ wɪtʃ wʌn ɪz mɔːɹ vælɪd./', '<span>And</span><span>I''m</span><span>not</span><span tid="117944">sure</span><span>which</span><span>one</span><span>is</span><span>more</span><span tid="117949" class="highlight highlight-a">valid.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 27, 73.32, 77.16, 'And it also depends what you define as success.', '而且这还取决于你如何定义成功。', '/ænd ɪɾ ɔːlsoʊ dᵻpɛndz wʌt juː dᵻfaɪn æz səksɛs./', '<span>And</span><span>it</span><span>also</span><span tid="117953">depends</span><span>what</span><span>you</span><span tid="117956">define</span><span>as</span><span tid="117958">success.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 28, 77.16, 81.18, 'If the end goal is happiness, then why not cut to the chase and just go straight for it.', '如果最终目标是幸福，那为什么不直接奔着幸福去呢？', '/ɪf ðɪ ɛnd ɡoʊl ɪz hæpɪnəs, ðɛn waɪ nɑːt kʌt tə ðə tʃeɪs ænd dʒʌst ɡoʊ stɹeɪt fɔːɹ ɪt./', '<span>If</span><span>the</span><span pid="2104" class="highlight highlight-c">end goal</span><span>is</span><span tid="117964">happiness,</span><span>then</span><span>why</span><span>not</span><span pid="2105" class="highlight highlight-f">cut to the chase</span><span>and</span><span>just</span><span pid="2106" class="highlight highlight-c">go straight for it.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 29, 81.18, 84.48, 'Does being happy make you less successful.', '快乐会不会让你变得没那么成功？', '/dʌz biːɪŋ hæpi meɪk juː lɛs səksɛsfəl./', '<span>Does</span><span>being</span><span tid="117980">happy</span><span tid="117981">make</span><span>you</span><span tid="117983">less</span><span tid="117984">successful.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 30, 84.48, 85.86, 'That is a conventional wisdom.', '这是一种常见的观点。', '/ðæt ɪz ɐ kənvɛnʃənəl wɪzdəm./', '<span>That</span><span>is</span><span>a</span><span tid="117988" class="highlight highlight-a">conventional</span><span tid="117989" class="highlight highlight-a">wisdom.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 31, 85.86, 89.54, 'That may even be the practical earned experience of your reality.', '甚至可能是很多人现实经验中的结论。', '/ðæt meɪ iːvən biː ðə pɹæktɪkəl ɜːnd ɛkspiəɹɪəns ʌv jʊɹ ɹɪælᵻɾi./', '<span>That</span><span tid="117991">may</span><span tid="117992">even</span><span>be</span><span>the</span><span tid="117995" class="highlight highlight-a">practical</span><span tid="117996" class="highlight highlight-a">earned</span><span tid="117997">experience</span><span>of</span><span>your</span><span tid="118000">reality.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 32, 89.54, 91.26, 'You find that when you''re happy, you don''t want anything.', '你会发现，当你很快乐的时候，你其实什么都不想要。', '/juː faɪnd ðæt wɛn jʊɹ hæpi, juː doʊnt wɔnt ɛnɪθɪŋ./', '<span>You</span><span tid="118002">find</span><span>that</span><span>when</span><span>you''re</span><span tid="118006">happy,</span><span>you</span><span>don''t</span><span>want</span><span tid="118010">anything.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 33, 91.26, 92.46, 'So you don''t get up and do anything.', '于是你就不太想起身去做什么。', '/soʊ juː doʊnt ɡɛt ʌp ænd duː ɛnɪθɪŋ./', '<span>So</span><span>you</span><span>don''t</span><span>get</span><span>up</span><span>and</span><span>do</span><span tid="118018">anything.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 34, 92.46, 96.28, 'On the other hand, you know, you still got to do something.', '但另一方面，你还是得做点事情。', '/ɔnðɪ ʌðɚ hænd, juː noʊ, juː stɪl ɡɑːt tə duː sʌmθɪŋ./', '<span>On</span><span>the</span><span tid="118021">other</span><span tid="118022">hand,</span><span>you</span><span>know,</span><span>you</span><span tid="118026">still</span><span>got</span><span>to</span><span>do</span><span>something.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 35, 96.28, 96.92, 'You''re an animal.', '毕竟你是个动物。', '/jʊɹ ɐn ænɪməl./', '<span>You''re</span><span>an</span><span tid="118033">animal.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 36, 96.92, 99.34, 'You''re here You''re here to survive You''re here to replicate.', '你来到这个世界，是为了生存，也是为了繁衍。', '/jʊɹ hɪɹ jʊɹ hɪɹ tə sɚvaɪv jʊɹ hɪɹ tə ɹɛplᵻkeɪt./', '<span>You''re</span><span>here</span><span>You''re</span><span>here</span><span>to</span><span tid="118039">survive</span><span>You''re</span><span>here</span><span>to</span><span tid="118043" class="highlight highlight-a">replicate.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 37, 99.34, 102.52, 'You''re driven You''re motivated You''re going to do something.', '你有驱动力、有动机，总会去做点什么。', '/jʊɹ dɹɪvən jʊɹ moʊɾᵻveɪɾᵻd jʊɹ ɡoʊɪŋ tə duː sʌmθɪŋ./', '<span>You''re</span><span tid="118045">driven</span><span>You''re</span><span tid="118047" class="highlight highlight-a">motivated</span><span>You''re</span><span>going</span><span>to</span><span>do</span><span>something.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 38, 102.52, 103.94, 'You''re not just going to sit there all day.', '你不太可能整天什么都不做地坐在那里。', '/jʊɹ nɑːt dʒʌst ɡoʊɪŋ tə sɪt ðɛɹ ɔːl deɪ./', '<span>You''re</span><span>not</span><span>just</span><span>going</span><span>to</span><span tid="118058">sit</span><span>there</span><span>all</span><span>day.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 39, 103.94, 106.22, 'Unlikely some people do, maybe it''s in their nature.', '当然也有人会这样，也许那是他们的天性。', '/ʌnlaɪkli sʌm piːpəl duː, meɪbiː ɪts ɪn ðɛɹ neɪtʃɚ./', '<span tid="118062" class="highlight highlight-a">Unlikely</span><span>some</span><span tid="118064">people</span><span>do,</span><span tid="118066">maybe</span><span>it''s</span><span>in</span><span>their</span><span tid="118070">nature.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 40, 106.22, 109.08, 'but I think most people still want to act.', '但我觉得大多数人还是想要行动。', '/bʌt aɪ θɪŋk moʊst piːpəl stɪl wɔnt tʊ ækt./', '<span>but</span><span>I</span><span>think</span><span tid="118074">most</span><span tid="118075">people</span><span tid="118076">still</span><span>want</span><span>to</span><span tid="118079" class="highlight highlight-a">act.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 41, 109.08, 111.38, 'They want to live in the arena.', '他们想进入竞技场去生活。', '/ðeɪ wɔnt tə lɪv ɪn ðɪ ɚɹiːnə./', '<span>They</span><span>want</span><span>to</span><span tid="118083">live</span><span>in</span><span>the</span><span tid="118086" class="highlight highlight-a">arena.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 42, 111.38, 116.42, 'I found for myself as I''ve become happier is a big word.', '就我个人而言，我发现当我变得更快乐——当然“快乐”这个词很大。', '/aɪ faʊnd fɔːɹ maɪsɛlf æz aɪv bɪkʌm hæpɪɚɹ ɪz ɐ bɪɡ wɜːd./', '<span>I</span><span tid="118088">found</span><span>for</span><span tid="118090">myself</span><span>as</span><span>I''ve</span><span tid="118093">become</span><span tid="118094">happier</span><span>is</span><span>a</span><span tid="118097">big</span><span tid="118098">word.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 43, 116.42, 121.12, 'but you know, more peaceful, more calm, more present, more satisfied with what I have.', '更准确地说，是更平和、更冷静、更专注当下，也更满足于自己拥有的东西。', '/bʌt juː noʊ, mɔːɹ piːsfəl, mɔːɹ kɑːm, mɔːɹ pɹɛzənt, mɔːɹ sæɾɪsfaɪd wɪð wʌt aɪ hæv./', '<span>but</span><span>you</span><span>know,</span><span>more</span><span tid="118103">peaceful,</span><span>more</span><span tid="118105">calm,</span><span>more</span><span tid="118107" class="highlight highlight-a">present,</span><span>more</span><span tid="118109" class="highlight highlight-a">satisfied</span><span>with</span><span>what</span><span>I</span><span>have.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 44, 121.12, 123.0, 'I still want to do things.', '我依然想做事情。', '/aɪ stɪl wɔnt tə duː θɪŋz./', '<span>I</span><span tid="118115">still</span><span>want</span><span>to</span><span>do</span><span>things.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 45, 123.0, 124.18, 'I just want to do bigger things.', '只是我想做更大的事情。', '/aɪ dʒʌst wɔnt tə duː bɪɡɚ θɪŋz./', '<span>I</span><span>just</span><span>want</span><span>to</span><span>do</span><span tid="118125">bigger</span><span>things.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 46, 124.18, 126.42, 'I want to do things that are more pure.', '我想做更纯粹的事情。', '/aɪ wɔnt tə duː θɪŋz ðæt ɑːɹ mɔːɹ pjʊɹ./', '<span>I</span><span>want</span><span>to</span><span>do</span><span>things</span><span>that</span><span>are</span><span>more</span><span tid="118135">pure.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 47, 126.42, 131.62, 'more aligned with what I think needs to be done and what I can uniquely do.', '更符合我认为应该做的事，也更符合只有我能做的事情。', '/mɔːɹ ɐlaɪnd wɪð wʌt aɪ θɪŋk niːdz təbi dʌn ænd wʌt aɪ kæn juːniːkli duː./', '<span>more</span><span pid="2107" class="highlight highlight-c">aligned with</span><span>what</span><span>I</span><span>think</span><span tid="118142">needs</span><span>to</span><span>be</span><span>done</span><span>and</span><span>what</span><span>I</span><span>can</span><span tid="118150">uniquely</span><span>do.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 48, 131.62, 135.76, 'So in that sense, I think that being happier can actually make you more successful.', '所以从这个意义上说，我觉得更快乐其实会让你更成功。', '/soʊ ɪn ðæt sɛns, aɪ θɪŋk ðæt biːɪŋ hæpɪɚ kæn æktʃuːəli meɪk juː mɔːɹ səksɛsfəl./', '<span>So</span><span pid="2108" class="highlight highlight-i">in that sense,</span><span>I</span><span>think</span><span>that</span><span>being</span><span tid="118160">happier</span><span>can</span><span tid="118162">actually</span><span tid="118163">make</span><span>you</span><span>more</span><span tid="118166">successful.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 49, 135.76, 138.96, 'but your definition of success will likely change along the way.', '只是你对成功的定义，往往会在过程中发生改变。', '/bʌt jʊɹ dɛfɪnɪʃən ʌv səksɛs wɪl laɪkli tʃeɪndʒ ɐlɔŋ ðə weɪ./', '<span>but</span><span>your</span><span tid="118169">definition</span><span>of</span><span tid="118171">success</span><span>will</span><span tid="118173">likely</span><span tid="118174">change</span><span pid="2097" class="highlight highlight-c">along the way.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 50, 138.96, 144.22, 'Is that a realization you think you could have gotten to had you have not had some success in the first place.', '你觉得，如果一开始没有取得一些成功，你还能得到这样的领悟吗？', '/ɪz ðæɾɚ ɹiːəlᵻzeɪʃən juː θɪŋk juː kʊdɐv ɡɑːʔn̩ tə hæd juː hɐvnɑːt hæd sʌm səksɛs ɪnðə fɜːst pleɪs./', '<span>Is</span><span>that</span><span>a</span><span tid="118181">realization</span><span>you</span><span>think</span><span>you</span><span>could</span><span>have</span><span>gotten</span><span>to</span><span>had</span><span>you</span><span>have</span><span>not</span><span>had</span><span>some</span><span tid="118195">success</span><span pid="2101" class="highlight highlight-i">in the first place.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 51, 144.22, 152.6, 'At least for me, I always wanted to take the path of material success first.', '至少对我来说，我一直想先走物质成功这条路。', '/æt liːst fɔːɹ miː, aɪ ɔːlweɪz wɔntᵻd tə teɪk ðə pæθ ʌv mətɪɹiəl səksɛs fɜːst./', '<span>At</span><span tid="118201">least</span><span>for</span><span>me,</span><span>I</span><span tid="118205">always</span><span>wanted</span><span>to</span><span tid="118208">take</span><span>the</span><span tid="118210">path</span><span>of</span><span tid="118212" class="highlight highlight-a">material</span><span tid="118213">success</span><span tid="118214">first.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 52, 152.6, 156.06, 'I was not going to go be an ascetic and sit there and renounce everything.', '我不打算一开始就去当苦行僧，把一切都放下。', '/aɪ wʌz nɑːt ɡoʊɪŋ tə ɡoʊ biː ɐn ɐsɛɾɪk ænd sɪt ðɛɹ ænd ɹᵻnaʊns ɛvɹɪθɪŋ./', '<span>I</span><span>was</span><span>not</span><span>going</span><span>to</span><span>go</span><span>be</span><span>an</span><span tid="118223" class="highlight highlight-a">ascetic</span><span>and</span><span tid="118225">sit</span><span>there</span><span>and</span><span tid="118228" class="highlight highlight-a">renounce</span><span tid="118229">everything.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 53, 156.06, 158.96, 'That just seems too unrealistic and too painful.', '那听起来太不现实，也太痛苦了。', '/ðæt dʒʌst siːmz tuː ʌnɹiːəlɪstɪk ænd tuː peɪnfəl./', '<span>That</span><span>just</span><span tid="118232" class="highlight highlight-a">seems</span><span>too</span><span tid="118234" class="highlight highlight-a">unrealistic</span><span>and</span><span>too</span><span tid="118237" class="highlight highlight-a">painful.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 54, 158.96, 161.9, 'In the story of Buddha, he starts out as a prince.', '在佛陀的故事里，他一开始是个王子。', '/ɪnðə stɔːɹi ʌv buːdə, hiː stɑːɹts aʊt æz ɐ pɹɪns./', '<span>In</span><span>the</span><span tid="118240">story</span><span>of</span><span tid="118242" class="highlight highlight-a">Buddha,</span><span>he</span><span tid="118244">starts</span><span tid="118245">out</span><span>as</span><span>a</span><span tid="118248" class="highlight highlight-a">prince.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 55, 161.9, 166.1, 'And then he sees that it''s all kind of meaningless because you''re still going to get old and die.', '后来他发现这一切其实没有意义，因为人终究还是会变老、会死。', '/ænd ðɛn hiː siːz ðæt ɪts ɔːl kaɪnd ʌv miːnɪŋləs bɪkʌz jʊɹ stɪl ɡoʊɪŋ tə ɡɛt oʊld ænd daɪ./', '<span>And</span><span>then</span><span>he</span><span tid="118252">sees</span><span>that</span><span>it''s</span><span>all</span><span tid="118256">kind</span><span>of</span><span tid="118258" class="highlight highlight-a">meaningless</span><span>because</span><span>you''re</span><span tid="118261">still</span><span>going</span><span>to</span><span>get</span><span tid="118265">old</span><span>and</span><span tid="118267" class="highlight highlight-a">die.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 56, 166.1, 168.68, 'And then he goes into the woods looking for something more.', '于是他走进森林，去寻找更深的答案。', '/ænd ðɛn hiː ɡoʊz ɪntʊ ðə wʊdz lʊkɪŋ fɔːɹ sʌmθɪŋ mɔːɹ./', '<span>And</span><span>then</span><span>he</span><span>goes</span><span tid="118272" class="highlight highlight-a">into</span><span>the</span><span tid="118274">woods</span><span tid="118275" class="highlight highlight-a">looking</span><span>for</span><span>something</span><span>more.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 57, 168.68, 174.5, 'I''ll take the happy route that involves material success Thank you.', '我会选择那条既能获得幸福、又包含物质成功的路，谢谢。', '/aɪl teɪk ðə hæpi ɹaʊt ðæt ɪnvɑːlvz mətɪɹiəl səksɛs θæŋk juː./', '<span>I''ll</span><span tid="118280">take</span><span>the</span><span tid="118282">happy</span><span tid="118283" class="highlight highlight-a">route</span><span>that</span><span tid="118285" class="highlight highlight-a">involves</span><span tid="118286" class="highlight highlight-a">material</span><span tid="118287">success</span><span tid="118288">Thank</span><span>you.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 58, 174.5, 177.44, 'I think it''s quicker in some ways.', '某种程度上，我觉得那样更快。', '/aɪ θɪŋk ɪts kwɪkɚɹ ɪn sʌm weɪz./', '<span>I</span><span>think</span><span>it''s</span><span tid="118293">quicker</span><span pid="2109" class="highlight highlight-i">in some ways.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 59, 177.44, 183.32, 'You know, one of your insights is it''s far easier to achieve our material desires than it is to renounce them.', '你有一个洞见是：实现物质欲望，其实比彻底放下它们要容易得多。', '/juː noʊ, wʌn ʌv jʊɹ ɪnsaɪts ɪz ɪts fɑːɹ iːziɚ tʊ ɐtʃiːv aʊɚ mətɪɹiəl dɪzaɪɚz ðɐn ɪɾ ɪz tə ɹᵻnaʊns ðɛm./', '<span>You</span><span>know,</span><span>one</span><span>of</span><span>your</span><span tid="118302" class="highlight highlight-a">insights</span><span>is</span><span>it''s</span><span tid="118305">far</span><span tid="118306">easier</span><span>to</span><span tid="118308" class="highlight highlight-a">achieve</span><span>our</span><span pid="2110" class="highlight highlight-c">material desires</span><span tid="118312">than</span><span>it</span><span>is</span><span>to</span><span tid="118316" class="highlight highlight-a">renounce</span><span>them.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 60, 183.32, 188.06, 'It depends on the person, but I think you have to try that path.', '这因人而异，但我觉得你还是得试一试那条路。', '/ɪt dᵻpɛndz ɔnðə pɜːsən, bʌt aɪ θɪŋk juː hæv tə tɹaɪ ðæt pæθ./', '<span>It</span><span tid="118319">depends</span><span>on</span><span>the</span><span tid="118322">person,</span><span>but</span><span>I</span><span>think</span><span>you</span><span>have</span><span>to</span><span tid="118329">try</span><span>that</span><span tid="118331">path.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 61, 188.06, 189.9, 'If you want something, go get it.', '如果你想要什么，就去把它拿到手。', '/ɪf juː wɔnt sʌmθɪŋ, ɡoʊ ɡɛt ɪt./', '<span>If</span><span>you</span><span>want</span><span>something,</span><span pid="2111" class="highlight highlight-i">go get it.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 62, 189.9, 194.84, 'You know, like I, I quip that the reason to win the game is to be free of it.', '我常开玩笑说，赢得游戏的意义，是为了从游戏中解脱。', '/juː noʊ, laɪk aɪ, aɪ kwɪp ðætðə ɹiːzən tə wɪn ðə ɡeɪm ɪz təbi fɹiː ʌv ɪt./', '<span>You</span><span>know,</span><span>like</span><span>I,</span><span>I</span><span tid="118344" class="highlight highlight-a">quip</span><span>that</span><span>the</span><span tid="118347">reason</span><span>to</span><span tid="118349">win</span><span>the</span><span tid="118351" class="highlight highlight-a">game</span><span>is</span><span>to</span><span>be</span><span tid="118355">free</span><span>of</span><span>it.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 63, 194.84, 199.72, 'So you, you play the games, you win the games, and then you get, hopefully you get bored of the games.', '所以你去玩这些游戏，赢得这些游戏，然后——希望——你最终会对这些游戏感到厌倦。', '/soʊ juː, juː pleɪ ðə ɡeɪmz, juː wɪn ðə ɡeɪmz, ænd ðɛn juː ɡɛt, hoʊpfəli juː ɡɛt bɔːɹd ʌvðə ɡeɪmz./', '<span>So</span><span>you,</span><span>you</span><span tid="118361">play</span><span>the</span><span tid="118363" class="highlight highlight-a">games,</span><span>you</span><span tid="118365">win</span><span>the</span><span tid="118367" class="highlight highlight-a">games,</span><span>and</span><span>then</span><span>you</span><span>get,</span><span tid="118372" class="highlight highlight-a">hopefully</span><span>you</span><span>get</span><span tid="118375">bored</span><span>of</span><span>the</span><span tid="118378" class="highlight highlight-a">games.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 64, 199.72, 202.38, 'You don''t want to just keep looping on the same game over and over.', '你不会想一直在同一个游戏里反复循环。', '/juː doʊnt wɔnt tə dʒʌst kiːp luːpɪŋ ɔnðə seɪm ɡeɪm oʊvɚ ænd oʊvɚ./', '<span>You</span><span>don''t</span><span>want</span><span>to</span><span>just</span><span tid="118384">keep</span><span tid="118385" class="highlight highlight-a">looping</span><span>on</span><span>the</span><span tid="118388">same</span><span tid="118389" class="highlight highlight-a">game</span><span pid="2112" class="highlight highlight-f">over and over.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 65, 202.38, 206.44, 'Although a lot of these games are very enticing and have many levels and are relatively open -ended.', '当然，这些游戏非常诱人，层级很多，而且往往是开放式的。', '/ɔːlðoʊ ɐ lɑːt ʌv ðiːz ɡeɪmz ɑːɹ vɛɹi ɛntaɪsɪŋ ænd hæv mɛni lɛvəlz ænd ɑːɹ ɹɛlətɪvli oʊpən ɛndᵻd./', '<span tid="118393">Although</span><span>a</span><span tid="118395">lot</span><span>of</span><span>these</span><span tid="118398" class="highlight highlight-a">games</span><span>are</span><span>very</span><span tid="118401" class="highlight highlight-a">enticing</span><span>and</span><span>have</span><span>many</span><span tid="118405">levels</span><span>and</span><span>are</span><span tid="118408">relatively</span><span tid="118409">open</span><span tid="118410">-ended.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 66, 206.44, 209.36, 'Uh, and then you become free of the game.', '然后你就会从这个游戏里获得自由。', '/ʌ, ænd ðɛn juː bɪkʌm fɹiː ʌvðə ɡeɪm./', '<span>Uh,</span><span>and</span><span>then</span><span>you</span><span tid="118415">become</span><span tid="118416">free</span><span>of</span><span>the</span><span tid="118419" class="highlight highlight-a">game.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 67, 209.36, 212.48, 'uh, in a sense that you''re no longer trying to win it.', '某种意义上说，就是你不再执着于赢它。', '/ʌ, ɪn ɐ sɛns ðæt jʊɹ noʊ lɑːŋɡɚ tɹaɪɪŋ tə wɪn ɪt./', '<span>uh,</span><span>in</span><span>a</span><span tid="118423" class="highlight highlight-a">sense</span><span>that</span><span>you''re</span><span>no</span><span tid="118427">longer</span><span tid="118428">trying</span><span>to</span><span tid="118430">win</span><span>it.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 68, 212.48, 213.54, 'you know, you can win it.', '你知道自己可以赢。', '/juː noʊ, juː kæn wɪn ɪt./', '<span>you</span><span>know,</span><span>you</span><span>can</span><span tid="118436">win</span><span>it.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 69, 213.54, 218.26, 'uh, and either you move to a different game or you play the game for the sheer joy of it.', '于是你要么换一个新的游戏，要么只是单纯享受游戏本身的乐趣。', '/ʌ, ænd iːðɚ juː muːv tʊ ɐ dɪfɹənt ɡeɪm ɔːɹ juː pleɪ ðə ɡeɪm fɚðə ʃɪɹ dʒɔɪ ʌv ɪt./', '<span>uh,</span><span>and</span><span tid="118440">either</span><span>you</span><span tid="118442">move</span><span>to</span><span>a</span><span tid="118445">different</span><span tid="118446" class="highlight highlight-a">game</span><span>or</span><span>you</span><span tid="118449">play</span><span>the</span><span tid="118451" class="highlight highlight-a">game</span><span>for</span><span>the</span><span tid="118454" class="highlight highlight-a">sheer</span><span tid="118455">joy</span><span>of</span><span>it.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 70, 218.26, 220.96, 'Yeah Another one of yours.', '对，还有你说过的一句话。', '/jɛh ɐnʌðɚ wʌn ʌv jɔːɹz./', '<span>Yeah</span><span tid="118459">Another</span><span>one</span><span>of</span><span>yours.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 71, 220.96, 223.9, 'Most of the gains in life come from suffering in the short term.', '人生大多数收获，都来自短期的痛苦。', '/moʊst əv ðə ɡeɪnz ɪn laɪf kʌm fɹʌm sʌfɚɹɪŋ ɪnðə ʃɔːɹt tɜːm./', '<span tid="118463">Most</span><span>of</span><span>the</span><span tid="118466">gains</span><span>in</span><span tid="118468">life</span><span tid="118469">come</span><span>from</span><span tid="118471" class="highlight highlight-a">suffering</span><span pid="2113" class="highlight highlight-c">in the short term.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 72, 223.9, 226.96, 'so you can get paid in the long term I think that''s classic.', '这样你才能在长期得到回报——这很经典。', '/soʊ juː kæn ɡɛt peɪd ɪnðə lɔŋ tɜːm aɪ θɪŋk ðæts klæsɪk./', '<span>so</span><span>you</span><span>can</span><span>get</span><span tid="118480">paid</span><span pid="2096" class="highlight highlight-c">in the long term</span><span>I</span><span>think</span><span>that''s</span><span tid="118488" class="highlight highlight-a">classic.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 73, 226.96, 229.52, 'Winning the marshmallow test on a daily basis.', '就像每天都在通过“棉花糖实验”。', '/wɪnɪŋ ðə mɑːɹʃmɐloʊ tɛst ɔn ɐ deɪli beɪsɪs./', '<span tid="118489">Winning</span><span>the</span><span pid="2114" class="highlight highlight-b">marshmallow test</span><span pid="2094" class="highlight highlight-i">on a daily basis.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 74, 229.52, 235.46, 'but, uh, there''s an interesting challenge where I think people need to avoid becoming a suffering addict.', '但我觉得有个很有意思的挑战是，人们需要避免变成“受苦上瘾”。', '/bʌt, ʌ, ðɛɹz ɐn ɪntɹɛstɪŋ tʃælɪndʒ wɛɹ aɪ θɪŋk piːpəl niːd tʊ ɐvɔɪd bᵻkʌmɪŋ ɐ sʌfɚɹɪŋ ædɪkt./', '<span>but,</span><span>uh,</span><span>there''s</span><span>an</span><span tid="118501">interesting</span><span tid="118502">challenge</span><span>where</span><span>I</span><span>think</span><span tid="118506">people</span><span tid="118507">need</span><span>to</span><span tid="118509" class="highlight highlight-a">avoid</span><span tid="118510">becoming</span><span>a</span><span tid="118512" class="highlight highlight-a">suffering</span><span tid="118513" class="highlight highlight-a">addict.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 75, 235.46, 239.04, 'sort of using suffering as the proxy for progress.', '也就是把痛苦当作进步的替代指标。', '/sɔːɹt ʌv juːzɪŋ sʌfɚɹɪŋ æz ðə pɹɑːksi fɔːɹ pɹɑːɡɹɛs./', '<span tid="118514">sort</span><span>of</span><span tid="118516">using</span><span tid="118517" class="highlight highlight-a">suffering</span><span>as</span><span>the</span><span tid="118520" class="highlight highlight-a">proxy</span><span>for</span><span tid="118522" class="highlight highlight-a">progress.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 76, 239.04, 242.62, 'as opposed to the outcome of the suffering, right.', '而不是关注痛苦最终带来的结果。', '/æz əpoʊzd tə ðɪ aʊtkʌm ʌvðə sʌfɚɹɪŋ, ɹaɪt./', '<span pid="2115" class="highlight highlight-c">as opposed to</span><span>the</span><span tid="118527" class="highlight highlight-a">outcome</span><span>of</span><span>the</span><span tid="118530" class="highlight highlight-a">suffering,</span><span tid="118531" class="highlight highlight-a">right.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 77, 242.62, 245.52, 'It''s like I was in pain, not eating the marshmallow.', '就像：我忍住没吃棉花糖，很痛苦。', '/ɪts laɪk aɪ wʌz ɪn peɪn, nɑːt iːɾɪŋ ðə mɑːɹʃmɐloʊ./', '<span>It''s</span><span>like</span><span>I</span><span>was</span><span>in</span><span tid="118537">pain,</span><span>not</span><span tid="118539">eating</span><span>the</span><span tid="118541" class="highlight highlight-a">marshmallow.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 78, 245.52, 247.2, 'I was in pain doing this work.', '我做这些工作也很痛苦。', '/aɪ wʌz ɪn peɪn duːɪŋ ðɪs wɜːk./', '<span>I</span><span>was</span><span>in</span><span tid="118545">pain</span><span>doing</span><span>this</span><span tid="118548">work.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 79, 247.2, 252.78, 'I have attached well -being and satisfaction to pain.', '于是我把幸福感和满足感和痛苦绑定在一起。', '/aɪ hæv ɐtætʃt wɛl biːɪŋ ænd sæɾɪsfækʃən tə peɪn./', '<span>I</span><span>have</span><span tid="118551" class="highlight highlight-a">attached</span><span tid="118552">well</span><span tid="118553">-being</span><span>and</span><span tid="118555" class="highlight highlight-a">satisfaction</span><span>to</span><span tid="118557">pain.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 80, 252.78, 255.3, 'not to what the pain gets me on the other side of it.', '而不是绑定在痛苦之后得到的结果上。', '/nɑːt tə wʌt ðə peɪn ɡɛts miː ɔnðɪ ʌðɚ saɪd ʌv ɪt./', '<span>not</span><span>to</span><span>what</span><span>the</span><span tid="118562">pain</span><span>gets</span><span>me</span><span>on</span><span>the</span><span tid="118567">other</span><span tid="118568">side</span><span>of</span><span>it.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 81, 255.3, 259.4, 'If you define pain as physical pain, then it''s a real thing.', '如果你把痛苦定义为身体上的疼痛，那它确实是客观存在的。', '/ɪf juː dᵻfaɪn peɪn æz fɪzɪkəl peɪn, ðɛn ɪts ɐ ɹiːəl θɪŋ./', '<span>If</span><span>you</span><span tid="118573">define</span><span tid="118574">pain</span><span>as</span><span pid="2116" class="highlight highlight-c">physical pain,</span><span>then</span><span>it''s</span><span>a</span><span tid="118581">real</span><span>thing.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 82, 259.4, 262.94, 'It happens and you can''t ignore it, but that''s not what we mean by suffering.', '它发生时你无法忽视，但我们说的“受苦”不是这个意思。', '/ɪt hæpənz ænd juː kænt ɪɡnɔːɹ ɪt, bʌt ðæts nɑːt wʌt wiː miːn baɪ sʌfɚɹɪŋ./', '<span>It</span><span tid="118584">happens</span><span>and</span><span>you</span><span tid="118587">can''t</span><span tid="118588">ignore</span><span>it,</span><span>but</span><span>that''s</span><span>not</span><span>what</span><span>we</span><span tid="118595">mean</span><span>by</span><span tid="118597" class="highlight highlight-a">suffering.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 83, 262.94, 265.36, 'Suffering is mostly mental anguish and mental pain.', '所谓受苦，大多数是精神上的折磨和心理上的痛苦。', '/sʌfɚɹɪŋ ɪz moʊstli mɛntəl æŋɡwɪʃ ænd mɛntəl peɪn./', '<span tid="118598" class="highlight highlight-a">Suffering</span><span>is</span><span tid="118600" class="highlight highlight-a">mostly</span><span tid="118601" class="highlight highlight-a">mental</span><span tid="118602" class="highlight highlight-a">anguish</span><span>and</span><span pid="2117" class="highlight highlight-c">mental pain.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 84, 265.36, 268.0, 'And it just means you don''t want to do the task at hand.', '其实它只是意味着你不想做眼前的事情。', '/ænd ɪt dʒʌst miːnz juː doʊnt wɔnt tə duː ðə tæsk æt hænd./', '<span>And</span><span>it</span><span>just</span><span tid="118609">means</span><span>you</span><span>don''t</span><span>want</span><span>to</span><span>do</span><span>the</span><span tid="118616">task</span><span pid="2118" class="highlight highlight-c">at hand.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 85, 268.0, 271.56, 'Uh, if you were fine doing the task at hand, then you wouldn''t be suffering.', '如果你很愿意做这件事，那你就不会觉得在受苦。', '/ʌ, ɪf juː wɜː faɪn duːɪŋ ðə tæsk æt hænd, ðɛn juː wʊdənt biː sʌfɚɹɪŋ./', '<span>Uh,</span><span>if</span><span>you</span><span>were</span><span tid="118623" class="highlight highlight-a">fine</span><span>doing</span><span>the</span><span tid="118626">task</span><span pid="2119" class="highlight highlight-c">at hand,</span><span>then</span><span>you</span><span>wouldn''t</span><span>be</span><span tid="118633" class="highlight highlight-a">suffering.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 86, 271.56, 277.12, 'And then the question is what''s more effective to suffer along the way, or just to interpret it in a way that it''s not suffering.', '所以问题是：一路受苦更有效，还是换一种解释方式，让自己不觉得这是受苦？', '/ænd ðɛn ðə kwɛstʃən ɪz wʌts mɔːɹ ɪfɛktɪv tə sʌfɚɹ ɐlɔŋ ðə weɪ, ɔːɹ dʒʌst tʊ ɪntɜːpɹɪt ɪɾ ɪn ɐ weɪ ðæt ɪts nɑːt sʌfɚɹɪŋ./', '<span>And</span><span>then</span><span>the</span><span tid="118637">question</span><span>is</span><span>what''s</span><span>more</span><span tid="118641" class="highlight highlight-a">effective</span><span>to</span><span tid="118643" class="highlight highlight-a">suffer</span><span pid="2098" class="highlight highlight-c">along the way,</span><span>or</span><span>just</span><span>to</span><span tid="118650" class="highlight highlight-a">interpret</span><span>it</span><span pid="2092" class="highlight highlight-c">in a way</span><span>that</span><span>it''s</span><span>not</span><span tid="118658" class="highlight highlight-a">suffering.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 87, 277.12, 282.32, 'You hear from a lot of successful people, they look back and they say, oh, the journey was a fun part, right.', '很多成功人士回头看时都会说：其实过程才是最有趣的部分。', '/juː hɪɹ fɹʌm ɐ lɑːt ʌv səksɛsfəl piːpəl, ðeɪ lʊk bæk ænd ðeɪ seɪ, oʊ, ðə dʒɜːni wʌzɐ fʌn pɑːɹt, ɹaɪt./', '<span>You</span><span tid="118660">hear</span><span>from</span><span>a</span><span tid="118663">lot</span><span>of</span><span tid="118665">successful</span><span tid="118666">people,</span><span>they</span><span tid="118668" class="highlight highlight-a">look</span><span tid="118669" class="highlight highlight-a">back</span><span>and</span><span>they</span><span tid="118672">say,</span><span>oh,</span><span>the</span><span tid="118675">journey</span><span>was</span><span>a</span><span tid="118678">fun</span><span tid="118679">part,</span><span tid="118680" class="highlight highlight-a">right.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 88, 282.32, 285.1, 'That was actually the entertaining part and I should have enjoyed it more.', '那其实才是最精彩的时光，而我当时应该更好地享受它。', '/ðæt wʌz æktʃuːəli ðɪ ɛntɚteɪnɪŋ pɑːɹt ænd aɪ ʃʊdəv ɛndʒɔɪd ɪt mɔːɹ./', '<span>That</span><span>was</span><span tid="118683">actually</span><span>the</span><span tid="118685">entertaining</span><span tid="118686">part</span><span>and</span><span>I</span><span tid="118689">should</span><span>have</span><span tid="118691">enjoyed</span><span>it</span><span>more.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 89, 285.1, 287.26, 'It''s a common regret Uh.', '这是一种很常见的遗憾。', '/ɪts ɐ kɑːmən ɹᵻɡɹɛt ʌ./', '<span>It''s</span><span>a</span><span tid="118696">common</span><span tid="118697" class="highlight highlight-a">regret</span><span>Uh.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 90, 287.26, 289.16, 'there''s a little thought exercise I like to do.', '我喜欢做一个小小的思想实验。', '/ðɛɹz ɐ lɪɾəl θɔːt ɛksɚsaɪz aɪ laɪk tə duː./', '<span>there''s</span><span>a</span><span tid="118701">little</span><span pid="2120" class="highlight highlight-c">thought exercise</span><span>I</span><span>like</span><span>to</span><span>do.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 91, 289.16, 292.38, 'which is you can go back into your own life.', '就是回到你自己的人生里。', '/wɪtʃ ɪz juː kæn ɡoʊ bæk ɪntʊ jʊɹ oʊn laɪf./', '<span>which</span><span>is</span><span>you</span><span>can</span><span>go</span><span tid="118713" class="highlight highlight-a">back</span><span tid="118714" class="highlight highlight-a">into</span><span>your</span><span tid="118716" class="highlight highlight-a">own</span><span tid="118717">life.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 92, 292.38, 297.86, 'and, uh, try to put yourself in the exact position you were in five years ago.', '试着把自己放回五年前的那个位置。', '/ænd, ʌ, tɹaɪ tə pʊt jɔːɹsɛlf ɪnðɪ ɛɡzækt pəzɪʃən juː wɜːɹ ɪn faɪv jɪɹz ɐɡoʊ./', '<span>and,</span><span>uh,</span><span tid="118720">try</span><span>to</span><span tid="118722">put</span><span tid="118723">yourself</span><span>in</span><span>the</span><span tid="118726" class="highlight highlight-a">exact</span><span tid="118727" class="highlight highlight-a">position</span><span>you</span><span>were</span><span>in</span><span>five</span><span tid="118732">years</span><span tid="118733">ago.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 93, 297.86, 300.06, '10 years ago, 15 years ago, 20 years ago.', '或者十年前、十五年前、二十年前。', '/tɛn jɪɹz ɐɡoʊ, fɪftiːn jɪɹz ɐɡoʊ, twɛnti jɪɹz ɐɡoʊ./', '<span>10</span><span tid="118735">years</span><span tid="118736">ago,</span><span>15</span><span tid="118738">years</span><span tid="118739">ago,</span><span>20</span><span tid="118741">years</span><span tid="118742">ago.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 94, 300.06, 303.22, 'and you try to remember, okay, who was I with What was I doing.', '然后去回忆：当时我和谁在一起？我在做什么？', '/ænd juː tɹaɪ tə ɹᵻmɛmbɚ, oʊkeɪ, huː wʌz aɪ wɪð wʌt wʌz aɪ duːɪŋ./', '<span>and</span><span>you</span><span tid="118745">try</span><span>to</span><span tid="118747">remember,</span><span>okay,</span><span>who</span><span>was</span><span>I</span><span>with</span><span>What</span><span>was</span><span>I</span><span>doing.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 95, 303.22, 305.62, 'What was I feeling What were my emotions.', '我当时是什么感觉？我的情绪是什么？', '/wʌt wʌz aɪ fiːlɪŋ wʌt wɜː maɪ ɪmoʊʃənz./', '<span>What</span><span>was</span><span>I</span><span tid="118760">feeling</span><span>What</span><span>were</span><span>my</span><span tid="118764" class="highlight highlight-a">emotions.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 96, 305.62, 309.18, 'What were my objectives And really, really try to transport yourself back.', '我的目标是什么？尽可能把自己真正带回那个时刻。', '/wʌt wɜː maɪ ɑːbdʒɛktɪvz ænd ɹiəli, ɹiəli tɹaɪ tə tɹænspɔːɹt jɔːɹsɛlf bæk./', '<span>What</span><span>were</span><span>my</span><span tid="118768" class="highlight highlight-a">objectives</span><span>And</span><span tid="118770">really,</span><span tid="118771">really</span><span tid="118772">try</span><span>to</span><span tid="118774" class="highlight highlight-a">transport</span><span tid="118775">yourself</span><span tid="118776" class="highlight highlight-a">back.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 97, 309.18, 312.72, 'and see if there''s any advice you''d give yourself, anything you''d do differently.', '然后看看你会不会给当时的自己一些建议，或者会不会做出不同的选择。', '/ænd siː ɪf ðɛɹz ɛni ɐdvaɪs juːd ɡɪv jɔːɹsɛlf, ɛnɪθɪŋ juːd duː dɪfɹəntli./', '<span>and</span><span tid="118778">see</span><span>if</span><span>there''s</span><span tid="118781">any</span><span tid="118782">advice</span><span>you''d</span><span tid="118784">give</span><span tid="118785">yourself,</span><span tid="118786">anything</span><span>you''d</span><span>do</span><span tid="118789">differently.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 98, 312.72, 314.4, 'Now you don''t have new information.', '注意，你不能假设自己拥有新的信息。', '/naʊ juː doʊnt hæv nuː ɪnfɚmeɪʃən./', '<span tid="118790">Now</span><span>you</span><span>don''t</span><span>have</span><span tid="118794">new</span><span tid="118795">information.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 99, 314.4, 318.7, 'Don''t pretend you could have gone back and, you know, bought a stock or bought Bitcoin or whatever.', '不要假装你可以回去买某只股票或者买比特币之类的。', '/doʊnt pɹɪtɛnd juː kʊdɐv ɡɔn bæk ænd, juː noʊ, bɔːt ɐ stɑːk ɔːɹ bɔːt bɪtkɔɪn ɔːɹ wʌtɛvɚ./', '<span>Don''t</span><span tid="118797" class="highlight highlight-a">pretend</span><span>you</span><span>could</span><span>have</span><span>gone</span><span tid="118802" class="highlight highlight-a">back</span><span>and,</span><span>you</span><span>know,</span><span tid="118806">bought</span><span>a</span><span tid="118808" class="highlight highlight-a">stock</span><span>or</span><span tid="118810">bought</span><span tid="118811" class="highlight highlight-a">Bitcoin</span><span pid="2121" class="highlight highlight-i">or whatever.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 100, 318.7, 325.72, 'but just knowing what you know now in terms of your temperament and a little bit of age related experience.', '只是基于你现在对自己性格的理解，以及一点年龄带来的经验。', '/bʌt dʒʌst noʊɪŋ wʌt juː noʊ naʊ ɪn tɜːmz ʌv jʊɹ tɛmpɹəmənt ænd ɐ lɪɾəl bɪt ʌv eɪdʒ ɹᵻleɪɾᵻd ɛkspiəɹɪəns./', '<span>but</span><span>just</span><span>knowing</span><span>what</span><span>you</span><span>know</span><span tid="118820">now</span><span>in</span><span tid="118822" class="highlight highlight-a">terms</span><span>of</span><span>your</span><span tid="118825" class="highlight highlight-a">temperament</span><span>and</span><span>a</span><span tid="118828">little</span><span tid="118829">bit</span><span>of</span><span tid="118831" class="highlight highlight-a">age</span><span tid="118832" class="highlight highlight-a">related</span><span tid="118833">experience.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 101, 325.72, 328.26, 'how would you have done things differently.', '你会怎么做得不同？', '/haʊ wʊd juː hæv dʌn θɪŋz dɪfɹəntli./', '<span>how</span><span>would</span><span>you</span><span>have</span><span>done</span><span>things</span><span tid="118840">differently.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 102, 328.26, 330.46, 'And I think it''s a worthwhile exercise to do.', '我觉得这是一个非常值得做的练习。', '/ænd aɪ θɪŋk ɪts ɐ wɜːθwaɪl ɛksɚsaɪz tə duː./', '<span>And</span><span>I</span><span>think</span><span>it''s</span><span>a</span><span tid="118846" class="highlight highlight-a">worthwhile</span><span tid="118847" class="highlight highlight-a">exercise</span><span>to</span><span>do.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 103, 330.46, 332.22, 'So don''t let me rob you of the conclusion.', '不过我不想替你得出结论。', '/soʊ doʊnt lɛt miː ɹɑːb juː ʌvðə kəŋkluːʒən./', '<span>So</span><span>don''t</span><span>let</span><span>me</span><span tid="118854">rob</span><span>you</span><span>of</span><span>the</span><span tid="118858">conclusion.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 104, 332.22, 338.02, 'but I''ll tell you for me, uh, I would have done everything the same.', '但就我自己来说，我大概还是会做同样的事情。', '/bʌt aɪl tɛl juː fɔːɹ miː, ʌ, aɪ wʊdhɐv dʌn ɛvɹɪθɪŋ ðə seɪm./', '<span>but</span><span>I''ll</span><span tid="118861">tell</span><span>you</span><span>for</span><span>me,</span><span>uh,</span><span>I</span><span>would</span><span>have</span><span>done</span><span tid="118870">everything</span><span>the</span><span tid="118872">same.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 105, 338.02, 342.32, 'except I would have done it with less anger, less emotion, less internal suffering.', '唯一的区别是，我会少一点愤怒、少一点情绪、少一点内心的折磨。', '/ɛksɛpt aɪ wʊdhɐv dʌn ɪt wɪð lɛs æŋɡɚ, lɛs ɪmoʊʃən, lɛs ɪntɜːnəl sʌfɚɹɪŋ./', '<span tid="118873" class="highlight highlight-a">except</span><span>I</span><span>would</span><span>have</span><span>done</span><span>it</span><span>with</span><span tid="118880">less</span><span tid="118881">anger,</span><span tid="118882">less</span><span tid="118883" class="highlight highlight-a">emotion,</span><span tid="118884">less</span><span tid="118885">internal</span><span tid="118886" class="highlight highlight-a">suffering.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 106, 342.32, 344.6, 'because that was optional It wasn''t necessary.', '因为那些其实是可以选择不要的，并不是必须的。', '/bɪkʌz ðæt wʌz ɑːpʃənəl ɪt wʌzn̩t nɛsᵻsɚɹi./', '<span>because</span><span>that</span><span>was</span><span tid="118890">optional</span><span>It</span><span tid="118892">wasn''t</span><span tid="118893">necessary.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 107, 344.6, 348.14, 'And I would argue that someone who can do the job.', '而且我认为，一个能够把事情做好的人。', '/ænd aɪ wʊd ɑːɹɡjuː ðæt sʌmwʌn huː kæn duː ðə dʒɑːb./', '<span>And</span><span>I</span><span>would</span><span tid="118897" class="highlight highlight-a">argue</span><span>that</span><span tid="118899">someone</span><span>who</span><span>can</span><span>do</span><span>the</span><span tid="118904">job.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 108, 348.14, 355.5, 'uh, at least peacefully, but maybe happily is going to be more effective than someone who has unnecessary emotional turmoil.', '如果至少能在平和的状态下工作，甚至是快乐地工作，会比情绪内耗的人更高效。', '/ʌ, æt liːst piːsfəli, bʌt meɪbiː hæpɪli ɪz ɡoʊɪŋ təbi mɔːɹ ɪfɛktɪv ðɐn sʌmwʌn huː hɐz ʌnnɛsᵻsɚɹi ɪmoʊʃənəl tɜːmɔɪl./', '<span>uh,</span><span>at</span><span tid="118907">least</span><span tid="118908">peacefully,</span><span>but</span><span tid="118910">maybe</span><span tid="118911">happily</span><span>is</span><span>going</span><span>to</span><span>be</span><span>more</span><span tid="118917" class="highlight highlight-a">effective</span><span tid="118918">than</span><span tid="118919">someone</span><span>who</span><span>has</span><span tid="118922">unnecessary</span><span tid="118923" class="highlight highlight-a">emotional</span><span tid="118924" class="highlight highlight-a">turmoil.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 109, 355.5, 359.66, 'Well, you end up with a series of miserable successes, right.', '否则最后你得到的只是一连串“痛苦的成功”。', '/wɛl, juː ɛnd ʌp wɪð ɐ sɪɹiz ʌv mɪzɹəbəl səksɛsᵻz, ɹaɪt./', '<span tid="118925">Well,</span><span>you</span><span tid="118927">end</span><span>up</span><span>with</span><span>a</span><span tid="118931" class="highlight highlight-a">series</span><span>of</span><span tid="118933">miserable</span><span tid="118934">successes,</span><span tid="118935" class="highlight highlight-a">right.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 110, 359.66, 364.06, 'The outcome may have been the same, but the entire experience of getting there.', '结果也许一样，但整个过程的体验却完全不同。', '/ðɪ aʊtkʌm meɪhɐv bɪn ðə seɪm, bʌt ðɪ ɛntaɪɚɹ ɛkspiəɹɪəns ʌv ɡɛɾɪŋ ðɛɹ./', '<span>The</span><span tid="118937" class="highlight highlight-a">outcome</span><span tid="118938">may</span><span>have</span><span>been</span><span>the</span><span tid="118942">same,</span><span>but</span><span>the</span><span tid="118945" class="highlight highlight-a">entire</span><span tid="118946">experience</span><span>of</span><span>getting</span><span>there.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 111, 364.06, 365.72, 'And the journey is not only the reward.', '而且过程不仅仅是奖励。', '/ænd ðə dʒɜːni ɪz nɑːt oʊnli ðə ɹᵻwɔːɹd./', '<span>And</span><span>the</span><span tid="118952">journey</span><span>is</span><span>not</span><span tid="118955">only</span><span>the</span><span tid="118957" class="highlight highlight-a">reward.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 112, 365.72, 367.14, 'the journey is the only thing there is.', '过程其实就是全部。', '/ðə dʒɜːni ɪz ðɪ oʊnli θɪŋ ðɛɹɪz./', '<span>the</span><span tid="118959">journey</span><span>is</span><span>the</span><span tid="118962">only</span><span>thing</span><span>there</span><span>is.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 113, 367.14, 372.9, 'you know, even success, it''s human nature to bank it very, very quickly, right.', '即便是成功，人类也会非常非常快地把它存档。', '/juː noʊ, iːvən səksɛs, ɪts hjuːmən neɪtʃɚ tə bæŋk ɪt vɛɹi, vɛɹi kwɪkli, ɹaɪt./', '<span>you</span><span>know,</span><span tid="118968">even</span><span tid="118969">success,</span><span>it''s</span><span tid="118971">human</span><span tid="118972">nature</span><span>to</span><span tid="118974" class="highlight highlight-a">bank</span><span>it</span><span>very,</span><span>very</span><span tid="118978">quickly,</span><span tid="118979" class="highlight highlight-a">right.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 114, 372.9, 375.96, 'Because the normal loop that we run through is you sit around.', '因为我们通常的循环是这样的：你先无聊地待着。', '/bɪkʌz ðə nɔːɹməl luːp ðæt wiː ɹʌn θɹuː ɪz juː sɪt ɚɹaʊnd./', '<span>Because</span><span>the</span><span tid="118982">normal</span><span tid="118983" class="highlight highlight-a">loop</span><span>that</span><span>we</span><span tid="118986">run</span><span tid="118987">through</span><span>is</span><span>you</span><span tid="118990">sit</span><span tid="118991">around.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 115, 375.96, 378.32, 'you''re bored, then you want something.', '然后你开始想要某样东西。', '/jʊɹ bɔːɹd, ðɛn juː wɔnt sʌmθɪŋ./', '<span>you''re</span><span tid="118993" class="highlight highlight-a">bored,</span><span>then</span><span>you</span><span>want</span><span>something.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 116, 378.32, 382.42, 'then when you want something, you decide you''re not going to be happy until you get that thing.', '一旦想要，你就会觉得在得到它之前自己都不会快乐。', '/ðɛn wɛn juː wɔnt sʌmθɪŋ, juː dᵻsaɪd jʊɹ nɑːt ɡoʊɪŋ təbi hæpi ʌntɪl juː ɡɛt ðæt θɪŋ./', '<span>then</span><span>when</span><span>you</span><span>want</span><span>something,</span><span>you</span><span tid="119004">decide</span><span>you''re</span><span>not</span><span>going</span><span>to</span><span>be</span><span tid="119010">happy</span><span tid="119011" class="highlight highlight-a">until</span><span>you</span><span>get</span><span>that</span><span>thing.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 117, 382.42, 387.36, 'then you start your bout of suffering or anticipation while you strive to get that thing.', '于是你开始在追求它的过程中受苦或期待。', '/ðɛn juː stɑːɹt jʊɹ baʊt ʌv sʌfɚɹɪŋ ɔːɹ æntɪsɪpeɪʃən waɪl juː stɹaɪv tə ɡɛt ðæt θɪŋ./', '<span>then</span><span>you</span><span tid="119018">start</span><span>your</span><span tid="119020" class="highlight highlight-a">bout</span><span>of</span><span tid="119022" class="highlight highlight-a">suffering</span><span>or</span><span tid="119024">anticipation</span><span tid="119025">while</span><span>you</span><span tid="119027">strive</span><span>to</span><span>get</span><span>that</span><span>thing.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 118, 387.36, 391.12, 'If you get that thing, then you get used to it and then you get bored again.', '如果你得到了它，很快就会习惯，然后又开始无聊。', '/ɪf juː ɡɛt ðæt θɪŋ, ðɛn juː ɡɛt juːzd tʊ ɪt ænd ðɛn juː ɡɛt bɔːɹd ɐɡɛn./', '<span>If</span><span>you</span><span>get</span><span>that</span><span>thing,</span><span>then</span><span>you</span><span pid="2093" class="highlight highlight-c">get used to</span><span>it</span><span>and</span><span>then</span><span>you</span><span>get</span><span tid="119047" class="highlight highlight-a">bored</span><span tid="119048">again.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 119, 391.12, 392.82, 'Then a few months later, you want something else.', '几个月后，你又想要新的东西。', '/ðɛn ɐ fjuː mʌnθs leɪɾɚ, juː wɔnt sʌmθɪŋ ɛls./', '<span>Then</span><span>a</span><span tid="119051">few</span><span tid="119052">months</span><span tid="119053" class="highlight highlight-a">later,</span><span>you</span><span>want</span><span>something</span><span tid="119057">else.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 120, 392.82, 395.4, 'And if you don''t get it, then you''re unhappy for a bit.', '如果没得到，你会短暂地不开心。', '/ænd ɪf juː doʊnt ɡɛt ɪt, ðɛn jʊɹ ʌnhæpi fɚɹə bɪt./', '<span>And</span><span>if</span><span>you</span><span>don''t</span><span>get</span><span>it,</span><span>then</span><span>you''re</span><span tid="119066">unhappy</span><span>for</span><span>a</span><span tid="119069">bit.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 121, 395.4, 398.78, 'And then you get over it and then you want something else, right That''s the normal cycle.', '然后你又会走出来，再想要别的东西——这就是常见的循环。', '/ænd ðɛn juː ɡɛt oʊvɚɹ ɪt ænd ðɛn juː wɔnt sʌmθɪŋ ɛls, ɹaɪt ðæts ðə nɔːɹməl saɪkəl./', '<span>And</span><span>then</span><span>you</span><span pid="2122" class="highlight highlight-f">get over it</span><span>and</span><span>then</span><span>you</span><span>want</span><span>something</span><span tid="119081">else,</span><span tid="119082" class="highlight highlight-a">right</span><span>That''s</span><span>the</span><span tid="119085">normal</span><span tid="119086">cycle.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 122, 398.78, 404.1, 'So whether you''re happy or unhappy at the end, it tends not to last.', '所以无论最后你是快乐还是不快乐，这种状态往往都不会持续太久。', '/soʊ wɛðɚ jʊɹ hæpi ɔːɹ ʌnhæpi æt ðɪ ɛnd, ɪt tɛndz nɑːt tə læst./', '<span>So</span><span tid="119088">whether</span><span>you''re</span><span tid="119090">happy</span><span>or</span><span tid="119092">unhappy</span><span>at</span><span>the</span><span tid="119095">end,</span><span>it</span><span tid="119097" class="highlight highlight-a">tends</span><span>not</span><span>to</span><span tid="119100" class="highlight highlight-a">last.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 123, 404.1, 406.06, 'Now I don''t want to be glib and say that.', '当然，我不想轻描淡写地说。', '/naʊ aɪ doʊnt wɔnt təbi ɡlɪb ænd seɪ ðæt./', '<span tid="119101">Now</span><span>I</span><span>don''t</span><span>want</span><span>to</span><span>be</span><span tid="119107" class="highlight highlight-a">glib</span><span>and</span><span tid="119109">say</span><span>that.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 124, 406.06, 409.34, 'oh, there''s no point in making money or being successful There absolutely is.', '赚钱或者成功没有意义——那绝对不是。', '/oʊ, ðɛɹz noʊ pɔɪnt ɪn meɪkɪŋ mʌni ɔːɹ biːɪŋ səksɛsfəl ðɛɹ æbsəluːtli ɪz./', '<span>oh,</span><span pid="2123" class="highlight highlight-i">there''s no point in</span><span tid="119116">making</span><span tid="119117">money</span><span>or</span><span>being</span><span tid="119120">successful</span><span>There</span><span tid="119122" class="highlight highlight-a">absolutely</span><span>is.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 125, 409.34, 410.82, 'Money solves all your money problems.', '钱能解决所有和钱有关的问题。', '/mʌni sɑːlvz ɔːl jʊɹ mʌni pɹɑːbləmz./', '<span tid="119124">Money</span><span tid="119125">solves</span><span>all</span><span>your</span><span tid="119128">money</span><span tid="119129">problems.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 126, 410.82, 412.28, 'So it is good to have money.', '所以拥有钱当然是好事。', '/soʊ ɪɾ ɪz ɡʊd tə hæv mʌni./', '<span>So</span><span>it</span><span>is</span><span>good</span><span>to</span><span>have</span><span tid="119136">money.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 127, 412.28, 416.38, 'Um, that said, there are those, uh, those stories.', '不过确实有一些故事。', '/ʌm, ðæt sɛd, ðɛɹɑːɹ ðoʊz, ʌ, ðoʊz stɔːɹiz./', '<span tid="119137">Um,</span><span pid="2124" class="highlight highlight-i">that said,</span><span>there</span><span>are</span><span>those,</span><span>uh,</span><span>those</span><span tid="119145">stories.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 128, 416.38, 417.6, 'I don''t know if you''ve seen those studies.', '我不知道你有没有看过那些研究。', '/aɪ doʊnt noʊ ɪf juːv siːn ðoʊz stʌdiz./', '<span>I</span><span>don''t</span><span>know</span><span>if</span><span>you''ve</span><span tid="119151">seen</span><span>those</span><span tid="119153">studies.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 129, 417.6, 418.6, 'I don''t know how real these are.', '也不知道它们到底有多可靠。', '/aɪ doʊnt noʊ haʊ ɹiːəl ðiːz ɑːɹ./', '<span>I</span><span>don''t</span><span>know</span><span>how</span><span tid="119158">real</span><span>these</span><span>are.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 130, 418.6, 420.12, 'A lot of these psych studies don''t replicate.', '很多心理学研究其实都难以重复验证。', '/ɐ lɑːt ʌv ðiːz saɪk stʌdiz doʊnt ɹɛplᵻkeɪt./', '<span>A</span><span tid="119162">lot</span><span>of</span><span>these</span><span tid="119165">psych</span><span tid="119166">studies</span><span>don''t</span><span tid="119168" class="highlight highlight-a">replicate.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 131, 420.12, 423.1, 'but it''s a fun, fun little study that shows that.', '但有一个很有意思的小研究说。', '/bʌt ɪts ɐ fʌn, fʌn lɪɾəl stʌdi ðæt ʃoʊz ðæt./', '<span>but</span><span>it''s</span><span>a</span><span tid="119172">fun,</span><span tid="119173">fun</span><span tid="119174">little</span><span tid="119175">study</span><span>that</span><span tid="119177">shows</span><span>that.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 132, 423.1, 428.38, 'uh, people who break their back and people who win the lottery are back to their baseline happiness two years later.', '辛勤工作的人和中彩票的人，两年后都会回到原本的幸福基线。', '/ʌ, piːpəl huː bɹeɪk ðɛɹ bæk ænd piːpəl huː wɪn ðə lɑːɾɚɹi ɑːɹ bæk tə ðɛɹ beɪslaɪn hæpɪnəs tuː jɪɹz leɪɾɚ./', '<span>uh,</span><span tid="119180">people</span><span>who</span><span pid="3493" class="highlight highlight-f">break their back</span><span>and</span><span tid="119186">people</span><span>who</span><span pid="2125" class="highlight highlight-c">win the lottery</span><span>are</span><span tid="119192" class="highlight highlight-a">back</span><span>to</span><span>their</span><span tid="119195" class="highlight highlight-a">baseline</span><span tid="119196">happiness</span><span>two</span><span tid="119198">years</span><span tid="119199" class="highlight highlight-a">later.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 133, 428.38, 430.94, 'Again, I don''t know if that''s entirely true.', '当然，我也不确定这是不是完全真实。', '/ɐɡɛn, aɪ doʊnt noʊ ɪf ðæts ɛntaɪɚli tɹuː./', '<span tid="119200">Again,</span><span>I</span><span>don''t</span><span>know</span><span>if</span><span>that''s</span><span pid="2126" class="highlight highlight-c">entirely true.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 134, 430.94, 434.18, 'I think money can buy you happiness if you earned it.', '但我觉得，如果钱是你自己挣来的，它确实能买来幸福。', '/aɪ θɪŋk mʌni kæn baɪ juː hæpɪnəs ɪf juː ɜːnd ɪt./', '<span>I</span><span>think</span><span tid="119210">money</span><span>can</span><span tid="119212">buy</span><span>you</span><span tid="119214">happiness</span><span>if</span><span>you</span><span tid="119217" class="highlight highlight-a">earned</span><span>it.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 135, 434.18, 438.88, 'because then along the way you have both pride and confidence in yourself.', '因为在这个过程中，你会获得自豪感和自信。', '/bɪkʌz ðɛn ɐlɔŋ ðə weɪ juː hæv boʊθ pɹaɪd ænd kɑːnfɪdəns ɪn jɔːɹsɛlf./', '<span>because</span><span>then</span><span pid="2099" class="highlight highlight-c">along the way</span><span>you</span><span>have</span><span tid="119226">both</span><span tid="119227">pride</span><span>and</span><span tid="119229">confidence</span><span>in</span><span tid="119231">yourself.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 136, 438.88, 440.86, 'and you have a sense of accomplishment.', '你会有一种成就感。', '/ænd juː hæv ɐ sɛns ʌv ɐkɑːmplɪʃmənt./', '<span>and</span><span>you</span><span>have</span><span>a</span><span tid="119236" class="highlight highlight-a">sense</span><span>of</span><span tid="119238" class="highlight highlight-a">accomplishment.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 137, 440.86, 443.94, 'and you, you know, set out to do something and you were right.', '你设定了一个目标，然后证明自己做得到。', '/ænd juː, juː noʊ, sɛt aʊt tə duː sʌmθɪŋ ænd juː wɜː ɹaɪt./', '<span>and</span><span>you,</span><span>you</span><span>know,</span><span tid="119243" class="highlight highlight-a">set</span><span tid="119244">out</span><span>to</span><span>do</span><span>something</span><span>and</span><span>you</span><span>were</span><span tid="119251" class="highlight highlight-a">right.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 138, 443.94, 445.34, 'So I''ll bet that lingers.', '我猜这种感觉会持续更久。', '/soʊ aɪl bɛt ðæt lɪŋɡɚz./', '<span>So</span><span>I''ll</span><span tid="119254" class="highlight highlight-a">bet</span><span>that</span><span tid="119256" class="highlight highlight-a">lingers.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 139, 445.34, 447.36, 'And then, as I said, money solves your money problem.', '而且就像我说的，钱能解决你的金钱问题。', '/ænd ðɛn, æz aɪ sɛd, mʌni sɑːlvz jʊɹ mʌni pɹɑːbləm./', '<span>And</span><span>then,</span><span>as</span><span>I</span><span tid="119261">said,</span><span tid="119262">money</span><span tid="119263">solves</span><span>your</span><span tid="119265">money</span><span tid="119266">problem.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 140, 447.36, 448.74, 'So I don''t want to be too glib about it.', '所以我不想对这个问题说得太轻巧。', '/soʊ aɪ doʊnt wɔnt təbi tuː ɡlɪb ɐbaʊt ɪt./', '<span>So</span><span>I</span><span>don''t</span><span>want</span><span>to</span><span>be</span><span>too</span><span tid="119274" class="highlight highlight-a">glib</span><span>about</span><span>it.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 141, 448.74, 456.28, 'but I would say in general, this, this loop that we run through, um, of desire, dopamine, fulfillment, unfulfillment.', '但总体来说，我们一直在经历的这个循环——欲望、多巴胺、满足、再度不满足。', '/bʌt aɪ wʊd seɪ ɪn dʒɛnɚɹəl, ðɪs, ðɪs luːp ðæt wiː ɹʌn θɹuː, ʌm, ʌv dɪzaɪɚ, dɑːpɐmiːn, fʊlfɪlmənt, ʌnfʊlfɪlmənt./', '<span>but</span><span>I</span><span>would</span><span tid="119280">say</span><span>in</span><span tid="119282">general,</span><span>this,</span><span>this</span><span tid="119285" class="highlight highlight-a">loop</span><span>that</span><span>we</span><span tid="119288">run</span><span tid="119289">through,</span><span tid="119290">um,</span><span>of</span><span tid="119292" class="highlight highlight-a">desire,</span><span tid="119293" class="highlight highlight-a">dopamine,</span><span tid="119294" class="highlight highlight-a">fulfillment,</span><span tid="119295">unfulfillment.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 142, 456.28, 457.56, 'Like you have to enjoy the journey.', '关键还是要学会享受过程。', '/laɪk juː hæv tʊ ɛndʒɔɪ ðə dʒɜːni./', '<span>Like</span><span>you</span><span>have</span><span>to</span><span tid="119300">enjoy</span><span>the</span><span tid="119302">journey.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 143, 457.56, 458.58, 'The journey is all there is.', '因为过程就是全部。', '/ðə dʒɜːni ɪz ɔːl ðɛɹɪz./', '<span>The</span><span tid="119304">journey</span><span>is</span><span>all</span><span>there</span><span>is.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 144, 458.58, 461.16, '99 % of your time is spent on the journey.', '你99%的时间都在过程里。', '/naɪnti naɪn pɚsɛnt ʌv jʊɹ taɪm ɪz spɛnt ɔnðə dʒɜːni./', '<span>99</span><span>%</span><span>of</span><span>your</span><span tid="119313">time</span><span>is</span><span tid="119315">spent</span><span>on</span><span>the</span><span tid="119318">journey.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 145, 461.16, 463.38, 'So what kind of a journey is it if you''re not going to enjoy it.', '如果你不打算享受它，那这段旅程又算什么呢？', '/soʊ wʌt kaɪnd əvə dʒɜːni ɪz ɪt ɪf jʊɹ nɑːt ɡoʊɪŋ tʊ ɛndʒɔɪ ɪt./', '<span>So</span><span>what</span><span tid="119321">kind</span><span>of</span><span>a</span><span tid="119324">journey</span><span>is</span><span>it</span><span>if</span><span>you''re</span><span>not</span><span>going</span><span>to</span><span tid="119332">enjoy</span><span>it.</span>'
FROM episodes e WHERE e.video_id = '134DHRPZp2BKOEk';

-- episode 137: 137tgoWv5FgGzt3
INSERT INTO episodes (
  index, video_id, short_title, summary, remark, stars, voca_size,
  subtitle_count, clip_length, cover, video_url, audio_url, thumbnail_url,
  original_video_url, author_id, submitted_by_user_id, rejection_reason,
  created_at, is_demo, status, published_at
) VALUES (
  137, '137tgoWv5FgGzt3', 'JENNIE：音乐与成长',
  'JENNIE分享新专辑发布后的惊喜与压力，谈及音乐风格探索、自我成长及与Dua Lipa合作的体验，同时表达对身边女性支持与启发的感激。', 'JENNIE的声音真的很好听',
  3, 182, 65,
  335.04, 'http://oss.sxakgs.com/en/137tgoWv5FgGzt3/cover.webp',
  'http://oss.sxakgs.com/en/137tgoWv5FgGzt3/video.mp4', 'http://oss.sxakgs.com/en/137tgoWv5FgGzt3/audio.mp3',
  'http://oss.sxakgs.com/en/137tgoWv5FgGzt3/cover.webp', 'https://www.youtube.com/watch?v=2QWSIdPvsA4',
  (SELECT id FROM authors WHERE name = 'Audacy Music' AND accent = '' LIMIT 1),
  NULL, NULL,
  '2026-06-30 15:07:39'::timestamp,
  FALSE, 'published',
  '2026-06-30 15:07:39'::timestamp
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
  SELECT s.id FROM subtitles s JOIN episodes e ON s.episode_id = e.id WHERE e.video_id = '137tgoWv5FgGzt3'
);
DELETE FROM subtitles WHERE episode_id = (SELECT id FROM episodes WHERE video_id = '137tgoWv5FgGzt3');
DELETE FROM episode_tags WHERE episode_id = (SELECT id FROM episodes WHERE video_id = '137tgoWv5FgGzt3');

INSERT INTO episode_tags (episode_id, tag_id)
SELECT e.id, t.id FROM episodes e, tags t
WHERE e.video_id = '137tgoWv5FgGzt3' AND t.name = '访谈'
ON CONFLICT DO NOTHING;
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 1, 2.96, 7.22, 'Hello JENNIE It is so nice to meet you Hello Welcome to the studio.', '你好 JENNIE 很高兴见到你 你好 欢迎来到录音室。', '/həloʊ dʒɛni ɪɾ ɪz soʊ naɪs tə miːt juː həloʊ wɛlkʌm tə ðə stuːdɪoʊ./', '<span>Hello</span><span tid="120637">JENNIE</span><span>It</span><span>is</span><span>so</span><span tid="120641">nice</span><span>to</span><span tid="120643">meet</span><span>you</span><span>Hello</span><span tid="120646">Welcome</span><span>to</span><span>the</span><span tid="120649" class="highlight highlight-a">studio.</span>'
FROM episodes e WHERE e.video_id = '137tgoWv5FgGzt3';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 2, 7.22, 13.38, 'Thank you for stopping by and congratulations on all the news the announcements Congrats on Ruby.', '感谢你抽空过来 也恭喜你最近所有的消息和官宣 恭喜 Ruby。', '/θæŋk juː fɔːɹ stɑːpɪŋ baɪ ænd kəŋɡɹætʃʊleɪʃənz ɔn ɔːl ðə nuːz ðɪ ɐnaʊnsmənts kəŋɡɹæts ɔn ɹuːbi./', '<span tid="120650">Thank</span><span>you</span><span>for</span><span tid="120653">stopping</span><span>by</span><span>and</span><span pid="573" class="highlight highlight-i">congratulations on</span><span>all</span><span>the</span><span tid="120660">news</span><span>the</span><span tid="120662" class="highlight highlight-a">announcements</span><span tid="120663">Congrats</span><span>on</span><span tid="120665">Ruby.</span>'
FROM episodes e WHERE e.video_id = '137tgoWv5FgGzt3';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 3, 13.38, 18.72, 'Thank you Coachella Coachella It’s the LA accent.', '谢谢 Coachella Coachella 是洛杉矶口音。', '/θæŋk juː koʊtʃɛlə koʊtʃɛlə ɪts ðɪ ɛleɪ æksənt./', '<span tid="120666">Thank</span><span>you</span><span tid="120668">Coachella</span><span tid="120669">Coachella</span><span>It’s</span><span>the</span><span tid="120672">LA</span><span tid="120673" class="highlight highlight-a">accent.</span>'
FROM episodes e WHERE e.video_id = '137tgoWv5FgGzt3';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 4, 18.72, 20.28, 'It’s wearing on me.', '我都被它带跑了。', '/ɪts wɛɹɪŋ ɔn miː./', '<span>It’s</span><span pid="574" class="highlight highlight-d">wearing on me.</span>'
FROM episodes e WHERE e.video_id = '137tgoWv5FgGzt3';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 5, 20.28, 24.28, 'So many fun things happening and I can’t wait to dive into a bunch of it with you.', '最近有很多有趣的事情发生 我已经迫不及待想和你深入聊聊了。', '/soʊ mɛni fʌn θɪŋz hæpənɪŋ ænd aɪ kænt weɪt tə daɪv ɪntʊ ɐ bʌntʃ ʌv ɪt wɪð juː./', '<span>So</span><span>many</span><span tid="120680">fun</span><span>things</span><span tid="120682">happening</span><span>and</span><span>I</span><span tid="120685">can’t</span><span tid="120686">wait</span><span>to</span><span pid="568" class="highlight highlight-d">dive into</span><span pid="563" class="highlight highlight-i">a bunch of</span><span>it</span><span>with</span><span>you.</span>'
FROM episodes e WHERE e.video_id = '137tgoWv5FgGzt3';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 6, 24.28, 29.98, 'Gotta start with like JENNIE Everyone wants to be like JENNIE.', '必须从 JENNIE 开始聊 大家都想成为像 JENNIE 一样的人。', '/ɡɑːɾə stɑːɹt wɪð laɪk dʒɛni ɛvɹɪwʌn wɔnts təbi laɪk dʒɛni./', '<span tid="120696">Gotta</span><span tid="120697">start</span><span>with</span><span>like</span><span tid="120700">JENNIE</span><span tid="120701">Everyone</span><span>wants</span><span>to</span><span>be</span><span>like</span><span tid="120706">JENNIE.</span>'
FROM episodes e WHERE e.video_id = '137tgoWv5FgGzt3';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 7, 29.98, 35.86, 'no Has that been such a surprise to see how like massive it’s gotten just right when your album comes out.', '没有 看到它在你专辑刚发行时就变得这么火爆 有没有让你很惊讶。', '/noʊ hɐz ðæt bɪn sʌtʃ ɐ sɚpɹaɪz tə siː haʊ laɪk mæsɪv ɪts ɡɑːʔn̩ dʒʌst ɹaɪt wɛn jʊɹ ælbəm kʌmz aʊt./', '<span>no</span><span>Has</span><span>that</span><span>been</span><span tid="120711">such</span><span>a</span><span tid="120713">surprise</span><span>to</span><span tid="120715">see</span><span>how</span><span>like</span><span tid="120718" class="highlight highlight-a">massive</span><span>it’s</span><span>gotten</span><span>just</span><span tid="120722" class="highlight highlight-a">right</span><span>when</span><span>your</span><span tid="120725">album</span><span pid="564" class="highlight highlight-d">comes out.</span>'
FROM episodes e WHERE e.video_id = '137tgoWv5FgGzt3';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 8, 35.86, 44.48, 'It’s crazy I was just saying even today I was like wow I’m just so amazed at how the song is doing and how everyone’s reacting to the song.', '真的很疯狂 我今天还在说 我真的很惊讶这首歌的表现以及大家对它的反应。', '/ɪts kɹeɪzi aɪ wʌz dʒʌst seɪɪŋ iːvən tədeɪ aɪ wʌz laɪk waʊ aɪm dʒʌst soʊ ɐmeɪzd æt haʊ ðə sɔŋ ɪz duːɪŋ ænd haʊ ɛvɹɪwʌnz ɹɪæktɪŋ tə ðə sɔŋ./', '<span>It’s</span><span tid="120729">crazy</span><span>I</span><span>was</span><span>just</span><span tid="120733">saying</span><span tid="120734">even</span><span tid="120735">today</span><span>I</span><span>was</span><span>like</span><span tid="120739">wow</span><span>I’m</span><span>just</span><span>so</span><span tid="120743">amazed</span><span>at</span><span>how</span><span>the</span><span tid="120747">song</span><span>is</span><span>doing</span><span>and</span><span>how</span><span tid="120752">everyone’s</span><span tid="120753" class="highlight highlight-a">reacting</span><span>to</span><span>the</span><span tid="120756">song.</span>'
FROM episodes e WHERE e.video_id = '137tgoWv5FgGzt3';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 9, 44.48, 47.08, 'It’s definitely not what I expected.', '这完全不是我预期的。', '/ɪts dɛfɪnətli nɑːt wʌt aɪ ɛkspɛktᵻd./', '<span>It’s</span><span tid="120758" class="highlight highlight-a">definitely</span><span>not</span><span>what</span><span>I</span><span tid="120762">expected.</span>'
FROM episodes e WHERE e.video_id = '137tgoWv5FgGzt3';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 10, 47.08, 51.32, 'I didn’t probably know what to expect but yeah I’m glad.', '我其实也不知道该期待什么 但总之我很开心。', '/aɪ dɪdnt pɹɑːbəbli noʊ wʌt tʊ ɛkspɛkt bʌt jɛh aɪm ɡlæd./', '<span>I</span><span>didn’t</span><span tid="120765" class="highlight highlight-a">probably</span><span>know</span><span>what</span><span>to</span><span tid="120769">expect</span><span>but</span><span>yeah</span><span>I’m</span><span tid="120773">glad.</span>'
FROM episodes e WHERE e.video_id = '137tgoWv5FgGzt3';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 11, 51.32, 55.52, 'Because when you put it out you’re not thinking like oh I think that song is going to do well.', '因为你发布的时候并不会去想 哦我觉得这首歌会火。', '/bɪkʌz wɛn juː pʊt ɪɾ aʊt jʊɹ nɑːt θɪŋkɪŋ laɪk oʊ aɪ θɪŋk ðæt sɔŋ ɪz ɡoʊɪŋ tə duː wɛl./', '<span>Because</span><span>when</span><span>you</span><span tid="120777">put</span><span>it</span><span tid="120779">out</span><span>you’re</span><span>not</span><span>thinking</span><span>like</span><span>oh</span><span>I</span><span>think</span><span>that</span><span tid="120788">song</span><span>is</span><span>going</span><span>to</span><span>do</span><span tid="120793">well.</span>'
FROM episodes e WHERE e.video_id = '137tgoWv5FgGzt3';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 12, 55.52, 59.0, 'or that song is it’s just kind of nice to see the fans you know blow it up.', '或者那首歌会怎样 看到粉丝把它推火真的很开心。', '/ɔːɹ ðæt sɔŋ ɪz ɪts dʒʌst kaɪnd ʌv naɪs tə siː ðə fænz juː noʊ bloʊ ɪɾ ʌp./', '<span>or</span><span>that</span><span tid="120796">song</span><span>is</span><span>it’s</span><span>just</span><span tid="120800">kind</span><span>of</span><span tid="120802">nice</span><span>to</span><span tid="120804">see</span><span>the</span><span tid="120806" class="highlight highlight-a">fans</span><span>you</span><span>know</span><span tid="120809">blow</span><span>it</span><span>up.</span>'
FROM episodes e WHERE e.video_id = '137tgoWv5FgGzt3';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 13, 59.0, 63.34, 'When you scroll on social media are you seeing like your own song Is it coming up the trends.', '当你刷社交媒体的时候 会看到自己的歌吗 会出现在趋势里吗。', '/wɛn juː skɹoʊl ɔn soʊʃəl miːdiːə ɑːɹ juː siːɪŋ laɪk jʊɹ oʊn sɔŋ ɪz ɪt kʌmɪŋ ʌp ðə tɹɛndz./', '<span>When</span><span>you</span><span pid="575" class="highlight highlight-c">scroll on social media</span><span>are</span><span>you</span><span tid="120820">seeing</span><span>like</span><span>your</span><span tid="120823" class="highlight highlight-a">own</span><span tid="120824">song</span><span>Is</span><span>it</span><span tid="120827">coming</span><span>up</span><span>the</span><span tid="120830" class="highlight highlight-a">trends.</span>'
FROM episodes e WHERE e.video_id = '137tgoWv5FgGzt3';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 14, 63.34, 65.34, 'I am! Is that trippy?', '会的！这会不会有点魔幻？', '/aɪæm! ɪz ðæt tɹɪpi?/', '<span>I</span><span>am!</span><span>Is</span><span>that</span><span tid="120835" class="highlight highlight-a">trippy?</span>'
FROM episodes e WHERE e.video_id = '137tgoWv5FgGzt3';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 15, 65.34, 67.58, 'Yeah I don’t enjoy it. No?', '是啊 其实我不太享受。不是吗？', '/jɛh aɪ doʊnt ɛndʒɔɪ ɪt. noʊ?/', '<span>Yeah</span><span>I</span><span>don’t</span><span tid="120839">enjoy</span><span>it.</span><span>No?</span>'
FROM episodes e WHERE e.video_id = '137tgoWv5FgGzt3';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 16, 67.58, 72.32, 'I mean it’s cool but then like if it keeps happening.', '我是说挺酷的 但如果一直发生的话。', '/aɪ miːn ɪts kuːl bʌt ðɛn laɪk ɪf ɪt kiːps hæpənɪŋ./', '<span>I</span><span tid="120843">mean</span><span>it’s</span><span tid="120845" class="highlight highlight-a">cool</span><span>but</span><span>then</span><span>like</span><span>if</span><span>it</span><span tid="120851">keeps</span><span tid="120852">happening.</span>'
FROM episodes e WHERE e.video_id = '137tgoWv5FgGzt3';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 17, 72.32, 75.86, 'it’s like you hear yourself so many times and you’re like ah.', '就会一直听到自己的声音 然后就会觉得 啊。', '/ɪts laɪk juː hɪɹ jɔːɹsɛlf soʊ mɛni taɪmz ænd jʊɹ laɪk ɑː./', '<span>it’s</span><span>like</span><span>you</span><span tid="120856">hear</span><span tid="120857">yourself</span><span>so</span><span>many</span><span tid="120860">times</span><span>and</span><span>you’re</span><span>like</span><span>ah.</span>'
FROM episodes e WHERE e.video_id = '137tgoWv5FgGzt3';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 18, 75.86, 77.92, 'If I hear myself my voice.', '如果我听到自己的声音。', '/ɪf aɪ hɪɹ maɪsɛlf maɪ vɔɪs./', '<span>If</span><span>I</span><span tid="120867">hear</span><span tid="120868">myself</span><span>my</span><span tid="120870">voice.</span>'
FROM episodes e WHERE e.video_id = '137tgoWv5FgGzt3';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 19, 77.92, 80.74, 'oh it’s the same thing I know exactly what you’re talking about.', '哦 是一样的 我完全懂你在说什么。', '/oʊ ɪts ðə seɪm θɪŋ aɪ noʊ ɛɡzæktli wʌt jʊɹ tɔːkɪŋ ɐbaʊt./', '<span>oh</span><span>it’s</span><span>the</span><span tid="120874">same</span><span>thing</span><span>I</span><span>know</span><span tid="120878">exactly</span><span>what</span><span>you’re</span><span tid="120881">talking</span><span>about.</span>'
FROM episodes e WHERE e.video_id = '137tgoWv5FgGzt3';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 20, 80.74, 84.24, 'And your rapping is so good Thank you.', '而且你的说唱真的很好 谢谢。', '/ænd jʊɹ ɹæpɪŋ ɪz soʊ ɡʊd θæŋk juː./', '<span>And</span><span>your</span><span tid="120885" class="highlight highlight-a">rapping</span><span>is</span><span>so</span><span>good</span><span tid="120889">Thank</span><span>you.</span>'
FROM episodes e WHERE e.video_id = '137tgoWv5FgGzt3';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 21, 84.24, 87.0, 'It’s been so fun to see like your journey and development.', '看到你的成长和变化真的很有意思。', '/ɪts bɪn soʊ fʌn tə siː laɪk jʊɹ dʒɜːni ænd dɪvɛləpmənt./', '<span>It’s</span><span>been</span><span>so</span><span tid="120894">fun</span><span>to</span><span tid="120896">see</span><span>like</span><span>your</span><span tid="120899">journey</span><span>and</span><span tid="120901" class="highlight highlight-a">development.</span>'
FROM episodes e WHERE e.video_id = '137tgoWv5FgGzt3';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 22, 87.0, 92.02, 'How do you think your sounds evolve and like in your you know your own project for the first time as well.', '你觉得你的音乐风格是如何进化的 这是你第一次做个人项目。', '/haʊ duː juː θɪŋk jʊɹ saʊndz ɪvɑːlv ænd laɪk ɪn jʊɹ juː noʊ jʊɹ oʊn pɹɑːdʒɛkt fɚðə fɜːst taɪm æz wɛl./', '<span>How</span><span>do</span><span>you</span><span>think</span><span>your</span><span tid="120907">sounds</span><span tid="120908" class="highlight highlight-a">evolve</span><span>and</span><span>like</span><span>in</span><span>your</span><span>you</span><span>know</span><span>your</span><span tid="120916" class="highlight highlight-a">own</span><span tid="120917">project</span><span pid="570" class="highlight highlight-i">for the first time</span><span>as</span><span tid="120923">well.</span>'
FROM episodes e WHERE e.video_id = '137tgoWv5FgGzt3';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 23, 92.02, 106.64, 'I’ve noticed that I didn’t realize how many genres and different type of sounds that I wanted to tap into before I worked on this album.', '我发现 在做这张专辑之前 我没有意识到自己想尝试这么多不同的风格和声音。', '/aɪv noʊɾɪst ðæt aɪ dɪdnt ɹiːəlaɪz haʊ mɛni ʒɑːnɹəz ænd dɪfɹənt taɪp ʌv saʊndz ðæt aɪ wɔntᵻd tə tæp ɪntʊ bᵻfɔːɹ aɪ wɜːkt ɔn ðɪs ælbəm./', '<span>I’ve</span><span tid="120925" class="highlight highlight-a">noticed</span><span>that</span><span>I</span><span>didn’t</span><span tid="120929" class="highlight highlight-a">realize</span><span>how</span><span>many</span><span tid="120932" class="highlight highlight-a">genres</span><span>and</span><span tid="120934">different</span><span tid="120935" class="highlight highlight-a">type</span><span>of</span><span tid="120937">sounds</span><span>that</span><span>I</span><span>wanted</span><span>to</span><span pid="569" class="highlight highlight-d">tap into</span><span tid="120944">before</span><span>I</span><span tid="120946">worked</span><span>on</span><span>this</span><span tid="120949">album.</span>'
FROM episodes e WHERE e.video_id = '137tgoWv5FgGzt3';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 24, 106.64, 111.74, 'And you know I’m finding myself really as I’m going I’m learning.', '而且我是在这个过程中慢慢找到自己 我在不断学习。', '/ænd juː noʊ aɪm faɪndɪŋ maɪsɛlf ɹiəli æz aɪm ɡoʊɪŋ aɪm lɜːnɪŋ./', '<span>And</span><span>you</span><span>know</span><span>I’m</span><span tid="120954">finding</span><span tid="120955">myself</span><span tid="120956">really</span><span>as</span><span>I’m</span><span>going</span><span>I’m</span><span tid="120961">learning.</span>'
FROM episodes e WHERE e.video_id = '137tgoWv5FgGzt3';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 25, 111.74, 115.8, 'how to rap for the first time almost how to sing for the first time.', '几乎是第一次学习怎么说唱 第一次学习怎么唱歌。', '/haʊ tə ɹæp fɚðə fɜːst taɪm ɔːlmoʊst haʊ tə sɪŋ fɚðə fɜːst taɪm./', '<span>how</span><span>to</span><span tid="120964">rap</span><span pid="571" class="highlight highlight-i">for the first time</span><span tid="120969">almost</span><span>how</span><span>to</span><span tid="120972">sing</span><span pid="571" class="highlight highlight-i">for the first time.</span>'
FROM episodes e WHERE e.video_id = '137tgoWv5FgGzt3';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 26, 115.8, 124.78, 'Because I’ve never like in a good way I’ve never been able to really focus on only on myself.', '因为从好的方面来说 我以前从来没有真正只专注于自己。', '/bɪkʌz aɪv nɛvɚ laɪk ɪn ɐ ɡʊd weɪ aɪv nɛvɚ bɪn eɪbəl tə ɹiəli foʊkəs ɔn oʊnli ɔn maɪsɛlf./', '<span>Because</span><span>I’ve</span><span tid="120979">never</span><span>like</span><span>in</span><span>a</span><span>good</span><span tid="120984" class="highlight highlight-a">way</span><span>I’ve</span><span tid="120986">never</span><span>been</span><span tid="120988">able</span><span>to</span><span tid="120990">really</span><span tid="120991">focus</span><span>on</span><span tid="120993">only</span><span>on</span><span tid="120995">myself.</span>'
FROM episodes e WHERE e.video_id = '137tgoWv5FgGzt3';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 27, 124.78, 129.74, 'I’ve always had the girls with me you know I’ve always had other things happening around me.', '我一直都有成员在身边 也总有其他事情在发生。', '/aɪv ɔːlweɪz hæd ðə ɡɜːlz wɪð miː juː noʊ aɪv ɔːlweɪz hæd ʌðɚ θɪŋz hæpənɪŋ ɚɹaʊnd miː./', '<span>I’ve</span><span tid="120997">always</span><span>had</span><span>the</span><span tid="121000">girls</span><span>with</span><span>me</span><span>you</span><span>know</span><span>I’ve</span><span tid="121006">always</span><span>had</span><span tid="121008">other</span><span>things</span><span tid="121010">happening</span><span tid="121011">around</span><span>me.</span>'
FROM episodes e WHERE e.video_id = '137tgoWv5FgGzt3';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 28, 129.74, 137.72, 'But for this for this album I got to really sit down and explore different voices and sounds.', '但这张专辑让我可以真正坐下来 探索不同的声音和表达。', '/bʌt fɔːɹ ðɪs fɔːɹ ðɪs ælbəm aɪ ɡɑːt tə ɹiːɐlɪsɪtdaʊn ænd ɛksplɔːɹ dɪfɹənt vɔɪsᵻz ænd saʊndz./', '<span>But</span><span>for</span><span>this</span><span>for</span><span>this</span><span tid="121018">album</span><span>I</span><span>got</span><span>to</span><span tid="121022">really</span><span tid="121023">sit</span><span tid="121024">down</span><span>and</span><span tid="121026" class="highlight highlight-a">explore</span><span tid="121027">different</span><span tid="121028">voices</span><span>and</span><span tid="121030">sounds.</span>'
FROM episodes e WHERE e.video_id = '137tgoWv5FgGzt3';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 29, 137.72, 140.7, 'And it was great So.', '这真的很棒。', '/ænd ɪt wʌz ɡɹeɪt soʊ./', '<span>And</span><span>it</span><span>was</span><span tid="121034">great</span><span>So.</span>'
FROM episodes e WHERE e.video_id = '137tgoWv5FgGzt3';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 30, 140.7, 149.88, 'I’m looking into I’m going to look into it and find out more about who and what kind of sound that I want to like hold on to.', '所以我会继续去探索 找到自己想坚持的那种声音和方向。', '/aɪm lʊkɪŋ ɪntʊ aɪm ɡoʊɪŋ tə lʊk ɪntʊ ɪt ænd faɪnd aʊt mɔːɹ ɐbaʊt huː ænd wʌt kaɪnd ʌv saʊnd ðæt aɪ wɔnt tə laɪk hoʊld ɔn tuː./', '<span>I’m</span><span tid="121037" class="highlight highlight-a">looking</span><span tid="121038" class="highlight highlight-a">into</span><span>I’m</span><span>going</span><span>to</span><span tid="121042" class="highlight highlight-a">look</span><span tid="121043" class="highlight highlight-a">into</span><span>it</span><span>and</span><span tid="121046">find</span><span tid="121047">out</span><span>more</span><span>about</span><span>who</span><span>and</span><span>what</span><span tid="121053">kind</span><span>of</span><span tid="121055">sound</span><span>that</span><span>I</span><span>want</span><span>to</span><span>like</span><span tid="121061">hold</span><span>on</span><span>to.</span>'
FROM episodes e WHERE e.video_id = '137tgoWv5FgGzt3';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 31, 149.88, 152.26, 'So you’re getting to experiment a little bit.', '所以你现在可以多做一些尝试了。', '/soʊ jʊɹ ɡɛɾɪŋ tʊ ɛkspɛɹɪmənt ɐ lɪɾəl bɪt./', '<span>So</span><span>you’re</span><span>getting</span><span>to</span><span tid="121068" class="highlight highlight-a">experiment</span><span pid="565" class="highlight highlight-i">a little bit.</span>'
FROM episodes e WHERE e.video_id = '137tgoWv5FgGzt3';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 32, 152.26, 156.02, 'Is your confidence and like comfort level at like an all time high for making music.', '你现在在做音乐时的自信和舒适度是历史最高吗。', '/ɪz jʊɹ kɑːnfɪdəns ænd laɪk kʌmfɚt lɛvəl æt laɪk ɐn ɔːl taɪm haɪ fɔːɹ meɪkɪŋ mjuːzɪk./', '<span>Is</span><span>your</span><span tid="121074">confidence</span><span>and</span><span>like</span><span tid="121077" class="highlight highlight-a">comfort</span><span tid="121078">level</span><span>at</span><span>like</span><span>an</span><span pid="576" class="highlight highlight-i">all time high</span><span>for</span><span tid="121086">making</span><span tid="121087">music.</span>'
FROM episodes e WHERE e.video_id = '137tgoWv5FgGzt3';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 33, 156.02, 161.78, 'No I feel like I need more time in the studio for me to feel that way.', '没有 我觉得我还需要更多时间在录音室里才能达到那种状态。', '/noʊ aɪ fiːl laɪk aɪ niːd mɔːɹ taɪm ɪnðə stuːdɪoʊ fɔːɹ miː tə fiːl ðæt weɪ./', '<span>No</span><span>I</span><span tid="121090">feel</span><span>like</span><span>I</span><span tid="121093">need</span><span>more</span><span tid="121095">time</span><span>in</span><span>the</span><span tid="121098" class="highlight highlight-a">studio</span><span>for</span><span>me</span><span>to</span><span tid="121102">feel</span><span>that</span><span tid="121104" class="highlight highlight-a">way.</span>'
FROM episodes e WHERE e.video_id = '137tgoWv5FgGzt3';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 34, 161.78, 163.3, 'But I think it was a great start.', '但我觉得这是一个很好的开始。', '/bʌt aɪ θɪŋk ɪt wʌzɐ ɡɹeɪt stɑːɹt./', '<span>But</span><span>I</span><span>think</span><span>it</span><span>was</span><span>a</span><span tid="121111">great</span><span tid="121112">start.</span>'
FROM episodes e WHERE e.video_id = '137tgoWv5FgGzt3';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 35, 163.3, 174.68, 'And I’ve met so many amazing people on the way to and they’ve inspired me in a way that I was able to finish this album.', '而且这一路上我遇到了很多很棒的人 他们以某种方式激励了我 让我完成了这张专辑。', '/ænd aɪv mɛt soʊ mɛni ɐmeɪzɪŋ piːpəl ɔnðə weɪ tʊ ænd ðeɪv ɪnspaɪɚd miː ɪn ɐ weɪ ðæt aɪ wʌz eɪbəl tə fɪnɪʃ ðɪs ælbəm./', '<span>And</span><span>I’ve</span><span tid="121115">met</span><span>so</span><span>many</span><span tid="121118">amazing</span><span tid="121119">people</span><span>on</span><span>the</span><span tid="121122" class="highlight highlight-a">way</span><span>to</span><span>and</span><span>they’ve</span><span tid="121126" class="highlight highlight-a">inspired</span><span>me</span><span>in</span><span>a</span><span tid="121130" class="highlight highlight-a">way</span><span>that</span><span>I</span><span>was</span><span tid="121134">able</span><span>to</span><span tid="121136">finish</span><span>this</span><span tid="121138">album.</span>'
FROM episodes e WHERE e.video_id = '137tgoWv5FgGzt3';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 36, 174.68, 179.82, 'So I can’t wait to get back in you know get into it more.', '所以我迫不及待想回到录音室 继续深入去做。', '/soʊ aɪ kænt weɪt tə ɡɛt bæk ɪn juː noʊ ɡɛt ɪntʊ ɪt mɔːɹ./', '<span>So</span><span>I</span><span tid="121141">can’t</span><span tid="121142">wait</span><span>to</span><span>get</span><span tid="121145" class="highlight highlight-a">back</span><span>in</span><span>you</span><span>know</span><span>get</span><span tid="121150" class="highlight highlight-a">into</span><span>it</span><span>more.</span>'
FROM episodes e WHERE e.video_id = '137tgoWv5FgGzt3';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 37, 179.82, 183.54, 'You feel like a workaholic a little bit like you just love to keep working.', '你会觉得自己有点工作狂吗 就是很喜欢一直工作。', '/juː fiːl laɪk ɐ wɜːkɐhɑːlɪk ɐ lɪɾəl bɪt laɪk juː dʒʌst lʌv tə kiːp wɜːkɪŋ./', '<span>You</span><span tid="121154">feel</span><span>like</span><span>a</span><span tid="121157" class="highlight highlight-a">workaholic</span><span pid="566" class="highlight highlight-i">a little bit</span><span>like</span><span>you</span><span>just</span><span tid="121164">love</span><span>to</span><span tid="121166">keep</span><span tid="121167">working.</span>'
FROM episodes e WHERE e.video_id = '137tgoWv5FgGzt3';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 38, 183.54, 195.5, 'You know what though it’s not all work that I love So I don’t consider myself as a workaholic Wait do I Oh man.', '其实也不是所有工作我都喜欢 所以我不觉得自己是工作狂 等等 我是吗 天哪。', '/juː noʊ wʌt ðoʊ ɪts nɑːt ɔːl wɜːk ðæt aɪ lʌv soʊ aɪ doʊnt kənsɪdɚ maɪsɛlf æz ɐ wɜːkɐhɑːlɪk weɪt duː aɪ oʊ mæn./', '<span>You</span><span>know</span><span>what</span><span tid="121171">though</span><span>it’s</span><span>not</span><span>all</span><span tid="121175">work</span><span>that</span><span>I</span><span tid="121178">love</span><span>So</span><span>I</span><span>don’t</span><span tid="121182" class="highlight highlight-a">consider</span><span tid="121183">myself</span><span>as</span><span>a</span><span tid="121186" class="highlight highlight-a">workaholic</span><span tid="121187">Wait</span><span>do</span><span>I</span><span>Oh</span><span tid="121191">man.</span>'
FROM episodes e WHERE e.video_id = '137tgoWv5FgGzt3';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 39, 195.5, 200.16, 'Well there’s so many fun collabs Congratulations on all these friends that are hopping on the project.', '这次有很多很棒的合作 恭喜你有这么多朋友参与这个项目。', '/wɛl ðɛɹz soʊ mɛni fʌn kəlæbz kəŋɡɹætʃʊleɪʃənz ɔn ɔːl ðiːz fɹɛndz ðæt ɑːɹ hɑːpɪŋ ɔnðə pɹɑːdʒɛkt./', '<span tid="121192">Well</span><span>there’s</span><span>so</span><span>many</span><span tid="121196">fun</span><span tid="121197">collabs</span><span tid="121198">Congratulations</span><span>on</span><span>all</span><span>these</span><span tid="121202">friends</span><span>that</span><span>are</span><span tid="121205">hopping</span><span>on</span><span>the</span><span tid="121208">project.</span>'
FROM episodes e WHERE e.video_id = '137tgoWv5FgGzt3';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 40, 200.16, 203.3, 'You and Dua Lipa sound so good together.', '你和 Dua Lipa 的声音搭在一起很好听。', '/juː ænd duːə liːpə saʊnd soʊ ɡʊd təɡɛðɚ./', '<span>You</span><span>and</span><span tid="121211">Dua</span><span tid="121212">Lipa</span><span tid="121213">sound</span><span>so</span><span>good</span><span tid="121216">together.</span>'
FROM episodes e WHERE e.video_id = '137tgoWv5FgGzt3';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 41, 203.3, 207.22, 'Our voices though I love it too I love our voices together.', '我们的声音 我也很喜欢 我也很喜欢我们在一起的声音。', '/aʊɚ vɔɪsᵻz ðoʊ aɪ lʌv ɪt tuː aɪ lʌv aʊɚ vɔɪsᵻz təɡɛðɚ./', '<span>Our</span><span tid="121218">voices</span><span tid="121219">though</span><span>I</span><span tid="121221">love</span><span>it</span><span>too</span><span>I</span><span tid="121225">love</span><span>our</span><span tid="121227">voices</span><span tid="121228">together.</span>'
FROM episodes e WHERE e.video_id = '137tgoWv5FgGzt3';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 42, 207.22, 211.92, 'I loved hearing this song I remember for the first time and it’s like a perfect peanut butter jelly sandwich you know.', '我第一次听到这首歌的时候就很喜欢 就像完美的花生酱果酱三明治一样。', '/aɪ lʌvd hɪɹɪŋ ðɪs sɔŋ aɪ ɹᵻmɛmbɚ fɚðə fɜːst taɪm ænd ɪts laɪk ɐ pɜːfɛkt piːnʌt bʌɾɚ dʒɛli sændwɪtʃ juː noʊ./', '<span>I</span><span tid="121230">loved</span><span tid="121231">hearing</span><span>this</span><span tid="121233">song</span><span>I</span><span tid="121235">remember</span><span pid="572" class="highlight highlight-i">for the first time</span><span>and</span><span>it’s</span><span>like</span><span>a</span><span tid="121244">perfect</span><span pid="577" class="highlight highlight-c">peanut butter jelly sandwich</span><span>you</span><span>know.</span>'
FROM episodes e WHERE e.video_id = '137tgoWv5FgGzt3';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 43, 211.92, 215.32, 'Or like when you get the right amount of coffee creamer in your coffee it’s like.', '或者就像咖啡里加了刚刚好的奶精一样。', '/ɔːɹ laɪk wɛn juː ɡɛt ðə ɹaɪt ɐmaʊnt ʌv kɔfi kɹiːmɚɹ ɪn jʊɹ kɔfi ɪts laɪk./', '<span>Or</span><span>like</span><span>when</span><span>you</span><span>get</span><span>the</span><span tid="121257" class="highlight highlight-a">right</span><span tid="121258">amount</span><span>of</span><span pid="578" class="highlight highlight-c">coffee creamer</span><span>in</span><span>your</span><span tid="121264">coffee</span><span>it’s</span><span>like.</span>'
FROM episodes e WHERE e.video_id = '137tgoWv5FgGzt3';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 44, 215.32, 216.74, 'thank you It flows so well together.', '谢谢 它们融合得非常自然。', '/θæŋk juː ɪt floʊz soʊ wɛl təɡɛðɚ./', '<span tid="121267">thank</span><span>you</span><span>It</span><span tid="121270" class="highlight highlight-a">flows</span><span>so</span><span tid="121272">well</span><span tid="121273">together.</span>'
FROM episodes e WHERE e.video_id = '137tgoWv5FgGzt3';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 45, 216.74, 219.16, 'Such a sweet compliment Thank you I appreciate that.', '真是很甜的夸奖 谢谢 我很感激。', '/sʌtʃ ɐ swiːt kɑːmplɪmənt θæŋk juː aɪ ɐpɹiːʃɪeɪt ðæt./', '<span tid="121274">Such</span><span>a</span><span pid="579" class="highlight highlight-c">sweet compliment</span><span tid="121278">Thank</span><span>you</span><span>I</span><span tid="121281" class="highlight highlight-a">appreciate</span><span>that.</span>'
FROM episodes e WHERE e.video_id = '137tgoWv5FgGzt3';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 46, 219.16, 224.88, 'I was so curious about like you guys have been friends for a little bit too What have you learned from just your friendship with her.', '我很好奇 你们也认识一段时间了 从你们的友谊中你学到了什么。', '/aɪ wʌz soʊ kjʊɹɹiəs ɐbaʊt laɪk juː ɡaɪz hɐvbɪn fɹɛndz fɚɹə lɪɾəl bɪt tuː wʌt hæv juː lɜːnd fɹʌm dʒʌst jʊɹ fɹɛndʃɪp wɪð hɜː./', '<span>I</span><span>was</span><span>so</span><span tid="121286" class="highlight highlight-a">curious</span><span>about</span><span>like</span><span>you</span><span tid="121290">guys</span><span>have</span><span>been</span><span tid="121293">friends</span><span>for</span><span pid="567" class="highlight highlight-i">a little bit</span><span>too</span><span>What</span><span>have</span><span>you</span><span tid="121302">learned</span><span>from</span><span>just</span><span>your</span><span tid="121306">friendship</span><span>with</span><span>her.</span>'
FROM episodes e WHERE e.video_id = '137tgoWv5FgGzt3';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 47, 224.88, 227.9, 'She’s a caring person in general.', '她本身就是一个很关心别人的人。', '/ʃiːz ɐ kɛɹɪŋ pɜːsən ɪn dʒɛnɚɹəl./', '<span>She’s</span><span>a</span><span tid="121311">caring</span><span tid="121312">person</span><span>in</span><span tid="121314">general.</span>'
FROM episodes e WHERE e.video_id = '137tgoWv5FgGzt3';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 48, 227.9, 233.48, 'And we used to like do dinners and we would meet at parties.', '我们以前会一起吃饭 也会在派对上见面。', '/ænd wiː juːzd tə laɪk duː dɪnɚz ænd wiː wʊd miːt æt pɑːɹɾiz./', '<span>And</span><span>we</span><span tid="121317">used</span><span>to</span><span>like</span><span>do</span><span tid="121321">dinners</span><span>and</span><span>we</span><span>would</span><span tid="121325">meet</span><span>at</span><span tid="121327">parties.</span>'
FROM episodes e WHERE e.video_id = '137tgoWv5FgGzt3';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 49, 233.48, 239.04, 'And every time she’s always like making sure if I’m good and happy and healthy is everything good around you.', '而且每次她都会确认我过得好不好 是否开心 是否健康 身边的一切都好吗。', '/ænd ɛvɹi taɪm ʃiːz ɔːlweɪz laɪk meɪkɪŋ ʃʊɹ ɪf aɪm ɡʊd ænd hæpi ænd hɛlθi ɪz ɛvɹɪθɪŋ ɡʊd ɚɹaʊnd juː./', '<span>And</span><span tid="121329">every</span><span tid="121330">time</span><span>she’s</span><span tid="121332">always</span><span>like</span><span tid="121334">making</span><span tid="121335">sure</span><span>if</span><span>I’m</span><span>good</span><span>and</span><span tid="121340">happy</span><span>and</span><span tid="121342">healthy</span><span>is</span><span tid="121344">everything</span><span>good</span><span tid="121346">around</span><span>you.</span>'
FROM episodes e WHERE e.video_id = '137tgoWv5FgGzt3';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 50, 239.04, 242.78, 'So she’s someone that’s always made sure that I feel you know I’m feeling good.', '所以她一直让我感觉很好。', '/soʊ ʃiːz sʌmwʌn ðæts ɔːlweɪz meɪd ʃʊɹ ðæt aɪ fiːl juː noʊ aɪm fiːlɪŋ ɡʊd./', '<span>So</span><span>she’s</span><span tid="121350">someone</span><span>that’s</span><span tid="121352">always</span><span tid="121353">made</span><span tid="121354">sure</span><span>that</span><span>I</span><span tid="121357">feel</span><span>you</span><span>know</span><span>I’m</span><span tid="121361">feeling</span><span>good.</span>'
FROM episodes e WHERE e.video_id = '137tgoWv5FgGzt3';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 51, 242.78, 246.26, 'So to have her work on a song on this album.', '所以能让她参与这张专辑的歌曲。', '/soʊ tə hæv hɜː wɜːk ɔn ɐ sɔŋ ɔn ðɪs ælbəm./', '<span>So</span><span>to</span><span>have</span><span>her</span><span tid="121367">work</span><span>on</span><span>a</span><span tid="121370">song</span><span>on</span><span>this</span><span tid="121373">album.</span>'
FROM episodes e WHERE e.video_id = '137tgoWv5FgGzt3';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 52, 246.26, 254.24, 'she it’s like a great it’s it’s like having a great friend at work with you you know.', '就像是在工作中有一个很好的朋友陪在你身边。', '/ʃiː ɪts laɪk ɐ ɡɹeɪt ɪts ɪts laɪk hævɪŋ ɐ ɡɹeɪt fɹɛnd æt wɜːk wɪð juː juː noʊ./', '<span>she</span><span>it’s</span><span>like</span><span>a</span><span tid="121378">great</span><span>it’s</span><span>it’s</span><span>like</span><span>having</span><span>a</span><span tid="121384">great</span><span tid="121385">friend</span><span>at</span><span tid="121387">work</span><span>with</span><span>you</span><span>you</span><span>know.</span>'
FROM episodes e WHERE e.video_id = '137tgoWv5FgGzt3';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 53, 254.24, 263.66, 'Like what more can I ask for She’s supportive and she’s obviously giving sharing her beautiful voice with me on this album.', '我还能要求什么呢 她很支持我 而且也把她美妙的声音分享给了这张专辑。', '/laɪk wʌt mɔːɹ kæn aɪ æsk fɔːɹ ʃiːz səpɔːɹɾɪv ænd ʃiːz ɑːbviəsli ɡɪvɪŋ ʃɛɹɪŋ hɜː bjuːɾifəl vɔɪs wɪð miː ɔn ðɪs ælbəm./', '<span>Like</span><span>what</span><span>more</span><span>can</span><span>I</span><span tid="121397">ask</span><span>for</span><span>She’s</span><span tid="121400" class="highlight highlight-a">supportive</span><span>and</span><span>she’s</span><span tid="121403" class="highlight highlight-a">obviously</span><span tid="121404">giving</span><span tid="121405" class="highlight highlight-a">sharing</span><span>her</span><span tid="121407">beautiful</span><span tid="121408">voice</span><span>with</span><span>me</span><span>on</span><span>this</span><span tid="121413">album.</span>'
FROM episodes e WHERE e.video_id = '137tgoWv5FgGzt3';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 54, 263.66, 267.52, 'Like I’m just so happy And it was a great day when we had the shoot.', '我真的很开心 而且我们拍摄那天也很棒。', '/laɪk aɪm dʒʌst soʊ hæpi ænd ɪt wʌzɐ ɡɹeɪt deɪ wɛn wiː hæd ðə ʃuːt./', '<span>Like</span><span>I’m</span><span>just</span><span>so</span><span tid="121418">happy</span><span>And</span><span>it</span><span>was</span><span>a</span><span tid="121423">great</span><span>day</span><span>when</span><span>we</span><span>had</span><span>the</span><span tid="121429" class="highlight highlight-a">shoot.</span>'
FROM episodes e WHERE e.video_id = '137tgoWv5FgGzt3';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 55, 267.52, 272.92, 'It felt like we were just out in New York in the cold wearing crazy outfits just jamming to a song.', '感觉就像我们在纽约的寒冷中 穿着很夸张的衣服 一起随着音乐摇摆。', '/ɪt fɛlt laɪk wiː wɜː dʒʌst aʊt ɪn nuː jɔːɹk ɪnðə koʊld wɛɹɪŋ kɹeɪzi aʊtfɪts dʒʌst dʒæmɪŋ tʊ ɐ sɔŋ./', '<span>It</span><span tid="121431">felt</span><span>like</span><span>we</span><span>were</span><span>just</span><span tid="121436">out</span><span>in</span><span tid="121438">New</span><span tid="121439">York</span><span>in</span><span>the</span><span tid="121442" class="highlight highlight-a">cold</span><span tid="121443">wearing</span><span tid="121444">crazy</span><span tid="121445" class="highlight highlight-a">outfits</span><span>just</span><span tid="121447" class="highlight highlight-a">jamming</span><span>to</span><span>a</span><span tid="121450">song.</span>'
FROM episodes e WHERE e.video_id = '137tgoWv5FgGzt3';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 56, 272.92, 278.12, 'She really is like a comfort human right like your comfort support human.', '她真的就是那种让人安心的人 对吧 就是你的情绪支撑。', '/ʃiː ɹiəli ɪz laɪk ɐ kʌmfɚt hjuːmən ɹaɪt laɪk jʊɹ kʌmfɚt səpɔːɹt hjuːmən./', '<span>She</span><span tid="121452">really</span><span>is</span><span>like</span><span>a</span><span tid="121456" class="highlight highlight-a">comfort</span><span tid="121457">human</span><span tid="121458" class="highlight highlight-a">right</span><span>like</span><span>your</span><span tid="121461" class="highlight highlight-a">comfort</span><span tid="121462">support</span><span tid="121463">human.</span>'
FROM episodes e WHERE e.video_id = '137tgoWv5FgGzt3';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 57, 278.12, 281.94, 'She just has that presence about her And she’s got to be one of them for you.', '她身上有那种气场 对你来说她一定是其中之一。', '/ʃiː dʒʌst hɐz ðæt pɹɛzəns ɐbaʊt hɜː ænd ʃiːz ɡɑːt təbi wʌn ʌv ðɛm fɔːɹ juː./', '<span>She</span><span>just</span><span>has</span><span>that</span><span tid="121468" class="highlight highlight-a">presence</span><span>about</span><span>her</span><span>And</span><span>she’s</span><span>got</span><span>to</span><span>be</span><span>one</span><span>of</span><span>them</span><span>for</span><span>you.</span>'
FROM episodes e WHERE e.video_id = '137tgoWv5FgGzt3';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 58, 281.94, 288.6, 'But being honored coming up at Billboard’s Women in Music you’re one of the global forces for 2025 Sounds so cool.', '而且你还将在 Billboard Women in Music 上被表彰 你是2025年的全球力量之一 听起来很酷。', '/bʌt biːɪŋ ɑːnɚd kʌmɪŋ ʌp æt bɪlbɔːɹdz wɪmɪn ɪn mjuːzɪk jʊɹ wʌn ʌvðə ɡloʊbəl fɔːɹsᵻz fɔːɹ tuː θaʊzənd twɛnti faɪv saʊndz soʊ kuːl./', '<span>But</span><span>being</span><span tid="121483">honored</span><span tid="121484">coming</span><span>up</span><span>at</span><span tid="121487">Billboard’s</span><span tid="121488">Women</span><span>in</span><span tid="121490">Music</span><span>you’re</span><span>one</span><span>of</span><span>the</span><span tid="121495">global</span><span tid="121496" class="highlight highlight-a">forces</span><span>for</span><span>2025</span><span tid="121499">Sounds</span><span>so</span><span tid="121501" class="highlight highlight-a">cool.</span>'
FROM episodes e WHERE e.video_id = '137tgoWv5FgGzt3';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 59, 288.6, 292.48, 'Obviously you know your mom is such an important figure in your life.', '当然你也知道 你的妈妈在你的人生中非常重要。', '/ɑːbviəsli juː noʊ jʊɹ mɑːm ɪz sʌtʃ ɐn ɪmpɔːɹtənt fɪɡjɚɹ ɪn jʊɹ laɪf./', '<span tid="121502" class="highlight highlight-a">Obviously</span><span>you</span><span>know</span><span>your</span><span tid="121506">mom</span><span>is</span><span tid="121508">such</span><span>an</span><span tid="121510">important</span><span tid="121511" class="highlight highlight-a">figure</span><span>in</span><span>your</span><span tid="121514">life.</span>'
FROM episodes e WHERE e.video_id = '137tgoWv5FgGzt3';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 60, 292.48, 295.72, 'But what about some other women that have inspired you and helped shape your journey.', '但还有哪些女性也启发了你 并塑造了你的成长之路。', '/bʌt wʌt ɐbaʊt sʌm ʌðɚ wɪmɪn ðæt hæv ɪnspaɪɚd juː ænd hɛlpt ʃeɪp jʊɹ dʒɜːni./', '<span>But</span><span>what</span><span>about</span><span>some</span><span tid="121519">other</span><span tid="121520">women</span><span>that</span><span>have</span><span tid="121523" class="highlight highlight-a">inspired</span><span>you</span><span>and</span><span tid="121526">helped</span><span tid="121527" class="highlight highlight-a">shape</span><span>your</span><span tid="121529">journey.</span>'
FROM episodes e WHERE e.video_id = '137tgoWv5FgGzt3';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 61, 295.72, 307.76, 'On my team there’s so many strong women or I have so many strong women around me that are really in every step of the way that I’m in.', '在我的团队里有很多很强大的女性 或者说我身边一直有很多很强大的女性陪伴着我走每一步。', '/ɔn maɪ tiːm ðɛɹz soʊ mɛni stɹɔŋ wɪmɪn ɔːɹ aɪ hæv soʊ mɛni stɹɔŋ wɪmɪn ɚɹaʊnd miː ðæt ɑːɹ ɹiəli ɪn ɛvɹi stɛp ʌvðə weɪ ðæt aɪm ɪn./', '<span>On</span><span>my</span><span tid="121532">team</span><span>there’s</span><span>so</span><span>many</span><span tid="121536">strong</span><span tid="121537">women</span><span>or</span><span>I</span><span>have</span><span>so</span><span>many</span><span tid="121543">strong</span><span tid="121544">women</span><span tid="121545">around</span><span>me</span><span>that</span><span>are</span><span tid="121549">really</span><span>in</span><span tid="121551">every</span><span tid="121552">step</span><span>of</span><span>the</span><span tid="121555" class="highlight highlight-a">way</span><span>that</span><span>I’m</span><span>in.</span>'
FROM episodes e WHERE e.video_id = '137tgoWv5FgGzt3';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 62, 307.76, 316.4, 'So to have that bond to always kind of shows taught me a way to respect them.', '所以这种联系一直让我学会去尊重她们。', '/soʊ tə hæv ðæt bɑːnd tʊ ɔːlweɪz kaɪnd ʌv ʃoʊz tɔːt miː ɐ weɪ tə ɹᵻspɛkt ðɛm./', '<span>So</span><span>to</span><span>have</span><span>that</span><span tid="121563" class="highlight highlight-a">bond</span><span>to</span><span tid="121565">always</span><span tid="121566">kind</span><span>of</span><span tid="121568">shows</span><span tid="121569">taught</span><span>me</span><span>a</span><span tid="121572" class="highlight highlight-a">way</span><span>to</span><span tid="121574">respect</span><span>them.</span>'
FROM episodes e WHERE e.video_id = '137tgoWv5FgGzt3';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 63, 316.4, 322.14, 'And and I’ll always be learning from people around me.', '而且我也会一直从身边的人身上学习。', '/ænd ænd aɪl ɔːlweɪz biː lɜːnɪŋ fɹʌm piːpəl ɚɹaʊnd miː./', '<span>And</span><span>and</span><span>I’ll</span><span tid="121579">always</span><span>be</span><span tid="121581">learning</span><span>from</span><span tid="121583">people</span><span tid="121584">around</span><span>me.</span>'
FROM episodes e WHERE e.video_id = '137tgoWv5FgGzt3';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 64, 322.14, 330.88, 'So to to be someone for to be that person for somebody else would be you know an honor.', '所以如果我也能成为别人那样的人 那会是一种荣幸。', '/soʊ tʊtə biː sʌmwʌn fɔːɹ təbi ðæt pɜːsən fɔːɹ sʌmbɑːdi ɛls wʊd biː juː noʊ ɐn ɑːnɚ./', '<span>So</span><span>to</span><span>to</span><span>be</span><span tid="121590">someone</span><span>for</span><span>to</span><span>be</span><span>that</span><span tid="121595">person</span><span>for</span><span tid="121597">somebody</span><span tid="121598">else</span><span>would</span><span>be</span><span>you</span><span>know</span><span>an</span><span tid="121604">honor.</span>'
FROM episodes e WHERE e.video_id = '137tgoWv5FgGzt3';
INSERT INTO subtitles (episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT e.id, 65, 330.88, 335.04, 'And you know I want to do well and take care of this honor; of course.', '而且我也希望能把这份荣誉做好并好好珍惜 当然。', '/ænd juː noʊ aɪ wɔnt tə duː wɛl ænd teɪk kɛɹ ʌv ðɪs ɑːnɚ; ʌv kɔːɹs./', '<span>And</span><span>you</span><span>know</span><span>I</span><span>want</span><span>to</span><span>do</span><span tid="121612">well</span><span>and</span><span tid="121614">take</span><span tid="121615">care</span><span>of</span><span>this</span><span tid="121618">honor;</span><span>of</span><span tid="121620" class="highlight highlight-a">course.</span>'
FROM episodes e WHERE e.video_id = '137tgoWv5FgGzt3';

-- sync tags id sequence if present
SELECT setval(
  pg_get_serial_sequence('tags', 'id'),
  GREATEST(COALESCE((SELECT MAX(id) FROM tags), 1), 1)
) WHERE pg_get_serial_sequence('tags', 'id') IS NOT NULL;

COMMIT;

-- imported video_ids: dlfC9v8siowrhA8, 7wO304w7y7rT6wM, 7cDe7KDz5VDVJ9s, A2lf_e3bIcXxIJY, LgYY-X3UwLxRpx4, 130mCl4CJRRAC9Q, 131pRP2r5fuTOvP, 1320cmtnAGaDO4R, 134DHRPZp2BKOEk, 137tgoWv5FgGzt3
