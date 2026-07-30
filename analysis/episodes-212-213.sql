-- vlogish episode import SQL
-- generated: 2026-07-07T14:58:28.026257Z
-- episodes: 2 (index 212..213)
-- Run on production PostgreSQL inside transaction.

BEGIN;

INSERT INTO authors (name, gender, nationality, accent)
SELECT 'The Tonight Show Starring Jimmy Fallon', 'm', '', '美国'
WHERE NOT EXISTS (
  SELECT 1 FROM authors x
  WHERE x.name = 'The Tonight Show Starring Jimmy Fallon' AND x.accent = '美国'
);
INSERT INTO authors (name, gender, nationality, accent)
SELECT 'Jimmy Kimmel Live', 'm', '', '美国'
WHERE NOT EXISTS (
  SELECT 1 FROM authors x
  WHERE x.name = 'Jimmy Kimmel Live' AND x.accent = '美国'
);


-- episode 212: i8tBrrjm1aoxSbc
UPDATE user_word_lookups SET subtitle_id = NULL WHERE subtitle_id IN (SELECT s.id FROM subtitles s JOIN episodes e ON s.episode_id = e.id WHERE e.video_id = 'i8tBrrjm1aoxSbc');
UPDATE user_vocabulary_items SET source_subtitle_id = NULL WHERE source_subtitle_id IN (SELECT s.id FROM subtitles s JOIN episodes e ON s.episode_id = e.id WHERE e.video_id = 'i8tBrrjm1aoxSbc');
DELETE FROM user_subtitle_progress WHERE subtitle_id IN (SELECT s.id FROM subtitles s JOIN episodes e ON s.episode_id = e.id WHERE e.video_id = 'i8tBrrjm1aoxSbc');
DELETE FROM user_subtitle_progress WHERE episode_id = (SELECT id FROM episodes WHERE video_id = 'i8tBrrjm1aoxSbc');
DELETE FROM subtitles WHERE episode_id = (SELECT id FROM episodes WHERE video_id = 'i8tBrrjm1aoxSbc');
DELETE FROM episode_tags WHERE episode_id = (SELECT id FROM episodes WHERE video_id = 'i8tBrrjm1aoxSbc');
INSERT INTO episodes (
  index, video_id, short_title, summary, remark, stars, voca_size,
  subtitle_count, clip_length, cover, video_url, audio_url, thumbnail_url,
  original_video_url, author_id, submitted_by_user_id, rejection_reason,
  created_at, is_demo, status, published_at
) VALUES (
  212, 'i8tBrrjm1aoxSbc', '安妮·海瑟薇谈《公主日记》《穿普拉达的女王》细节与《关于你的想法》',
  '安妮·海瑟薇谈论与安娜·温图尔在百老汇客串、答错关于自己角色的《穿普拉达的女王》冷知识，以及与尼古拉斯·加利齐纳合作《关于你的想法》。
0:00-2:35 安妮·海瑟薇谈《穿普拉达的女王》和《公主日记》
2:36-4:14 安妮·海瑟薇谈与安娜·温图尔的百老汇客串
4:15-6:20 浣熊抢了安妮·海瑟薇的风头
6:21-9:58 安妮·海瑟薇谈《关于你的想法》
《吉米·法伦今夜秀》。现已在Peacock流媒体播出：https://bit.ly/3gZJaNy
立即订阅《吉米·法伦今夜秀》：http://bit.ly/1nwT1aN
观看《吉米·法伦今夜秀》工作日晚上11:35ET/10:35c
获取更多《吉米·法伦今夜秀》：https://www.nbc.com/the-tonight-show
吉米·法伦社交媒体
关注吉米：http://Twitter.com/JimmyFallon
点赞吉米：https://Facebook.com/JimmyFallon
关注吉米：https://www.instagram.com/jimmyfallon/
关注吉米TikTok：https://www.tiktok.com/
今夜秀社交媒体
关注今夜秀：http://Twitter.com/FallonTonight
点赞今夜秀：https://Facebook.com/FallonTonight
关注今夜秀：https://www.instagram.com/fallontonight/
今夜秀TikTok：https://www.tiktok.com/
今夜秀Tumblr：http://fallontonight.tumblr.com
《吉米·法伦今夜秀》包含节目精彩片段，包括喜剧小品、音乐模仿、名人访谈、搞笑游戏，当然还有吉米的感谢信和话题标签！你还会找到幕后花絮和其他精彩的网络独家内容。
获取更多NBC
NBC YouTube：http://bit.ly/1dM1qBH
点赞NBC：http://Facebook.com/NBC
关注NBC：http://Twitter.com/NBC
NBC Instagram：http://instagram.com/nbctv
NBC Tumblr：http://nbctv.tumblr.com/
安妮·海瑟薇忘记《公主日记》和《穿普拉达的女王》细节，畅谈《关于你的想法》
http://www.youtube.com/fallontonight', '',
  4, 85, 221,
  602.302, 'http://oss.sxakgs.com/en/ocGJWc2F1Yk/cover.webp',
  'http://oss.sxakgs.com/en/ocGJWc2F1Yk/video.mp4', 'http://oss.sxakgs.com/en/ocGJWc2F1Yk/audio.mp3',
  'http://oss.sxakgs.com/en/ocGJWc2F1Yk/cover.webp', 'https://www.youtube.com/watch?v=ocGJWc2F1Yk',
  (SELECT id FROM authors WHERE name = 'The Tonight Show Starring Jimmy Fallon' AND accent = '美国' LIMIT 1),
  NULL, NULL,
  '2026-07-07 14:44:27'::timestamp,
  FALSE, 'draft',
  '2026-07-07 14:44:27'::timestamp
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
  submitted_by_user_id = EXCLUDED.submitted_by_user_id,
  rejection_reason = EXCLUDED.rejection_reason,
  is_demo = EXCLUDED.is_demo,
  status = EXCLUDED.status,
  published_at = EXCLUDED.published_at;

INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 0, 1.201, 2.336, '-Who doesn''t love Anne Hathaway?', '谁不喜欢安妮·海瑟薇呢？', '/huː ˈdʌzənt ˈlʌv æn ˈhæθəweɪ/', '<span>-</span><span>Who</span><span>doesn''t</span><span tid="50001" class="highlight highlight-a">love</span><span>Anne</span><span>Hathaway</span><span>?</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 1, 2.336, 3.704, 'Thank you for coming. -That''s very nice.', '谢谢你能来。 - 那太好了。', '/θæŋk juː fɔːr ˈkʌmɪŋ | ðæts ˈvɛri naɪs/', '<span>Thank</span><span>you</span><span>for</span><span tid="50002" class="highlight highlight-a">coming</span><span>.</span><span>-</span><span>That''s</span><span>very</span><span>nice</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 2, 3.704, 5.739, 'But you know when you have a moment, you''re just like, "Oh, I''m gonna remember that forever."', '但你知道当你有一个时刻，你会想，‘哦，我会永远记住那个。’', '/bʌt juː noʊ wɛn juː hæv ə ˈmoʊmənt | jʊr dʒʌst laɪk | oʊ | aɪm ˈɡoʊɪŋ tə rɪˈmɛmbər ðæt fərˈɛvər/', '<span>But</span><span>you</span><span>know</span><span>when</span><span>you</span><span>have</span><span>a</span><span tid="50003" class="highlight highlight-a">moment</span><span>,</span><span>you''re</span><span>just</span><span>like</span><span>,</span><span>"</span><span>Oh</span><span>,</span><span>I''m</span><span>gonna</span><span tid="50004" class="highlight highlight-a">remember</span><span>that</span><span tid="50005" class="highlight highlight-a">forever</span><span>.</span><span>"</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 3, 5.739, 7.007, 'Thank you so much for that.', '非常感谢你。', '/θæŋk juː soʊ mʌtʃ fɔːr ðæt/', '<span>Thank</span><span>you</span><span>so</span><span>much</span><span>for</span><span>that</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 4, 7.007, 8.976, '-There you go. It just happened. Come on. The Roots.', '- 就是这样。它刚刚发生了。来吧。The Roots。', '/ðɛr juː ɡoʊ | ɪt dʒʌst ˈhæpənd | kʌm ɑn | ðə ruːts/', '<span>-</span><span>There</span><span>you</span><span tid="50006" class="highlight highlight-i">go</span><span>.</span><span>It</span><span>just</span><span tid="50007" class="highlight highlight-a">happened</span><span>.</span><span>Come</span><span tid="50008" class="highlight highlight-d">on</span><span>.</span><span>The</span><span>Roots</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 5, 8.976, 11.745, '-Thank you. Hi, everybody.', '- 谢谢。大家好。', '/θæŋk juː | haɪ ˈɛvriˌbɑdi/', '<span>-</span><span>Thank</span><span>you</span><span>.</span><span>Hi</span><span>,</span><span>everybody</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 6, 11.745, 13.68, '-Thank you for playing "Reverse Charades" with me.', '- 谢谢你和我一起玩“反向猜词”。', '/θæŋk juː fɔːr ˈpleɪɪŋ rɪˈvɜːrs ˈʃærədz wɪð miː/', '<span>-</span><span>Thank</span><span>you</span><span>for</span><span tid="50009" class="highlight highlight-a">playing</span><span>"</span><span>Reverse</span><span>Charades</span><span>"</span><span>with</span><span>me</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 7, 13.68, 14.948, 'You''re a great partner. -Thank you.', '你是个好搭档。 - 谢谢。', '/jʊr ə ɡreɪt ˈpɑːrtnər | θæŋk juː/', '<span>You''re</span><span>a</span><span>great</span><span tid="50010" class="highlight highlight-a">partner</span><span>.</span><span>-</span><span>Thank</span><span>you</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 8, 14.948, 16.85, 'You''re a great partner.', '你是个很棒的搭档。', '/jʊr ə greɪt ˈpɑːrtnər/', '<span>You''re</span><span>a</span><span tid="50011" class="highlight highlight-a">great</span><span>partner.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 9, 16.85, 18.218, '-I mean, are you are you competitive when you play games?', '我的意思是，你玩游戏的时候有竞争心吗？', '/aɪ min ɑːr juː ɑːr juː kəmˈpɛtətɪv wɛn juː pleɪ geɪmz/', '<span>-I</span><span>mean,</span><span>are</span><span>you</span><span>are</span><span>you</span><span tid="50012" class="highlight highlight-a">competitive</span><span>when</span><span>you</span><span>play</span><span>games?</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 10, 18.218, 20.22, 'Do you play games at home? -Oh, I don''t mean to be.', '你在家玩游戏吗？——哦，我不是故意的。', '/duː juː pleɪ geɪmz æt hoʊm oʊ aɪ doʊnt min tuː biː/', '<span>Do</span><span>you</span><span>play</span><span>games</span><span>at</span><span>home?</span><span>-Oh,</span><span>I</span><span>don''t</span><span>mean</span><span>to</span><span>be.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 11, 20.22, 21.522, '-I know. Me neither. -I don''t mean to me.', '我知道。我也不是。——我不是针对我。', '/aɪ noʊ miː ˈniːðər aɪ doʊnt min tuː miː/', '<span>-I</span><span>know.</span><span>Me</span><span tid="50013" class="highlight highlight-a">neither.</span><span>-I</span><span>don''t</span><span>mean</span><span>to</span><span>me.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 12, 21.522, 24.157, 'But then you saw her over there, I was like, "No, it''s just a nice, friendly game."', '但后来你看到她在那儿，我就想，“不，这只是个友好、轻松的游戏。”', '/bʌt ðɛn juː sɔː hər ˈoʊvər ðɛr aɪ wʌz laɪk noʊ ɪts dʒʌst ə naɪs ˈfrendli geɪm/', '<span>But</span><span>then</span><span>you</span><span>saw</span><span>her</span><span>over</span><span>there,</span><span>I</span><span>was</span><span>like,</span><span>"No,</span><span>it''s</span><span>just</span><span>a</span><span>nice,</span><span tid="50014" class="highlight highlight-a">friendly</span><span>game."</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 13, 24.157, 25.993, 'And then the last, I''m like, "But the points are on.', '然后到最后，我就想，“但是分数是算的。”', '/ænd ðɛn ðə læst aɪm laɪk bʌt ðə pɔɪnts ɑːr ɑːn/', '<span>And</span><span>then</span><span>the</span><span>last,</span><span>I''m</span><span>like,</span><span>"But</span><span>the</span><span tid="50015" class="highlight highlight-a">points</span><span>are</span><span>on.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 14, 25.993, 28.161, 'Like, it''s on." -Let''s go. I want to win this.', '就像，算数的。——走吧。我想赢这个。', '/laɪk ɪts ɑːn lɛts goʊ aɪ wɑːnt tuː wɪn ðɪs/', '<span>Like,</span><span>it''s</span><span>on."</span><span>-Let''s</span><span tid="50016" class="highlight highlight-i">go.</span><span>I</span><span>want</span><span>to</span><span>win</span><span>this.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 15, 28.161, 31.331, '-Something takes over. I''m less competitive now.', '有什么东西控制了我。我现在没那么有竞争心了。', '/ˈsʌmθɪŋ teɪks ˈoʊvər aɪm lɛs kəmˈpɛtətɪv naʊ/', '<span>-Something</span><span>takes</span><span tid="50017" class="highlight highlight-d">over.</span><span>I''m</span><span>less</span><span tid="50018" class="highlight highlight-a">competitive</span><span>now.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 16, 31.331, 32.699, '-Why? -Kids.', '——为什么？——孩子。', '/waɪ kɪdz/', '<span>-Why?</span><span>-Kids.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 17, 32.699, 34.201, '-Yeah. Yeah.', '——是啊。是啊。', '/jɛə jɛə/', '<span>-Yeah.</span><span>Yeah.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 18, 34.201, 39.406, '-I think maybe being competitive is genetic, because my kids are, like -- They''re competitive, too.', '——我觉得竞争性可能是遗传的，因为我的孩子们就像——他们也很有竞争性。', '/aɪ θɪŋk ˈmeɪbi ˈbiːɪŋ kəmˈpɛtətɪv ɪz dʒəˈnɛtɪk bɪˈkʌz maɪ kɪdz ɑːr laɪk ðeɪr kəmˈpɛtətɪv tuː/', '<span>-I</span><span>think</span><span>maybe</span><span>being</span><span tid="50019" class="highlight highlight-a">competitive</span><span>is</span><span tid="50020" class="highlight highlight-a">genetic</span><span>,</span><span>because</span><span>my</span><span>kids</span><span>are</span><span>,</span><span>like</span><span>--</span><span>They</span><span>''re</span><span tid="50021" class="highlight highlight-a">competitive</span><span>,</span><span>too.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 19, 39.406, 42.009, 'And it turns out motherhood has softened me, and I like to watch them win.', '结果发现当母亲让我变得心软了，我喜欢看他们赢。', '/ænd ɪt tɜːrnz aʊt ˈmʌðərhʊd hæz ˈsɔːfənd miː ænd aɪ laɪk tuː wɑːtʃ ðɛm wɪn/', '<span>And</span><span>it</span><span pid="501" class="highlight highlight-d">turns out</span><span tid="50022" class="highlight highlight-a">motherhood</span><span>has</span><span tid="50023" class="highlight highlight-a">softened</span><span>me</span><span>,</span><span>and</span><span>I</span><span>like</span><span>to</span><span>watch</span><span>them</span><span>win.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 20, 42.009, 43.043, '-Yeah. -Aww.', '——是啊。——噢。', '/jɛə ɔː/', '<span>-Yeah.</span><span>-Aww.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 21, 43.043, 45.412, '-My kids are very competitive, too.', '——我的孩子们也很有竞争性。', '/maɪ kɪdz ɑːr ˈvɛri kəmˈpɛtətɪv tuː/', '<span>-My</span><span>kids</span><span>are</span><span>very</span><span tid="50024" class="highlight highlight-a">competitive</span><span>,</span><span>too.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 22, 45.412, 48.015, 'Well, my one daughter is. Yeah. Yeah.', '嗯，我的一个女儿是。是啊。是啊。', '/wɛl maɪ wʌn ˈdɔːtər ɪz jɛə jɛə/', '<span>Well</span><span>,</span><span>my</span><span>one</span><span>daughter</span><span>is.</span><span>Yeah.</span><span>Yeah.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 23, 48.015, 50.083, 'The other one doesn''t really care.', '另一个不太在乎。', '/ði ˈʌðər wʌn ˈdʌzənt ˈrɪli kɛr/', '<span>The</span><span>other</span><span>one</span><span>doesn</span><span>''t</span><span>really</span><span>care.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 24, 50.083, 51.785, 'She''s like, "That''s fun. It''s all good."', '她说：“那很有趣。一切都很好。”', '/ʃiːz laɪk ðæt fʌn ɪts ɔːl ɡʊd/', '<span>She''s</span><span>like</span><span>,</span><span>"</span><span>That''s</span><span tid="50025" class="highlight highlight-a">fun</span><span>.</span><span>It''s</span><span>all</span><span>good</span><span>.</span><span>"</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 25, 51.785, 53.387, 'But the other one really wants to win.', '但另一个真的很想赢。', '/bʌt ðə ˈʌðər wʌn ˈrɪli wɑːnts tə wɪn/', '<span>But</span><span>the</span><span>other</span><span>one</span><span>really</span><span>wants</span><span>to</span><span tid="50026" class="highlight highlight-a">win</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 26, 53.387, 55.489, 'And I don''t throw the games.', '而且我不会故意输掉比赛。', '/ænd aɪ doʊnt θroʊ ðə ɡeɪmz/', '<span>And</span><span>I</span><span>don''t</span><span tid="50027" class="highlight highlight-a">throw</span><span>the</span><span>games</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 27, 55.489, 60.36, 'You know, I go -- I really -- And I play for -- I play for money, too.', '你知道，我——我真的——我玩——我也为了钱玩。', '/juː noʊ aɪ ɡoʊ aɪ ˈrɪli ænd aɪ pleɪ fɔːr aɪ pleɪ fɔːr ˈmʌni tuː/', '<span>You</span><span>know</span><span>,</span><span>I</span><span>go</span><span>--</span><span>I</span><span>really</span><span>--</span><span>And</span><span>I</span><span>play</span><span>for</span><span>--</span><span>I</span><span>play</span><span>for</span><span tid="50028" class="highlight highlight-a">money</span><span>,</span><span>too</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 28, 62.129, 65.632, 'Are you -- Is there a party game that you''re especially good at?', '你——有没有一种派对游戏你特别擅长？', '/ɑːr juː ɪz ðər ə ˈpɑːrti ɡeɪm ðæt jʊər ɪˈspeʃəli ɡʊd æt/', '<span>Are</span><span>you</span><span>--</span><span>Is</span><span>there</span><span>a</span><span>party</span><span>game</span><span>that</span><span>you''re</span><span tid="50029" class="highlight highlight-a">especially</span><span>good</span><span>at</span><span>?</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 29, 65.632, 67.401, '-Es-- No.', '——呃——没有。', '/ɛs noʊ/', '<span>-Es--</span><span>No</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 30, 67.401, 74.508, 'I mean, you know, I was playing a game -- We play a lot of Pokémon and we play a lot of Trouble and Sorry!', '我的意思是，你知道，我在玩一个游戏——我们玩很多宝可梦，也玩很多麻烦和抱歉！', '/aɪ miːn juː noʊ aɪ wəz ˈpleɪɪŋ ə ɡeɪm wiː pleɪ ə lɑːt əv ˈpoʊkɪmɑːn ænd wiː pleɪ ə lɑːt əv ˈtrʌbəl ænd ˈsɔːri/', '<span>I</span><span>mean</span><span>,</span><span>you</span><span>know</span><span>,</span><span>I</span><span>was</span><span>playing</span><span>a</span><span>game</span><span>--</span><span>We</span><span>play</span><span>a</span><span>lot</span><span>of</span><span tid="50030" class="highlight highlight-a">Pokémon</span><span>and</span><span>we</span><span>play</span><span>a</span><span>lot</span><span>of</span><span tid="50031" class="highlight highlight-a">Trouble</span><span>and</span><span tid="50032" class="highlight highlight-a">Sorry</span><span>!</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 31, 74.508, 79.313, 'But there is a game -- I was working last week and I was on set, and we were just passing the time.', '但有一个游戏——上周我在工作，在片场，我们只是在打发时间。', '/bʌt ðər ɪz ə ɡeɪm aɪ wəz ˈwɜːrkɪŋ læst wiːk ænd aɪ wəz ɑːn sɛt ænd wiː wər ˈdʒʌst ˈpæsɪŋ ðə taɪm/', '<span>But</span><span>there</span><span>is</span><span>a</span><span>game</span><span>--</span><span>I</span><span>was</span><span>working</span><span>last</span><span>week</span><span>and</span><span>I</span><span>was</span><span>on</span><span tid="50033" class="highlight highlight-a">set</span><span>,</span><span>and</span><span>we</span><span>were</span><span>just</span><span tid="50034" class="highlight highlight-d">passing</span><span>the</span><span>time</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 32, 79.313, 83.383, 'And have you seen that movie trivia game where it''s cards and they -- and it just asks you questions?', '你看过那个电影问答游戏吗？就是有卡片，然后它问你问题的那种。', '/ænd hæv juː siːn ðæt ˈmʊvi ˈtrɪviə geɪm wɛr ɪts kɑːrdz ænd ðeɪ -- ænd ɪt dʒʌst æskz juː ˈkwɛstʃənz/', '<span>And</span><span pid="502" class="highlight highlight-d">have you seen</span><span>that</span><span tid="50035" class="highlight highlight-a">movie</span><span tid="50036" class="highlight highlight-a">trivia</span><span>game</span><span>where</span><span>it''s</span><span>cards</span><span>and</span><span>they</span><span>--</span><span>and</span><span>it</span><span>just</span><span tid="50037" class="highlight highlight-a">asks</span><span>you</span><span>questions?</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 33, 83.383, 86.887, '-Oh, yeah, I''ve seen -- Like, they have a bunch of quizzes, like sports and movies.', '哦，是的，我见过——就像，他们有一堆测验，比如体育和电影。', '/oʊ jɛs aɪv siːn -- laɪk ðeɪ hæv ə bʌntʃ əv ˈkwɪziz laɪk spɔːrts ænd ˈmuːviz/', '<span>-Oh,</span><span>yeah,</span><span>I''ve</span><span>seen</span><span>--</span><span>Like,</span><span>they</span><span>have</span><span>a</span><span tid="50038" class="highlight highlight-a">bunch</span><span>of</span><span tid="50039" class="highlight highlight-a">quizzes,</span><span>like</span><span>sports</span><span>and</span><span>movies.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 34, 86.887, 90.657, '-And I was just having one of those, like, runs where I couldn''t miss.', '我当时正好处于那种状态，怎么答都对。', '/ænd aɪ wʌz dʒʌst ˈhævɪŋ wʌn əv ðoʊz laɪk rʌnz wɛr aɪ ˈkʊdənt mɪs/', '<span>-And</span><span>I</span><span>was</span><span>just</span><span>having</span><span>one</span><span>of</span><span>those,</span><span>like,</span><span tid="50040" class="highlight highlight-a">runs</span><span>where</span><span>I</span><span>couldn''t</span><span tid="50041" class="highlight highlight-a">miss.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 35, 90.657, 93.093, 'Like, I just knew and I was, like, surprising myself.', '就是，我都知道，我自己都感到惊讶。', '/laɪk aɪ dʒʌst nuː ænd aɪ wʌz laɪk sərˈpraɪzɪŋ maɪˈsɛlf/', '<span>Like,</span><span>I</span><span>just</span><span>knew</span><span>and</span><span>I</span><span>was,</span><span>like,</span><span tid="50042" class="highlight highlight-a">surprising</span><span>myself.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 36, 93.093, 94.394, '-Well, you know your stuff. You know movies.', '嗯，你懂行。你懂电影。', '/wɛl juː noʊ jɔːr stʌf juː noʊ ˈmuːviz/', '<span>-Well,</span><span>you</span><span>know</span><span>your</span><span tid="50043" class="highlight highlight-a">stuff.</span><span>You</span><span>know</span><span>movies.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 37, 94.394, 96.063, '-I didn''t -- I mean, apparently, I do.', '我并没有——我是说，显然我懂。', '/aɪ dɪdənt -- aɪ miːn əˈpɛrəntli aɪ duː/', '<span>-I</span><span>didn''t</span><span>--</span><span>I</span><span>mean,</span><span tid="50044" class="highlight highlight-a">apparently,</span><span>I</span><span>do.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 38, 96.063, 100.434, 'And then I got to this one question, and they were like, "Oh, okay.', '然后我遇到了一个问题，他们说：“哦，好吧。', '/ænd ðɛn aɪ gɑːt tuː ðɪs wʌn ˈkwɛstʃən ænd ðeɪ wɜːr laɪk oʊ oʊˈkeɪ/', '<span>And</span><span>then</span><span>I</span><span>got</span><span>to</span><span>this</span><span>one</span><span>question,</span><span>and</span><span>they</span><span>were</span><span>like,</span><span>"Oh,</span><span>okay.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 39, 100.434, 103.537, 'So, uh, junior executive assistant, ''Devil Wears Prada.''"', '那么，呃，初级行政助理，《穿普拉达的女王》。', '/soʊ ʌh ˈdʒuːnjər ɪkˈsɛkjətɪv æsɪstənt ˈdɛvəl wɛrz ˈprɑːdə/', '<span>So,</span><span>uh,</span><span tid="50045" class="highlight highlight-a">junior</span><span tid="50046" class="highlight highlight-a">executive</span><span tid="50047" class="highlight highlight-a">assistant,</span><span>''Devil</span><span>Wears</span><span>Prada.''"</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 40, 103.537, 105.539, 'I''m just like, "Emily Blunt."', '我当时就说，“艾米莉·布朗特。”', '/aɪm dʒʌst laɪk | ˈɛməli ˈblʌnt/', '<span>I''m</span><span>just</span><span>like,</span><span tid="50048" class="highlight highlight-a">"Emily</span><span tid="50049" class="highlight highlight-a">Blunt."</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 41, 105.539, 108.041, 'And they were like, "No."', '他们就说，“不是。”', '/ænd ðeɪ wɜːr laɪk | noʊ/', '<span>And</span><span>they</span><span>were</span><span>like,</span><span>"No."</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 42, 108.041, 109.71, 'And it wasn''t her. It was me. So...', '结果那不是她，是我。所以……', '/ænd ɪt ˈwɑːzənt hɜːr | ɪt wʌz miː | soʊ/', '<span>And</span><span>it</span><span>wasn''t</span><span>her.</span><span>It</span><span>was</span><span>me.</span><span>So...</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 43, 111.778, 113.28, 'I was gonna say, "Wait..."', '我本来想说，“等等……”', '/aɪ wʌz ˈɡʌnə seɪ | weɪt/', '<span>I</span><span>was</span><span>gonna</span><span>say,</span><span>"Wait..."</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 44, 113.28, 116.283, '-But I was genuinely confused. I''m like, "Wait, but it is her."', '但我真的糊涂了。我就想，“等等，但那就是她啊。”', '/bʌt aɪ wʌz ˈdʒɛnjuɪnli kənˈfjuːzd | aɪm laɪk | weɪt | bʌt ɪt ɪz hɜːr/', '<span>-But</span><span>I</span><span>was</span><span tid="50050" class="highlight highlight-a">genuinely</span><span tid="50051" class="highlight highlight-a">confused.</span><span>I''m</span><span>like,</span><span>"Wait,</span><span>but</span><span>it</span><span>is</span><span>her."</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 45, 116.283, 117.584, 'It is. -"That was me, but I''m the..."', '就是她。 -“那是我，但我是那个……”', '/ɪt ɪz | ðæt wʌz miː | bʌt aɪm ðə/', '<span>It</span><span>is.</span><span>-"That</span><span>was</span><span>me,</span><span>but</span><span>I''m</span><span>the..."</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 46, 117.584, 121.154, 'That''s wild. See, when it comes to you -- -Yeah, so...', '那太疯狂了。你看，说到你—— -是啊，所以……', '/ðæts waɪld | siː | wɛn ɪt kʌmz tuː juː | jɛs | soʊ/', '<span>That''s</span><span tid="50052" class="highlight highlight-a">wild.</span><span>See,</span><span>when</span><span>it</span><span>comes</span><span>to</span><span>you</span><span>--</span><span>-Yeah,</span><span>so...</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 47, 121.154, 125.359, '-Do you ever -- Do you kind of do a project and then you kind of block it out of your mind or no?', '你有没有——你有没有做过一个项目，然后把它从脑子里清空，还是不会？', '/duː juː ˈɛvər | duː juː kaɪnd əv duː ə ˈprɑːdʒɛkt ænd ðɛn juː kaɪnd əv blɑːk ɪt aʊt əv jɔːr maɪnd ɔːr noʊ/', '<span>-Do</span><span>you</span><span>ever</span><span>--</span><span>Do</span><span>you</span><span>kind</span><span>of</span><span>do</span><span>a</span><span tid="50053" class="highlight highlight-a">project</span><span>and</span><span>then</span><span>you</span><span>kind</span><span>of</span><span tid="50054" class="highlight highlight-d">block</span><span>it</span><span>out</span><span>of</span><span>your</span><span>mind</span><span>or</span><span>no?</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 48, 125.359, 127.261, 'You just -- It just so happens you...', '你只是——碰巧你...', '/juː dʒʌst ɪt dʒʌst soʊ ˈhæpənz juː/', '<span>You</span><span>just</span><span>--</span><span>It</span><span pid="503" class="highlight highlight-i">just so happens</span><span>you</span><span>...</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 49, 127.261, 129.963, '-I don''t know. I''m not huge on looking back.', '我不知道。我不太喜欢回顾过去。', '/aɪ doʊnt noʊm aɪm nɑːt hjuːdʒ ɑːn ˈlʊkɪŋ bæk/', '<span>-I</span><span pid="504" class="highlight highlight-d">don''t know</span><span>.</span><span>I''m</span><span pid="505" class="highlight highlight-i">not huge on</span><span pid="506" class="highlight highlight-d">looking back</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 50, 129.963, 134.935, 'It is kind of funny when -- Like, because, you know, I was in this movie when I was 17 years old called "The Princess Diaries."', '这有点好笑，因为，你知道，我17岁时拍了一部电影叫《公主日记》。', '/ɪt ɪz kaɪnd əv ˈfʌni wɛn laɪk bɪˈkɔz juː noʊ aɪ wʌz ɪn ðɪs ˈmuvi wɛn aɪ wʌz ˈsɛvəntin jɪrz oʊld kɔld ðə ˈprɪnsɪs ˈdaɪəriz/', '<span>It</span><span>is</span><span pid="507" class="highlight highlight-c">kind of</span><span tid="50055" class="highlight highlight-a">funny</span><span>when</span><span>--</span><span>Like</span><span>,</span><span>because</span><span>,</span><span pid="508" class="highlight highlight-i">you know</span><span>,</span><span>I</span><span>was</span><span>in</span><span>this</span><span tid="50056" class="highlight highlight-a">movie</span><span>when</span><span>I</span><span>was</span><span>17</span><span>years old</span><span>called</span><span>"The Princess Diaries."</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 51, 134.935, 135.936, '-Yeah. [ Cheers and applause ]', '是的。[欢呼和掌声]', '/jɛs tʃɪrz ænd əˈplɔz/', '<span>-Yeah.</span><span>[</span><span tid="50057" class="highlight highlight-a">Cheers</span><span>and</span><span tid="50058" class="highlight highlight-a">applause</span><span>]</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 52, 137.571, 140.407, '-Have you seen it? -I watch you all the time.', '你看过吗？我一直在看你。', '/hæv juː sɪn ɪt aɪ wɑːtʃ juː ɔːl ðə taɪm/', '<span>-Have</span><span>you</span><span>seen</span><span>it</span><span>?</span><span>-I</span><span>watch</span><span>you</span><span pid="509" class="highlight highlight-i">all the time</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 53, 140.407, 141.909, 'To this day, I watch you all the time.', '直到今天，我一直在看你。', '/tuː ðɪs deɪ aɪ wɑːtʃ juː ɔːl ðə taɪm/', '<span pid="510" class="highlight highlight-i">To this day</span><span>,</span><span>I</span><span>watch</span><span>you</span><span pid="511" class="highlight highlight-i">all the time</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 54, 141.909, 142.943, '-Really? -My family loves you.', '真的吗？我的家人喜欢你。', '/ˈrɪli maɪ ˈfæməli lʌvz juː/', '<span>-Really</span><span>?</span><span>-My</span><span>family</span><span>loves</span><span>you</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 55, 142.943, 144.611, '-It must be your girls. -We love you.', '一定是你的女儿们。我们爱你。', '/ɪt mʌst bi jɔːr gɜːrlz wiː lʌv juː/', '<span>-It</span><span pid="512" class="highlight highlight-d">must be</span><span>your</span><span>girls</span><span>.</span><span>-We</span><span>love</span><span>you</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 56, 144.611, 146.446, 'Yeah, they love you so much.', '是啊，他们非常爱你。', '/jɛː, ðeɪ lʌv juː soʊ mʌtʃ/', '<span>Yeah</span><span>,</span><span>they</span><span tid="50059" class="highlight highlight-a">love</span><span>you</span><span>so</span><span>much</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 57, 146.446, 148.282, '-I love that it''s become kind of one of those family touchstones.', '我喜欢它成了那种家庭试金石之一。', '/aɪ lʌv ðæt ɪts bɪˈkʌm kaɪnd əv wʌn əv ðoʊz ˈfæməli ˈtoʊtʃstoʊnz/', '<span>-</span><span>I</span><span tid="50060" class="highlight highlight-a">love</span><span>that</span><span>it''s</span><span tid="50061" class="highlight highlight-a">become</span><span pid="513" class="highlight highlight-c">kind of</span><span>one</span><span>of</span><span>those</span><span>family</span><span tid="50062" class="highlight highlight-a">touchstones</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 58, 148.282, 153.42, 'So, anyway, people quote it to me all the time, and I don''t know what they''re talking about.', '所以，反正，人们总是对我引用它，而我不知道他们在说什么。', '/soʊ, ˈɛniweɪ, ˈpipəl kwoʊt ɪt tuː miː ɔːl ðə taɪm, ænd aɪ doʊnt noʊ wʌt ðeɪr ˈtɔːkɪŋ əˈbaʊt/', '<span>So</span><span>,</span><span>anyway</span><span>,</span><span>people</span><span tid="50063" class="highlight highlight-a">quote</span><span>it</span><span>to</span><span>me</span><span pid="514" class="highlight highlight-i">all the time</span><span>,</span><span>and</span><span>I</span><span pid="515" class="highlight highlight-c">don''t know</span><span>what</span><span>they''re</span><span pid="516" class="highlight highlight-d">talking about</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 59, 153.42, 154.688, 'I haven''t seen it in a minute.', '我有一阵子没看过了。', '/aɪ ˈhævənt siːn ɪt ɪn ə ˈmɪnɪt/', '<span>I</span><span pid="517" class="highlight highlight-d">haven''t seen</span><span>it</span><span pid="518" class="highlight highlight-i">in a minute</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 60, 154.688, 159.426, '-But "Devil Wears Prada" -- I recently saw a photo of you and Anna Wintour.', '但是《穿普拉达的女王》——我最近看到一张你和安娜·温图尔的照片。', '/bʌt ˈdɛvəl wɛrz ˈprɑːdə -- aɪ ˈriːsəntli sɔː ə ˈfoʊtoʊ əv juː ænd ˈænə ˈwɪntʊr/', '<span>-</span><span>But</span><span>"</span><span>Devil Wears Prada</span><span>"</span><span>--</span><span>I</span><span>recently</span><span>saw</span><span>a</span><span>photo</span><span>of</span><span>you</span><span>and</span><span>Anna Wintour</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 61, 159.426, 164.398, 'You made your kind of Broadway debut together in "Gutenberg! The Musical!"', '你们一起在《古腾堡！音乐剧！》中完成了百老汇首秀。', '/juː gɑɪz meɪd jʊr kaɪnd əv ˈbrɔːdweɪ dɪˈbjuː təˈɡɛðər ɪn ˈɡuːtənbɜːrɡ! ðə ˈmjuːzɪkəl/', '<span>You</span><span>made</span><span>your</span><span>kind</span><span>of</span><span>Broadway</span><span>debut</span><span>together</span><span>in</span><span>"Gutenberg!</span><span>The</span><span>Musical!"</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 62, 164.398, 165.599, 'You guys stood up. -There she is.', '你们站了起来。 -她在那儿。', '/juː gɑɪz stʊd ʌp. -ðɛr ʃiː ɪz/', '<span>You</span><span>guys</span><span pid="519" class="highlight highlight-d">stood up</span><span>.</span><span>-</span><span>There</span><span>she</span><span>is</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 63, 165.599, 168.468, '-Did the crowd go nuts?', '观众们疯狂了吗？', '/dɪd ðə kraʊd goʊ nʌts/', '<span>-</span><span>Did</span><span>the</span><span>crowd</span><span pid="520" class="highlight highlight-i">go nuts</span><span>?</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 64, 168.468, 173.173, '-So, they -- So, by the way, I have to say, that''s Josh Gad and that''s Andrew Rannells.', '所以，他们——顺便说一句，我得说，那是乔什·盖德和安德鲁·兰内斯。', '/soʊ ðeɪ soʊ baɪ ðə weɪ aɪ hæv tə seɪ ðæts dʒɑːʃ gæd ænd ðæts ˈændruː ˈrænəlz/', '<span>-So,</span><span>they</span><span>--</span><span>So,</span><span pid="521" class="highlight highlight-i">by the way,</span><span>I</span><span pid="522" class="highlight highlight-c">have to say,</span><span>that''s</span><span>Josh Gad</span><span>and</span><span>that''s</span><span>Andrew Rannells.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 65, 173.173, 174.541, 'They''re both dear friends.', '他们都是我亲爱的朋友。', '/ðeər boʊθ dɪr frɛndz/', '<span>They''re</span><span>both</span><span pid="523" class="highlight highlight-c">dear friends.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 66, 174.541, 176.844, 'And they''re so -- They were so brilliant in the show.', '而且他们非常——他们在剧中表现得非常出色。', '/ænd ðeər soʊ ðeɪ wɜːr soʊ ˈbrɪljənt ɪn ðə ʃoʊ/', '<span>And</span><span>they''re</span><span>so</span><span>--</span><span>They</span><span>were</span><span>so</span><span tid="50064" class="highlight highlight-a">brilliant</span><span>in</span><span>the show.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 67, 176.844, 178.912, 'It was really next level.', '那真的是更上一层楼。', '/ɪt wʌz ˈrɪli nɛkst ˈlɛvəl/', '<span>It</span><span>was</span><span>really</span><span pid="524" class="highlight highlight-i">next level.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 68, 178.912, 182.149, 'And at the end of the show, they invite two people up onstage.', '在演出结束时，他们邀请两个人上台。', '/ænd æt ði ɛnd əv ðə ʃoʊ ðeɪ ɪnˈvaɪt tuː ˈpiːpəl ʌp ɑnsteɪdʒ/', '<span>And</span><span pid="525" class="highlight highlight-c">at the end of</span><span>the show,</span><span>they</span><span>invite</span><span>two people</span><span>up</span><span>onstage.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 69, 182.149, 186.153, 'And, so, they said my name first, and the audience had a very nice reaction.', '所以，他们先叫了我的名字，观众反应非常好。', '/ænd soʊ ðeɪ sɛd maɪ neɪm fɜːrst ænd ði ˈɔdiəns hæd ə ˈvɛri naɪs riˈækʃən/', '<span>And,</span><span>so,</span><span>they</span><span>said</span><span>my name</span><span>first,</span><span>and</span><span>the audience</span><span>had</span><span pid="526" class="highlight highlight-c">a very nice reaction.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 70, 186.153, 188.989, 'And then they said Anna''s name, and it was like rock star.', '然后他们叫了安娜的名字，那就像摇滚明星一样。', '/ænd ðɛn ðeɪ sɛd ˈænəz neɪm ænd ɪt wʌz laɪk rɑːk stɑːr/', '<span>And</span><span>then</span><span>they</span><span>said</span><span>Anna''s name,</span><span>and</span><span>it</span><span>was</span><span>like</span><span pid="527" class="highlight highlight-i">rock star.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 71, 188.989, 190.858, '-Really? -Yeah, rock star.', '-真的吗？-是的，摇滚明星。', '/ˈrɪli jɛs rɑːk stɑːr/', '<span>-Really?</span><span>-Yeah,</span><span pid="528" class="highlight highlight-i">rock star.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 72, 190.858, 196.63, '-Because you don''t really see Anna do many things that are outside of her -- -Wear a trucker hat. -Yes, exactly.', '因为你真的没看到安娜做很多超出她——戴一顶卡车司机帽。是的，没错。', '/bɪˈkɔːz juː doʊnt ˈrɪəli siː ˈænə duː ˈmɛni ˈθɪŋz ðæt ɑːr ˌaʊtˈsaɪd əv hɜːr - wɛr ə ˈtrʌkər hæt - jɛs ɪɡˈzæktli/', '<span>-</span><span>Because</span><span>you</span><span>don''t</span><span>really</span><span tid="50065" class="highlight highlight-a">see</span><span>Anna</span><span>do</span><span>many</span><span>things</span><span>that</span><span>are</span><span tid="50066" class="highlight highlight-c">outside</span><span>of</span><span>her</span><span>--</span><span>-</span><span>Wear</span><span>a</span><span tid="50067" class="highlight highlight-a">trucker</span><span>hat.</span><span>-</span><span>Yes,</span><span>exactly.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 73, 196.63, 199.633, 'You''d never see Anna Wintour, from Vogue, wear a trucker hat.', '你永远不会看到《Vogue》的安娜·温图尔戴一顶卡车司机帽。', '/juːd ˈnɛvər siː ˈænə ˈwɪntər frəm voʊɡ wɛr ə ˈtrʌkər hæt/', '<span>You''d</span><span>never</span><span tid="50068" class="highlight highlight-a">see</span><span>Anna</span><span>Wintour,</span><span>from</span><span>Vogue,</span><span>wear</span><span>a</span><span tid="50069" class="highlight highlight-a">trucker</span><span>hat.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 74, 199.633, 201.802, 'That''s correct, yeah. But everyone just went nuts.', '没错，是的。但每个人都疯狂了。', '/ðæts kəˈrɛkt jɛs bʌt ˈɛvriˌwʌn dʒʌst wɛnt nʌts/', '<span>That''s</span><span>correct,</span><span>yeah.</span><span>But</span><span>everyone</span><span>just</span><span tid="50070" class="highlight highlight-d">went</span><span>nuts.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 75, 201.802, 203.904, 'She''s also a New York icon. -Oh, yeah.', '她也是纽约的标志性人物。哦，是的。', '/ʃiːz ˈɔːlsoʊ ə njuː jɔːrk ˈaɪkɑːn oʊ jɛs/', '<span>She''s</span><span>also</span><span>a</span><span>New</span><span>York</span><span tid="50071" class="highlight highlight-a">icon.</span><span>-</span><span>Oh,</span><span>yeah.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 76, 203.904, 207.741, '-So I think if she shows up at a pizzeria -- -Yeah, she''s a New York icon. She''s a worldwide icon.', '所以我觉得如果她出现在披萨店——是的，她是纽约的偶像。她是全球偶像。', '/soʊ aɪ θɪŋk ɪf ʃiː ʃoʊz ʌp æt ə piːtˈsɛriə -- jɛs, ʃiːz ə nuː jɔːrk ˈaɪkɑːn. ʃiːz ə wɜːrldwaɪd ˈaɪkɑːn./', '<span>-</span><span>So</span><span>I</span><span>think</span><span>if</span><span>she</span><span tid="50072" class="highlight highlight-d">shows</span><span>up</span><span>at</span><span>a</span><span tid="50073" class="highlight highlight-a">pizzeria</span><span>--</span><span>-</span><span>Yeah,</span><span>she''s</span><span>a</span><span>New</span><span>York</span><span tid="50074" class="highlight highlight-a">icon.</span><span>She''s</span><span>a</span><span tid="50075" class="highlight highlight-a">worldwide</span><span>icon.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 77, 207.741, 209.376, '-She''s a worldwide -- She''s everything.', '她是全球性的——她是一切。', '/ʃiːz ə wɜːrldwaɪd -- ʃiːz ˈɛvriθɪŋ./', '<span>-</span><span>She''s</span><span>a</span><span tid="50076" class="highlight highlight-a">worldwide</span><span>--</span><span>She''s</span><span>everything.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 78, 209.376, 211.211, 'Is she fun to share the stage with?', '和她同台有趣吗？', '/ɪz ʃiː fʌn tuː ʃɛr ðə steɪdʒ wɪð?/', '<span>Is</span><span>she</span><span>fun</span><span>to</span><span tid="50077" class="highlight highlight-d">share</span><span>the</span><span>stage</span><span>with?</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 79, 211.211, 212.779, '-Yeah. Yeah, really, really fun.', '是的。是的，真的，真的很有趣。', '/jɛs. jɛs, ˈrɪli, ˈrɪli fʌn./', '<span>-</span><span>Yeah.</span><span>Yeah,</span><span>really,</span><span>really</span><span>fun.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 80, 212.779, 217.584, 'And just -- She''s been incredibly sweet to me, and I''m very -- I''m just very grateful for our relationship.', '而且只是——她对我一直非常好，我非常——我只是非常感激我们的关系。', '/ænd dʒʌst ʃiːz bɪn ɪnˈkrɛdəbli swiːt tuː miː ænd aɪm ˈvɛri aɪm dʒʌst ˈvɛri ˈɡreɪtfəl fɔːr ˈaʊər rɪˈleɪʃənʃɪp/', '<span>And</span><span>just</span><span>--</span><span>She''s</span><span>been</span><span tid="50078" class="highlight highlight-a">incredibly</span><span tid="50079" class="highlight highlight-a">sweet</span><span>to</span><span>me</span><span>,</span><span>and</span><span>I''m</span><span>very</span><span>--</span><span>I''m</span><span>just</span><span>very</span><span tid="50080" class="highlight highlight-a">grateful</span><span>for</span><span>our</span><span tid="50081" class="highlight highlight-a">relationship</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 81, 217.584, 219.253, '-She''s so cool. -She''s so cool.', '-她太酷了。-她太酷了。', '/ʃiːz soʊ kuːl ʃiːz soʊ kuːl/', '<span>-She''s</span><span>so</span><span tid="50082" class="highlight highlight-a">cool</span><span>.</span><span>-She''s</span><span>so</span><span tid="50083" class="highlight highlight-a">cool</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 82, 219.253, 220.654, '-She''s so cool. -So cool.', '-她太酷了。-太酷了。', '/ʃiːz soʊ kuːl soʊ kuːl/', '<span>-She''s</span><span>so</span><span tid="50084" class="highlight highlight-a">cool</span><span>.</span><span>-So</span><span tid="50085" class="highlight highlight-a">cool</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 83, 220.654, 224.091, '-Do you get nervous around -- I get a little nervous -- -I absolutely do. -You do?', '-你会在她身边紧张吗——我有点紧张—— -我绝对会。-你会吗？', '/duː juː gɛt ˈnɜːrvəs əˈraʊnd aɪ gɛt ə ˈlɪtəl ˈnɜːrvəs aɪ ˈæbsəluːtli duː juː duː/', '<span>-Do</span><span>you</span><span>get</span><span tid="50086" class="highlight highlight-a">nervous</span><span>around</span><span>--</span><span>I</span><span>get</span><span>a</span><span>little</span><span tid="50087" class="highlight highlight-a">nervous</span><span>--</span><span>-I</span><span tid="50088" class="highlight highlight-a">absolutely</span><span>do</span><span>.</span><span>-You</span><span>do</span><span>?</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 84, 224.091, 229.53, 'Now, I have less to lose, because I''m never going to be on the cover of Vogue, so I have nothing to worry about.', '现在，我没什么可失去的，因为我永远不会登上《Vogue》封面，所以我没什么好担心的。', '/naʊ aɪ hæv lɛs tuː luːz bɪˈkɔːz aɪm ˈnɛvər ˈɡoʊɪŋ tuː biː ɑːn ðə ˈkʌvər ʌv voʊɡ soʊ aɪ hæv ˈnʌθɪŋ tuː wɜːri əˈbaʊt/', '<span>Now</span><span>,</span><span>I</span><span>have</span><span>less</span><span>to</span><span tid="50089" class="highlight highlight-a">lose</span><span>,</span><span>because</span><span>I''m</span><span>never</span><span>going</span><span>to</span><span>be</span><span>on</span><span>the</span><span tid="50090" class="highlight highlight-a">cover</span><span>of</span><span tid="50091" class="highlight highlight-a">Vogue</span><span>,</span><span>so</span><span>I</span><span>have</span><span>nothing</span><span>to</span><span tid="50092" class="highlight highlight-a">worry</span><span>about</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 85, 229.53, 233.7, 'But she likes me, and we''ve been friends for a long time, so I kind of -- I''m comfy around her, so I can --', '但她喜欢我，我们做朋友很久了，所以我有点——我在她身边很自在，所以我可以——', '/bʌt ʃiː laɪks miː ænd wiːv biːn frɛndz fɔːr ə lɔːŋ taɪm soʊ aɪ kaɪnd ʌv aɪm ˈkʌmfi əˈraʊnd hɜːr soʊ aɪ kæn/', '<span>But</span><span>she</span><span>likes</span><span>me</span><span>,</span><span>and</span><span>we''ve</span><span>been</span><span>friends</span><span>for</span><span>a</span><span>long</span><span>time</span><span>,</span><span>so</span><span>I</span><span>kind</span><span>of</span><span>--</span><span>I''m</span><span tid="50093" class="highlight highlight-a">comfy</span><span>around</span><span>her</span><span>,</span><span>so</span><span>I</span><span>can</span><span>--</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 86, 233.7, 235.269, '-I don''t mean to -- I try to keep it comfy.', '-我不是故意——我尽量保持舒适。', '/aɪ doʊnt miːn tuː aɪ traɪ tuː kiːp ɪt ˈkʌmfi/', '<span>-I</span><span>don''t</span><span>mean</span><span>to</span><span>--</span><span>I</span><span>try</span><span>to</span><span>keep</span><span>it</span><span tid="50094" class="highlight highlight-a">comfy</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 87, 235.269, 236.637, 'I try to keep it cozy.', '我尽量让它温馨。', '/aɪ traɪ tuː kiːp ɪt ˈkoʊzi/', '<span>I</span><span>try</span><span>to</span><span>keep</span><span>it</span><span tid="50095" class="highlight highlight-a">cozy</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 88, 236.637, 239.74, 'But inside, my heart is -- I just respect her so much.', '但内心深处，我的心是——我非常尊重她。', '/bʌt ɪnˈsaɪd maɪ hɑːrt ɪz aɪ dʒʌst rɪˈspɛkt hɜːr soʊ mʌtʃ/', '<span>But</span><span>inside</span><span>,</span><span>my</span><span>heart</span><span>is</span><span>--</span><span>I</span><span>just</span><span tid="50096" class="highlight highlight-a">respect</span><span>her</span><span>so</span><span>much</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 89, 239.74, 240.874, '-Yeah.', '是的。', '/jɛə/', '<span>-Yeah</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 90, 240.874, 242.609, '-But I feel very comfortable around you.', '但和你在一起我感觉很自在。', '/bʌt aɪ fiːl ˈvɛri kʌmfərtəbəl əˈraʊnd juː/', '<span>-But</span><span>I</span><span>feel</span><span>very</span><span tid="50097" class="highlight highlight-a">comfortable</span><span>around</span><span>you</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 91, 242.609, 244.845, '-Yeah, good. You should be. You should be.', '是的，很好。你应该这样。你应该这样。', '/jɛə ɡʊd juː ʃʊd biː juː ʃʊd biː/', '<span>-Yeah</span><span>,</span><span>good</span><span>.</span><span>You</span><span>should</span><span>be</span><span>.</span><span>You</span><span>should</span><span>be</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 92, 244.845, 247.08, 'I''m your bud. No, please.', '我是你的朋友。不，请。', '/aɪm jɔːr bʌd noʊ pliːz/', '<span>I''m</span><span>your</span><span tid="50098" class="highlight highlight-a">bud</span><span>.</span><span>No</span><span>,</span><span>please</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 93, 247.08, 250.617, 'I totally -- I got the respect and also the dig at the same time.', '我完全——我同时得到了尊重和调侃。', '/aɪ ˈtoʊtəli aɪ ɡɑːt ðə rɪˈspɛkt ænd ˈɔːlsoʊ ðə dɪɡ æt ðə seɪm taɪm/', '<span>I</span><span>totally</span><span>--</span><span>I</span><span>got</span><span>the</span><span>respect</span><span>and</span><span>also</span><span>the</span><span tid="50099" class="highlight highlight-a">dig</span><span>at</span><span>the</span><span>same</span><span>time</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 94, 250.617, 252.953, 'So it was perfect. -That''s how well I know you.', '所以这很完美。 -我多了解你啊。', '/soʊ ɪt wʌz ˈpɜːrfɪkt ðæts haʊ wɛl aɪ noʊ juː/', '<span>So</span><span>it</span><span>was</span><span>perfect</span><span>.</span><span>-That''s</span><span>how</span><span>well</span><span>I</span><span>know</span><span>you</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 95, 252.953, 254.721, 'That''s how cozy I am. -Yeah, exactly.', '我多自在啊。 -是的，没错。', '/ðæts haʊ ˈkoʊzi aɪ æm jɛə ɪɡˈzæktli/', '<span>That''s</span><span>how</span><span tid="50100" class="highlight highlight-a">cozy</span><span>I</span><span>am</span><span>.</span><span>-Yeah</span><span>,</span><span>exactly</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 96, 254.721, 258.592, 'You know, I saw you, by the way -- I was going to say on Broadway, but it wasn''t.', '你知道吗，我看到了你，顺便说一句——我本来想说在百老汇，但不是。', '/juː noʊ aɪ sɔː juː baɪ ðə weɪ aɪ wʌz ˈɡoʊɪŋ tə seɪ ɑːn ˈbrɔːdweɪ bʌt ɪt ˈwʌzənt/', '<span>You</span><span>know</span><span>,</span><span>I</span><span tid="50101" class="highlight highlight-a">saw</span><span>you</span><span>,</span><span pid="529" class="highlight highlight-i">by the way</span><span>--</span><span>I</span><span pid="530" class="highlight highlight-l">was going to say</span><span pid="531" class="highlight highlight-c">on Broadway</span><span>,</span><span>but</span><span>it</span><span>wasn''t</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 97, 258.592, 260.16, 'It was Shakespeare in the Park.', '是在公园里的莎士比亚。', '/ɪt wʌz ˈʃeɪkspɪr ɪn ðə pɑːrk/', '<span>It</span><span>was</span><span pid="532" class="highlight highlight-c">Shakespeare in the Park</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 98, 260.16, 261.862, '-You were there? -Yeah, I came to see you.', '-你在那里吗？-是的，我去看你了。', '/juː wɜːr ðer jɛs aɪ keɪm tə siː juː/', '<span>-You</span><span>were</span><span>there</span><span>?</span><span>-Yeah</span><span>,</span><span>I</span><span pid="533" class="highlight highlight-d">came to see</span><span>you</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 99, 261.862, 263.53, 'Absolutely. I''m a big fan. Yeah.', '当然。我是你的忠实粉丝。是的。', '/ˈæbsəluːtli aɪm ə bɪɡ fæn jɛs/', '<span>Absolutely</span><span>.</span><span>I''m</span><span>a</span><span pid="534" class="highlight highlight-c">big fan</span><span>.</span><span>Yeah</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 100, 263.53, 264.531, 'You did that.', '你做了那件事。', '/juː dɪd ðæt/', '<span>You</span><span>did</span><span>that.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 101, 264.531, 267.301, '-I feel really bad about the dig now.', '我现在对那个挖苦感到非常抱歉。', '/aɪ fiːl ˈrɪli bæd əˈbaʊt ðə dɪɡ naʊ/', '<span>-I</span><span tid="50102" class="highlight highlight-a">feel</span><span>really</span><span>bad</span><span>about</span><span>the</span><span tid="50103" class="highlight highlight-a">dig</span><span>now.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 102, 267.301, 269.236, '-You better keep digging me. Are you kidding me?', '你最好继续挖苦我。你在跟我开玩笑吗？', '/juː ˈbɛtər ˈkip ˈdɪɡɪŋ miː. ɑːr juː ˈkɪdɪŋ miː/', '<span>-You</span><span>better</span><span tid="50104" class="highlight highlight-d">keep</span><span>digging</span><span>me.</span><span>Are</span><span>you</span><span tid="50105" class="highlight highlight-a">kidding</span><span>me?</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 103, 269.236, 272.372, 'I have -- Please, if you don''t laugh yourself, then come on.', '我有——拜托，如果你自己不笑，那就来吧。', '/aɪ hæv -- pliːz, ɪf juː dɑːnt læf jərˈsɛlf, ðɛn kʌm ɑːn/', '<span>I</span><span>have</span><span>--</span><span>Please,</span><span>if</span><span>you</span><span>don''t</span><span tid="50106" class="highlight highlight-a">laugh</span><span>yourself,</span><span>then</span><span>come</span><span>on.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 104, 272.372, 274.608, 'I saw you, and it was at the...', '我看见你了，那是在……', '/aɪ sɔː juː ænd ɪt wʌz æt ðə/', '<span>I</span><span tid="50107" class="highlight highlight-a">saw</span><span>you</span><span>,</span><span>and</span><span>it</span><span>was</span><span>at</span><span>the</span><span>...</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 105, 274.608, 275.943, '-"Twelfth Night" at the Delacorte Theater.', '——在德拉科特剧院演出的《第十二夜》。', '/ˈtwɛlfθ naɪt æt ðə dəˈlækɔːrt ˈθɪətər/', '<span>-"</span><span pid="535" class="highlight highlight-a">Twelfth Night</span><span>"</span><span>at</span><span>the</span><span pid="536" class="highlight highlight-a">Delacorte Theater</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 106, 275.943, 277.044, '-...Delacorte Theater. -Yeah.', '……德拉科特剧院。——是的。', '/dəˈlækɔːrt ˈθɪətər jɛs/', '<span>-...</span><span pid="537" class="highlight highlight-a">Delacorte Theater</span><span>.</span><span>-Yeah</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 107, 277.044, 278.278, '-You were amazing. Do you get nervous?', '——你太棒了。你会紧张吗？', '/juː wɜːr əˈmeɪzɪŋ duː juː gɛt ˈnɜːrvəs/', '<span>-You</span><span>were</span><span tid="50108" class="highlight highlight-a">amazing</span><span>.</span><span>Do</span><span>you</span><span>get</span><span tid="50109" class="highlight highlight-a">nervous</span><span>?</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 108, 278.278, 279.78, 'Does anything go wrong?', '有什么出错的地方吗？', '/dʌz ˈɛniθɪŋ goʊ rɔːŋ/', '<span>Does</span><span>anything</span><span>go</span><span tid="50110" class="highlight highlight-a">wrong</span><span>?</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 109, 279.78, 281.315, 'Nothing went wrong when I saw you.', '我见到你的时候，什么都没出错。', '/ˈnʌθɪŋ wɛnt rɔːŋ wɛn aɪ sɔː juː/', '<span>Nothing</span><span>went</span><span tid="50111" class="highlight highlight-a">wrong</span><span>when</span><span>I</span><span tid="50112" class="highlight highlight-a">saw</span><span>you</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 110, 281.315, 282.716, '-Nothing went wrong? Thank goodness.', '——什么都没出错？谢天谢地。', '/ˈnʌθɪŋ wɛnt rɔːŋ θæŋk ˈɡʊdnəs/', '<span>-Nothing</span><span>went</span><span tid="50113" class="highlight highlight-a">wrong</span><span>?</span><span>Thank</span><span tid="50114" class="highlight highlight-i">goodness</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 111, 282.716, 283.951, '-No, you were perfect.', '——不，你完美无缺。', '/noʊ juː wɜːr ˈpɜːrfɪkt/', '<span>-No</span><span>,</span><span>you</span><span>were</span><span tid="50115" class="highlight highlight-a">perfect</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 112, 283.951, 287.654, '-Well, because -- So, the Delacorte Theater is an outdoor theater in Central Park.', '嗯，因为——所以，德拉科特剧院是中央公园的一个露天剧院。', '/wɛl bɪˈkʌz soʊ ðə dəˈlɑːkɔːrt ˈθɪətər ɪz ən ˈaʊtdɔːr ˈθɪətər ɪn ˈsɛntrəl pɑːrk/', '<span>-Well,</span><span>because</span><span>--</span><span>So,</span><span>the</span><span pid="538" class="highlight highlight-a">Delacorte Theater</span><span>is</span><span>an</span><span tid="50116" class="highlight highlight-a">outdoor</span><span>theater</span><span>in</span><span tid="50117" class="highlight highlight-a">Central Park.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 113, 287.654, 289.489, 'And, so -- -And you''re doing Shakespeare.', '而且，所以——而且你在演莎士比亚。', '/ænd soʊ ænd jʊr ˈduːɪŋ ˈʃeɪkspɪr/', '<span>And,</span><span>so</span><span>--</span><span>-And</span><span>you''re</span><span>doing</span><span tid="50118" class="highlight highlight-a">Shakespeare.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 114, 289.489, 290.791, '-Doing Shakespeare.', '演莎士比亚。', '/ˈduːɪŋ ˈʃeɪkspɪr/', '<span>-Doing</span><span tid="50119" class="highlight highlight-a">Shakespeare.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 115, 290.791, 293.093, 'And it rained almost every night.', '而且几乎每晚都下雨。', '/ænd ɪt reɪnd ˈɔːlmoʊst ˈɛvri naɪt/', '<span>And</span><span>it</span><span tid="50120" class="highlight highlight-a">rained</span><span>almost</span><span>every</span><span>night.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 116, 293.093, 300.067, 'And, so, but it''s kind of amazing, because every night, the last line of the show, which we actually sang, was for the rain, it raineth every day.', '而且，所以，但这有点神奇，因为每晚，演出的最后一句台词，我们实际上唱了出来，是关于雨，天天下雨。', '/ænd soʊ bət ɪts kaɪnd əv əˈmeɪzɪŋ bɪˈkʌz ˈɛvri naɪt ðə læst laɪn əv ðə ʃoʊ wɪtʃ wi ˈækʃuəli sæŋ wəz fɔːr ðə reɪn ɪt ˈreɪnɪθ ˈɛvri deɪ/', '<span>And,</span><span>so,</span><span>but</span><span>it''s</span><span pid="539" class="highlight highlight-i">kind of</span><span tid="50121" class="highlight highlight-a">amazing,</span><span>because</span><span>every</span><span>night,</span><span>the</span><span>last</span><span>line</span><span>of</span><span>the</span><span>show,</span><span>which</span><span>we</span><span>actually</span><span>sang,</span><span>was</span><span>for</span><span>the</span><span>rain,</span><span>it</span><span tid="50122" class="highlight highlight-a">raineth</span><span>every</span><span>day.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 117, 300.067, 302.836, 'And so the audience, at that moment, always burst out laughing.', '所以观众在那一刻总是爆发出笑声。', '/ænd soʊ ði ˈɔːdiəns æt ðæt ˈmoʊmənt ˈɔːlweɪz bɜːrst aʊt ˈlæfɪŋ/', '<span>And</span><span>so</span><span>the</span><span tid="50123" class="highlight highlight-a">audience,</span><span>at</span><span>that</span><span>moment,</span><span>always</span><span pid="540" class="highlight highlight-d">burst out</span><span>laughing.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 118, 302.836, 304.238, 'And the whole show was so joyful.', '整场演出非常欢乐。', '/ænd ðə hoʊl ʃoʊ wəz soʊ ˈdʒɔɪfəl/', '<span>And</span><span>the</span><span>whole</span><span>show</span><span>was</span><span>so</span><span tid="50124" class="highlight highlight-a">joyful.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 119, 304.238, 305.739, 'I had such a wonderful time.', '我度过了一段非常美好的时光。', '/aɪ hæd sʌtʃ ə ˈwʌndərfəl taɪm/', '<span>I</span><span>had</span><span>such</span><span>a</span><span tid="50125" class="highlight highlight-a">wonderful</span><span>time.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 120, 305.739, 309.543, 'But one night, something -- I don''t know if it went wrong, but something happened.', '但有一天晚上，发生了一些事——我不知道是不是出了差错，但确实发生了。', '/bʌt wʌn naɪt ˈsʌmθɪŋ aɪ doʊnt nəʊ ɪf ɪt wɛnt rɔːŋ bʌt ˈsʌmθɪŋ ˈhæpənd/', '<span>But</span><span pid="541" class="highlight highlight-c">one night</span><span>,</span><span>something</span><span>--</span><span pid="542" class="highlight highlight-i">I don''t know</span><span>if</span><span>it</span><span pid="543" class="highlight highlight-d">went wrong</span><span>,</span><span>but</span><span>something</span><span tid="50126" class="highlight highlight-a">happened</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 121, 309.543, 311.211, 'And, so, there''s this scene.', '于是，就有了这一幕。', '/ænd soʊ ðɛrz ðɪs siːn/', '<span>And</span><span>,</span><span>so</span><span>,</span><span>there''s</span><span>this scene</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 122, 311.211, 313.747, 'My character, Viola -- she comes onto the stage.', '我的角色，维奥拉——她走上舞台。', '/maɪ ˈkɛrəktər vaɪˈoʊlə ʃi kʌmz ɒntə ðə steɪdʒ/', '<span>My character</span><span>,</span><span>Viola</span><span>--</span><span>she</span><span pid="544" class="highlight highlight-d">comes onto</span><span>the stage</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 123, 313.747, 318.252, 'And I knew that the line was funny, but I couldn''t figure out how to make it funny.', '我知道那句台词很好笑，但我想不出怎么把它演得有趣。', '/ænd aɪ nuː ðæt ðə laɪn wʌz ˈfʌni bʌt aɪ ˈkʊdənt ˈfɪɡər aʊt haʊ tə meɪk ɪt ˈfʌni/', '<span>And</span><span>I</span><span tid="50127" class="highlight highlight-a">knew</span><span>that</span><span>the line</span><span>was</span><span>funny</span><span>,</span><span>but</span><span>I</span><span pid="545" class="highlight highlight-d">couldn''t figure out</span><span>how</span><span pid="546" class="highlight highlight-l">to make it funny</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 124, 318.252, 321.655, 'So every night, I was just trying something, just anything I could think of.', '所以每天晚上，我都在尝试各种方法，只要我能想到的。', '/soʊ ˈɛvri naɪt aɪ wʌz ˈdʒʌst ˈtraɪɪŋ ˈsʌmθɪŋ ˈdʒʌst ˈɛniθɪŋ aɪ ˈkʊd θɪŋk əv/', '<span>So</span><span>every night</span><span>,</span><span>I</span><span>was</span><span>just</span><span>trying something</span><span>,</span><span>just</span><span>anything</span><span>I</span><span pid="547" class="highlight highlight-d">could think of</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 125, 321.655, 325.325, 'And I was, you know, go out there, audience wouldn''t laugh, and I was like, "Tomorrow."', '然后我上台，你知道，观众不笑，我就想，“明天吧。”', '/ænd aɪ wʌz ju noʊ goʊ aʊt ðɛr ˈɔdiəns ˈwʊdənt læf ænd aɪ wʌz laɪk təˈmɑroʊ/', '<span>And</span><span>I</span><span>was</span><span>,</span><span pid="548" class="highlight highlight-i">you know</span><span>,</span><span pid="549" class="highlight highlight-d">go out there</span><span>,</span><span>audience</span><span>wouldn''t laugh</span><span>,</span><span>and</span><span>I</span><span pid="550" class="highlight highlight-i">was like</span><span>,</span><span>"Tomorrow."</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 126, 325.325, 331.231, 'And then, one night, I went out there and I said the line, and just the house went down.', '然后，有一天晚上，我上台说了那句台词，全场都笑翻了。', '/ænd ðɛn wʌn naɪt aɪ wɛnt aʊt ðɛr ænd aɪ sɛd ðə laɪn ænd ˈdʒʌst ðə haʊs wɛnt daʊn/', '<span>And then</span><span>,</span><span>one night</span><span>,</span><span>I</span><span pid="551" class="highlight highlight-d">went out there</span><span>and</span><span>I</span><span>said</span><span>the line</span><span>,</span><span>and</span><span>just</span><span pid="552" class="highlight highlight-i">the house went down</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 127, 331.231, 332.666, '-You killed it. -Killed.', '-你演得太棒了。-太棒了。', '/ju kɪld ɪt kɪld/', '<span pid="553" class="highlight highlight-i">-You killed it</span><span>.</span><span tid="50128" class="highlight highlight-a">-Killed</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 128, 332.666, 336.703, 'And I was like, "Oh, I found it. This is such a good feeling."', '我当时就想，‘哦，我找到了。这种感觉真好。’', '/ænd aɪ wʌz laɪk oʊ aɪ faʊnd ɪt ðɪs ɪz sʌtʃ ə gʊd ˈfilɪŋ/', '<span>And</span><span>I</span><span pid="554" class="highlight highlight-i">was like</span><span>,</span><span>"</span><span>Oh</span><span>,</span><span>I</span><span tid="50129" class="highlight highlight-a">found</span><span>it</span><span>.</span><span>This</span><span>is</span><span pid="555" class="highlight highlight-c">such a</span><span>good</span><span tid="50130" class="highlight highlight-a">feeling</span><span>.</span><span>"</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 129, 336.703, 340.274, 'And I just like -- And so then, of course, I leaned into it, because you do.', '然后我就——当然，我就顺势而为了，因为你也会这样。', '/ænd aɪ dʒʌst laɪk ænd soʊ ðɛn əv kɔːrs aɪ liːnd ˈɪntuː ɪt bɪˈkɔːz juː duː/', '<span>And</span><span>I</span><span>just</span><span>like</span><span>--</span><span>And</span><span>so</span><span>then</span><span>,</span><span pid="556" class="highlight highlight-c">of course</span><span>,</span><span>I</span><span pid="557" class="highlight highlight-d">leaned into</span><span>it</span><span>,</span><span>because</span><span>you</span><span>do</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 130, 340.274, 343.544, 'And so I lean into it and I''m just -- The audience is losing their minds.', '于是我就顺势而为，观众们简直要疯了。', '/ænd soʊ aɪ liːn ˈɪntuː ɪt ænd aɪm dʒʌst ði ˈɔːdiəns ɪz ˈluːzɪŋ ðɛr maɪndz/', '<span>And</span><span>so</span><span>I</span><span pid="558" class="highlight highlight-d">lean into</span><span>it</span><span>and</span><span>I''m</span><span>just</span><span>--</span><span>The</span><span tid="50131" class="highlight highlight-a">audience</span><span>is</span><span pid="559" class="highlight highlight-i">losing their minds</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 131, 343.544, 345.746, 'I look under the wings, the cast is losing their minds.', '我往翅膀下面一看，演员们也都疯了。', '/aɪ lʊk ˈʌndər ðə wɪŋz ðə kæst ɪz ˈluːzɪŋ ðɛr maɪndz/', '<span>I</span><span pid="560" class="highlight highlight-d">look under</span><span>the</span><span tid="50132" class="highlight highlight-a">wings</span><span>,</span><span>the</span><span tid="50133" class="highlight highlight-a">cast</span><span>is</span><span pid="561" class="highlight highlight-i">losing their minds</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 132, 345.746, 348.015, 'I''m high-fiving myself in my head.', '我在心里跟自己击掌。', '/aɪm haɪ ˈfaɪvɪŋ maɪˈsɛlf ɪn maɪ hɛd/', '<span>I''m</span><span tid="50134" class="highlight highlight-a">high-fiving</span><span>myself</span><span>in</span><span>my</span><span>head</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 133, 348.015, 350.851, 'I''m just like, "I''ve arrived. This is happening."', '我就想，‘我成功了。这一切正在发生。’', '/aɪm dʒʌst laɪk aɪv əˈraɪvd ðɪs ɪz ˈhæpənɪŋ/', '<span>I''m</span><span pid="562" class="highlight highlight-i">just like</span><span>,</span><span>"</span><span pid="563" class="highlight highlight-i">I''ve arrived</span><span>.</span><span>This</span><span>is</span><span tid="50135" class="highlight highlight-a">happening</span><span>.</span><span>"</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 134, 350.851, 353.086, 'And I get offstage and I''m just like, "Well..."', '我下了台，就想，‘嗯……’', '/ænd aɪ gɛt ɔːfˈsteɪdʒ ænd aɪm dʒʌst laɪk wɛl/', '<span>And</span><span>I</span><span pid="564" class="highlight highlight-d">get offstage</span><span>and</span><span>I''m</span><span pid="565" class="highlight highlight-i">just like</span><span>,</span><span>"</span><span>Well</span><span>...</span><span>"</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 135, 353.086, 356.723, 'And they go, "Did you see the raccoons?"', '他们问，‘你看到浣熊了吗？’', '/ænd ðeɪ goʊ dɪd juː siː ðə ræˈkuːnz/', '<span>And</span><span>they</span><span>go</span><span>,</span><span>"</span><span>Did</span><span>you</span><span>see</span><span>the</span><span tid="50136" class="highlight highlight-a">raccoons</span><span>?</span><span>"</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 136, 357.891, 359.66, 'And I''m like, "The...what?"', '然后我说：“那个……什么？”', '/ænd aɪm laɪk ðə wʌt/', '<span>And</span><span>I''m</span><span tid="50137" class="highlight highlight-a">like</span><span>,</span><span>"</span><span>The</span><span>...</span><span>what</span><span>?</span><span>"</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 137, 359.66, 361.261, 'And then they just go, "Behind you.', '然后他们就说：“在你身后。', '/ænd ðɛn ðeɪ dʒʌst goʊ bɪˈhaɪnd juː/', '<span>And</span><span>then</span><span>they</span><span>just</span><span tid="50138" class="highlight highlight-a">go</span><span>,</span><span>"</span><span tid="50139" class="highlight highlight-a">Behind</span><span>you</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 138, 361.261, 365.566, 'As soon as you came onstage, a family of raccoons came out.', '你刚上台，一窝浣熊就出来了。', '/æz suːn æz juː keɪm ɑːnˈsteɪdʒ ə ˈfæməli əv ræˈkuːnz keɪm aʊt/', '<span pid="566" class="highlight highlight-c">As soon as</span><span>you</span><span>came</span><span tid="50140" class="highlight highlight-a">onstage</span><span>,</span><span>a</span><span tid="50141" class="highlight highlight-a">family</span><span>of</span><span tid="50142" class="highlight highlight-a">raccoons</span><span>came</span><span>out</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 139, 365.566, 367.634, 'They were so cute.', '它们太可爱了。', '/ðeɪ wɜːr soʊ kjuːt/', '<span>They</span><span>were</span><span>so</span><span tid="50143" class="highlight highlight-a">cute</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 140, 367.634, 370.938, 'Couldn''t focus on the scene because the raccoons were so cute."', '因为浣熊太可爱了，都没法专注在戏上。”', '/ˈkʊdənt ˈfoʊkəs ɑːn ðə siːn bɪˈkɔːz ðə ræˈkuːnz wɜːr soʊ kjuːt/', '<span>Couldn''t</span><span tid="50144" class="highlight highlight-a">focus</span><span>on</span><span>the</span><span tid="50145" class="highlight highlight-a">scene</span><span>because</span><span>the</span><span tid="50146" class="highlight highlight-a">raccoons</span><span>were</span><span>so</span><span tid="50147" class="highlight highlight-a">cute</span><span>.</span><span>"</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 141, 370.938, 375.008, 'So I was like, "Well, actually, high five to the raccoons."', '所以我说：“好吧，其实，给浣熊们击个掌。”', '/soʊ aɪ wʌz laɪk wɛl ˈækʃuəli haɪ faɪv tuː ðə ræˈkuːnz/', '<span>So</span><span>I</span><span>was</span><span tid="50148" class="highlight highlight-a">like</span><span>,</span><span>"</span><span>Well</span><span>,</span><span tid="50149" class="highlight highlight-a">actually</span><span>,</span><span pid="567" class="highlight highlight-i">high five</span><span>to</span><span>the</span><span tid="50150" class="highlight highlight-a">raccoons</span><span>.</span><span>"</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 142, 375.008, 377.477, '-See? You got to work with everybody.', '-看吧？你得和所有人合作。', '/siː juː gɑːt tuː wɜːrk wɪð ˈɛvribɑːdi/', '<span>-</span><span>See</span><span>?</span><span>You</span><span>got</span><span>to</span><span>work</span><span>with</span><span tid="50151" class="highlight highlight-a">everybody</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 143, 377.477, 378.712, '-Absolutely.', '-绝对。', '/ˈæbsəluːtli/', '<span>-</span><span tid="50152" class="highlight highlight-a">Absolutely</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 144, 378.712, 380.781, '-You got to work -- You play well with others.', '你得工作——你和别人相处得很好。', '/juː gɑːt tə wɜːrk | juː pleɪ wɛl wɪð ˈʌðərz/', '<span>-You</span><span>got</span><span>to</span><span>work</span><span>--</span><span>You</span><span>play</span><span>well</span><span>with</span><span>others.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 145, 380.781, 382.649, 'Let''s talk about "The Idea of You."', '我们来谈谈《关于你的想法》。', '/lɛts tɔːk əˈbaʊt ðə aɪˈdiːə əv juː/', '<span>Let''s</span><span pid="568" class="highlight highlight-d">talk about</span><span pid="569" class="highlight highlight-a">"The Idea of You."</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 146, 382.649, 384.585, 'Oh, my gosh, buddy.', '哦，天哪，伙计。', '/oʊ maɪ gɑːʃ ˈbʌdi/', '<span>Oh,</span><span>my</span><span>gosh,</span><span>buddy.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 147, 384.585, 386.72, 'The trailer alone has gotten over 125 million views.', '仅预告片就获得了超过1.25亿次观看。', '/ðə ˈtreɪlər əˈloʊn hæz ˈɡɑːtən ˈoʊvər wʌn ˈhʌndrəd ənd ˈtwɛnti faɪv ˈmɪljən vjuːz/', '<span>The</span><span>trailer</span><span>alone</span><span pid="570" class="highlight highlight-d">has gotten</span><span>over</span><span>125</span><span>million</span><span>views.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 148, 386.72, 389.623, '-Yeah. -It crushed, broke the record.', '是的。它大获成功，打破了纪录。', '/jɛs | ɪt krʌʃt broʊk ðə ˈrɛkərd/', '<span>-Yeah.</span><span>-It</span><span tid="50153" class="highlight highlight-a">crushed,</span><span>broke</span><span>the</span><span>record.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 149, 389.623, 393.594, 'Most-watched trailer of any streaming movie in history.', '历史上观看次数最多的流媒体电影预告片。', '/moʊst ˈwɑːtʃt ˈtreɪlər əv ˈɛni ˈstriːmɪŋ ˈmuːvi ɪn ˈhɪstəri/', '<span tid="50154" class="highlight highlight-a">Most-watched</span><span>trailer</span><span>of</span><span>any</span><span>streaming</span><span>movie</span><span>in</span><span>history.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 150, 393.594, 395.362, 'Can we set up what the movie''s about?', '我们能介绍一下这部电影是关于什么的吗？', '/kæn wiː sɛt ʌp wʌt ðə ˈmuːvi z əˈbaʊt/', '<span>Can</span><span>we</span><span pid="571" class="highlight highlight-d">set up</span><span>what</span><span>the</span><span>movie''s</span><span>about?</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 151, 395.362, 396.73, '-Oh, sure, sure.', '哦，当然，当然。', '/oʊ ʃʊr ʃʊr/', '<span>-Oh,</span><span>sure,</span><span>sure.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 152, 396.73, 400.968, 'The story is about Solène Marchand, who is a woman who lives in Silver Lake.', '故事是关于索莱娜·马尔尚的，她是一位住在银湖的女性。', '/ðə ˈstɔri ɪz əˈbaʊt soʊˈlɛn mɑrˈʃɑn hu ɪz ə ˈwʊmən hu lɪvz ɪn ˈsɪlvər leɪk/', '<span>The</span><span tid="50155" class="highlight highlight-a">story</span><span>is</span><span>about</span><span tid="50156" class="highlight highlight-a">Solène</span><span tid="50157" class="highlight highlight-a">Marchand</span><span>,</span><span>who</span><span>is</span><span>a</span><span>woman</span><span>who</span><span>lives</span><span>in</span><span tid="50158" class="highlight highlight-a">Silver</span><span tid="50159" class="highlight highlight-a">Lake</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 153, 400.968, 402.936, 'She''s a gallery owner.', '她是一家画廊的老板。', '/ʃiz ə ˈɡæləri ˈoʊnər/', '<span>She</span><span>''s</span><span>a</span><span tid="50160" class="highlight highlight-a">gallery</span><span tid="50161" class="highlight highlight-a">owner</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 154, 402.936, 406.073, 'She''s a mom and she''s got this really wonderful life.', '她是一位母亲，拥有非常美好的生活。', '/ʃiz ə mɑm ænd ʃiz gɑt ðɪs ˈrɪli ˈwʌndərfəl laɪf/', '<span>She</span><span>''s</span><span>a</span><span>mom</span><span>and</span><span>she</span><span>''s</span><span>got</span><span>this</span><span>really</span><span tid="50162" class="highlight highlight-a">wonderful</span><span>life</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 155, 406.073, 412.546, 'And she unexpectedly meets the lead singer of the biggest boy band in the world, a 24-year-old young man named Hayes Campbell.', '她意外地遇到了世界上最大男孩乐队的主唱，一个24岁的年轻人，名叫海耶斯·坎贝尔。', '/ænd ʃi ˌʌnɪkˈspɛktɪdli mits ðə lid ˈsɪŋər əv ðə ˈbɪɡəst bɔɪ bænd ɪn ðə wɜːrld ə ˈtwɛnti fɔr jɪr oʊld jʌŋ mæn neɪmd heɪz ˈkæmbəl/', '<span>And</span><span>she</span><span tid="50163" class="highlight highlight-a">unexpectedly</span><span>meets</span><span>the</span><span tid="50164" class="highlight highlight-a">lead</span><span>singer</span><span>of</span><span>the</span><span tid="50165" class="highlight highlight-a">biggest</span><span>boy</span><span>band</span><span>in</span><span>the</span><span>world</span><span>,</span><span>a</span><span tid="50166" class="highlight highlight-a">24-year-old</span><span>young</span><span>man</span><span>named</span><span tid="50167" class="highlight highlight-a">Hayes</span><span tid="50168" class="highlight highlight-a">Campbell</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 156, 412.546, 413.58, '-Yeah.', '是的。', '/jɛs/', '<span>-Yeah</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 157, 413.58, 415.883, '-And he thinks she''s kind of great.', '他觉得她挺不错的。', '/ænd hi θɪŋks ʃiz kaɪnd əv greɪt/', '<span>-And</span><span>he</span><span>thinks</span><span>she</span><span>''s</span><span>kind</span><span>of</span><span>great</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 158, 415.883, 418.385, 'And so the story is about how they fall in love.', '所以故事是关于他们如何相爱的。', '/ænd soʊ ðə ˈstɔri ɪz əˈbaʊt haʊ ðeɪ fɔːl ɪn lʌv/', '<span>And</span><span>so</span><span>the</span><span>story</span><span>is</span><span>about</span><span>how</span><span>they</span><span>fall</span><span>in</span><span>love</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 159, 418.385, 423.857, '-Yeah. Because you''re just a mom and you''re chaperoning this thing and you go to this thing and then you see this boy band.', '是的。因为你只是一个母亲，你在陪同参加这个活动，然后你去了这个活动，然后你看到了这个男孩乐队。', '/jɛs bɪˈkɔz jʊr dʒʌst ə mɑm ænd jʊr ˈtʃæpəroʊnɪŋ ðɪs θɪŋ ænd jʊ goʊ tu ðɪs θɪŋ ænd ðɛn jʊ si ðɪs bɔɪ bænd/', '<span>-Yeah</span><span>.</span><span>Because</span><span>you</span><span>''re</span><span>just</span><span>a</span><span>mom</span><span>and</span><span>you</span><span>''re</span><span tid="50169" class="highlight highlight-a">chaperoning</span><span>this</span><span>thing</span><span>and</span><span>you</span><span>go</span><span>to</span><span>this</span><span>thing</span><span>and</span><span>then</span><span>you</span><span>see</span><span>this</span><span>boy</span><span>band</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 160, 423.857, 426.226, '-I love hearing you describe my movie.', '我喜欢听你描述我的电影。', '/aɪ lʌv ˈhirɪŋ ju dɪˈskraɪb maɪ ˈmuvi/', '<span>-</span><span>I</span><span tid="50170" class="highlight highlight-a">love</span><span>hearing</span><span>you</span><span tid="50171" class="highlight highlight-a">describe</span><span>my</span><span>movie.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 161, 426.226, 427.961, '"Just a mom in this thing."', '“只是这部电影里的一个妈妈。”', '/ˈdʒʌst ə mɑm ɪn ðɪs θɪŋ/', '<span>"</span><span>Just</span><span>a</span><span>mom</span><span>in</span><span>this</span><span>thing."</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 162, 427.961, 429.096, '-Yeah, you''re a mom in this thing.', '是的，你在这部电影里是个妈妈。', '/jɛs jʊr ə mɑm ɪn ðɪs θɪŋ/', '<span>-</span><span>Yeah,</span><span>you''re</span><span>a</span><span>mom</span><span>in</span><span>this</span><span>thing.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 163, 429.096, 431.064, 'That''s how I described it.', '我就是这么描述的。', '/ðæts haʊ aɪ dɪˈskraɪbd ɪt/', '<span>That''s</span><span>how</span><span>I</span><span tid="50172" class="highlight highlight-a">described</span><span>it.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 164, 431.064, 437.538, 'Mom is chaperoning, like, a Coachella type of thing, like a giant outdoor festival thing, and the biggest boy band', '妈妈在 chaperoning，就像科切拉音乐节那种，一个巨大的户外音乐节，还有世界上最大的男孩乐队', '/mɑm ɪz ˈʃæpəroʊnɪŋ laɪk ə koʊˈtʃɛlə taɪp əv θɪŋ laɪk ə ˈdʒaɪənt ˈaʊtdɔr ˈfɛstəvəl θɪŋ ænd ðə ˈbɪgəst bɔɪ bænd/', '<span>Mom</span><span>is</span><span tid="50173" class="highlight highlight-a">chaperoning,</span><span>like,</span><span>a</span><span tid="50174" class="highlight highlight-a">Coachella</span><span>type</span><span>of</span><span>thing,</span><span>like</span><span>a</span><span tid="50175" class="highlight highlight-a">giant</span><span>outdoor</span><span>festival</span><span>thing,</span><span>and</span><span>the</span><span>biggest</span><span>boy</span><span>band</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 165, 437.538, 443.544, 'in the world, and then the lead singer -- -Oh, yes, so, my daughter is off watching St. Vincent.', '然后主唱——哦，是的，所以我女儿去看圣文森特了。', '/ɪn ðə wɜːrld ænd ðɛn ðə lid ˈsɪŋər oʊ jɛs soʊ maɪ ˈdɔtər ɪz ɔf ˈwɑtʃɪŋ seɪnt ˈvɪnsənt/', '<span>in</span><span>the</span><span>world,</span><span>and</span><span>then</span><span>the</span><span>lead</span><span>singer</span><span>--</span><span>-</span><span>Oh,</span><span>yes,</span><span>so,</span><span>my</span><span>daughter</span><span>is</span><span>off</span><span>watching</span><span>St.</span><span>Vincent.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 166, 443.544, 445.379, 'Because she doesn''t like the boy band anymore.', '因为她不再喜欢那个男孩乐队了。', '/bɪˈkɔz ʃi dʌznt laɪk ðə bɔɪ bænd ˈɛnɪmɔr/', '<span>Because</span><span>she</span><span>doesn''t</span><span>like</span><span>the</span><span>boy</span><span>band</span><span>anymore.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 167, 445.379, 447.114, 'She liked them in seventh grade.', '她七年级的时候喜欢他们。', '/ʃi laɪkt ðɛm ɪn ˈsɛvənθ greɪd/', '<span>She</span><span>liked</span><span>them</span><span>in</span><span>seventh</span><span>grade.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 168, 447.114, 451.251, 'But, anyway, I have a backstage pass, so I''m a -- all-access thing.', '但不管怎样，我有后台通行证，所以我是——全通票。', '/bʌt ˈɛniˌweɪ aɪ hæv ə ˈbækˌsteɪdʒ pæs soʊ aɪm ə ɔːl ˈækˌsɛs θɪŋ/', '<span>But</span><span>,</span><span tid="50176" class="highlight highlight-a">anyway</span><span>,</span><span>I</span><span>have</span><span>a</span><span pid="572" class="highlight highlight-c">backstage pass</span><span>,</span><span>so</span><span>I''m</span><span>a</span><span>--</span><span tid="50177" class="highlight highlight-a">all-access</span><span>thing</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 169, 451.251, 452.352, 'I have to go to the bathroom.', '我得去洗手间。', '/aɪ hæv tə ɡoʊ tə ðə ˈbæθruːm/', '<span>I</span><span>have</span><span>to</span><span>go</span><span>to</span><span>the</span><span tid="50178" class="highlight highlight-a">bathroom</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 170, 452.352, 453.954, 'Somebody tells me where the trailers are.', '有人告诉我拖车在哪里。', '/ˈsʌmbədi tɛlz miː wɛr ðə ˈtreɪlərz ɑːr/', '<span>Somebody</span><span>tells</span><span>me</span><span>where</span><span>the</span><span tid="50179" class="highlight highlight-a">trailers</span><span>are</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 171, 453.954, 457.391, 'I go and I walk into the wrong trailer.', '我走过去，走进了错误的拖车。', '/aɪ ɡoʊ ænd aɪ wɔːk ˈɪntuː ðə rɒŋ ˈtreɪlər/', '<span>I</span><span>go</span><span>and</span><span>I</span><span>walk</span><span>into</span><span>the</span><span tid="50180" class="highlight highlight-a">wrong</span><span tid="50181" class="highlight highlight-a">trailer</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 172, 457.391, 461.061, '-Yeah. And the rest is -- High jinks ensues.', '是的。然后剩下的就是——闹剧发生了。', '/jɛs ænd ðə rɛst ɪz haɪ dʒɪŋks ɪnˈsjuːz/', '<span>-Yeah</span><span>.</span><span>And</span><span>the</span><span>rest</span><span>is</span><span>--</span><span pid="573" class="highlight highlight-i">High jinks</span><span tid="50182" class="highlight highlight-a">ensues</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 173, 461.061, 464.798, 'But remind me of the actor who plays the lead singer.', '但提醒我一下扮演主唱的演员。', '/bʌt rɪˈmaɪnd miː ʌv ði ˈæktər huː pleɪz ðə liːd ˈsɪŋər/', '<span>But</span><span>remind</span><span>me</span><span>of</span><span>the</span><span tid="50183" class="highlight highlight-a">actor</span><span>who</span><span>plays</span><span>the</span><span pid="574" class="highlight highlight-c">lead singer</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 174, 464.798, 465.933, '-Nick Galitzine.', '尼克·加利齐纳。', '/nɪk ˈɡælɪtsiːn/', '<span>-Nick</span><span>Galitzine</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 175, 465.933, 468.135, '-Oh, man, you guys have great chemistry.', '哦，天哪，你们之间很有化学反应。', '/oʊ mæn juː ɡaɪz hæv ɡreɪt ˈkɛmɪstri/', '<span>-Oh</span><span>,</span><span>man</span><span>,</span><span>you</span><span>guys</span><span>have</span><span tid="50184" class="highlight highlight-a">great</span><span tid="50185" class="highlight highlight-a">chemistry</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 176, 468.135, 469.703, 'Did you know when he was auditioning?', '你知道他试镜的时候吗？', '/dɪd juː noʊ wɛn hiː wʌz ˌɔːdɪˈʃənɪŋ/', '<span>Did</span><span>you</span><span>know</span><span>when</span><span>he</span><span>was</span><span>auditioning?</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 177, 469.703, 471.572, 'You go, "Oh, this the guy." -Oh, yeah.', '你会说，“哦，就是这个人。” -哦，是的。', '/juː ɡoʊ oʊ ðɪs ðə ɡaɪ oʊ jɛs/', '<span>You</span><span>go,</span><span>"Oh,</span><span>this</span><span>the</span><span>guy."</span><span>-Oh,</span><span>yeah.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 178, 471.572, 479.613, 'Yeah, no, as soon as he -- I actually burst out laughing when he walked in, because -- Has anybody here read the book?', '是的，不，他一进来我就笑出声了，因为——这里有人读过这本书吗？', '/jɛs noʊ æz suːn æz hiː aɪ ˈækʧuəli bɜːrst aʊt ˈlæfɪŋ wɛn hiː wɔːkt ɪn bɪˈkɔːz hæz ˈɛnibɑːdi hɪr rɛd ðə bʊk/', '<span>Yeah</span><span>,</span><span>no</span><span>,</span><span>as</span><span>soon</span><span>as</span><span>he</span><span>--</span><span>I</span><span>actually</span><span pid="575" class="highlight highlight-d">burst out laughing</span><span>when</span><span>he</span><span pid="576" class="highlight highlight-d">walked in</span><span>,</span><span>because</span><span>--</span><span>Has</span><span>anybody</span><span>here</span><span>read</span><span>the</span><span>book</span><span>?</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 179, 479.613, 482.349, '-No, we don''t read.', '-不，我们不读书。', '/noʊ wiː doʊnt riːd/', '<span>-No</span><span>,</span><span>we</span><span>don''t</span><span>read</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 180, 482.349, 483.984, '-Well, you should. It''s fabulous.', '嗯，你应该觉得。它太棒了。', '/wɛl ju ʃʊd ɪts ˈfæbjələs/', '<span>-Well,</span><span>you</span><span>should.</span><span>It''s</span><span>fabulous.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 181, 483.984, 485.118, '-This is "The Tonight Show."', '这是《今夜秀》。', '/ðɪs ɪz ðə təˈnaɪt ʃoʊ/', '<span>-This</span><span>is</span><span>"</span><span>The</span><span>Tonight</span><span>Show</span><span>."</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 182, 485.118, 493.06, 'Yeah, you want to go over to Stephen -- You want to go to Stephen Colbert if you want to get people that read books.', '是的，你想去斯蒂芬——如果你想找读书的人，你应该去斯蒂芬·科尔伯特那里。', '/jɛs ju wɑnt tə goʊ ˈoʊvər tə ˈstivən ju wɑnt tə goʊ tə ˈstivən ˈkoʊlbərt ɪf ju wɑnt tə gɛt ˈpipəl ðæt rɛd bʊks/', '<span>Yeah</span><span>,</span><span>you</span><span>want</span><span>to</span><span pid="577" class="highlight highlight-d">go over to</span><span>Stephen</span><span>--</span><span>You</span><span>want</span><span>to</span><span pid="578" class="highlight highlight-d">go to</span><span>Stephen</span><span>Colbert</span><span>if</span><span>you</span><span>want</span><span>to</span><span>get</span><span>people</span><span>that</span><span>read</span><span>books</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 183, 493.06, 494.862, 'We don''t read.', '我们不读书。', '/wi doʊnt rɛd/', '<span>We</span><span>don''t</span><span>read</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 184, 497.364, 499.233, 'Lame!', '真差劲！', '/leɪm/', '<span tid="50186" class="highlight highlight-a">Lame!</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 185, 499.233, 501.401, '-Well, you have an awesome book in store for you.', '嗯，你有一本很棒的书等着你呢。', '/wɛl, juː hæv æn ˈɔːsəm bʊk ɪn stɔːr fɔːr juː/', '<span>-Well,</span><span>you</span><span>have</span><span>an</span><span tid="50187" class="highlight highlight-a">awesome</span><span>book</span><span pid="579" class="highlight highlight-c">in store for</span><span>you.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 186, 501.401, 503.57, 'It''s written by -- -Lame-O!', '是——写的—— -差劲鬼！', '/ɪts ˈrɪtən baɪ -- -leɪm oʊ/', '<span>It''s</span><span>written</span><span>by</span><span>--</span><span tid="50188" class="highlight highlight-a">-Lame-O!</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 187, 503.57, 507.241, 'We do Audible here. We do that. Does that count?', '我们这里用Audible。我们做那个。那算数吗？', '/wiː duː ˈɔːdəbl hɪr. wiː duː ðæt. dʌz ðæt kaʊnt/', '<span>We</span><span>do</span><span tid="50189" class="highlight highlight-a">Audible</span><span>here.</span><span>We</span><span>do</span><span>that.</span><span>Does</span><span>that</span><span tid="50190" class="highlight highlight-a">count?</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 188, 507.241, 510.344, '-I think it''s time for you to -- to get me back.', '我想是时候让你——让我回去了。', '/aɪ θɪŋk ɪts taɪm fɔːr juː tuː tuː ɡɛt miː bæk/', '<span>-I</span><span>think</span><span>it''s</span><span>time</span><span>for</span><span>you</span><span>to</span><span>--</span><span>to</span><span>get</span><span>me</span><span tid="50191" class="highlight highlight-d">back.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 189, 510.344, 514.248, '-Yeah, I know. -Okay, so -- -It''s based on this book.', '是的，我知道。-好的，所以——-这是基于这本书。', '/jɛs aɪ noʊ ˈoʊkeɪ soʊ ɪts beɪst ɑn ðɪs bʊk/', '<span>-Yeah,</span><span>I</span><span>know.</span><span>-Okay,</span><span>so</span><span>--</span><span>-It''s</span><span pid="580" class="highlight highlight-c">based on</span><span>this</span><span>book.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 190, 514.248, 515.782, '-What''s a book? -Yeah.', '什么是书？-是的。', '/wʌts ə bʊk jɛs/', '<span>-What''s</span><span>a</span><span>book?</span><span>-Yeah.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 191, 515.782, 518.051, 'No, too late. No, too late.', '不，太晚了。不，太晚了。', '/noʊ tuː leɪt noʊ tuː leɪt/', '<span>No,</span><span>too</span><span>late.</span><span>No,</span><span>too</span><span>late.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 192, 518.051, 520.521, 'But this is based on the big best-selling book.', '但这是基于那本畅销书。', '/bʌt ðɪs ɪz ˈbeɪst ɑn ðə bɪɡ ˈbɛstˈsɛlɪŋ bʊk/', '<span>But</span><span>this</span><span>is</span><span pid="581" class="highlight highlight-c">based on</span><span>the</span><span>big</span><span tid="50192" class="highlight highlight-a">best-selling</span><span>book.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 193, 520.521, 523.891, '-Well, the book does have a fan following somewhere.', '嗯，这本书确实有一些粉丝。', '/wɛl ðə bʊk dʌz hæv ə fæn ˈfoʊləˌsɪŋ ˈsʌmˌwɛr/', '<span>-Well,</span><span>the</span><span>book</span><span>does</span><span>have</span><span>a</span><span pid="582" class="highlight highlight-i">fan following</span><span>somewhere.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 194, 523.891, 527.327, 'And -- Anyway, and I think the book is incredible.', '而且——不管怎样，我认为这本书非常棒。', '/ænd ˈɛniˌweɪ ænd aɪ θɪŋk ðə bʊk ɪz ɪnˈkrɛdəbəl/', '<span>And</span><span>--</span><span>Anyway,</span><span>and</span><span>I</span><span>think</span><span>the</span><span>book</span><span>is</span><span tid="50193" class="highlight highlight-a">incredible.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 195, 527.327, 530.631, 'And Hayes Campbell is so beautifully written in the book, and so we knew that we just really needed to find', '而海耶斯·坎贝尔在书中被写得如此优美，所以我们知道我们真的需要找到', '/ænd heɪz ˈkæmbəl ɪz soʊ ˈbjutəfəli ˈrɪtən ɪn ðə bʊk ænd soʊ wi nju ðæt wi dʒʌst ˈrɪli nidɪd tu faɪnd/', '<span>And</span><span>Hayes</span><span>Campbell</span><span>is</span><span>so</span><span tid="50194" class="highlight highlight-a">beautifully</span><span>written</span><span>in</span><span>the</span><span>book,</span><span>and</span><span>so</span><span>we</span><span>knew</span><span>that</span><span>we</span><span>just</span><span>really</span><span>needed</span><span>to</span><span>find</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 196, 530.631, 531.632, 'someone really special.', '一个非常特别的人。', '/ˈsʌmˌwʌn ˈrɪli ˈspɛʃəl/', '<span>someone</span><span>really</span><span tid="50195" class="highlight highlight-a">special.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 197, 531.632, 535.335, 'And he walked in, yeah, and I just thought, "Oh, that''s Hayes Campbell."', '他走进来了，是的，我当时就想，“哦，那就是海耶斯·坎贝尔。”', '/ænd hi wɔkt ɪn jɛs ænd aɪ dʒʌst θɔt oʊ ðæts heɪz ˈkæmbəl/', '<span>And</span><span>he</span><span pid="583" class="highlight highlight-d">walked in,</span><span>yeah,</span><span>and</span><span>I</span><span>just</span><span>thought,</span><span>"Oh,</span><span>that''s</span><span>Hayes</span><span>Campbell."</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 198, 535.335, 537.137, 'And that was almost two years ago.', '那几乎是两年前的事了。', '/ænd ðæt wʌz ˈɔlmoʊst tu jɪrz əˈgoʊ/', '<span>And</span><span>that</span><span>was</span><span>almost</span><span>two</span><span>years</span><span>ago.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 199, 537.137, 540.641, 'And now Nick and I have become really good friends, and, yeah, it''s opened up in this beautiful way.', '现在尼克和我成了非常好的朋友，而且，是的，它以这种美好的方式展开了。', '/ænd naʊ nɪk ænd aɪ hæv bɪˈkʌm ˈrɪli gʊd frɛndz ænd jɛs ɪts ˈoʊpənd ɪn ðɪs ˈbjutəfəl weɪ/', '<span>And</span><span>now</span><span>Nick</span><span>and</span><span>I</span><span>have</span><span>become</span><span>really</span><span>good</span><span>friends,</span><span>and,</span><span>yeah,</span><span>it''s</span><span pid="584" class="highlight highlight-d">opened up</span><span>in</span><span>this</span><span>beautiful</span><span>way.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 200, 540.641, 542.509, '-It''s really great. I want to show everyone a clip.', '这真的很棒。我想给大家看一个片段。', '/ɪts ˈrɪli greɪt. aɪ wɑnt tuː ʃoʊ ˈɛvriˌwʌn ə klɪp/', '<span>-It''s</span><span>really</span><span tid="50196" class="highlight highlight-a">great</span><span>.</span><span>I</span><span>want</span><span>to</span><span tid="50197" class="highlight highlight-a">show</span><span>everyone</span><span>a</span><span tid="50198" class="highlight highlight-a">clip</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 201, 542.509, 544.311, 'Here''s Anne Hathaway in "The Idea of You."', '这是安妮·海瑟薇在《对你的想象》中的片段。', '/hɪrz æn ˈhæθəˌweɪ ɪn ðə aɪˈdiːə əv juː/', '<span>Here''s</span><span>Anne</span><span>Hathaway</span><span>in</span><span>"The</span><span tid="50199" class="highlight highlight-a">Idea</span><span>of</span><span>You</span><span>."</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 202, 544.311, 545.312, 'Take a look.', '看一看。', '/teɪk ə lʊk/', '<span>Take</span><span>a</span><span>look.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 203, 554.555, 555.556, '-Hi again.', '又见面了。', '/haɪ əˈɡɛn/', '<span>-Hi</span><span>again</span><span>.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 204, 557.024, 560.661, '-Are you a part of that ASMR community that gets off on listening to people pee?', '你是那个通过听别人小便来获得快感的ASMR社区的一员吗？', '/ɑːr juː ə pɑːrt əv ðæt eɪ ɛs ɛm ɑːr kəˈmjuːnəti ðæt ɡɛts ɔːf ɑːn ˈlɪsənɪŋ tuː ˈpiːpəl piː/', '<span>-</span><span>Are</span><span>you</span><span>a</span><span pid="585" class="highlight highlight-c">part of</span><span>that</span><span tid="50200" class="highlight highlight-a">ASMR</span><span tid="50201" class="highlight highlight-a">community</span><span>that</span><span pid="586" class="highlight highlight-i">gets off on</span><span pid="587" class="highlight highlight-d">listening to</span><span>people</span><span tid="50202" class="highlight highlight-a">pee</span><span>?</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 205, 560.661, 564.565, '-No, I wasn''t -- -Because I don''t think you can just go around assuming -- -It''s actually my trailer.', '-不，我没有—— -因为我认为你不能随便假设—— -这其实是我的拖车。', '/noʊ aɪ ˈwɑːzənt bɪˈkɔːz aɪ doʊnt θɪŋk juː kæn dʒʌst ɡoʊ əˈraʊnd əˈsuːmɪŋ ɪts ˈækʃuəli maɪ ˈtreɪlər/', '<span>-No,</span><span>I</span><span>wasn''t</span><span>--</span><span>-Because</span><span>I</span><span>don''t</span><span>think</span><span>you</span><span>can</span><span>just</span><span>go</span><span>around</span><span>assuming</span><span>--</span><span>-It''s</span><span>actually</span><span>my</span><span>trailer.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 206, 564.565, 565.899, '-What?', '什么？', '/wʌt/', '<span>-What?</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 207, 565.899, 567.801, '-It''s not literally mine. You know, I don''t own it.', '它不真的是我的。你知道，我并不拥有它。', '/ɪts nɑt ˈlɪtərəli maɪn. ju noʊ, aɪ doʊnt oʊn ɪt./', '<span>-It''s</span><span>not</span><span tid="50203" class="highlight highlight-a">literally</span><span>mine.</span><span pid="588" class="highlight highlight-i">You know,</span><span>I</span><span>don''t</span><span tid="50204" class="highlight highlight-a">own</span><span>it.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 208, 567.801, 570.103, '-This is your trailer?', '这是你的拖车？', '/ðɪs ɪz jɔːr ˈtreɪlər/', '<span>-</span><span>This</span><span>is</span><span>your</span><span tid="50205" class="highlight highlight-a">trailer?</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 209, 570.103, 571.605, '-Yeah, I''m in the band.', '是的，我在乐队里。', '/jɛə aɪm ɪn ðə bænd/', '<span>-Yeah,</span><span>I''m</span><span>in</span><span>the</span><span tid="50206" class="highlight highlight-a">band.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 210, 571.605, 573.006, 'We''re performing on the main stage.', '我们将在主舞台表演。', '/wɪr pərˈfɔːrmɪŋ ɑn ðə meɪn steɪdʒ/', '<span>We''re</span><span tid="50207" class="highlight highlight-a">performing</span><span>on</span><span>the</span><span tid="50208" class="highlight highlight-a">main</span><span tid="50209" class="highlight highlight-a">stage.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 211, 573.006, 577.044, 'You know, I''m Hayes Campbell.', '你知道，我是海耶斯·坎贝尔。', '/juː noʊ aɪm heɪz ˈkæmbəl/', '<span>You</span><span>know,</span><span>I''m</span><span>Hayes</span><span>Campbell.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 212, 577.044, 578.745, '-August Moon?', '八月之月？', '/ɔːɡʌst muːn/', '<span>-August</span><span>Moon?</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 213, 578.745, 579.78, '-Yeah.', '是的。', '/jɛə/', '<span>-Yeah.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 214, 579.78, 582.316, '-Well, I absolutely know who you are.', '嗯，我当然知道你是谁。', '/wɛl aɪ ˈæbsəluːtli noʊ huː juː ɑːr/', '<span>-Well,</span><span>I</span><span tid="50210" class="highlight highlight-a">absolutely</span><span>know</span><span>who</span><span>you</span><span>are.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 215, 582.316, 587.221, 'Um, anyway...I''ll...', '嗯，不管怎样……我……', '/ʌm ˈɛniweɪ aɪl/', '<span>Um,</span><span>anyway...</span><span>I''ll...</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 216, 590.49, 593.16, '-Yeah. Come on. You know how to do it.', '是啊，来吧。你知道该怎么做。', '/jɛə kʌm ɑn ju noʊ haʊ tə du ɪt/', '<span>-Yeah.</span><span pid="589" class="highlight highlight-i">Come on.</span><span>You</span><span>know</span><span>how</span><span>to</span><span>do</span><span>it.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 217, 593.16, 594.828, 'Anne Hathaway, everybody.', '安妮·海瑟薇，各位。', '/æn ˈhæθəweɪ ˈɛvriˌbɑdi/', '<span>Anne</span><span>Hathaway,</span><span>everybody.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 218, 594.828, 598.999, '"The Idea of You" begins streaming on Prime Video this Thursday.', '《关于你的想法》将于本周四在Prime Video上线。', '/ði aɪˈdiə əv ju bɪˈɡɪnz ˈstriːmɪŋ ɑn praɪm ˈvɪdiˌoʊ ðɪs ˈθɜːrzdeɪ/', '<span>"The</span><span tid="50211" class="highlight highlight-a">Idea</span><span>of</span><span>You"</span><span>begins</span><span tid="50212" class="highlight highlight-a">streaming</span><span>on</span><span>Prime</span><span>Video</span><span>this</span><span>Thursday.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 219, 598.999, 601.301, 'We''ll be right back with Melanie Lynskey.', '我们马上回来，和梅兰妮·林斯基一起。', '/wil bi raɪt bæk wɪð ˈmɛləni ˈlɪnski/', '<span>We''ll</span><span>be</span><span>right</span><span>back</span><span>with</span><span>Melanie</span><span>Lynskey.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 220, 601.301, 602.302, 'Stick around, everybody.', '大家别走开。', '/stɪk əˈraʊnd ˈɛvriˌbɑdi/', '<span>Stick</span><span>around,</span><span>everybody.</span>'
FROM episodes e WHERE e.video_id = 'i8tBrrjm1aoxSbc';

-- episode 213: 2-5Q4-m4L9dvoac
UPDATE user_word_lookups SET subtitle_id = NULL WHERE subtitle_id IN (SELECT s.id FROM subtitles s JOIN episodes e ON s.episode_id = e.id WHERE e.video_id = '2-5Q4-m4L9dvoac');
UPDATE user_vocabulary_items SET source_subtitle_id = NULL WHERE source_subtitle_id IN (SELECT s.id FROM subtitles s JOIN episodes e ON s.episode_id = e.id WHERE e.video_id = '2-5Q4-m4L9dvoac');
DELETE FROM user_subtitle_progress WHERE subtitle_id IN (SELECT s.id FROM subtitles s JOIN episodes e ON s.episode_id = e.id WHERE e.video_id = '2-5Q4-m4L9dvoac');
DELETE FROM user_subtitle_progress WHERE episode_id = (SELECT id FROM episodes WHERE video_id = '2-5Q4-m4L9dvoac');
DELETE FROM subtitles WHERE episode_id = (SELECT id FROM episodes WHERE video_id = '2-5Q4-m4L9dvoac');
DELETE FROM episode_tags WHERE episode_id = (SELECT id FROM episodes WHERE video_id = '2-5Q4-m4L9dvoac');
INSERT INTO episodes (
  index, video_id, short_title, summary, remark, stars, voca_size,
  subtitle_count, clip_length, cover, video_url, audio_url, thumbnail_url,
  original_video_url, author_id, submitted_by_user_id, rejection_reason,
  created_at, is_demo, status, published_at
) VALUES (
  213, '2-5Q4-m4L9dvoac', '复仇者联盟主演谈首映、最爱台词、同款纹身与生日礼物',
  '小罗伯特·唐尼、克里斯·海姆斯沃斯、斯嘉丽·约翰逊和保罗·路德谈论《复仇者联盟4：终局之战》的首映、获得同款纹身、电影中最爱的台词、游览迪士尼乐园、互相赠送生日礼物（除了克里斯·海姆斯沃斯）、独立黑寡妇电影、蚁人粉丝理论，以及复仇者联盟为现场观众准备了惊喜。
吉米·坎摩尔与席琳·迪翁惊喜现身拉斯维加斯婚礼 https://youtu.be/R6X1V9c_HbA
订阅获取最新内容：http://bit.ly/JKLSubscribe
观看《恶毒推文》：http://bit.ly/KimmelMT10
与吉米·坎摩尔直播秀在线互动：
访问吉米·坎摩尔直播秀官网：http://bit.ly/JKLWebsite
在脸书上点赞吉米·坎摩尔：http://bit.ly/KimmelFB
在脸书上点赞吉米·坎摩尔直播秀：http://bit.ly/JKLFacebook
关注推特：http://bit.ly/KimmelTW
在推特上关注吉米·坎摩尔直播秀：http://bit.ly/JKLTwitter
在Instagram上关注吉米·坎摩尔直播秀：http://bit.ly/JKLInstagram
关于吉米·坎摩尔直播秀：
吉米·坎摩尔担任艾美奖获奖节目《吉米·坎摩尔直播秀》（ABC深夜脱口秀）的主持人和执行制片人。
《吉米·坎摩尔直播秀》以其巨大的病毒视频成功而闻名，仅在YouTube上就有56亿次观看。
坎摩尔最受欢迎的一些喜剧片段包括——恶毒推文、谎言见证新闻、吉米的电臀舞失败恶作剧、不必要的审查、YouTube挑战、婴儿单身汉、电影：电影、帅哥俱乐部、吉米·坎摩尔谎言侦探以及音乐视频，如《我想在你身上钱宁》和与罗宾·西克、法瑞尔、吉米及其保安吉列尔莫合作的《模糊界线》 parody。
现已进入第十七季，坎摩尔的嘉宾包括：约翰尼·德普、梅丽尔·斯特里普、汤姆·克鲁斯、哈莉·贝瑞、哈里森·福特、詹妮弗·安妮斯顿、威尔·法瑞尔、凯蒂·佩里、汤姆·汉克斯、斯嘉丽·约翰逊、查宁·塔图姆、乔治·克鲁尼、拉里·大卫、查理兹·塞隆、马克·沃尔伯格、科比·布莱恩特、史蒂夫·卡瑞尔、休·杰克曼、克里斯汀·韦格、杰夫·布里吉斯、詹妮弗·加纳、瑞恩·高斯林...', '',
  4, 85, 434,
  1021.14, 'http://oss.sxakgs.com/en/5ljluGA4dQU/cover.webp',
  'http://oss.sxakgs.com/en/5ljluGA4dQU/video.mp4', 'http://oss.sxakgs.com/en/5ljluGA4dQU/audio.mp3',
  'http://oss.sxakgs.com/en/5ljluGA4dQU/cover.webp', 'https://www.youtube.com/watch?v=5ljluGA4dQU',
  (SELECT id FROM authors WHERE name = 'Jimmy Kimmel Live' AND accent = '美国' LIMIT 1),
  NULL, NULL,
  '2026-07-07 14:54:16'::timestamp,
  FALSE, 'draft',
  '2026-07-07 14:54:16'::timestamp
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
  submitted_by_user_id = EXCLUDED.submitted_by_user_id,
  rejection_reason = EXCLUDED.rejection_reason,
  is_demo = EXCLUDED.is_demo,
  status = EXCLUDED.status,
  published_at = EXCLUDED.published_at;

INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 0, 0.0, 7.298, 'You know, every Spring at about this time tonight''s guests drop by to share their plans to save the world.', '你知道，每年春天大约这个时候，今晚的嘉宾都会来分享他们拯救世界的计划。', '/juː noʊ ˈɛvri sprɪŋ æt əˈbaʊt ðɪs taɪm təˈnaɪts ˈɡɛsts drɑːp baɪ tuː ʃɛr ðɛr plænz tuː seɪv ðə wɜːrld/', '<span pid="501" class="highlight highlight-i">You know</span><span>,</span><span>every</span><span tid="50001" class="highlight highlight-a">Spring</span><span>at</span><span>about</span><span>this</span><span>time</span><span>tonight''s</span><span tid="50002" class="highlight highlight-a">guests</span><span pid="502" class="highlight highlight-d">drop by</span><span>to</span><span tid="50003" class="highlight highlight-a">share</span><span>their</span><span>plans</span><span>to</span><span tid="50004" class="highlight highlight-a">save</span><span>the</span><span>world</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 1, 7.298, 9.59, 'This year they really have their work cut out for them.', '今年他们真的有很多工作要做。', '/ðɪs jɪr ðeɪ ˈrɪli hæv ðɛr wɜːrk kʌt aʊt fɔːr ðɛm/', '<span>This</span><span>year</span><span>they</span><span>really</span><span>have</span><span>their</span><span pid="503" class="highlight highlight-i">work cut out for them</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 2, 9.59, 12.35, 'The action unfolds in "Avengers, End Game."', '故事发生在《复仇者联盟4：终局之战》中。', '/ði ˈækʃən ənˈfəʊldz ɪn ˈævəndʒərz ɛnd ɡeɪm/', '<span>The</span><span tid="50005" class="highlight highlight-a">action</span><span tid="50006" class="highlight highlight-a">unfolds</span><span>in</span><span>"Avengers, End Game."</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 3, 12.35, 14.24, 'It opens April 26.', '它于4月26日上映。', '/ɪt ˈoʊpənz ˈeɪprəl ˈtwɛnti sɪks/', '<span>It</span><span tid="50007" class="highlight highlight-a">opens</span><span>April</span><span>26</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 4, 14.24, 19.34, 'Please welcome Robert Downey Jr, Chris Hemsworth, Scarlett Johansson, and Paul Rudd!', '请欢迎小罗伯特·唐尼、克里斯·海姆斯沃斯、斯嘉丽·约翰逊和保罗·路德！', '/pliːz ˈwɛlkəm ˈrɑːbərt ˈdaʊni dʒuːnjər krɪs ˈhɛmzwɜːrθ skɑːrˈlɛt ˈdʒɑːnsən ænd pɔːl rʌd/', '<span>Please</span><span tid="50008" class="highlight highlight-a">welcome</span><span>Robert Downey Jr</span><span>,</span><span>Chris Hemsworth</span><span>,</span><span>Scarlett Johansson</span><span>,</span><span>and</span><span>Paul Rudd</span><span>!</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 5, 19.34, 21.835, '[APPLAUSE]', '[掌声]', '/əˈplɔːz/', '<span>[APPLAUSE]</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 6, 41.795, 42.793, 'Welcome.', '欢迎。', '/ˈwɛlkəm/', '<span>Welcome</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 7, 42.793, 43.791, 'Look at you guys.', '看看你们。', '/lʊk æt juː ɡaɪz/', '<span pid="504" class="highlight highlight-d">Look at</span><span>you</span><span>guys</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 8, 43.791, 46.286, '[APPLAUSE]', '[掌声]', '/əˈplɔz/', '<span>[APPLAUSE]</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 9, 49.779, 52.274, 'Very nice.', '非常棒。', '/ˈvɛri ˈnaɪs/', '<span>Very</span><span>nice.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 10, 52.274, 54.27, 'You all look fantastic.', '你们看起来都很棒。', '/ju ɔːl lʊk fænˈtæstɪk/', '<span>You</span><span>all</span><span>look</span><span tid="50009" class="highlight highlight-a">fantastic.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 11, 60.757, 61.755, 'Ugh.', '呃。', '/ʌɡ/', '<span>Ugh.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 12, 61.755, 63.751, 'They can''t get enough.', '他们怎么都听不够。', '/ðeɪ kænt ɡɛt ɪˈnʌf/', '<span>They</span><span>can''t</span><span>get</span><span tid="50010" class="highlight highlight-i">enough.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 13, 63.751, 65.747, 'And in a way-- Wow.', '从某种意义上说——哇。', '/ænd ɪn ə weɪ— waʊ/', '<span>And</span><span>in</span><span>a</span><span tid="50011" class="highlight highlight-c">way--</span><span>Wow.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 14, 65.747, 67.78, 'Feels like home.', '感觉像家一样。', '/filz laɪk hoʊm/', '<span>Feels</span><span>like</span><span tid="50012" class="highlight highlight-i">home.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 15, 67.78, 74.768, 'I feel like this is-- this might-- [CHEERING] This might be it. Right?', '我觉得这可能是——这可能会——[欢呼] 这可能就是它了。对吧？', '/aɪ fil laɪk ðɪs ɪz— ðɪs maɪt— ðɪs maɪt bi ɪt. raɪt/', '<span>I</span><span>feel</span><span>like</span><span>this</span><span>is--</span><span>this</span><span>might--</span><span>[CHEERING]</span><span>This</span><span>might</span><span>be</span><span tid="50013" class="highlight highlight-i">it.</span><span>Right?</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 16, 74.768, 75.81, 'I mean, this could be it.', '我是说，这可能就是它了。', '/aɪ miːn, ðɪs kʊd biː ɪt/', '<span>I</span><span tid="50014" class="highlight highlight-a">mean</span><span>,</span><span>this</span><span>could</span><span>be</span><span>it</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 17, 75.81, 77.81, 'This could be the last one.', '这可能是最后一个了。', '/ðɪs kʊd biː ðə læst wʌn/', '<span>This</span><span>could</span><span>be</span><span>the</span><span tid="50015" class="highlight highlight-a">last</span><span>one</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 18, 77.81, 80.25, 'This probably is the last one.', '这很可能就是最后一个了。', '/ðɪs ˈprɑːbəbli ɪz ðə læst wʌn/', '<span>This</span><span tid="50016" class="highlight highlight-a">probably</span><span>is</span><span>the</span><span tid="50017" class="highlight highlight-a">last</span><span>one</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 19, 80.25, 81.615, 'On your show? JIMMY KIMMEL: No.', '在你的节目上？吉米·坎摩尔：不。', '/ɑːn jɔːr ʃoʊ? ˈdʒɪmi ˈkɪməl: noʊ/', '<span>On</span><span>your</span><span>show</span><span>?</span><span>JIMMY</span><span>KIMMEL</span><span>:</span><span>No</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 20, 81.615, 82.515, 'No.', '不。', '/noʊ/', '<span>No</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 21, 82.515, 83.845, 'No.', '不。', '/noʊ/', '<span>No</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 22, 83.845, 85.47, 'Just for them, Paul, you can come back.', '只是为了他们，保罗，你可以回来。', '/dʒʌst fɔːr ðɛm, pɔːl, juː kæn kʌm bæk/', '<span>Just</span><span>for</span><span>them</span><span>,</span><span>Paul</span><span>,</span><span>you</span><span>can</span><span pid="505" class="highlight highlight-d">come back</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 23, 85.47, 86.03, 'Yes. - OK.', '是的。- 好的。', '/jɛs. - oʊˈkeɪ/', '<span>Yes</span><span>.</span><span>-</span><span>OK</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 24, 86.03, 86.55, 'Good. - No.', '好的。 - 不。', '/ɡʊd | noʊ/', '<span>Good.</span><span>-</span><span>No.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 25, 86.55, 91.81, 'I feel like this is the last gathering of the Avengers on the show.', '我觉得这是复仇者联盟在节目上的最后一次聚会。', '/aɪ fiːl laɪk ðɪs ɪz ðə læst ˈɡæðərɪŋ əv ði əˈvendʒərz ɑn ðə ʃoʊ/', '<span>I</span><span pid="506" class="highlight highlight-d">feel like</span><span>this</span><span>is</span><span>the</span><span>last</span><span tid="50018" class="highlight highlight-a">gathering</span><span>of</span><span>the</span><span tid="50019" class="highlight highlight-a">Avengers</span><span>on</span><span>the</span><span>show.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 26, 91.81, 93.42, 'The future''s very uncertain. JIMMY KIMMEL: It is?', '未来非常不确定。吉米·坎摩尔：是吗？', '/ðə ˈfjuːtʃərz ˈvɛri ʌnˈsɜːrtn | ˈdʒɪmi ˈkɪməl: ɪt ɪz/', '<span>The</span><span>future''s</span><span>very</span><span tid="50020" class="highlight highlight-a">uncertain.</span><span>JIMMY KIMMEL:</span><span>It</span><span>is?</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 27, 93.42, 94.92, 'Oh, good. I''m glad to hear that.', '哦，好的。我很高兴听到这个。', '/oʊ ɡʊd | aɪm ɡlæd tə hɪr ðæt/', '<span>Oh,</span><span>good.</span><span>I''m</span><span tid="50021" class="highlight highlight-a">glad</span><span>to</span><span>hear</span><span>that.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 28, 94.92, 95.82, 'Yeah.', '是的。', '/jɛə/', '<span>Yeah.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 29, 95.82, 98.91, 'You know, it was May 5, 2008 that you were here.', '你知道吗，那是2008年5月5日你在这里的时候。', '/ju noʊ | ɪt wəz meɪ faɪv tuː ˈθaʊzənd eɪt ðæt ju wər hɪr/', '<span>You</span><span>know,</span><span>it</span><span>was</span><span>May</span><span>5,</span><span>2008</span><span>that</span><span>you</span><span>were</span><span>here.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 30, 98.91, 100.178, '- Oh, wow. - Don''t lie to him.', '- 哦，哇。 - 别骗他。', '/oʊ wɑ | doʊnt laɪ tə hɪm/', '<span>-</span><span>Oh,</span><span>wow.</span><span>-</span><span>Don''t</span><span tid="50022" class="highlight highlight-a">lie</span><span>to</span><span>him.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 31, 100.178, 102.845, 'We''re not going to ever-- JIMMY KIMMEL: You''re never coming back?', '我们永远不会——吉米·坎摩尔：你再也不回来了？', '/wi ɑrnt ˈɡoʊɪŋ tə ˈɛvər | ˈdʒɪmi ˈkɪməl: jər ˈnɛvər ˈkʌmɪŋ bæk/', '<span>We''re</span><span>not</span><span>going</span><span>to</span><span>ever--</span><span>JIMMY KIMMEL:</span><span>You''re</span><span>never</span><span>coming</span><span>back?</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 32, 102.845, 111.57, '[LAUGHING] I remember Jon Favreau showing me the sketches of "Iron Man," and that he was working on, and thinking,', '[笑] 我记得乔恩·费儒给我看《钢铁侠》的草图，他正在做那些，我想，', '/læfɪŋ aɪ rɪˈmɛmbər dʒɑn ˈfɛvroʊ ˈʃoʊɪŋ mi ðə skɛʧɪz əv ˈaɪərn mæn ænd ðæt hi wəz ˈwɜːrkɪŋ ɑn ænd ˈθɪŋkɪŋ/', '<span>[LAUGHING]</span><span>I</span><span tid="50023" class="highlight highlight-a">remember</span><span>Jon Favreau</span><span tid="50024" class="highlight highlight-a">showing</span><span>me</span><span>the</span><span tid="50025" class="highlight highlight-a">sketches</span><span>of</span><span>"Iron Man,"</span><span>and</span><span>that</span><span>he</span><span>was</span><span pid="507" class="highlight highlight-d">working on,</span><span>and</span><span tid="50026" class="highlight highlight-a">thinking,</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 33, 111.57, 116.61, 'what an interesting character to start with, you know, from the Marvel universe.', '从漫威宇宙开始，这是一个多么有趣的角色啊。', '/wʌt ən ˈɪntrəstɪŋ ˈkærɪktər tə stɑːrt wɪð ju noʊ frəm ðə ˈmɑːrvel ˈjuːnɪvɜːrs/', '<span>what</span><span>an</span><span tid="50027" class="highlight highlight-a">interesting</span><span tid="50028" class="highlight highlight-a">character</span><span>to</span><span pid="508" class="highlight highlight-d">start with,</span><span pid="509" class="highlight highlight-i">you know,</span><span>from</span><span>the</span><span>Marvel</span><span tid="50029" class="highlight highlight-a">universe.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 34, 116.61, 119.16, 'And here we are, like 21 movies later.', '而现在，我们已经有21部电影了。', '/ænd hɪr wi ɑr laɪk ˈtwɛnti wʌn ˈmuːviz ˈleɪtər/', '<span>And</span><span pid="510" class="highlight highlight-i">here we are,</span><span>like</span><span>21</span><span>movies</span><span>later.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 35, 119.16, 120.06, 'Yeah.', '是啊。', '/jeɪ/', '<span>Yeah.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 36, 120.06, 121.264, 'It really is amazing.', '真的很了不起。', '/ɪt ˈrɪli ɪz əˈmeɪzɪŋ/', '<span>It</span><span>really</span><span>is</span><span tid="50030" class="highlight highlight-a">amazing.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 37, 121.264, 124.168, '[APPLAUSE] JIMMY KIMMEL: 21 movies.', '[掌声] 吉米·坎摩尔：21部电影。', '/əˈplɔz ˈdʒɪmi ˈkɪməl ˈtwɛnti wʌn ˈmuːviz/', '<span>[APPLAUSE]</span><span>JIMMY KIMMEL:</span><span>21</span><span>movies.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 38, 127.556, 132.76, '[CHUCKLING] Have you guys seen the new movie?', '[轻笑] 你们看过新电影了吗？', '/hæv ˈɛni əv ju siːn ðə nuː ˈmuːvi/', '<span>[CHUCKLING]</span><span>Have</span><span>you</span><span>guys</span><span tid="50031" class="highlight highlight-a">seen</span><span>the</span><span>new</span><span>movie?</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 39, 132.76, 133.76, 'Have any of you seen it?', '你们有人看过吗？', '/hæv ˈɛni əv ju siːn ɪt/', '<span>Have</span><span>any</span><span>of</span><span>you</span><span tid="50032" class="highlight highlight-a">seen</span><span>it?</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 40, 133.76, 135.77, 'No.', '不。', '/noʊ/', '<span>No.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 41, 135.77, 136.67, 'Not really.', '不太算。', '/nɑt ˈrɪli/', '<span>Not</span><span>really.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 42, 136.67, 137.832, 'No. - No.', '不——不。', '/noʊ - noʊ/', '<span>No.</span><span>-</span><span>No.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 43, 137.832, 139.31, 'JIMMY KIMMEL: Did you see it? - I did.', 'JIMMY KIMMEL: 你看到了吗？——我看到了。', '/ˈdʒɪmi ˈkɪməl: dɪd ju si ɪt? - aɪ dɪd/', '<span>JIMMY</span><span>KIMMEL:</span><span>Did</span><span>you</span><span tid="50033" class="highlight highlight-a">see</span><span>it?</span><span>-</span><span>I</span><span>did.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 44, 139.31, 141.328, 'I saw it and I filmed it on my iPhone.', '我看到了，而且我用我的iPhone拍了视频。', '/aɪ sɔːr ɪt ænd aɪ fɪlmd ɪt ɑn maɪ ˈaɪfoʊn/', '<span>I</span><span>saw</span><span>it</span><span>and</span><span>I</span><span tid="50034" class="highlight highlight-a">filmed</span><span>it</span><span>on</span><span>my</span><span>iPhone.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 45, 141.328, 143.62, 'And I''m going to be screening it on my Instagram later.', '我稍后会在我的Instagram上播放它。', '/ænd aɪm ˈɡoʊɪŋ tə bi ˈskriːnɪŋ ɪt ɑn maɪ ˈɪnstəɡræm ˈleɪtər/', '<span>And</span><span>I''m</span><span>going</span><span>to</span><span>be</span><span tid="50035" class="highlight highlight-a">screening</span><span>it</span><span>on</span><span>my</span><span>Instagram</span><span>later.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 46, 143.62, 144.54, 'JIMMY KIMMEL: Oh, great. ROBERT DOWNEY JR: Aw.', 'JIMMY KIMMEL: 哦，太好了。ROBERT DOWNEY JR: 啊。', '/ˈdʒɪmi ˈkɪməl: oʊ ɡreɪt. ˈrɑbərt ˈdaʊni ˈdʒuːnjər: ɔː/', '<span>JIMMY</span><span>KIMMEL:</span><span>Oh,</span><span>great.</span><span>ROBERT</span><span>DOWNEY</span><span>JR:</span><span>Aw.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 47, 144.54, 145.548, 'So sweet.', '太贴心了。', '/soʊ swiːt/', '<span>So</span><span>sweet.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 48, 145.548, 148.48, '[INAUDIBLE], like that guy.', '听不清，就像那个家伙。', '/ɪnˈɔːdəbəl laɪk ðæt ɡaɪ/', '<span>[INAUDIBLE],</span><span>like</span><span>that</span><span>guy.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 49, 148.48, 149.38, 'Yeah.', '是的。', '/jɛə/', '<span>Yeah</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 50, 149.38, 151.23, 'There''s kind of a-- you know, we''re not supposed to see it.', '有点——你知道，我们不应该看到它。', '/ðɛrz kaɪnd əv ə ju noʊ wɪr nɑt səˈpoʊzd tə si ɪt/', '<span>There''s</span><span pid="511" class="highlight highlight-i">kind of</span><span>a--</span><span pid="512" class="highlight highlight-i">you know</span><span>,</span><span>we''re</span><span>not</span><span pid="513" class="highlight highlight-d">supposed to</span><span>see</span><span>it</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 51, 151.23, 152.647, 'And they''re showing little pieces.', '他们正在展示一些小片段。', '/ənd ðɛr ˈʃoʊɪŋ ˈlɪtəl ˈpiːsɪz/', '<span>And</span><span>they''re</span><span tid="50036" class="highlight highlight-a">showing</span><span>little</span><span>pieces</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 52, 152.647, 155.69, 'But then I''m doing an Easter screening.', '但后来我在做复活节放映。', '/bʌt ðɛn aɪm ˈduːɪŋ ən ˈiːstər ˈskriːnɪŋ/', '<span>But</span><span>then</span><span>I''m</span><span>doing</span><span>an</span><span tid="50037" class="highlight highlight-a">Easter</span><span tid="50038" class="highlight highlight-a">screening</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 53, 155.69, 156.59, 'JIMMY KIMMEL: Easter?', '吉米·坎摩尔：复活节？', '/ˈdʒɪmi ˈkɪməl ˈiːstər/', '<span>JIMMY KIMMEL</span><span>:</span><span tid="50039" class="highlight highlight-a">Easter</span><span>?</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 54, 156.59, 157.89, 'On Easter Sunday? - Yep.', '在复活节星期天？——是的。', '/ɑn ˈiːstər ˈsʌndeɪ jɛp/', '<span>On</span><span tid="50040" class="highlight highlight-a">Easter</span><span>Sunday</span><span>?</span><span>-</span><span>Yep</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 55, 157.89, 159.93, 'Up in Malibu, the day before the premiere.', '在马里布，首映前一天。', '/ʌp ɪn ˈmælɪbuː ðə deɪ bɪˈfɔr ðə prɪˈmɪr/', '<span>Up</span><span>in</span><span>Malibu</span><span>,</span><span>the</span><span>day</span><span>before</span><span>the</span><span tid="50041" class="highlight highlight-a">premiere</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 56, 159.93, 161.11, 'We''ll have it on a loop.', '我们会循环播放。', '/wiːl hæv ɪt ɑːn ə luːp/', '<span>We''ll</span><span>have</span><span>it</span><span>on</span><span>a</span><span tid="50042" class="highlight highlight-c">loop.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 57, 161.11, 162.48, '- Oh, in your house? - Yeah.', '- 哦，在你家？ - 是的。', '/oʊ ɪn jɔːr haʊs jɛə/', '<span>-</span><span>Oh,</span><span>in</span><span>your</span><span>house?</span><span>-</span><span>Yeah.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 58, 162.48, 163.86, 'This is not a-- - You guys are all invited.', '这不是——你们都被邀请了。', '/ðɪs ɪz nɑːt ə juː ɡaɪz ɑːr ɔːl ɪnˈvaɪtɪd/', '<span>This</span><span>is</span><span>not</span><span>a--</span><span>-</span><span>You</span><span>guys</span><span>are</span><span>all</span><span tid="50043" class="highlight highlight-a">invited.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 59, 163.86, 165.235, 'This is not an open invitation.', '这不是一个公开的邀请。', '/ðɪs ɪz nɑːt ən ˈoʊpən ɪnˈvaɪˈteɪʃən/', '<span>This</span><span>is</span><span>not</span><span>an</span><span tid="50044" class="highlight highlight-a">open</span><span tid="50045" class="highlight highlight-a">invitation.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 60, 165.235, 169.874, '[APPLAUSE] What''s the address?', '[掌声] 地址是什么？', '/əˈplɔːz wʌts ði ˈædrəs/', '<span>[APPLAUSE]</span><span>What''s</span><span>the</span><span tid="50046" class="highlight highlight-a">address?</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 61, 169.874, 171.865, 'What''s the address and gate code?', '地址和门禁密码是什么？', '/wʌts ði ˈædrəs ænd ɡeɪt koʊd/', '<span>What''s</span><span>the</span><span>address</span><span>and</span><span tid="50047" class="highlight highlight-a">gate</span><span tid="50048" class="highlight highlight-a">code?</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 62, 171.865, 174.07, 'Can you tell us the gate code and address?', '你能告诉我们门禁密码和地址吗？', '/kæn juː tɛl ʌs ðə ɡeɪt koʊd ænd ˈædrəs/', '<span>Can</span><span>you</span><span>tell</span><span>us</span><span>the</span><span>gate</span><span>code</span><span>and</span><span>address?</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 63, 174.07, 177.61, 'That is-- Easter Sunday is what?', '那是——复活节星期天是什么？', '/ðæt ɪz ˈiːstər ˈsʌndeɪ wʌt/', '<span>That</span><span>is--</span><span tid="50049" class="highlight highlight-a">Easter</span><span>Sunday</span><span>is</span><span>what?</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 64, 177.61, 178.65, 'The 21st.', '21号。', '/ðə ˈtwɛnti fɜːrst/', '<span>The</span><span tid="50050" class="highlight highlight-a">21st.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 65, 178.65, 179.68, '21st. Yes, sir.', '21号。是的，先生。', '/ˈtwɛnti fɜːrst jɛs sɜːr/', '<span tid="50051" class="highlight highlight-a">21st.</span><span>Yes</span><span>,</span><span>sir.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 66, 179.68, 180.58, 'The 21st.', '21号。', '/ðə ˈtwɛnti fɜːrst/', '<span>The</span><span tid="50052" class="highlight highlight-a">21st.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 67, 180.58, 182.71, 'So it will be a couple of days before the opening.', '所以离上映还有几天。', '/soʊ ɪt wɪl biː ə ˈkʌpəl əv deɪz bɪˈfɔːr ði ˈoʊpənɪŋ/', '<span>So</span><span>it</span><span>will be</span><span pid="514" class="highlight highlight-c">a couple of</span><span>days</span><span>before</span><span>the</span><span tid="50053" class="highlight highlight-a">opening.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 68, 182.71, 183.1, 'That''s correct.', '没错。', '/ðæts kəˈrɛkt/', '<span>That''s</span><span>correct.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 69, 183.1, 185.92, 'JIMMY KIMMEL: So people who come to your house, not only will they get eggs.', '吉米·坎摩尔：所以来你家的人，不仅能得到鸡蛋。', '/ˈdʒɪmi ˈkɪməl soʊ ˈpiːpəl huː kʌm tuː jɔːr haʊs nɑːt ˈoʊnli wɪl ðeɪ gɛt ɛɡz/', '<span>JIMMY</span><span>KIMMEL:</span><span>So</span><span>people</span><span>who</span><span pid="515" class="highlight highlight-d">come to</span><span>your</span><span>house</span><span>,</span><span pid="516" class="highlight highlight-c">not only</span><span>will</span><span>they</span><span>get</span><span>eggs.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 70, 185.92, 188.32, 'They will also be able to see the "Avengers" movie.', '他们还能看到《复仇者联盟》电影。', '/ðeɪ wɪl ˈɔːlsoʊ biː ˈeɪbəl tuː siː ði ˈævəndʒərz ˈmuːvi/', '<span>They</span><span>will also</span><span pid="517" class="highlight highlight-d">be able to</span><span>see</span><span>the</span><span tid="50054" class="highlight highlight-a">"Avengers"</span><span>movie.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 71, 188.32, 189.22, 'That''s right.', '没错。', '/ðæts raɪt/', '<span>That''s</span><span>right.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 72, 189.22, 190.12, 'Oh, my god.', '哦，我的天哪。', '/oʊ maɪ gɑd/', '<span>Oh,</span><span>my</span><span>god.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 73, 190.12, 192.31, 'We have to sign NDAs or do gag orders or something.', '我们必须签署保密协议或禁言令之类的。', '/wi hæv tə saɪn ɛn di eɪz ɔr du gæg ˈɔrdərz ɔr ˈsʌmθɪŋ/', '<span>We</span><span>have</span><span>to</span><span>sign</span><span>NDAs</span><span>or</span><span>do</span><span>gag</span><span>orders</span><span>or</span><span>something.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 74, 192.31, 193.24, 'You sure do.', '你确实如此。', '/ju ʃʊr du/', '<span>You</span><span>sure</span><span>do.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 75, 193.24, 194.19, 'Absolutely.', '当然。', '/ˈæbsəˌlutli/', '<span>Absolutely.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 76, 194.19, 195.25, 'Thanks for that, Jimmy.', '谢谢，吉米。', '/θæŋks fɔr ðæt ˈdʒɪmi/', '<span>Thanks</span><span>for</span><span>that,</span><span>Jimmy.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 77, 195.25, 197.32, 'A 3 hour and 2 minute long film.', '一部3小时2分钟长的电影。', '/ə θri aʊər ænd tu mɪnɪt lɔŋ fɪlm/', '<span>A</span><span>3</span><span>hour</span><span>and</span><span>2</span><span>minute</span><span>long</span><span>film.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 78, 197.32, 199.73, 'So you might only get to show it a couple of times.', '所以你也许只能放映几次。', '/soʊ ju maɪt oʊnli ɡɛt tə ʃoʊ ɪt ə ˈkʌpəl əv taɪmz/', '<span>So</span><span>you</span><span>might</span><span>only</span><span>get</span><span>to</span><span>show</span><span>it</span><span>a</span><span>couple</span><span>of</span><span>times.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 79, 199.73, 200.98, 'Right. No intermission.', '对。没有中场休息。', '/raɪt noʊ ˌɪntərˈmɪʃən/', '<span>Right.</span><span>No</span><span>intermission.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 80, 200.98, 202.17, 'JIMMY KIMMEL: With no intermission.', '吉米·坎摩尔：没有中场休息。', '/dʒɪmi ˈkɪməl wɪð noʊ ˌɪntərˈmɪʃən/', '<span>JIMMY KIMMEL:</span><span>With</span><span>no</span><span tid="50055" class="highlight highlight-a">intermission.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 81, 202.17, 203.11, 'No. - Wait.', '不。 - 等等。', '/noʊ weɪt/', '<span>No.</span><span>-</span><span>Wait.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 82, 203.11, 204.775, 'Why would he show it a couple of times?', '他为什么要放好几次？', '/waɪ wʊd hi ˈʃoʊ ɪt ə ˈkaɪpəl əv taɪmz/', '<span>Why</span><span>would</span><span>he</span><span>show</span><span>it</span><span pid="518" class="highlight highlight-c">a couple of</span><span>times?</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 83, 204.775, 206.09, 'Well, he''s said he''s showing it on a loop.', '嗯，他说他在循环播放。', '/wɛl hiz sɛd hiz ˈʃoʊɪŋ ɪt ɑn ə lup/', '<span>Well,</span><span>he''s</span><span>said</span><span>he''s</span><span>showing</span><span>it</span><span pid="519" class="highlight highlight-i">on a loop.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 84, 206.09, 207.38, '- On a loop? - Yeah.', '- 循环播放？ - 是的。', '/ɑn ə lup jɛə/', '<span>-</span><span pid="520" class="highlight highlight-i">On a loop?</span><span>-</span><span>Yeah.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 85, 207.38, 208.7, 'Well, that''s a long brunch. JIMMY KIMMEL: Yeah.', '嗯，那可真是一顿漫长的早午餐。吉米·坎摩尔：是啊。', '/wɛl ðæts ə lɔŋ brʌntʃ dʒɪmi ˈkɪməl jɛə/', '<span>Well,</span><span>that''s</span><span>a long</span><span tid="50056" class="highlight highlight-a">brunch.</span><span>JIMMY KIMMEL:</span><span>Yeah.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 86, 208.7, 210.182, 'That is quite a brunch.', '那可真是一顿丰盛的早午餐。', '/ðæt ɪz kwaɪt ə brʌntʃ/', '<span>That</span><span>is</span><span pid="521" class="highlight highlight-c">quite a</span><span tid="50057" class="highlight highlight-a">brunch.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 87, 210.182, 213.288, 'I mean, we can fast forward through the dumb stuff.', '我的意思是，我们可以快进跳过那些无聊的部分。', '/aɪ min wi kən fæst ˈfɔrwərd θruː ðə dʌm stʌf/', '<span>I mean,</span><span>we</span><span>can</span><span pid="522" class="highlight highlight-d">fast forward</span><span>through</span><span>the</span><span>dumb</span><span>stuff.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 88, 213.288, 216.272, '[LAUGHING] - What''s the dumb stuff? - Yeah.', '[笑] - 那些蠢事是什么？ - 是啊。', '/læfɪŋ wʌts ðə dʌm stʌf jɛə/', '<span>[LAUGHING]</span><span>-</span><span>What''s</span><span>the</span><span tid="50058" class="highlight highlight-a">dumb</span><span>stuff?</span><span>-</span><span>Yeah.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 89, 216.272, 217.84, 'What is the dumb stuff? - I don''t know.', '那些蠢事是什么？ - 我不知道。', '/wʌt ɪz ðə dʌm stʌf aɪ doʊnt noʊ/', '<span>What</span><span>is</span><span>the</span><span tid="50059" class="highlight highlight-a">dumb</span><span>stuff?</span><span>-</span><span>I</span><span>don''t</span><span>know.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 90, 217.84, 219.728, 'Probably like, you know, your character arc.', '可能就像，你知道，你的角色弧线。', '/ˈprɑbəbli laɪk ju noʊ jɔr ˈkærəktər ɑːrk/', '<span>Probably</span><span>like,</span><span>you</span><span>know,</span><span>your</span><span tid="50060" class="highlight highlight-a">character</span><span tid="50061" class="highlight highlight-a">arc.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 91, 219.728, 224.51, '[CROWD BOOS] Woo.', '[人群发出嘘声] 呜。', '/kraʊd buz wuː/', '<span>[CROWD</span><span>BOOS]</span><span>Woo.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 92, 224.51, 225.87, 'That''s the game changer.', '那是改变游戏规则的东西。', '/ðæts ðə ɡeɪm ˈtʃeɪndʒər/', '<span>That''s</span><span>the</span><span tid="50062" class="highlight highlight-a">game</span><span tid="50063" class="highlight highlight-a">changer.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 93, 225.87, 226.52, 'I''ll get you back for that one.', '我会为那个报复你的。', '/aɪl ɡɛt ju bæk fɔr ðæt wʌn/', '<span>I''ll</span><span>get</span><span>you</span><span>back</span><span>for</span><span>that</span><span>one.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 94, 226.52, 227.627, 'That I can''t wait for.', '那个我等不及了。', '/ðæt aɪ kænt weɪt fɔr/', '<span>That</span><span>I</span><span>can''t</span><span>wait</span><span>for.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 95, 227.627, 229.21, 'JIMMY KIMMEL: It''s a three hour movie.', '吉米·坎摩尔：这是一部三个小时的电影。', '/ˈdʒɪmi ˈkɪməl ɪts ə θri aʊər ˈmuːvi/', '<span>JIMMY</span><span>KIMMEL:</span><span>It''s</span><span>a</span><span>three</span><span>hour</span><span>movie.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 96, 229.21, 231.88, 'What''s-- I know you can''t reveal any of the plot details.', '什么——我知道你不能透露任何剧情细节。', '/wʌts aɪ noʊ juː kænt rɪˈviːl ˈɛni əv ðə plɑːt dɪˈteɪlz/', '<span>What''s--</span><span>I</span><span tid="50064" class="highlight highlight-a">know</span><span>you</span><span>can''t</span><span tid="50065" class="highlight highlight-a">reveal</span><span>any</span><span>of</span><span>the</span><span tid="50066" class="highlight highlight-a">plot</span><span>details.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 97, 231.88, 234.31, 'But what''s the best time to get up and go to the bathroom?', '但什么时候是起身去洗手间的最佳时机？', '/bʌt wʌts ðə bɛst taɪm tuː gɛt ʌp ænd goʊ tuː ðə ˈbæθruːm/', '<span>But</span><span>what''s</span><span>the</span><span tid="50067" class="highlight highlight-a">best</span><span>time</span><span>to</span><span pid="523" class="highlight highlight-d">get up</span><span>and</span><span>go</span><span>to</span><span>the</span><span>bathroom?</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 98, 234.31, 238.36, 'Because you do that thing in the movies where your race to the bathroom.', '因为你在电影里会做那种冲向洗手间的事。', '/bɪˈkɔːz juː duː ðæt θɪŋ ɪn ðə ˈmuːviz wɛr jɔːr reɪs tuː ðə ˈbæθruːm/', '<span>Because</span><span>you</span><span>do</span><span>that</span><span>thing</span><span>in</span><span>the</span><span>movies</span><span>where</span><span>your</span><span tid="50068" class="highlight highlight-a">race</span><span>to</span><span>the</span><span>bathroom.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 99, 238.36, 240.26, 'Is there a part that we should know?', '有没有一个我们应该知道的部分？', '/ɪz ðɛr ə pɑːrt ðæt wiː ʃʊd noʊ/', '<span>Is</span><span>there</span><span>a</span><span>part</span><span>that</span><span>we</span><span>should</span><span>know?</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 100, 240.26, 243.332, 'Well, Mark said that you should wear a diaper.', '嗯，马克说你应该穿尿布。', '/wɛl mɑːrk sɛd ðæt juː ʃʊd wɛr ə ˈdaɪpər/', '<span>Well,</span><span>Mark</span><span>said</span><span>that</span><span>you</span><span>should</span><span tid="50069" class="highlight highlight-a">wear</span><span>a</span><span tid="50070" class="highlight highlight-a">diaper.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 101, 243.332, 244.54, 'And you don''t have to get up.', '而且你不需要起身。', '/ænd juː doʊnt hæv tuː gɛt ʌp/', '<span>And</span><span>you</span><span>don''t</span><span>have</span><span>to</span><span pid="524" class="highlight highlight-d">get up.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 102, 244.54, 245.83, 'JIMMY KIMMEL: Well, that''s not a bad idea.', '吉米·坎摩尔：嗯，这主意不错。', '/ˈdʒɪmi ˈkɪməl wɛl ðæts nɑːt ə bæd aɪˈdiːə/', '<span>JIMMY</span><span>KIMMEL:</span><span>Well,</span><span>that''s</span><span>not</span><span>a</span><span tid="50071" class="highlight highlight-a">bad</span><span>idea.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 103, 245.83, 246.75, 'But you''re also sitting in your own urine.', '但你也坐在自己的尿液里。', '/bʌt jʊər ˈɔːlsoʊ ˈsɪtɪŋ ɪn jʊər oʊn ˈjʊrɪn/', '<span>But</span><span>you''re</span><span>also</span><span tid="50072" class="highlight highlight-a">sitting</span><span>in</span><span>your</span><span>own</span><span tid="50073" class="highlight highlight-a">urine.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 104, 246.75, 248.06, 'So-- JIMMY KIMMEL: Yeah.', '所以——吉米·坎摩尔：是的。', '/soʊ dʒɪmi ˈkɪməl jɛə/', '<span>So--</span><span>JIMMY</span><span>KIMMEL:</span><span>Yeah.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 105, 248.06, 250.5, 'Well, that is a bad idea.', '嗯，那是个坏主意。', '/wɛl ðæt ɪz ə bæd aɪˈdiə/', '<span>Well,</span><span>that</span><span>is</span><span>a</span><span tid="50074" class="highlight highlight-a">bad</span><span>idea.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 106, 250.5, 251.83, 'Best time, Paul?', '最佳时间，保罗？', '/bɛst taɪm pɔl/', '<span tid="50075" class="highlight highlight-a">Best</span><span>time,</span><span>Paul?</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 107, 251.83, 253.512, 'Oh, boy.', '哦，天哪。', '/oʊ bɔɪ/', '<span>Oh,</span><span>boy.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 108, 253.512, 264.17, 'Well, not having seen the film-- [LAUGHTER] I would say get one of those giant tubs of popcorn.', '嗯，没看过电影——[笑声] 我会说买一桶那种巨大的爆米花。', '/wɛl nɑt ˈhævɪŋ sin ðə fɪlm ˈlæftər aɪ wʊd seɪ ɡɛt wʌn əv ðoʊz ˈdʒaɪənt tʌbz əv ˈpɑpkɔrn/', '<span>Well,</span><span>not</span><span>having</span><span tid="50076" class="highlight highlight-a">seen</span><span>the</span><span>film--</span><span>[LAUGHTER]</span><span>I</span><span>would</span><span>say</span><span>get</span><span>one</span><span>of</span><span>those</span><span tid="50077" class="highlight highlight-a">giant</span><span tid="50078" class="highlight highlight-a">tubs</span><span>of</span><span>popcorn.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 109, 264.17, 265.665, 'JIMMY KIMMEL: Yeah?', '吉米·坎摩尔：是吗？', '/dʒɪmi ˈkɪməl jɛə/', '<span>JIMMY</span><span>KIMMEL:</span><span>Yeah?</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 110, 265.665, 267.54, 'And then just like lower it under the seat?', '然后就像把它放到座位下面？', '/ænd ðɛn dʒʌst laɪk ˈloʊər ɪt ˈʌndər ðə sit/', '<span>And</span><span>then</span><span>just</span><span>like</span><span tid="50079" class="highlight highlight-a">lower</span><span>it</span><span>under</span><span>the</span><span>seat?</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 111, 267.54, 268.81, 'JIMMY KIMMEL: Make the most of it?', '吉米·坎摩尔：充分利用它？', '/dʒɪmi ˈkɪməl meɪk ðə moʊst əv ɪt/', '<span>JIMMY</span><span>KIMMEL:</span><span>Make</span><span>the</span><span>most</span><span>of</span><span>it?</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 112, 268.81, 271.102, 'In the middle of the movie, and then you don''t have to get up.', '在电影中间，然后你就不必站起来了。', '/ɪn ðə ˈmɪdəl əv ðə ˈmuvi, ænd ðɛn ju doʊnt hæv tə gɛt ʌp./', '<span pid="525" class="highlight highlight-c">In the middle of</span><span>the</span><span>movie</span><span>,</span><span>and</span><span>then</span><span>you</span><span pid="526" class="highlight highlight-d">don''t have to</span><span pid="527" class="highlight highlight-d">get up</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 113, 271.102, 274.25, 'It''s so efficient.', '这太高效了。', '/ɪts soʊ ɪˈfɪʃənt./', '<span>It''s</span><span>so</span><span tid="50080" class="highlight highlight-a">efficient</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 114, 274.25, 276.5, 'Who has the Avengers tattoo?', '谁有复仇者联盟的纹身？', '/hu hæz ði æˈvɛndʒərz ˈtætuː?/', '<span>Who</span><span>has</span><span>the</span><span tid="50081" class="highlight highlight-a">Avengers</span><span>tattoo</span><span>?</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 115, 276.5, 277.55, 'You guys have it. - Yep.', '你们有。- 是的。', '/ju gʌz hæv ɪt. - jɛp./', '<span>You</span><span>guys</span><span>have</span><span>it</span><span>.</span><span>-</span><span>Yep</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 116, 277.55, 279.11, 'Right? Does Chris have it?', '对吧？克里斯有吗？', '/raɪt? dʌz krɪs hæv ɪt?/', '<span>Right</span><span>?</span><span>Does</span><span>Chris</span><span>have</span><span>it</span><span>?</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 117, 279.11, 282.368, 'I have a scratch and sniff of Paul Rudd''s face.', '我有一个保罗·路德脸的刮擦和嗅探贴纸。', '/aɪ hæv ə skrætʃ ənd snɪf əv pɔːl rʌdz feɪs./', '<span>I</span><span>have</span><span>a</span><span pid="528" class="highlight highlight-i">scratch and sniff</span><span>of</span><span>Paul Rudd''s</span><span>face</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 118, 282.368, 287.59, '[APPLAUSE] And it smells delicious.', '[掌声] 而且它闻起来很美味。', '/[əˈplɔz] ænd ɪt smɛlz dɪˈlɪʃəs./', '<span>[APPLAUSE]</span><span>And</span><span>it</span><span>smells</span><span tid="50082" class="highlight highlight-a">delicious</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 119, 287.59, 289.562, 'And by the way, it smells like me.', '顺便说一句，它闻起来像我。', '/ænd baɪ ðə weɪ, ɪt smɛlz laɪk mi./', '<span>And</span><span pid="529" class="highlight highlight-i">by the way</span><span>,</span><span>it</span><span>smells</span><span>like</span><span>me</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 120, 289.562, 290.98, 'It really does.', '确实如此。', '/ɪt ˈrɪli dʌz/', '<span>It</span><span>really</span><span>does</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 121, 290.98, 292.354, 'Where is it, Chris?', '它在哪里，克里斯？', '/wɛr ɪz ɪt krɪs/', '<span>Where</span><span>is</span><span>it</span><span>,</span><span>Chris</span><span>?</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 122, 292.354, 294.222, 'Ho.', '哦。', '/hoʊ/', '<span>Ho</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 123, 294.222, 295.18, 'It''s a mix of smells.', '这是各种气味的混合。', '/ɪts ə mɪks əv smɛlz/', '<span>It</span><span>''s</span><span>a</span><span tid="50083" class="highlight highlight-a">mix</span><span>of</span><span tid="50084" class="highlight highlight-a">smells</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 124, 295.18, 296.29, 'You know?', '你知道吗？', '/ju noʊ/', '<span>You</span><span>know</span><span>?</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 125, 296.29, 301.98, 'JIMMY KIMMEL: Scarlett, it was your idea for what-- the original six Avengers to become tattooed together?', '吉米·坎摩尔：斯嘉丽，是你提议让最初的六位复仇者一起纹身的吗？', '/ˈdʒɪmi ˈkɪməl skɑːrˈlɛt ɪt wʌz jɔr aɪˈdiə fɔr wʌt ðə əˈrɪdʒənəl sɪks əˈvɛndʒərz tə bɪˈkʌm tæˈtuːd təˈɡɛðər/', '<span>JIMMY</span><span>KIMMEL</span><span>:</span><span>Scarlett</span><span>,</span><span>it</span><span>was</span><span>your</span><span tid="50085" class="highlight highlight-a">idea</span><span>for</span><span>what</span><span>--</span><span>the</span><span tid="50086" class="highlight highlight-a">original</span><span>six</span><span tid="50087" class="highlight highlight-a">Avengers</span><span>to</span><span>become</span><span tid="50088" class="highlight highlight-a">tattooed</span><span>together</span><span>?</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 126, 301.98, 302.88, 'Yeah.', '是的。', '/jɛə/', '<span>Yeah</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 127, 302.88, 306.46, 'I thought-- well, I think Chris Evans and I kind of came up with it. JIMMY KIMMEL: OK.', '我想——嗯，我觉得克里斯·埃文斯和我差不多想出来的。吉米·坎摩尔：好的。', '/aɪ θɔt wɛl aɪ θɪŋk krɪs ˈɛvənz ænd aɪ kaɪnd əv keɪm ʌp wɪð ɪt ˈdʒɪmi ˈkɪməl oʊˈkeɪ/', '<span>I</span><span>thought</span><span>--</span><span>well</span><span>,</span><span>I</span><span>think</span><span>Chris</span><span>Evans</span><span>and</span><span>I</span><span>kind</span><span>of</span><span>came</span><span>up</span><span>with</span><span>it</span><span>.</span><span>JIMMY</span><span>KIMMEL</span><span>:</span><span>OK</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 128, 306.46, 308.5, 'And so Chris has it.', '所以克里斯有它。', '/ænd soʊ krɪs hæz ɪt/', '<span>And</span><span>so</span><span>Chris</span><span>has</span><span>it.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 129, 308.5, 309.4, 'You have it.', '你有它。', '/juː hæv ɪt/', '<span>You</span><span>have</span><span>it.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 130, 309.4, 310.3, 'Robert has it.', '罗伯特有它。', '/ˈrɑːbərt hæz ɪt/', '<span>Robert</span><span>has</span><span>it.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 131, 310.3, 311.58, 'Who else actually got it?', '还有谁真的得到了它？', '/huː ɛls ˈæktʃuəli gɑːt ɪt/', '<span>Who</span><span>else</span><span tid="50089" class="highlight highlight-a">actually</span><span>got</span><span>it?</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 132, 311.58, 312.48, 'We all have it.', '我们都有它。', '/wiː ɔːl hæv ɪt/', '<span>We</span><span>all</span><span>have</span><span>it.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 133, 312.48, 314.047, 'And then, but Mark does not have it.', '然后，但是马克没有它。', '/ænd ðɛn bʌt mɑːrk dʌz nɑːt hæv ɪt/', '<span>And</span><span>then,</span><span>but</span><span>Mark</span><span>does</span><span>not</span><span>have</span><span>it.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 134, 314.047, 315.88, 'JIMMY KIMMEL: Mark Ruffalo does not have it.', '吉米·坎摩尔：马克·鲁法洛没有它。', '/ˈdʒɪmi ˈkɪməl mɑːrk rəˈfæloʊ dʌz nɑːt hæv ɪt/', '<span>JIMMY</span><span>KIMMEL:</span><span>Mark</span><span>Ruffalo</span><span>does</span><span>not</span><span>have</span><span>it.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 135, 315.88, 316.93, '- Yeah. - He declined.', '- 是的。- 他拒绝了。', '/- jɛs - hiː dɪˈklaɪnd/', '<span>-</span><span>Yeah.</span><span>-</span><span>He</span><span tid="50090" class="highlight highlight-a">declined.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 136, 316.93, 317.89, 'He did. JIMMY KIMMEL: Did he really?', '他确实做了。吉米·坎摩尔：他真的做了吗？', '/hi dɪd. ˈdʒɪmi ˈkɪməl: dɪd hi ˈrɪli/', '<span>He</span><span>did</span><span>.</span><span>JIMMY KIMMEL:</span><span>Did</span><span>he</span><span>really</span><span>?</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 137, 317.89, 319.36, 'Yeah. At his own peril.', '是的，自担风险。', '/jɛs. æt hɪz oʊn ˈpɛrəl/', '<span>Yeah</span><span>.</span><span>At</span><span>his</span><span>own</span><span tid="50091" class="highlight highlight-a">peril</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 138, 319.36, 320.26, 'Yeah.', '是的。', '/jɛs/', '<span>Yeah</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 139, 320.26, 321.88, 'Did you apply peer pressure to Mark?', '你对马克施加了同伴压力吗？', '/dɪd ju əˈplaɪ pɪr ˈprɛʃər tu mɑrk/', '<span>Did</span><span>you</span><span>apply</span><span>peer</span><span tid="50092" class="highlight highlight-a">pressure</span><span>to</span><span>Mark</span><span>?</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 140, 321.88, 322.78, 'Yes.', '是的。', '/jɛs/', '<span>Yes</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 141, 322.78, 323.68, 'Well, no.', '嗯，不。', '/wɛl, noʊ/', '<span>Well</span><span>,</span><span>no</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 142, 323.68, 326.665, 'We''re not like some psycho, you know, marine squad.', '我们不像某些疯子，你知道，海军陆战队小队。', '/wir nɑt laɪk səm ˈsaɪkoʊ, ju noʊ, məˈrin skwɑd/', '<span>We''re</span><span>not</span><span>like</span><span>some</span><span tid="50093" class="highlight highlight-a">psycho</span><span>,</span><span>you</span><span>know</span><span>,</span><span tid="50094" class="highlight highlight-a">marine</span><span>squad</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 143, 326.665, 330.85, '[LAUGHTER] Well, you did get an Avengers tattoo put on your body.', '[笑声] 嗯，你确实在身上纹了复仇者联盟的纹身。', '/wɛl, ju dɪd gɛt ən ˈvɛndʒərz ˈtætuː pʊt ɑn jɔr ˈbɑdi/', '<span>[LAUGHTER]</span><span>Well</span><span>,</span><span>you</span><span>did</span><span>get</span><span>an</span><span tid="50095" class="highlight highlight-a">Avengers</span><span tid="50096" class="highlight highlight-a">tattoo</span><span>put</span><span>on</span><span>your</span><span>body</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 144, 330.85, 331.75, 'Yeah.', '是的。', '/jæ/.', '<span>Yeah.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 145, 331.75, 333.18, 'It''s why he''s not sitting right here.', '这就是为什么他现在不坐在这里。', '/ɪts waɪ hiːz nɑːt ˈsɪtɪŋ raɪt hɪr/.', '<span>It''s</span><span>why</span><span>he''s</span><span>not</span><span tid="50097" class="highlight highlight-a">sitting</span><span>right</span><span>here.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 146, 333.18, 334.638, 'Yeah. He would have been here.', '是的。他本来会在这里的。', '/jæ. hiː wʊd hæv biːn hɪr/.', '<span>Yeah.</span><span>He</span><span pid="530" class="highlight highlight-l">would have been</span><span>here.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 147, 334.638, 337.96, '- That''s why he''s been removed. - There was some-- I thought it was because he was keeps revealing the end--', '- 这就是他被移除的原因。- 有一些——我以为是因为他一直在剧透——', '/ðæts waɪ hiːz biːn rɪˈmuːvd. ðɛr wʌz sʌm-- aɪ θɔːt ɪt wʌz bɪˈkɔːz hiː wʌz kiːps rɪˈviːlɪŋ ðiː ɛnd--/', '<span>-</span><span>That''s</span><span>why</span><span>he''s</span><span>been</span><span>removed.</span><span>-</span><span>There</span><span>was</span><span>some--</span><span>I</span><span>thought</span><span>it</span><span>was</span><span>because</span><span>he</span><span>was</span><span>keeps</span><span>revealing</span><span>the</span><span>end--</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 148, 337.96, 338.864, 'Chris says he won''t do press with him.', '克里斯说他不会和他一起做媒体宣传。', '/krɪs sɛz hiː woʊnt duː prɛs wɪð hɪm/.', '<span>Chris</span><span>says</span><span>he</span><span>won''t</span><span>do</span><span tid="50098" class="highlight highlight-a">press</span><span>with</span><span>him.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 149, 338.864, 341.92, '[LAUGHTER] And that.', '[笑声] 还有那个。', '/ˈlæftər ænd ðæt/.', '<span>[LAUGHTER]</span><span>And</span><span>that.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 150, 341.92, 344.32, 'I guess he said yesterday that he''s afraid of needles.', '我猜他昨天说他害怕打针。', '/aɪ gɛs hiː sɛd ˈjɛstərdeɪ ðæt hiːz əˈfreɪd ʌv ˈniːdəlz/.', '<span>I</span><span>guess</span><span>he</span><span>said</span><span>yesterday</span><span>that</span><span>he''s</span><span tid="50099" class="highlight highlight-a">afraid</span><span>of</span><span tid="50100" class="highlight highlight-a">needles.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 151, 344.32, 345.22, 'JIMMY KIMMEL: Oh.', '吉米·坎摩尔：哦。', '/ˈdʒɪmi ˈkɪməl: oʊ/.', '<span>JIMMY</span><span>KIMMEL:</span><span>Oh.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 152, 345.22, 346.697, 'But he didn''t say that before.', '但他之前没这么说。', '/bʌt hiː ˈdɪdənt seɪ ðæt bɪˈfɔːr/', '<span>But</span><span>he</span><span>didn''t</span><span>say</span><span>that</span><span>before</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 153, 346.697, 349.53, 'Just made it-- he was just-- it seemed like he was really judgmental.', '只是觉得——他好像——他看起来真的很挑剔。', '/dʒʌst ˈmeɪd ɪt hiː wʌz dʒʌst ɪt ˈsiːmd laɪk hiː wʌz ˈriːəli ˈdʒʌdʒməntl/', '<span>Just</span><span tid="50101" class="highlight highlight-a">made</span><span>it</span><span>--</span><span>he</span><span>was</span><span>just</span><span>--</span><span>it</span><span>seemed</span><span>like</span><span>he</span><span>was</span><span>really</span><span tid="50102" class="highlight highlight-a">judgmental</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 154, 349.53, 351.05, 'The Hulk is afraid of needles.', '绿巨人害怕打针。', '/ðə hʌlk ɪz əˈfreɪd əv ˈniːdəlz/', '<span>The</span><span>Hulk</span><span>is</span><span tid="50103" class="highlight highlight-a">afraid</span><span>of</span><span tid="50104" class="highlight highlight-a">needles</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 155, 351.05, 352.717, 'CHRIS HEMSWORTH: He''s afraid of friends.', '克里斯·海姆斯沃斯：他害怕朋友。', '/krɪs ˈhɛmzwɜːrθ hiːz əˈfreɪd əv frɛndz/', '<span>CHRIS</span><span>HEMSWORTH</span><span>:</span><span>He</span><span>''s</span><span tid="50105" class="highlight highlight-a">afraid</span><span>of</span><span>friends</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 156, 352.717, 356.92, '[LAUGHTER] I have a dinner for schmucks tramp stamp.', '[笑声] 我有一个《笨人晚宴》的纹身。', '/ˈlæftər aɪ hæv ə ˈdɪnər fɔːr ʃmʌks træmp stæmp/', '<span>[LAUGHTER]</span><span>I</span><span>have</span><span>a</span><span>dinner</span><span>for</span><span tid="50106" class="highlight highlight-a">schmucks</span><span tid="50107" class="highlight highlight-a">tramp</span><span tid="50108" class="highlight highlight-a">stamp</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 157, 356.92, 366.73, '[LAUGHTER] Paul, of all these movies, and doing all this stuff, what was your favorite?', '[笑声] 保罗，在这些电影里，做了这么多事，你最喜欢哪个？', '/ˈlæftər pɔːl əv ɔːl ðiːz ˈmuːviz ænd ˈduːɪŋ ɔːl ðɪs stʌf wʌt wʌz jɔːr ˈfeɪvərɪt/', '<span>[LAUGHTER]</span><span>Paul</span><span>,</span><span>of</span><span>all</span><span>these</span><span>movies</span><span>,</span><span>and</span><span>doing</span><span>all</span><span>this</span><span>stuff</span><span>,</span><span>what</span><span>was</span><span>your</span><span tid="50109" class="highlight highlight-a">favorite</span><span>?</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 158, 366.73, 371.41, 'What''s the moment that stands out most brightly for you?', '哪个时刻对你来说最突出？', '/wʌts ðə ˈmoʊmənt ðæt stændz aʊt moʊst ˈbraɪtli fɔːr juː/', '<span>What</span><span>''s</span><span>the</span><span>moment</span><span>that</span><span tid="50110" class="highlight highlight-d">stands</span><span tid="50111" class="highlight highlight-d">out</span><span>most</span><span tid="50112" class="highlight highlight-a">brightly</span><span>for</span><span>you</span><span>?</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 159, 371.41, 372.31, 'Boy.', '男孩。', '/bɔɪ/', '<span>Boy</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 160, 372.31, 373.56, 'Well, there are a lot of them.', '嗯，有很多这样的人。', '/wɛl ðɛr ə lɑt əv ðɛm/', '<span>Well</span><span>,</span><span>there</span><span>are</span><span pid="531" class="highlight highlight-c">a lot of</span><span>them</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 161, 373.56, 379.81, 'But the very first time I filmed with these guys on "Civil War," it was pretty spectacular.', '但第一次和这些家伙一起拍摄《美国队长3：内战》时，场面相当壮观。', '/bət ðə ˈvɛri fɜːrst taɪm aɪ fɪlmd wɪð ðiːz gʌz ɑn ˈsɪvəl wɔr ɪt wəz ˈprɪti ˈspɛktəkələr/', '<span>But</span><span>the</span><span>very</span><span>first</span><span>time</span><span>I</span><span>filmed</span><span>with</span><span>these</span><span>guys</span><span>on</span><span>"Civil</span><span>War,"</span><span>it</span><span>was</span><span>pretty</span><span>spectacular.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 162, 379.81, 381.88, 'Because we''d already filmed "Ant-Man."', '因为我们之前已经拍完了《蚁人》。', '/bɪˈkɔz wiːd ɔːlˈrɛdi fɪlmd ˈænt mæn/', '<span>Because</span><span>we''d</span><span>already</span><span>filmed</span><span>"Ant-Man."</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 163, 381.88, 384.16, 'But that was a little bit in a bubble.', '但那有点像是在一个封闭的环境里。', '/bət ðæt wəz ə ˈlɪtəl bɪt ɪn ə ˈbʌbəl/', '<span>But</span><span>that</span><span>was</span><span pid="532" class="highlight highlight-c">a little bit</span><span>in</span><span pid="533" class="highlight highlight-i">a bubble</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 164, 384.16, 387.85, 'And all of a sudden I was seeing everybody in their suits.', '突然间我看到了每个人都穿着他们的战服。', '/ənd ɔːl əv ə ˈsʌdən aɪ wəz ˈsiːɪŋ ˈɛvriˌbɑdi ɪn ðɛr suts/', '<span>And</span><span pid="534" class="highlight highlight-i">all of a sudden</span><span>I</span><span>was</span><span>seeing</span><span>everybody</span><span>in</span><span>their</span><span>suits</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 165, 387.85, 389.23, 'And it was very exciting.', '那非常令人兴奋。', '/ənd ɪt wəz ˈvɛri ɪkˈsaɪtɪŋ/', '<span>And</span><span>it</span><span>was</span><span>very</span><span tid="50113" class="highlight highlight-a">exciting</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 166, 389.23, 392.62, 'In fact, one time Chris Evans-- I was standing opposite him.', '事实上，有一次克里斯·埃文斯——我就站在他对面。', '/ɪn fækt wʌn taɪm krɪs ˈɛvənz aɪ wəz ˈstændɪŋ ˈɑpəzɪt hɪm/', '<span pid="535" class="highlight highlight-c">In fact</span><span>,</span><span>one time</span><span>Chris Evans</span><span>--</span><span>I</span><span>was</span><span>standing</span><span tid="50114" class="highlight highlight-a">opposite</span><span>him</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 167, 392.62, 395.89, 'And he had to run to use the bathroom or something.', '他得跑去上厕所或什么的。', '/ənd hi hæd tə rʌn tə juz ðə ˈbæθrum ɔr ˈsʌmθɪŋ/', '<span>And</span><span>he</span><span pid="536" class="highlight highlight-d">had to</span><span>run</span><span>to</span><span>use</span><span>the bathroom</span><span>or something</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 168, 395.89, 398.71, 'And he asked the prop guy to hold his shield.', '他让道具师拿着他的盾牌。', '/ænd hi æskt ðə prɑp ɡaɪ tuː hoʊld hɪz ʃiːld/', '<span>And</span><span>he</span><span tid="50115" class="highlight highlight-a">asked</span><span>the</span><span tid="50116" class="highlight highlight-a">prop</span><span>guy</span><span>to</span><span>hold</span><span>his</span><span tid="50117" class="highlight highlight-a">shield.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 169, 398.71, 404.11, 'And as he walked off I just said, can I try it?', '当他走开时，我就说，我能试试吗？', '/ænd æz hiː wɔːkt ɑːf aɪ dʒʌst sɛd, kæn aɪ traɪ ɪt/', '<span>And</span><span>as</span><span>he</span><span pid="537" class="highlight highlight-d">walked off</span><span>I</span><span>just</span><span>said,</span><span>can</span><span>I</span><span>try</span><span>it?</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 170, 404.11, 406.33, 'And I took the shield.', '然后我拿起了盾牌。', '/ænd aɪ tʊk ðə ʃiːld/', '<span>And</span><span>I</span><span>took</span><span>the</span><span tid="50118" class="highlight highlight-a">shield.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 171, 406.33, 407.7, 'And it was-- yeah.', '那真是——是的。', '/ænd ɪt wʌz jɛə/', '<span>And</span><span>it</span><span>was--</span><span>yeah.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 172, 407.7, 408.74, 'it was very exciting.', '非常激动人心。', '/ɪt wʌz ˈvɛri ɪkˈsaɪtɪŋ/', '<span>it</span><span>was</span><span>very</span><span tid="50119" class="highlight highlight-a">exciting.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 173, 408.74, 413.08, 'It was not dissimilar to what my character was feeling in the scene.', '这和我的角色在场景中的感受没什么不同。', '/ɪt wʌz nɑt dɪˈsɪmələr tuː wʌt maɪ ˈkɛrɪktər wʌz ˈfilɪŋ ɪn ðə siːn/', '<span>It</span><span>was</span><span pid="538" class="highlight highlight-i">not dissimilar to</span><span>what</span><span>my</span><span tid="50120" class="highlight highlight-a">character</span><span>was</span><span>feeling</span><span>in</span><span>the</span><span tid="50121" class="highlight highlight-a">scene.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 174, 413.08, 415.86, 'What did you do with the shield while you had it?', '你拿着盾牌的时候做了什么？', '/wʌt dɪd juː duː wɪð ðə ʃiːld waɪl juː hæd ɪt/', '<span>What</span><span>did</span><span>you</span><span>do</span><span>with</span><span>the</span><span tid="50122" class="highlight highlight-a">shield</span><span>while</span><span>you</span><span>had</span><span>it?</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 175, 415.86, 419.515, 'I just kind of went pew, pew, pew.', '我就只是比划着咻咻咻。', '/aɪ dʒʌst kaɪnd əv wɛnt pjuː pjuː pjuː/', '<span>I</span><span>just</span><span pid="539" class="highlight highlight-i">kind of</span><span>went</span><span>pew,</span><span>pew,</span><span>pew.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 176, 419.515, 420.64, 'Acting it out a little bit.', '稍微表演一下。', '/ˈæktɪŋ ɪt aʊt ə ˈlɪtəl bɪt/', '<span tid="50123" class="highlight highlight-a">Acting</span><span>it</span><span tid="50124" class="highlight highlight-d">out</span><span>a</span><span>little</span><span>bit.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 177, 420.64, 423.472, 'But then I gave it back and, you know, tried to be a little cool.', '但后来我把它还了回去，然后，你知道，试着表现得酷一点。', '/bʌt ðɛn aɪ geɪv ɪt bæk ænd, ju noʊ, traɪd tu bi ə ˈlɪtəl kul/', '<span>But</span><span>then</span><span>I</span><span>gave</span><span>it</span><span tid="50125" class="highlight highlight-d">back</span><span>and,</span><span>you</span><span tid="50126" class="highlight highlight-i">know,</span><span>tried</span><span>to</span><span>be</span><span>a</span><span>little</span><span tid="50127" class="highlight highlight-a">cool.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 178, 423.472, 430.06, 'Do any of you-- and I know this might be hard to remember-- have a favorite line that you delivered in character?', '你们中有人——我知道这可能很难记住——有没有一句最喜欢的台词是在角色中说出的？', '/duː ˈɛni əv ju-- ænd aɪ noʊ ðɪs maɪt bi hɑːrd tu rɪˈmɛmbər-- hæv ə ˈfeɪvərɪt laɪn ðæt ju dɪˈlɪvərd ɪn ˈkærɪktər/', '<span>Do</span><span>any</span><span>of</span><span>you--</span><span>and</span><span>I</span><span>know</span><span>this</span><span>might</span><span>be</span><span tid="50128" class="highlight highlight-a">hard</span><span>to</span><span>remember--</span><span>have</span><span>a</span><span tid="50129" class="highlight highlight-a">favorite</span><span>line</span><span>that</span><span>you</span><span tid="50130" class="highlight highlight-a">delivered</span><span>in</span><span>character?</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 179, 430.06, 430.96, 'Oh, gosh.', '哦，天哪。', '/oʊ, gɑʃ/', '<span>Oh,</span><span tid="50131" class="highlight highlight-i">gosh.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 180, 430.96, 431.86, 'I don''t know.', '我不知道。', '/aɪ doʊnt noʊ/', '<span>I</span><span>don''t</span><span>know.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 181, 431.86, 440.53, 'I had this-- when we were doing reshoots for "Iron Man 2," I guess my character was kind of overseeing the action', '我有一句——当我们为《钢铁侠2》重拍时，我想我的角色在某种程度上监督着行动。', '/aɪ hæd ðɪs-- wɛn wi wɜr ˈduɪŋ ˈriʃuːts fɔr ˈaɪərn mæn tuː, aɪ gɛs maɪ ˈkærɪktər wʌz kaɪnd əv ˈoʊvərˌsiɪŋ ði ˈækʃən/', '<span>I</span><span>had</span><span>this--</span><span>when</span><span>we</span><span>were</span><span>doing</span><span tid="50132" class="highlight highlight-a">reshoots</span><span>for</span><span>"Iron</span><span>Man</span><span>2,"</span><span>I</span><span>guess</span><span>my</span><span>character</span><span>was</span><span>kind</span><span>of</span><span tid="50133" class="highlight highlight-a">overseeing</span><span>the</span><span>action</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 182, 440.53, 442.09, 'on a computer screen.', '在电脑屏幕上。', '/ɑn ə kəmˈpjutər skrin/', '<span>on</span><span>a</span><span>computer</span><span>screen.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 183, 442.09, 444.61, 'And I''m really-- I am just bad at techie jargon.', '而且我真的——我就是不擅长技术术语。', '/ænd aɪm ˈrɪli-- aɪ æm dʒʌst bæd æt ˈtɛki ˈdʒɑrgɑn/', '<span>And</span><span>I''m</span><span>really--</span><span>I</span><span>am</span><span>just</span><span tid="50134" class="highlight highlight-a">bad</span><span tid="50135" class="highlight highlight-c">at</span><span tid="50136" class="highlight highlight-a">techie</span><span tid="50137" class="highlight highlight-a">jargon.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 184, 444.61, 445.84, 'Like I''m terrible at it.', '我在这方面糟透了。', '/laɪk aɪm ˈtɛrəbəl æt ɪt/', '<span>Like</span><span>I''m</span><span tid="50138" class="highlight highlight-a">terrible</span><span>at</span><span>it.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 185, 445.84, 449.37, 'And I had a line that went, Oracle is converging.', '我有一句台词是：Oracle 正在汇聚。', '/ænd aɪ hæd ə laɪn ðæt wɛnt ˈɔrəkəl ɪz kənˈvɜrdʒɪŋ/', '<span>And</span><span>I</span><span>had</span><span>a</span><span tid="50139" class="highlight highlight-a">line</span><span>that</span><span>went,</span><span tid="50140" class="highlight highlight-a">Oracle</span><span>is</span><span tid="50141" class="highlight highlight-a">converging.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 186, 449.37, 450.5, 'No. Wait.', '不，等等。', '/noʊ weɪt/', '<span>No.</span><span>Wait.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 187, 450.5, 451.5, 'It was-- it was-- sorry.', '那是——那是——抱歉。', '/ɪt wʌz ɪt wʌz ˈsɑri/', '<span>It</span><span>was--</span><span>it</span><span>was--</span><span>sorry.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 188, 451.5, 453.85, 'It was, bogie is converging on the Oracle Pavilion.', '那是：不明飞行物正在向 Oracle 展馆汇聚。', '/ɪt wʌz ˈboʊɡi ɪz kənˈvɜrdʒɪŋ ɑn ði ˈɔrəkəl pəˈvɪljən/', '<span>It</span><span>was,</span><span tid="50142" class="highlight highlight-a">bogie</span><span>is</span><span tid="50143" class="highlight highlight-a">converging</span><span>on</span><span>the</span><span tid="50144" class="highlight highlight-a">Oracle</span><span tid="50145" class="highlight highlight-a">Pavilion.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 189, 453.85, 454.75, 'Lock and load.', '上膛，准备战斗。', '/lɑk ænd loʊd/', '<span tid="50146" class="highlight highlight-i">Lock</span><span>and</span><span>load.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 190, 454.75, 456.243, 'The fight''s coming to you.', '战斗要来找你了。', '/ðə faɪts ˈkʌmɪŋ tu ju/', '<span>The</span><span>fight''s</span><span>coming</span><span>to</span><span>you.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 191, 456.243, 462.93, '[LAUGHTER] [APPLAUSE] JIMMY KIMMEL: That''s pretty solid.', '[笑声][掌声] 吉米·坎摩尔：这相当不错。', '/ˈlæftər ˈæplɔz ˈdʒɪmi ˈkɪməl ðæts ˈfɛrli ˈsɑlɪd/', '<span>[LAUGHTER]</span><span>[APPLAUSE]</span><span>JIMMY</span><span>KIMMEL:</span><span>That''s</span><span>pretty</span><span tid="50147" class="highlight highlight-a">solid.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 192, 462.93, 464.04, 'So bad.', '太糟糕了。', '/soʊ bæd/', '<span>So</span><span tid="50148" class="highlight highlight-a">bad.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 193, 464.04, 465.63, 'I mean, I think it got cut.', '我的意思是，我觉得它被剪掉了。', '/aɪ miːn aɪ θɪŋk ɪt ɡɑːt kʌt/', '<span>I</span><span>mean,</span><span>I</span><span>think</span><span>it</span><span>got</span><span tid="50149" class="highlight highlight-a">cut.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 194, 465.63, 469.89, 'I think actually Jon Favreau is saying the line, and I''m just mouthing the words.', '我觉得实际上是乔恩·费儒在说台词，而我只是在对口型。', '/aɪ θɪŋk ˈæktʃuəli dʒɑːn ˈfeɪvruː ɪz ˈseɪɪŋ ðə laɪn ænd aɪm dʒʌst ˈmaʊðɪŋ ðə wɜːrdz/', '<span>I</span><span>think</span><span>actually</span><span>Jon</span><span>Favreau</span><span>is</span><span>saying</span><span>the</span><span tid="50150" class="highlight highlight-a">line,</span><span>and</span><span>I''m</span><span>just</span><span tid="50151" class="highlight highlight-a">mouthing</span><span>the</span><span>words.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 195, 469.89, 471.72, 'That''s how bad it was.', '那就是有多糟糕。', '/ðæts haʊ bæd ɪt wʌz/', '<span>That''s</span><span>how</span><span>bad</span><span>it</span><span>was.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 196, 471.72, 472.72, 'How about you, Chris?', '你呢，克里斯？', '/haʊ əˈbaʊt juː krɪs/', '<span>How</span><span>about</span><span>you,</span><span>Chris?</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 197, 472.72, 473.7, 'Any "Thor?"', '有“雷神”吗？', '/ˈɛni θɔːr/', '<span>Any</span><span tid="50152" class="highlight highlight-a">"Thor?"</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 198, 473.7, 482.48, 'When we were shooting "Ragnarok" we had a young kid on set who was-- who was unwell at the time and had come to visit.', '我们在拍摄《诸神黄昏》时，片场有一个小孩，他当时身体不适，来探班。', '/wɛn wiː wɜːr ˈʃuːtɪŋ ˈræɡnərɑːk wiː hæd ə jʌŋ kɪd ɑːn sɛt huː wʌz huː wʌz ʌnˈwɛl æt ðə taɪm ænd hæd kʌm tuː ˈvɪzɪt/', '<span>When</span><span>we</span><span>were</span><span tid="50153" class="highlight highlight-a">shooting</span><span>"Ragnarok"</span><span>we</span><span>had</span><span>a</span><span>young</span><span>kid</span><span>on</span><span tid="50154" class="highlight highlight-a">set</span><span>who</span><span>was--</span><span>who</span><span>was</span><span tid="50155" class="highlight highlight-a">unwell</span><span>at</span><span>the</span><span>time</span><span>and</span><span>had</span><span>come</span><span>to</span><span tid="50156" class="highlight highlight-a">visit.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 199, 482.48, 487.44, 'And we were shooting the scene with Hulk and Thor in the arena.', '我们正在拍摄浩克和雷神在竞技场里的那场戏。', '/ænd wiː wɜːr ˈʃuːtɪŋ ðə siːn wɪð hʌlk ænd θɔːr ɪn ði ˈɑːrənə/', '<span>And</span><span>we</span><span>were</span><span tid="50157" class="highlight highlight-a">shooting</span><span>the</span><span>scene</span><span>with</span><span>Hulk</span><span>and</span><span>Thor</span><span>in</span><span>the</span><span tid="50158" class="highlight highlight-a">arena.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 200, 487.44, 491.07, 'And it was right when I was talking to the Hulk, and I was saying, oh, my god, it''s you.', '就在我和浩克说话的时候，我说，哦，天哪，是你。', '/ænd ɪt wʌz raɪt wɛn aɪ wʌz ˈtɔːkɪŋ tuː ðə hʌlk, ænd aɪ wʌz ˈseɪɪŋ, oʊ, maɪ gɑːd, ɪts juː/', '<span>And</span><span>it</span><span>was</span><span>right</span><span>when</span><span>I</span><span>was</span><span pid="540" class="highlight highlight-d">talking to</span><span>the</span><span tid="50159" class="highlight highlight-a">Hulk</span><span>,</span><span>and</span><span>I</span><span>was</span><span>saying</span><span>,</span><span>oh</span><span>,</span><span>my</span><span>god</span><span>,</span><span>it''s</span><span>you</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 201, 491.07, 492.7, 'Where''ve you been? And da, da, da.', '你去哪儿了？等等等等。', '/wɛr hæv juː bɪn? ænd dɑː, dɑː, dɑː/', '<span>Where''ve</span><span>you</span><span>been</span><span>?</span><span>And</span><span>da</span><span>,</span><span>da</span><span>,</span><span>da</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 202, 492.7, 493.825, 'And he was on the sideline.', '他在场边。', '/ænd hiː wʌz ɑːn ðə ˈsaɪdlaɪn/', '<span>And</span><span>he</span><span>was</span><span>on</span><span>the</span><span tid="50160" class="highlight highlight-a">sideline</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 203, 493.825, 500.31, 'And he''s like, why don''t you say, when you look up at Loki in the crowd, say, he''s a friend from work.', '他说，你为什么不这样说，当你抬头看着人群中的洛基时，说，他是我工作上的朋友。', '/ænd hiːz laɪk, waɪ doʊnt juː seɪ, wɛn juː lʊk ʌp æt ˈloʊki ɪn ðə kraʊd, seɪ, hiːz ə frɛnd frʌm wɜːrk/', '<span>And</span><span>he''s</span><span>like</span><span>,</span><span>why</span><span>don''t</span><span>you</span><span>say</span><span>,</span><span>when</span><span>you</span><span pid="541" class="highlight highlight-d">look up at</span><span tid="50161" class="highlight highlight-a">Loki</span><span>in</span><span>the</span><span>crowd</span><span>,</span><span>say</span><span>,</span><span>he''s</span><span>a</span><span>friend</span><span>from</span><span>work</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 204, 500.31, 502.54, 'And then so that line-- JIMMY KIMMEL: A kid gave you that line?', '然后那句台词——吉米·坎摩尔：一个孩子给了你那句台词？', '/ænd ðɛn soʊ ðæt laɪn-- ˈdʒɪmi ˈkɪməl: ə kɪd geɪv juː ðæt laɪn?/', '<span>And</span><span>then</span><span>so</span><span>that</span><span>line</span><span>--</span><span>JIMMY</span><span>KIMMEL</span><span>:</span><span>A</span><span>kid</span><span>gave</span><span>you</span><span>that</span><span>line</span><span>?</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 205, 502.54, 503.64, 'A kid gave us that line. Yeah.', '一个孩子给了我们那句台词。是的。', '/ə kɪd geɪv ʌs ðæt laɪn. jɛə/', '<span>A</span><span>kid</span><span>gave</span><span>us</span><span>that</span><span>line</span><span>.</span><span>Yeah</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 206, 503.64, 506.093, 'And it became one of the best lines of the movie.', '它成了电影里最好的台词之一。', '/ænd ɪt bɪˈkeɪm wʌn ʌv ðə bɛst laɪnz ʌv ðə ˈmuːvi/', '<span>And</span><span>it</span><span>became</span><span pid="542" class="highlight highlight-c">one of</span><span>the</span><span>best</span><span>lines</span><span>of</span><span>the</span><span>movie</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 207, 506.093, 508.931, '[APPLAUSE] JIMMY KIMMEL: Wow.', '[掌声] 吉米·坎摩尔：哇。', '/əˈplɔːz/ ˈdʒɪmi ˈkɪməl: waʊ/', '<span>[APPLAUSE]</span><span>JIMMY</span><span>KIMMEL</span><span>:</span><span>Wow</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 208, 512.715, 514.74, '- He used the stones again. - Hey.', '- 他又用了那些石头。- 嘿。', '/hiː juːzd ðə stoʊnz əˈɡen. heɪ/', '<span>-</span><span>He</span><span tid="50162" class="highlight highlight-a">used</span><span>the</span><span tid="50163" class="highlight highlight-a">stones</span><span>again.</span><span>-</span><span>Hey.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 209, 514.74, 514.805, 'Hey.', '嘿。', '/heɪ/', '<span>Hey.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 210, 514.805, 515.705, 'Hey.', '嘿。', '/heɪ/', '<span>Hey.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 211, 515.705, 516.84, 'Hey.', '嘿。', '/heɪ/', '<span>Hey.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 212, 516.84, 518.705, 'We''d be going in shorthanded. You know?', '我们人手不足。你知道吗？', '/wiːd biː ˈɡoʊɪŋ ɪn ˈʃɔːrthændɪd. juː noʊ/', '<span>We''d</span><span>be</span><span>going</span><span>in</span><span tid="50164" class="highlight highlight-a">shorthanded.</span><span>You</span><span>know?</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 213, 518.705, 520.08, 'Look he''s still got the stones.', '看，他还有那些石头。', '/lʊk hiːz stɪl ɡɑːt ðə stoʊnz/', '<span>Look</span><span>he''s</span><span>still</span><span tid="50165" class="highlight highlight-a">got</span><span>the</span><span tid="50166" class="highlight highlight-a">stones.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 214, 520.08, 523.59, 'So-- So let''s get them, and use them to bring everyone back.', '所以——所以我们去拿它们，然后用它们把所有人都带回来。', '/soʊ soʊ lets ɡet ðəm ænd juːz ðəm tə brɪŋ ˈɛvriˌwʌn bæk/', '<span>So--</span><span>So</span><span>let''s</span><span tid="50167" class="highlight highlight-a">get</span><span>them,</span><span>and</span><span>use</span><span>them</span><span>to</span><span tid="50168" class="highlight highlight-d">bring</span><span>everyone</span><span>back.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 215, 523.59, 524.73, 'Just like that?', '就这样？', '/dʒʌst laɪk ðæt/', '<span>Just</span><span>like</span><span tid="50169" class="highlight highlight-i">that?</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 216, 524.73, 525.63, 'Yeah.', '是的。', '/jæː/', '<span>Yeah.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 217, 525.63, 526.65, 'Just like that.', '就像那样。', '/dʒʌst laɪk ðæt/', '<span>Just</span><span>like</span><span>that.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 218, 526.65, 532.59, 'Even if there''s a small chance that we can undo this, I mean, we owe it to everyone who''s not in this room to try.', '即使我们只有很小的机会能扭转这一切，我的意思是，我们欠这个房间之外的所有人一个尝试。', '/ˈiːvən ɪf ðɛrz ə smɔːl tʃæns ðæt wiː kæn ʌnˈduː ðɪs, aɪ miːn, wiː oʊ ɪt tuː ˈɛvriwʌn huːz nɑːt ɪn ðɪs ruːm tuː traɪ/', '<span>Even</span><span>if</span><span>there''s</span><span>a</span><span tid="50170" class="highlight highlight-a">small</span><span tid="50171" class="highlight highlight-a">chance</span><span>that</span><span>we</span><span>can</span><span tid="50172" class="highlight highlight-a">undo</span><span>this,</span><span>I</span><span>mean,</span><span>we</span><span tid="50173" class="highlight highlight-a">owe</span><span>it</span><span>to</span><span>everyone</span><span>who''s</span><span>not</span><span>in</span><span>this</span><span>room</span><span>to</span><span>try.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 219, 532.59, 536.79, 'If we do this, how do we know it''s going to end any differently than it did before?', '如果我们这样做，我们怎么知道结果会和以前有什么不同呢？', '/ɪf wiː duː ðɪs, haʊ duː wiː noʊ ɪts ˈɡoʊɪŋ tuː ɛnd ˈɛni ˈdɪfərəntli ðæn ɪt dɪd bɪˈfɔːr/', '<span>If</span><span>we</span><span>do</span><span>this,</span><span>how</span><span>do</span><span>we</span><span>know</span><span>it''s</span><span>going</span><span>to</span><span>end</span><span>any</span><span tid="50174" class="highlight highlight-a">differently</span><span>than</span><span>it</span><span>did</span><span>before?</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 220, 536.79, 539.34, 'Because before you didn''t have me.', '因为以前你没有我。', '/bɪˈkɔːz bɪˈfɔːr juː ˈdɪdənt hæv miː/', '<span>Because</span><span>before</span><span>you</span><span>didn''t</span><span>have</span><span>me.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 221, 539.34, 543.502, 'Hey, new girl, everybody in this room is about that superhero life.', '嘿，新来的，这个房间里的每个人都过着超级英雄的生活。', '/heɪ, nuː ɡɜːrl, ˈɛvribɑːdi ɪn ðɪs ruːm ɪz əˈbaʊt ðæt ˈsuːpərˌhɪroʊ laɪf/', '<span>Hey,</span><span>new</span><span>girl,</span><span>everybody</span><span>in</span><span>this</span><span>room</span><span>is</span><span>about</span><span>that</span><span tid="50175" class="highlight highlight-a">superhero</span><span>life.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 222, 543.502, 546.39, 'And if you don''t mind my asking, where the hell have you been all this time?', '如果你不介意我问的话，这段时间你到底去哪儿了？', '/ænd ɪf juː doʊnt maɪnd maɪ ˈæskɪŋ, wɛr ðə hɛl hæv juː biːn ɔːl ðɪs taɪm/', '<span>And</span><span>if</span><span>you</span><span>don''t</span><span>mind</span><span>my</span><span>asking,</span><span>where</span><span>the</span><span tid="50176" class="highlight highlight-i">hell</span><span>have</span><span>you</span><span>been</span><span>all</span><span>this</span><span>time?</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 223, 546.39, 548.745, 'There are a lot of other planets in the universe.', '宇宙中还有很多其他的行星。', '/ðɛr ɑːr ə lɑːt əv ˈʌðər ˈplænɪts ɪn ðə ˈjuːnɪvɜːrs/', '<span>There</span><span>are</span><span>a</span><span>lot</span><span>of</span><span>other</span><span tid="50177" class="highlight highlight-a">planets</span><span>in</span><span>the</span><span tid="50178" class="highlight highlight-a">universe.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 224, 548.745, 550.8, 'And unfortunately, they didn''t have you guys.', '不幸的是，他们没有你们这些人。', '/ænd ʌnˈfɔːrtʃənətli, ðeɪ ˈdɪdənt hæv juː ɡaɪz/', '<span>And</span><span tid="50179" class="highlight highlight-a">unfortunately</span><span>,</span><span>they</span><span>didn''t</span><span>have</span><span>you</span><span>guys</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 225, 555.74, 558.21, '[CHEERING]', '[欢呼声]', '/ˈtʃɪrɪŋ/', '<span>[CHEERING]</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 226, 571.054, 573.12, 'I like this one.', '我喜欢这个。', '/aɪ laɪk ðɪs wʌn/', '<span>I</span><span>like</span><span>this</span><span>one</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 227, 573.12, 580.47, '[APPLAUSE] Let''s go get this son of a bitch.', '[掌声] 我们去抓住这个狗娘养的。', '/əˈplɔːz/ lɛts ɡoʊ ɡɛt ðɪs sʌn əv ə bɪtʃ/', '<span>[APPLAUSE]</span><span>Let''s</span><span>go</span><span>get</span><span>this</span><span pid="543" class="highlight highlight-i">son of a bitch</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 228, 580.47, 582.92, '[APPLAUSE] Yeah.', '[掌声] 是的。', '/əˈplɔːz/ jɛs/', '<span>[APPLAUSE]</span><span>Yeah</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 229, 582.92, 583.9, 'Yes.', '是的。', '/jɛs/', '<span>Yes</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 230, 583.9, 585.86, 'That''s what you need to do.', '那就是你需要做的。', '/ðæts wʌt juː niːd tuː duː/', '<span>That''s</span><span>what</span><span>you</span><span>need</span><span>to</span><span>do</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 231, 585.86, 587.41, 'Go get that son of a bitch.', '去抓住那个狗娘养的。', '/ɡoʊ ɡɛt ðæt sʌn əv ə bɪtʃ/', '<span>Go</span><span>get</span><span>that</span><span pid="544" class="highlight highlight-i">son of a bitch</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 232, 587.41, 588.31, 'I got chills.', '我起鸡皮疙瘩了。', '/aɪ gɑt tʃɪlz/', '<span>I</span><span>got</span><span>chills.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 233, 591.74, 595.76, 'I would imagine that everyone wanted to say, let''s go get the son of a bitch.', '我想象每个人都想说，我们去抓住那个狗娘养的。', '/aɪ wʊd ɪˈmædʒɪn ðæt ˈɛvriˌwʌn ˈwɑntɪd tə seɪ, lɛts goʊ gɛt ðə sʌn əv ə bɪtʃ/', '<span>I</span><span>would</span><span>imagine</span><span>that</span><span>everyone</span><span>wanted</span><span>to</span><span>say,</span><span>let''s</span><span>go</span><span>get</span><span>the</span><span>son</span><span>of</span><span>a</span><span>bitch.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 234, 595.76, 596.66, 'Right?', '对吧？', '/raɪt/', '<span>Right</span><span>?</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 235, 596.66, 598.24, 'I mean, that''s the line you want.', '我的意思是，那是你想要的台词。', '/aɪ min, ðæts ðə laɪn ju wɑnt/', '<span>I</span><span>mean</span><span>,</span><span>that''s</span><span>the</span><span tid="50180" class="highlight highlight-a">line</span><span>you</span><span>want</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 236, 598.24, 600.89, 'And Chris got, let''s go get that son of a bitch.', '而克里斯说的是，我们去抓住那个狗娘养的。', '/ænd krɪs gɑt, lɛts goʊ gɛt ðæt sʌn əv ə bɪtʃ/', '<span>And</span><span>Chris</span><span>got</span><span>,</span><span pid="545" class="highlight highlight-i">let''s go get</span><span>that</span><span pid="546" class="highlight highlight-i">son of a bitch</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 237, 600.89, 602.14, 'You''re not in that clip.', '你不在那个片段里。', '/jʊr nɑt ɪn ðæt klɪp/', '<span>You''re</span><span>not</span><span>in</span><span>that</span><span tid="50181" class="highlight highlight-a">clip</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 238, 602.14, 603.26, '- Yeah. - All right.', '- 是的。 - 好吧。', '/- jɛs. - ɔl raɪt/', '<span>-</span><span>Yeah</span><span>.</span><span>-</span><span pid="547" class="highlight highlight-c">All right</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 239, 603.26, 604.53, 'So-- - I enjoyed it.', '所以——我很喜欢。', '/soʊ - aɪ ɪnˈdʒɔɪd ɪt/', '<span>So--</span><span>-</span><span>I</span><span>enjoyed</span><span>it.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 240, 604.53, 605.57, 'I enjoyed it anyway.', '反正我很喜欢。', '/aɪ ɪnˈdʒɔɪd ɪt ˈɛniˌweɪ/', '<span>I</span><span>enjoyed</span><span>it</span><span>anyway.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 241, 605.57, 610.04, 'Does that mean-- does that mean something bad for Tony Stark, for Iron Man?', '那是不是意味着——那是不是对托尼·斯塔克，对钢铁侠来说意味着什么不好的事？', '/dʌz ðæt min-- dʌz ðæt min ˈsʌmθɪŋ bæd fɔr ˈtoʊni stɑrk, fɔr ˈaɪərn mæn?/', '<span>Does</span><span>that</span><span>mean</span><span>--</span><span>does</span><span>that</span><span>mean</span><span>something</span><span tid="50182" class="highlight highlight-a">bad</span><span>for</span><span>Tony Stark</span><span>,</span><span>for</span><span>Iron Man</span><span>?</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 242, 610.04, 610.298, 'No. No.', '不。不。', '/noʊ. noʊ./', '<span>No</span><span>.</span><span>No</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 243, 610.298, 611.64, 'No. Not in the slightest.', '不，一点也不。', '/noʊ. nɑt ɪn ðə ˈslaɪtəst/', '<span>No.</span><span>Not</span><span>in</span><span>the</span><span>slightest.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 244, 611.64, 612.56, 'Ant-Man?', '蚁人？', '/ˈænt mæn?/', '<span>Ant-Man</span><span>?</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 245, 612.56, 613.738, 'Nothing? - I was in it.', '没什么？——我在里面。', '/ˈnʌθɪŋ? - aɪ wʌz ɪn ɪt/', '<span>Nothing</span><span>?</span><span>-</span><span>I</span><span>was</span><span>in</span><span>it</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 246, 613.738, 614.78, 'You just couldn''t see me.', '你只是看不见我。', '/juː dʒʌst ˈkʊdənt siː miː/', '<span>You</span><span>just</span><span>couldn''t</span><span>see</span><span>me</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 247, 614.78, 618.548, '[LAUGHTER]', '[笑声]', '/[ˈlæftər]/', '<span>[LAUGHTER]</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 248, 622.32, 625.32, 'On Friday you guys were all at Disneyland.', '周五你们都在迪士尼乐园。', '/ɑːn ˈfraɪdeɪ juː ɡaɪz wɜːr ɔːl æt ˈdɪznilænd/', '<span>On</span><span>Friday</span><span>you</span><span>guys</span><span>were</span><span>all</span><span>at</span><span>Disneyland.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 249, 625.32, 628.54, 'Avengers made a huge donation to children''s hospitals.', '复仇者联盟向儿童医院捐赠了一大笔钱。', '/ˈævəndʒərz meɪd ə hjuːdʒ dəˈneɪʃən tuː ˈtʃɪldrənz ˈhɑːspɪtlz/', '<span>Avengers</span><span>made</span><span>a</span><span tid="50183" class="highlight highlight-a">huge</span><span tid="50184" class="highlight highlight-a">donation</span><span>to</span><span>children''s</span><span>hospitals.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 250, 628.54, 629.44, 'Yeah.', '是的。', '/jeə/', '<span>Yeah.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 251, 629.44, 630.934, '$5 million I believe.', '我以为是500万美元。', '/faɪv ˈmɪljən aɪ bɪˈliːv/', '<span>$5</span><span>million</span><span>I</span><span>believe.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 252, 630.934, 635.78, '[APPLAUSE] And did you go on any rides while you were there?', '[掌声] 你在那里的时候有没有玩什么游乐设施？', '/ænd dɪd juː ɡoʊ ɑːn ˈeni raɪdz waɪl juː wɜːr ðeər/', '<span>[APPLAUSE]</span><span>And</span><span>did</span><span>you</span><span>go</span><span>on</span><span>any</span><span>rides</span><span>while</span><span>you</span><span>were</span><span>there?</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 253, 635.78, 636.92, 'Did you enj-- - Yeah.', '你享受——是的。', '/dɪd juː ɛnʤ- - jeə/', '<span>Did</span><span>you</span><span>enj--</span><span>-</span><span>Yeah.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 254, 636.92, 637.82, 'We did.', '我们玩了。', '/wiː dɪd/', '<span>We</span><span>did.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 255, 637.82, 640.13, 'We went on the Guardians of the Galaxy ride.', '我们玩了银河护卫队过山车。', '/wiː wɛnt ɑːn ðə ˈɡɑːrdiənz əv ðə ˈɡæləksi raɪd/', '<span>We</span><span>went</span><span>on</span><span>the</span><span>Guardians</span><span>of</span><span>the</span><span>Galaxy</span><span>ride.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 256, 640.13, 641.87, 'The one that drops like crazy.', '那个掉得特别厉害的。', '/ðə wʌn ðæt drɑːps laɪk ˈkreɪzi/', '<span>The</span><span>one</span><span>that</span><span>drops</span><span>like</span><span>crazy.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 257, 641.87, 643.37, 'We went on it. I don''t know.', '我们上去了。我不知道。', '/wi wɛnt ɑːn ɪt. aɪ doʊnt noʊ/', '<span>We</span><span>went</span><span>on</span><span>it.</span><span>I</span><span>don''t</span><span>know.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 258, 643.37, 644.325, 'Where were you?', '你在哪里？', '/wɛr wɜːr juː/', '<span>Where</span><span>were</span><span>you</span><span>?</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 259, 644.325, 645.74, 'Where did you go? - I didn''t.', '你去哪儿了？——我没去。', '/wɛr dɪd juː goʊ? - aɪ dɪdnt/', '<span>Where</span><span>did</span><span>you</span><span>go</span><span>?</span><span>-</span><span>I</span><span>didn''t</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 260, 645.74, 646.64, 'I didn''t.', '我没去。', '/aɪ dɪdnt/', '<span>I</span><span>didn''t</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 261, 646.64, 649.28, 'Well, I was there February 7 for my kid''s birthday.', '嗯，我2月7号在那儿，为了我孩子的生日。', '/wɛl, aɪ wʌz ðɛr ˈfɛbruːɛri ˈsɛvənθ fɔːr maɪ kɪdz ˈbɜːrθdeɪ/', '<span>Well</span><span>,</span><span>I</span><span>was</span><span>there</span><span>February</span><span>7</span><span>for</span><span>my</span><span>kid''s</span><span>birthday</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 262, 649.28, 651.11, 'We went on that ride and I almost yacked.', '我们坐了那个过山车，我差点吐了。', '/wi wɛnt ɑːn ðæt raɪd ænd aɪ ˈɔːlmoʊst jækt/', '<span>We</span><span>went</span><span>on</span><span>that</span><span>ride</span><span>and</span><span>I</span><span>almost</span><span>yacked.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 263, 651.11, 652.19, '- Oh, is that right? - Yeah.', '——哦，是吗？——是的。', '/- oʊ, ɪz ðæt raɪt? - jɛs/', '<span>-</span><span>Oh</span><span>,</span><span>is</span><span>that</span><span>right</span><span>?</span><span>-</span><span>Yeah</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 264, 652.19, 653.17, 'So I wasn''t really going to do it again.', '所以我其实不打算再做了。', '/soʊ aɪ ˈwʌzənt ˈrɪli ˈɡoʊɪŋ tə du ɪt əˈɡɛn/', '<span>So</span><span>I</span><span>wasn''t</span><span>really</span><span pid="548" class="highlight highlight-d">going to</span><span>do</span><span>it</span><span>again</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 265, 653.17, 654.65, 'I was really-- it was good.', '我当时真的——那挺好的。', '/aɪ wʌz ˈrɪli ɪt wʌz ɡʊd/', '<span>I</span><span>was</span><span>really</span><span>--</span><span>it</span><span>was</span><span>good</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 266, 654.65, 656.4, 'A couple of your people that work for you.', '有几个你的手下为你工作。', '/ə ˈkʌpəl əv jɔr ˈpipəl ðæt wɜːrk fər ju/', '<span>A</span><span pid="549" class="highlight highlight-c">couple of</span><span>your</span><span>people</span><span>that</span><span>work</span><span>for</span><span>you</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 267, 656.4, 657.3, 'Yeah.', '是的。', '/jɛə/', '<span>Yeah</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 268, 657.3, 658.25, 'My team came on a bit.', '我的团队有点介入。', '/maɪ tim keɪm ɑn ə bɪt/', '<span>My</span><span>team</span><span pid="550" class="highlight highlight-d">came on</span><span>a</span><span>bit</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 269, 658.25, 663.68, 'I took my daughter on it a couple years ago when it was previously called the Tower of Terror or something.', '几年前我带女儿去玩过，当时它叫“恐怖之塔”之类的。', '/aɪ tʊk maɪ ˈdɔtər ɑn ɪt ə ˈkʌpəl jɪrz əɡoʊ wɛn ɪt wʌz prɪˈviəsli kɔld ðə ˈtaʊər əv ˈtɛrər ɔr ˈsʌmθɪŋ/', '<span>I</span><span>took</span><span>my</span><span>daughter</span><span>on</span><span>it</span><span>a</span><span>couple</span><span>years</span><span>ago</span><span>when</span><span>it</span><span>was</span><span>previously</span><span>called</span><span>the</span><span>Tower</span><span>of</span><span>Terror</span><span>or</span><span>something.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 270, 663.68, 665.19, 'And she wasn''t tall enough.', '她身高不够。', '/ənd ʃi wʌzənt tɔl ɪˈnʌf/', '<span>And</span><span>she</span><span>wasn''t</span><span>tall</span><span>enough</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 271, 665.19, 666.44, 'And she was really upset.', '她当时非常难过。', '/ənd ʃi wʌz ˈrɪli ʌpˈsɛt/', '<span>And</span><span>she</span><span>was</span><span>really</span><span tid="50185" class="highlight highlight-a">upset</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 272, 666.44, 667.91, 'And I was like, no. Forget this.', '我当时就想，不。算了吧。', '/ænd aɪ wʌz laɪk noʊ fərˈɡɛt ðɪs/', '<span>And</span><span>I</span><span pid="551" class="highlight highlight-i">was like</span><span>,</span><span>no</span><span>.</span><span tid="50186" class="highlight highlight-a">Forget</span><span>this</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 273, 667.91, 668.53, 'Come here.', '过来。', '/kʌm hɪr/', '<span>Come</span><span>here</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 274, 668.53, 673.53, 'So I grabbed a couple of Snickers bars and things, and slammed it in the back of her shoe under her heel.', '于是我拿了几条士力架之类的东西，塞进她鞋后跟下面。', '/soʊ aɪ ɡræbd ə ˈkʌpəl əv ˈsnɪkərz bɑːrz ænd θɪŋz ænd slæmd ɪt ɪn ðə bæk əv hɜr ʃuː ˈʌndər hɜr hiːl/', '<span>So</span><span>I</span><span tid="50187" class="highlight highlight-a">grabbed</span><span>a</span><span pid="552" class="highlight highlight-c">couple of</span><span>Snickers</span><span>bars</span><span>and</span><span>things</span><span>,</span><span>and</span><span tid="50188" class="highlight highlight-a">slammed</span><span>it</span><span>in</span><span>the</span><span pid="553" class="highlight highlight-c">back of</span><span>her</span><span>shoe</span><span>under</span><span>her</span><span>heel</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 275, 673.53, 674.66, 'So I propped her up.', '所以我把她扶起来。', '/soʊ aɪ prɑːpt hɜr ʌp/', '<span>So</span><span>I</span><span tid="50189" class="highlight highlight-a">propped</span><span>her</span><span>up</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 276, 674.66, 678.727, 'She was like this much short, walked up, was like, what about now?', '她大概这么矮，走过来，说，现在呢？', '/ʃi wʌz laɪk ðɪs mʌtʃ ʃɔːrt wɔːkt ʌp wʌz laɪk wʌt əˈbaʊt naʊ/', '<span>She</span><span pid="554" class="highlight highlight-i">was like</span><span>this</span><span>much</span><span>short</span><span>,</span><span>walked</span><span>up</span><span>,</span><span pid="555" class="highlight highlight-i">was like</span><span>,</span><span pid="556" class="highlight highlight-c">what about</span><span>now</span><span>?</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 277, 678.727, 679.81, 'So-- and they''re like, OK.', '然后——他们就说，好吧。', '/soʊ ænd ðeɪr laɪk oʊˈkeɪ/', '<span>So</span><span>--</span><span>and</span><span pid="557" class="highlight highlight-i">they''re like</span><span>,</span><span>OK</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 278, 679.81, 680.71, 'In you come.', '进来吧。', '/ɪn juː kʌm/', '<span>In</span><span>you</span><span>come</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 279, 680.71, 685.27, 'I''m like-- so-- Snickers work.', '我就——所以——士力架管用。', '/aɪm laɪk soʊ ˈsnɪkərz wɜːrk/', '<span pid="558" class="highlight highlight-i">I''m like</span><span>--</span><span>so</span><span>--</span><span>Snickers</span><span>work</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 280, 685.27, 687.96, 'Wildly irresponsible as well, and you''re all cheering.', '同样极其不负责任，而你们都在欢呼。', '/ˈwaɪldli ˌɪrɪˈspɑnsəbəl æz wɛl, ænd jʊr ɔːl ˈtʃɪrɪŋ/', '<span tid="50190" class="highlight highlight-a">Wildly</span><span tid="50191" class="highlight highlight-a">irresponsible</span><span pid="559" class="highlight highlight-c">as well</span><span>,</span><span>and</span><span>you''re</span><span>all</span><span tid="50192" class="highlight highlight-a">cheering</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 281, 687.96, 689.34, 'It gets worse. Right?', '情况更糟了。对吧？', '/ɪt ˈɡɛts wɜːrs. raɪt/', '<span>It</span><span>gets</span><span tid="50193" class="highlight highlight-a">worse</span><span>.</span><span>Right</span><span>?</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 282, 689.34, 689.82, 'OK. Go on.', '好的。继续说。', '/oʊˈkeɪ. ɡoʊ ɑn/', '<span>OK</span><span>.</span><span pid="560" class="highlight highlight-d">Go on</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 283, 689.82, 691.32, 'So I was sitting in the chair.', '所以我当时坐在椅子上。', '/soʊ aɪ wəz ˈsɪtɪŋ ɪn ðə tʃɛr/', '<span>So</span><span>I</span><span>was</span><span>sitting</span><span>in</span><span>the</span><span>chair</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 284, 691.32, 694.56, 'And this thing-- it''s, you know, I don''t know how many hundreds of feet high, and whatever. SCARLETT JOHANSSON: Oh god.', '而这个东西——它，你知道，我不知道它有多少百英尺高，等等。斯嘉丽·约翰逊：哦天哪。', '/ænd ðɪs θɪŋ-- ɪts, ju noʊ, aɪ doʊnt noʊ haʊ ˈmɛni ˈhʌndrədz əv fit haɪ, ænd wʌtˈɛvər. skɑrˈlɛt ˈdʒoʊnsən: oʊ ɡɑd/', '<span>And</span><span>this</span><span>thing</span><span>--</span><span>it''s</span><span>,</span><span pid="561" class="highlight highlight-i">you know</span><span>,</span><span>I</span><span pid="562" class="highlight highlight-d">don''t know</span><span pid="563" class="highlight highlight-l">how many</span><span tid="50194" class="highlight highlight-a">hundreds</span><span>of</span><span>feet</span><span>high</span><span>,</span><span>and</span><span>whatever</span><span>.</span><span>SCARLETT JOHANSSON</span><span>:</span><span pid="564" class="highlight highlight-i">Oh god</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 285, 694.56, 695.72, 'We''re at the top. And I''m looking at her.', '我们在顶端。而我看着她。', '/wiːr æt ðə tɑp. ænd aɪm ˈlʊkɪŋ æt hər/', '<span>We''re</span><span>at</span><span>the</span><span>top</span><span>.</span><span>And</span><span>I''m</span><span pid="565" class="highlight highlight-d">looking at</span><span>her</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 286, 695.72, 696.62, 'She''s strapped in.', '她被绑在座位上。', '/ʃiz stræpt ɪn/', '<span>She''s</span><span pid="566" class="highlight highlight-d">strapped in</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 287, 696.62, 698.75, 'And, you know, the seat is massive on her.', '而且，你知道，那个座位对她来说非常大。', '/ænd, ju noʊ, ðə sit ɪz ˈmæsɪv ɑn hər/', '<span>And</span><span>,</span><span pid="567" class="highlight highlight-i">you know</span><span>,</span><span>the</span><span>seat</span><span>is</span><span tid="50195" class="highlight highlight-a">massive</span><span>on</span><span>her</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 288, 698.75, 701.72, 'And I''m like, you know, we beat the system, honey.', '我就说，你知道吗，我们打败了系统，亲爱的。', '/ænd aɪm laɪk ju noʊ wi biːt ðə ˈsɪstəm ˈhʌni/', '<span>And</span><span pid="568" class="highlight highlight-i">I''m like</span><span>,</span><span pid="569" class="highlight highlight-i">you know</span><span>,</span><span>we</span><span tid="50196" class="highlight highlight-a">beat</span><span>the</span><span tid="50197" class="highlight highlight-a">system</span><span>,</span><span>honey</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 289, 701.72, 703.852, 'And then it drops and she''s like zoop.', '然后它掉下来，她就像‘嗖’的一声。', '/ænd ðɛn ɪt drɑːps ænd ʃiːz laɪk zuːp/', '<span>And</span><span>then</span><span>it</span><span tid="50198" class="highlight highlight-a">drops</span><span>and</span><span pid="570" class="highlight highlight-i">she''s like</span><span tid="50199" class="highlight highlight-a">zoop</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 290, 703.852, 705.9, '[LAUGHTER] Grab on to her.', '[笑声] 抓住她。', '/ɡræb ɑːn tu hɜːr/', '<span>[LAUGHTER]</span><span pid="571" class="highlight highlight-d">Grab on to</span><span>her</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 291, 705.9, 708.023, 'She''s like screaming the whole way down, like cat.', '她一路尖叫着下来，像猫一样。', '/ʃiːz laɪk skriːmɪŋ ðə hoʊl weɪ daʊn laɪk kæt/', '<span pid="572" class="highlight highlight-i">She''s like</span><span tid="50200" class="highlight highlight-a">screaming</span><span pid="573" class="highlight highlight-c">the whole way down</span><span>,</span><span>like</span><span>cat</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 292, 708.023, 710.19, 'You know.', '你知道吗。', '/ju noʊ/', '<span pid="574" class="highlight highlight-i">You know</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 293, 710.19, 713.22, 'I was like, maybe there''s a reason that there''s a height.', '我就想，也许有身高限制是有原因的。', '/aɪ wʌz laɪk ˈmeɪbi ðɛrz ə ˈriːzən ðæt ðɛrz ə haɪt/', '<span pid="575" class="highlight highlight-i">I was like</span><span>,</span><span>maybe</span><span>there''s</span><span>a</span><span tid="50201" class="highlight highlight-a">reason</span><span>that</span><span>there''s</span><span>a</span><span tid="50202" class="highlight highlight-a">height</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 294, 713.22, 714.12, 'Maybe!', '也许吧！', '/ˈmeɪbi/', '<span>Maybe</span><span>!</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 295, 714.12, 715.53, 'Size.', '尺寸。', '/saɪz/', '<span tid="50203" class="highlight highlight-a">Size</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 296, 715.53, 717.39, 'So don''t do that.', '所以别那样做。', '/soʊ doʊnt duː ðæt/', '<span>So</span><span>don''t</span><span tid="50204" class="highlight highlight-a">do</span><span>that.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 297, 717.39, 718.62, 'Don''t do that. She''s fine.', '别那样做。她没事。', '/doʊnt duː ðæt ʃiːz faɪn/', '<span>Don''t</span><span tid="50205" class="highlight highlight-a">do</span><span>that.</span><span>She''s</span><span tid="50206" class="highlight highlight-a">fine.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 298, 718.62, 721.29, 'She''s well. She''s-- I mean, hones-- Woo-hoo.', '她很好。她——我是说，老实——呜呼。', '/ʃiːz wɛl ʃiːz aɪ miːn hʌnst wuː huː/', '<span>She''s</span><span tid="50207" class="highlight highlight-a">well.</span><span>She''s--</span><span>I</span><span>mean,</span><span>hones--</span><span>Woo-hoo.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 299, 721.29, 721.63, 'Go Chris.', '加油克里斯。', '/ɡoʊ krɪs/', '<span>Go</span><span>Chris.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 300, 721.63, 722.86, 'JIMMY KIMMEL: Snickers bars in the shoes.', '吉米·坎摩尔：鞋子里的士力架。', '/ˈdʒɪmi ˈkɪməl ˈsnɪkərz bɑːrz ɪn ðə ʃuːz/', '<span>JIMMY</span><span>KIMMEL:</span><span tid="50208" class="highlight highlight-a">Snickers</span><span>bars</span><span>in</span><span>the</span><span>shoes.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 301, 722.86, 723.93, 'Yes. Up here.', '是的。在这儿。', '/jɛs ʌp hɪr/', '<span>Yes.</span><span>Up</span><span>here.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 302, 723.93, 725.61, 'I love it. - I''m her hero.', '我喜欢。 - 我是她的英雄。', '/aɪ lʌv ɪt aɪm hɜr ˈhɪroʊ/', '<span>I</span><span tid="50209" class="highlight highlight-a">love</span><span>it.</span><span>-</span><span>I''m</span><span>her</span><span tid="50210" class="highlight highlight-a">hero.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 303, 725.61, 727.11, 'I have to say, it''s very creative.', '我不得不说，这非常有创意。', '/aɪ hæv tə seɪ ɪts ˈvɛri kriˈeɪtɪv/', '<span>I</span><span>have</span><span>to</span><span>say,</span><span>it''s</span><span>very</span><span tid="50211" class="highlight highlight-a">creative.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 304, 727.11, 728.49, 'The Snickers bars in the shoes.', '鞋子里的士力架巧克力棒。', '/ðə ˈsnɪkərz bɑːrz ɪn ðə ʃuːz/', '<span>The</span><span tid="50212" class="highlight highlight-a">Snickers</span><span>bars</span><span>in</span><span>the</span><span>shoes.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 305, 728.49, 730.192, 'That really is-- in a pinch.', '那确实是——在紧急情况下。', '/ðæt ˈrɪli ɪz ɪn ə pɪntʃ/', '<span>That</span><span>really</span><span>is--</span><span>in</span><span>a</span><span tid="50213" class="highlight highlight-i">pinch.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 306, 730.192, 731.15, 'That''s the last time.', '那是最后一次了。', '/ðæts ðə læst taɪm/', '<span>That''s</span><span>the</span><span>last</span><span>time.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 307, 731.15, 733.802, 'Paul, you had a birthday this week.', '保罗，你这周过生日了。', '/pɔːl ju hæd ə ˈbɜːrθdeɪ ðɪs wiːk/', '<span>Paul,</span><span>you</span><span>had</span><span>a</span><span>birthday</span><span>this</span><span>week.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 308, 733.802, 735.51, 'And Robert, you had a birthday this week.', '罗伯特，你这周过生日了。', '/ˈrɑːbərt ju hæd ə ˈbɜːrθdeɪ ðɪs wiːk/', '<span>And</span><span>Robert,</span><span>you</span><span>had</span><span>a</span><span>birthday</span><span>this</span><span>week.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 309, 735.51, 737.772, 'Yes.', '是的。', '/jɛs/', '<span>Yes.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 310, 737.772, 739.605, 'JIMMY KIMMEL: Happy birthday to both of you.', '吉米·坎摩尔：祝你们俩生日快乐。', '/ˈdʒɪmi ˈkɪməl ˈhæpi ˈbɜːrθdeɪ tuː boʊθ əv juː/', '<span>JIMMY</span><span>KIMMEL:</span><span>Happy</span><span>birthday</span><span>to</span><span>both</span><span>of</span><span>you.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 311, 739.605, 740.97, 'Thank you.', '谢谢。', '/θæŋk juː/', '<span>Thank</span><span>you.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 312, 740.97, 744.4, 'You have to be very difficult to shop for, I would imagine.', '我想你肯定很难买礼物。', '/juː hæv tə biː ˈvɛri ˈdɪfɪkəlt tə ʃɑːp fɔːr, aɪ wʊd ɪˈmædʒɪn/', '<span>You</span><span pid="576" class="highlight highlight-d">have to</span><span>be</span><span>very</span><span tid="50214" class="highlight highlight-a">difficult</span><span>to</span><span>shop</span><span>for</span><span>,</span><span>I</span><span>would</span><span tid="50215" class="highlight highlight-a">imagine</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 313, 744.4, 745.3, 'Oh.', '哦。', '/oʊ/', '<span>Oh</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 314, 745.3, 747.18, 'I brought some pictures.', '我带了些照片来。', '/aɪ brɔːt sʌm ˈpɪktʃərz/', '<span>I</span><span tid="50216" class="highlight highlight-a">brought</span><span>some</span><span>pictures</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 315, 747.18, 748.56, 'Scarlett never forgets.', '斯嘉丽从不忘记。', '/skɑːrlɛt ˈnɛvər fərˈɡɛts/', '<span>Scarlett</span><span>never</span><span tid="50217" class="highlight highlight-a">forgets</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 316, 748.56, 753.81, 'This year she got me a lovely bouquet of my favorites, which are-- - Of sunflowers? - Sunflowers.', '今年她送了我一束我最喜欢的花，是—— - 向日葵？ - 向日葵。', '/ðɪs jɪr ʃiː ɡɑːt miː ə ˈlʌvli buːˈkeɪ əv maɪ ˈfeɪvərɪts, wɪtʃ ɑːr-- - ʌv ˈsʌnflaʊərz? - ˈsʌnflaʊərz/', '<span>This</span><span>year</span><span>she</span><span>got</span><span>me</span><span>a</span><span tid="50218" class="highlight highlight-a">lovely</span><span tid="50219" class="highlight highlight-a">bouquet</span><span>of</span><span>my</span><span>favorites</span><span>,</span><span>which</span><span>are</span><span>--</span><span>-</span><span>Of</span><span>sunflowers</span><span>?</span><span>-</span><span>Sunflowers</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 317, 753.81, 754.78, 'Yeah. - Nice.', '是的。 - 不错。', '/jɛs. - naɪs/', '<span>Yeah</span><span>.</span><span>-</span><span>Nice</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 318, 754.78, 755.68, 'That is nice.', '那很好。', '/ðæt ɪz naɪs/', '<span>That</span><span>is</span><span>nice</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 319, 755.68, 760.05, 'And then cause I''m the fourth and Paul is the sixth, I got him a little framed art piece.', '然后因为我是四号，保罗是六号，我送了他一个小画框。', '/ænd ðɛn kɔːz aɪm ðə fɔːrθ ænd pɔːl ɪz ðə sɪksθ, aɪ ɡɑːt hɪm ə ˈlɪtəl freɪmd ɑːrt piːs/', '<span>And</span><span>then</span><span>cause</span><span>I</span><span>''m</span><span>the</span><span>fourth</span><span>and</span><span>Paul</span><span>is</span><span>the</span><span>sixth</span><span>,</span><span>I</span><span>got</span><span>him</span><span>a</span><span>little</span><span tid="50220" class="highlight highlight-a">framed</span><span>art</span><span>piece</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 320, 760.05, 761.49, 'Did you like it? - I loved it.', '你喜欢吗？——我很喜欢。', '/dɪd juː laɪk ɪt? - aɪ lʌvd ɪt/', '<span>Did</span><span>you</span><span tid="50221" class="highlight highlight-a">like</span><span>it</span><span>?</span><span>-</span><span>I</span><span tid="50222" class="highlight highlight-a">loved</span><span>it</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 321, 761.49, 762.39, 'Gorgeous.', '太美了。', '/ˈɡɔːrdʒəs/', '<span tid="50223" class="highlight highlight-a">Gorgeous</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 322, 762.39, 763.89, 'Really, really, really, really nice.', '真的，真的，真的，非常好。', '/ˈrɪli, ˈrɪli, ˈrɪli, ˈrɪli naɪs/', '<span>Really,</span><span>really,</span><span>really,</span><span>really</span><span>nice.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 323, 763.89, 764.79, 'I was very touched.', '我深受感动。', '/aɪ wʌz ˈvɛri tʌtʃt/', '<span>I</span><span>was</span><span>very</span><span tid="50224" class="highlight highlight-a">touched</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 324, 764.79, 769.083, 'And then I had gotten him that alpaca that he wanted, because that''s his favorite animal.', '然后我给他买了那只他想要的羊驼，因为那是他最喜欢的动物。', '/ænd ðɛn aɪ hæd ˈɡɑtən hɪm ðæt ˈælpækə ðæt hiː ˈwɑntɪd, bɪˈkɔz ðæts hɪz ˈfeɪvərɪt ˈænɪməl/', '<span>And</span><span>then</span><span>I</span><span>had</span><span>gotten</span><span>him</span><span>that</span><span tid="50225" class="highlight highlight-a">alpaca</span><span>that</span><span>he</span><span>wanted</span><span>,</span><span>because</span><span>that''s</span><span>his</span><span tid="50226" class="highlight highlight-a">favorite</span><span>animal</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 325, 769.083, 770.0, '- Oh, my gosh. - Oh.', '——哦，天哪。——哦。', '/- oʊ, maɪ ɡɑʃ. - oʊ/', '<span>-</span><span>Oh</span><span>,</span><span>my</span><span tid="50227" class="highlight highlight-i">gosh</span><span>.</span><span>-</span><span>Oh</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 326, 770.0, 773.92, 'You got Paul an-- - That was-- That was-- That really blew me away.', '你给保罗买了……——那真是……那真是……那真的让我大吃一惊。', '/juː ɡɑt pɔːl æn-- - ðæt wʌz-- ðæt wʌz-- ðæt ˈrɪli bloʊ miː əˈweɪ/', '<span>You</span><span>got</span><span>Paul</span><span>an--</span><span>-</span><span>That</span><span>was--</span><span>That</span><span>was--</span><span>That</span><span>really</span><span>blew</span><span>me</span><span>away.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 327, 773.92, 778.86, 'I named him-- I named him Dennis. [LAUGHTER] JIMMY KIMMEL: Oh, that''s nice. - He''s got a bit of an attitude.', '我给他取名……我给他取名丹尼斯。[笑声] 吉米·坎摩尔：哦，真好。——他有点脾气。', '/aɪ neɪmd hɪm-- aɪ neɪmd hɪm ˈdɛnɪs. [ˈlæftər] ˈdʒɪmi ˈkɪməl: oʊ, ðæts naɪs. - hiːz ɡɑt ə bɪt əv ən ˈætɪtud/', '<span>I</span><span>named</span><span>him</span><span>-</span><span>-</span><span>I</span><span>named</span><span>him</span><span>Dennis</span><span>.</span><span>[LAUGHTER]</span><span>JIMMY</span><span>KIMMEL</span><span>:</span><span>Oh</span><span>,</span><span>that''s</span><span>nice</span><span>.</span><span>-</span><span>He''s</span><span>got</span><span>a</span><span>bit</span><span>of</span><span>an</span><span tid="50228" class="highlight highlight-a">attitude</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 328, 778.86, 779.76, 'But he''s fun.', '但他很有趣。', '/bʌt hiz fʌn/', '<span>But</span><span>he''s</span><span>fun.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 329, 779.76, 780.75, 'And he-- you know.', '而且他——你知道的。', '/ænd hi ju noʊ/', '<span>And</span><span>he--</span><span pid="577" class="highlight highlight-i">you know.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 330, 780.75, 786.6, 'And I was so moved that I remember I think I got you, in return-- I feel, you know, a little bad, just reciprocal,', '而且我深受感动，我记得我好像给你买了——作为回报——我觉得，你知道，有点不好意思，只是礼尚往来，', '/ænd aɪ wʌz soʊ ˈmoʊvɪd ðæt aɪ rɪˈmɛmbər aɪ θɪŋk aɪ gɑt ju ɪn rɪˈtɜːrn aɪ fil ju noʊ ə ˈlɪtəl bæd dʒʌst rɪˈsɪprəkəl/', '<span>And</span><span>I</span><span>was</span><span>so</span><span tid="50229" class="highlight highlight-a">moved</span><span>that</span><span>I</span><span>remember</span><span>I</span><span>think</span><span>I</span><span>got</span><span>you,</span><span>in</span><span>return--</span><span>I</span><span>feel,</span><span pid="578" class="highlight highlight-i">you know,</span><span>a</span><span>little</span><span>bad,</span><span>just</span><span tid="50230" class="highlight highlight-a">reciprocal,</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 331, 786.6, 788.44, 'but I got you a balloon. - That''s right.', '但我给你买了个气球。——没错。', '/bʌt aɪ gɑt ju ə bəˈluːn ðæts raɪt/', '<span>but</span><span>I</span><span>got</span><span>you</span><span>a</span><span>balloon.</span><span>-</span><span>That''s</span><span>right.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 332, 788.44, 789.03, 'He bought her a hot air balloon.', '他给她买了一个热气球。', '/hi bɔːt hər ə hɑt ɛr bəˈluːn/', '<span>He</span><span>bought</span><span>her</span><span>a</span><span>hot</span><span>air</span><span>balloon.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 333, 789.03, 790.213, 'A hot air balloon.', '一个热气球。', '/ə hɑt ɛr bəˈluːn/', '<span>A</span><span>hot</span><span>air</span><span>balloon.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 334, 790.213, 791.88, 'There I am smiling back at the ground.', '我正对着地面微笑。', '/ðɛr aɪ æm ˈsmaɪlɪŋ bæk æt ðə graʊnd/', '<span>There</span><span>I</span><span>am</span><span>smiling</span><span>back</span><span>at</span><span>the</span><span>ground.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 335, 791.88, 794.76, 'But this year-- this year they really blew my mind.', '但今年——今年他们真的让我大吃一惊。', '/bʌt ðɪs jɪr ðɪs jɪr ðeɪ ˈrɪli blu maɪ maɪnd/', '<span>But</span><span>this</span><span>year--</span><span>this</span><span>year</span><span>they</span><span>really</span><span tid="50231" class="highlight highlight-a">blew</span><span>my</span><span>mind.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 336, 794.76, 796.11, 'Yeah. Well, that''s right.', '是啊。嗯，没错。', '/jæ wɛl ðæts raɪt/', '<span>Yeah.</span><span>Well,</span><span>that''s</span><span>right.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 337, 796.11, 798.06, 'We had planned that together.', '我们之前一起计划好的。', '/wi hæd plænd ðæt təˈɡɛðər/', '<span>We</span><span>had</span><span tid="50232" class="highlight highlight-a">planned</span><span>that</span><span>together.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 338, 798.06, 798.96, 'We both chipped in.', '我们都凑了钱。', '/wi boʊθ tʃɪpt ɪn/', '<span>We</span><span>both</span><span tid="50233" class="highlight highlight-d">chipped</span><span>in.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 339, 798.96, 802.47, 'Then we got him this super yacht, which he-- was the one toy he-- - Oh, my god.', '然后我们给他买了这艘超级游艇，这是他——他唯一的玩具——哦，我的天。', '/ðɛn wi ɡɑːt hɪm ðɪs ˈsupər jɑːt wɪtʃ hi wʌz ðə wʌn tɔɪ hi oʊ maɪ ɡɑːd/', '<span>Then</span><span>we</span><span>got</span><span>him</span><span>this</span><span tid="50234" class="highlight highlight-a">super</span><span tid="50235" class="highlight highlight-a">yacht,</span><span>which</span><span>he--</span><span>was</span><span>the</span><span>one</span><span>toy</span><span>he--</span><span>-</span><span>Oh,</span><span>my</span><span>god.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 340, 802.47, 803.94, 'You did. - Yeah.', '你们确实送了。 - 是啊。', '/ju dɪd jɛ/', '<span>You</span><span>did.</span><span>-</span><span>Yeah.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 341, 803.94, 804.9, '- Oh, that''s cool. - Yeah.', '- 哦，那很酷。 - 是啊。', '/oʊ ðæts kul jɛ/', '<span>-</span><span>Oh,</span><span>that''s</span><span>cool.</span><span>-</span><span>Yeah.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 342, 804.9, 806.12, '- And then-- - That is quite a gift.', '- 然后—— - 那真是份大礼。', '/ænd ðɛn ðæt ɪz kwaɪt ə ɡɪft/', '<span>-</span><span>And</span><span>then--</span><span>-</span><span>That</span><span>is</span><span>quite</span><span>a</span><span>gift.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 343, 806.12, 810.81, 'Just to get ahead of next year, I thought-- and just-- this is a bit of a surprise to the show, I got the two', '为了提前准备明年，我想——而且——这对节目来说有点意外，我得到了这两个', '/dʒʌst tə ɡɛt əhɛd əv nɛr jɪr aɪ θɔːt ænd dʒʌst ðɪs ɪz ə bɪt əv ə sərˈpraɪz tə ðə ʃoʊ aɪ ɡɑːt ðə tu/', '<span>Just</span><span>to</span><span>get</span><span tid="50236" class="highlight highlight-c">ahead</span><span>of</span><span>next</span><span>year,</span><span>I</span><span>thought--</span><span>and</span><span>just--</span><span>this</span><span>is</span><span>a</span><span>bit</span><span>of</span><span>a</span><span tid="50237" class="highlight highlight-a">surprise</span><span>to</span><span>the</span><span>show,</span><span>I</span><span>got</span><span>the</span><span>two</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 344, 810.81, 812.464, 'of you the Buffalo Bills. - Oh, my god.', '你，布法罗比尔队。哦，我的天哪。', '/əv juː ðə ˈbʌfəloʊ bɪlz. oʊ, maɪ ɡɑd/', '<span>of</span><span>you</span><span>the</span><span tid="50238" class="highlight highlight-a">Buffalo</span><span tid="50239" class="highlight highlight-a">Bills.</span><span>-</span><span>Oh,</span><span>my</span><span tid="50240" class="highlight highlight-i">god.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 345, 812.464, 813.364, 'That''s his favorite.', '那是他最喜欢的。', '/ðæts hɪz ˈfeɪvərɪt/', '<span>That''s</span><span>his</span><span tid="50241" class="highlight highlight-a">favorite.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 346, 813.364, 814.382, 'No way!', '不可能！', '/noʊ weɪ/', '<span>No</span><span tid="50242" class="highlight highlight-i">way!</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 347, 814.382, 816.234, 'What?', '什么？', '/wʌt/', '<span>What?</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 348, 816.234, 817.65, 'A football team.', '一支橄榄球队。', '/ə ˈfʊtbɔːl tiːm/', '<span>A</span><span>football</span><span>team.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 349, 817.65, 819.23, 'Is that-- is that OK?', '那——那可以吗？', '/ɪz ðæt-- ɪz ðæt oʊˈkeɪ/', '<span>Is</span><span>that--</span><span>is</span><span>that</span><span tid="50243" class="highlight highlight-a">OK?</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 350, 819.23, 821.15, 'Nobody got Chris anything, though, huh?', '不过没人给克里斯买任何东西，是吧？', '/ˈnoʊbɑdi ɡɑt krɪs ˈɛniθɪŋ, ðoʊ, hʌ/', '<span>Nobody</span><span>got</span><span>Chris</span><span>anything,</span><span>though,</span><span>huh?</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 351, 821.15, 822.38, 'I think it''s-- well, I''m a Chiefs fan.', '我觉得——嗯，我是酋长队的粉丝。', '/aɪ θɪŋk ɪts-- wɛl, aɪm ə tʃiːfs fæn/', '<span>I</span><span>think</span><span>it''s--</span><span>well,</span><span>I''m</span><span>a</span><span tid="50244" class="highlight highlight-a">Chiefs</span><span>fan.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 352, 822.38, 824.085, 'But you know what? It''s not a division rival.', '但你知道吗？这不是同区对手。', '/bʌt juː noʊ wʌt ɪts nɑːt ə dɪˈvɪʒən ˈraɪvəl/', '<span>But</span><span>you</span><span pid="579" class="highlight highlight-i">know what</span><span>?</span><span>It</span><span>''s</span><span>not</span><span>a</span><span tid="50245" class="highlight highlight-a">division</span><span tid="50246" class="highlight highlight-a">rival</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 353, 824.085, 825.89, 'I''m happy. This is really-- OK. Great.', '我很开心。这真是——好的。太棒了。', '/aɪm ˈhæpi ðɪs ɪz ˈrɪli oʊkeɪ ɡreɪt/', '<span>I</span><span>''m</span><span>happy</span><span>.</span><span>This</span><span>is</span><span>really</span><span>--</span><span>OK</span><span>.</span><span>Great</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 354, 825.89, 826.36, '- This is really sweet. - Yeah.', '- 这真的很贴心。 - 是的。', '/ðɪs ɪz ˈrɪli swiːt jɛə/', '<span>-</span><span>This</span><span>is</span><span>really</span><span tid="50247" class="highlight highlight-a">sweet</span><span>.</span><span>-</span><span>Yeah</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 355, 826.36, 827.41, 'What he just said.', '他刚才说的。', '/wʌt hiː dʒʌst sɛd/', '<span>What</span><span>he</span><span>just</span><span>said</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 356, 827.41, 828.65, 'Nothing for Chris.', '克里斯什么都没有。', '/ˈnʌθɪŋ fɔːr krɪs/', '<span>Nothing</span><span>for</span><span>Chris</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 357, 828.65, 830.54, 'Interesting. Nothing at all for Chris.', '有意思。克里斯什么都没有。', '/ˈɪntrəstɪŋ ˈnʌθɪŋ æt ɔːl fɔːr krɪs/', '<span tid="50248" class="highlight highlight-a">Interesting</span><span>.</span><span>Nothing</span><span pid="580" class="highlight highlight-c">at all</span><span>for</span><span>Chris</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 358, 830.54, 831.59, 'Oh, you know what? Yeah.', '哦，你知道吗？是的。', '/oʊ juː noʊ wʌt jɛə/', '<span>Oh</span><span>,</span><span>you</span><span pid="581" class="highlight highlight-i">know what</span><span>?</span><span>Yeah</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 359, 831.59, 833.56, 'I got you something, Robert. Here you go.', '我给你买了点东西，罗伯特。给你。', '/aɪ ɡɑːt juː ˈsʌmθɪŋ ˈrɑːbərt hɪr jə ɡoʊ/', '<span>I</span><span>got</span><span>you</span><span>something</span><span>,</span><span>Robert</span><span>.</span><span>Here</span><span>you</span><span>go</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 360, 833.56, 834.46, 'Oh, my gosh.', '哦，我的天哪。', '/oʊ maɪ ɡɑːʃ/', '<span>Oh,</span><span>my</span><span>gosh.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 361, 834.46, 835.434, 'Incredible.', '难以置信。', '/ɪnˈkrɛdəbəl/', '<span>Incredible.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 362, 835.434, 838.917, '[GUITAR NOTE] [APPLAUSE]', '[吉他音符] [掌声]', '/ɡɪˈtɑːr noʊt æpˈlɔːz/', '<span>[GUITAR NOTE]</span><span>[APPLAUSE]</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 363, 839.817, 841.765, 'Wow.', '哇。', '/waʊ/', '<span>Wow.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 364, 841.765, 842.739, 'That''s really nice.', '那真的很不错。', '/ðæts ˈrɪli naɪs/', '<span>That''s</span><span>really</span><span>nice.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 365, 850.55, 853.848, 'And Hemsworth, I''ve like met the guy twice.', '而且海姆斯沃斯，我见过那家伙两次。', '/ænd ˈhɛmzwɜːrθ aɪv laɪk mɛt ðə ɡaɪ twaɪs/', '<span>And</span><span>Hemsworth,</span><span>I''ve</span><span>like</span><span>met</span><span>the</span><span>guy</span><span>twice.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 366, 853.848, 854.89, 'So you should be ashamed.', '所以你应该感到羞愧。', '/soʊ juː ʃʊd biː əˈʃeɪmd/', '<span>So</span><span>you</span><span>should</span><span>be</span><span>ashamed.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 367, 854.89, 855.99, '- Well-- - Hey.', '- 嗯-- - 嘿。', '/wɛl heɪ/', '<span>-</span><span>Well--</span><span>-</span><span>Hey.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 368, 855.99, 856.48, 'Wait. Wait.', '等等。等等。', '/weɪt weɪt/', '<span>Wait.</span><span>Wait.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 369, 856.48, 857.62, 'I did get you a present.', '我确实给你买了礼物。', '/aɪ dɪd ɡɛt juː ə ˈprɛzənt/', '<span>I</span><span>did</span><span>get</span><span>you</span><span>a</span><span tid="50249" class="highlight highlight-a">present.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 370, 857.62, 861.53, 'But it''s like, the postal service from Australia to here is like wha.', '但是，从澳大利亚到这里的邮政服务就像，哇。', '/bʌt ɪts laɪk ðə ˈpoʊstəl ˈsɜːrvɪs frəm ɔːˈstreɪliə tə hɪr ɪz laɪk wʌ/', '<span>But</span><span>it''s</span><span>like,</span><span>the</span><span pid="582" class="highlight highlight-a">postal service</span><span>from</span><span>Australia</span><span>to</span><span>here</span><span>is</span><span>like</span><span>wha.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 371, 861.53, 865.04, 'So it might have ended up-- Sounds like a damn lie to me.', '所以它可能已经——听起来像是个该死的谎言。', '/soʊ ɪt maɪt hæv ˈɛndɪd ʌp saʊndz laɪk ə dæm laɪn tə miː/', '<span>So</span><span>it</span><span>might</span><span>have</span><span pid="583" class="highlight highlight-d">ended up--</span><span>Sounds</span><span>like</span><span>a</span><span>damn</span><span tid="50250" class="highlight highlight-a">lie</span><span>to</span><span>me.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 372, 865.04, 867.12, 'And-- and then.', '然后——然后。', '/ænd ænd ðɛn/', '<span>And--</span><span>and</span><span>then.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 373, 867.12, 868.727, 'I did actually-- ah. Tricking.', '我确实——啊。骗你的。', '/aɪ dɪd ˈækʃuəli ɑː ˈtrɪkɪŋ/', '<span>I</span><span>did</span><span>actually--</span><span>ah.</span><span tid="50251" class="highlight highlight-a">Tricking.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 374, 868.727, 869.627, 'Just kidding.', '开玩笑的。', '/dʒʌst ˈkɪdɪŋ/', '<span>Just</span><span tid="50252" class="highlight highlight-i">kidding.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 375, 869.627, 874.34, '[LAUGHTER] [APPLAUSE] Wow.', '[笑声] [掌声] 哇。', '/ˈlæftər ˈæplɔːz waʊ/', '<span>[LAUGHTER]</span><span>[APPLAUSE]</span><span>Wow.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 376, 874.34, 876.0, 'That''s great, cause it''s tape.', '那太好了，因为这是胶带。', '/ðæts ɡreɪt kɔːz ɪts teɪp/', '<span>That''s</span><span tid="50253" class="highlight highlight-a">great</span><span>,</span><span>cause</span><span>it''s</span><span tid="50254" class="highlight highlight-a">tape</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 377, 876.0, 877.974, 'And you always need tape for stuff.', '而且你总是需要胶带做东西。', '/ænd juː ˈɔːlweɪz niːd teɪp fɔːr stʌf/', '<span>And</span><span>you</span><span>always</span><span>need</span><span tid="50255" class="highlight highlight-a">tape</span><span>for</span><span tid="50256" class="highlight highlight-a">stuff</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 378, 877.974, 881.09, '[LAUGHING] - We''ll share that. - Yeah.', '[笑] - 我们会分享那个。 - 是的。', '/wiːl ʃer ðæt jɛə/', '<span>[LAUGHING]</span><span>-</span><span>We''ll</span><span tid="50257" class="highlight highlight-a">share</span><span>that</span><span>.</span><span>-</span><span>Yeah</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 379, 881.09, 881.99, 'It''s a whole roll.', '这是一整卷。', '/ɪts ə hoʊl roʊl/', '<span>It''s</span><span>a</span><span tid="50258" class="highlight highlight-a">whole</span><span tid="50259" class="highlight highlight-a">roll</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 380, 881.99, 883.505, 'It''s expensive in Australia.', '在澳大利亚很贵。', '/ɪts ɪkˈspɛnsɪv ɪn ɔːˈstreɪliə/', '<span>It''s</span><span tid="50260" class="highlight highlight-a">expensive</span><span>in</span><span>Australia</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 381, 883.505, 886.08, '[LAUGHING] It''s very expensive there.', '[笑] 那里非常贵。', '/ɪts ˈvɛri ɪkˈspɛnsɪv ðɛr/', '<span>[LAUGHING]</span><span>It''s</span><span>very</span><span tid="50261" class="highlight highlight-a">expensive</span><span>there</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 382, 886.08, 887.14, 'It''s very rare there.', '那里非常稀有。', '/ɪts ˈvɛri rɛr ðɛr/', '<span>It''s</span><span>very</span><span tid="50262" class="highlight highlight-a">rare</span><span>there</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 383, 887.14, 889.27, 'They don''t find it in nature in Australia.', '在澳大利亚的自然界中找不到它们。', '/ðeɪ doʊnt faɪnd ɪt ɪn ˈneɪtʃər ɪn ɔːˈstreɪliə/', '<span>They</span><span>don''t</span><span>find</span><span>it</span><span>in</span><span tid="50263" class="highlight highlight-a">nature</span><span>in</span><span>Australia</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 384, 889.27, 893.26, 'Scarlett, when does the Black-- when does the Black Widow movie starts shooting?', '斯嘉丽，《黑寡妇》什么时候—— 《黑寡妇》电影什么时候开拍？', '/ˈskɑːrlɪt wɛn dʌz ðə blæk wɛn dʌz ðə blæk ˈwɪdoʊ ˈmuːvi stɑːrts ˈʃuːtɪŋ/', '<span>Scarlett,</span><span>when</span><span>does</span><span>the</span><span>Black--</span><span>when</span><span>does</span><span>the</span><span pid="584" class="highlight highlight-a">Black Widow</span><span>movie</span><span pid="585" class="highlight highlight-d">starts shooting?</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 385, 893.26, 894.16, 'When what?', '什么时候什么？', '/wɛn wʌt/', '<span>When</span><span>what?</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 386, 894.16, 896.13, 'JIMMY KIMMEL: When does the Black Widow movie start shooting?', '吉米·坎摩尔：《黑寡妇》电影什么时候开拍？', '/ˈdʒɪmi ˈkɪməl wɛn dʌz ðə blæk ˈwɪdoʊ ˈmuːvi stɑːrt ˈʃuːtɪŋ/', '<span>JIMMY KIMMEL:</span><span>When</span><span>does</span><span>the</span><span pid="586" class="highlight highlight-a">Black Widow</span><span>movie</span><span pid="587" class="highlight highlight-d">start shooting?</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 387, 896.13, 897.76, '- Where when? - The one you''re in.', '- 哪里什么时候？ - 你参演的那部。', '/wɛr wɛn ðə wʌn jʊr ɪn/', '<span>-</span><span>Where</span><span>when?</span><span>-</span><span pid="588" class="highlight highlight-l">The one</span><span pid="589" class="highlight highlight-l">you''re in.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 388, 897.76, 898.78, 'The Black Widow movie.', '《黑寡妇》电影。', '/ðə blæk ˈwɪdoʊ ˈmuːvi/', '<span>The</span><span pid="590" class="highlight highlight-a">Black Widow</span><span>movie.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 389, 898.78, 900.25, 'You know, your own like movie.', '你知道，你自己的电影。', '/ju noʊ jɔːr oʊn laɪk ˈmuːvi/', '<span pid="591" class="highlight highlight-i">You know,</span><span pid="592" class="highlight highlight-c">your own</span><span>like</span><span>movie.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 390, 900.25, 901.822, 'Everybody''s had their own movie.', '每个人都有自己的电影。', '/ˈɛvribɑːdi hæz hæd ðɛr oʊn ˈmuːvi/', '<span>Everybody''s</span><span>had</span><span pid="593" class="highlight highlight-c">their own</span><span>movie.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 391, 901.822, 903.28, 'And you haven''t had your own movie.', '而你还没有自己的电影。', '/ænd ju ˈhævənt hæd jɔːr oʊn ˈmuːvi/', '<span>And</span><span>you haven''t</span><span>had</span><span pid="594" class="highlight highlight-c">your own</span><span>movie.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 392, 903.28, 904.96, 'But I assume you''re going to have you own movie.', '但我猜你会有自己的电影。', '/bʌt aɪ əˈsuːm jɔːr ˈɡoʊɪŋ tə hæv jʊər oʊn ˈmuːvi/', '<span>But</span><span>I</span><span tid="50264" class="highlight highlight-a">assume</span><span>you''re</span><span pid="595" class="highlight highlight-d">going to</span><span>have</span><span>you</span><span>own</span><span>movie.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 393, 904.96, 905.59, 'No. That''s a lot of work.', '不，那工作量太大了。', '/noʊ ðæts ə lɑːt əv wɜːrk/', '<span>No.</span><span>That''s</span><span pid="596" class="highlight highlight-c">a lot of</span><span>work.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 394, 905.59, 906.994, 'I don''t know.', '我不知道。', '/aɪ doʊnt noʊ/', '<span>I</span><span>don''t</span><span>know.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 395, 906.994, 907.93, 'I don''t know.', '我不知道。', '/aɪ doʊnt noʊ/', '<span>I</span><span>don''t</span><span>know.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 396, 907.93, 909.4, 'JIMMY KIMMEL: It''s too much work?', '吉米·坎摩尔：工作量太大了？', '/ˈdʒɪmi ˈkɪməl ɪts tuː mʌtʃ wɜːrk/', '<span>JIMMY KIMMEL:</span><span>It''s</span><span pid="597" class="highlight highlight-c">too much</span><span>work?</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 397, 909.4, 910.09, 'Too many words.', '台词太多了。', '/tuː ˈmɛni wɜːrdz/', '<span pid="598" class="highlight highlight-c">Too many</span><span>words.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 398, 910.09, 911.26, 'What did [INAUDIBLE] say the other day?', '那天[听不清]说了什么？', '/wʌt dɪd ɪnˈɔːdəbl seɪ ðə ˈʌðər deɪ/', '<span>What</span><span>did</span><span>[INAUDIBLE]</span><span>say</span><span pid="599" class="highlight highlight-i">the other day?</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 399, 911.26, 912.343, 'We haven''t announced that!', '我们还没公布呢！', '/wiː hævənt əˈnaʊnst ðæt/', '<span>We</span><span>haven''t</span><span tid="50265" class="highlight highlight-a">announced</span><span>that!</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 400, 912.343, 914.62, 'I was like, yeah, but everyone''s talking about it.', '我当时想，是啊，但每个人都在谈论这件事。', '/aɪ wʌz laɪk, jɛə, bʌt ˈɛvriˌwʌnz ˈtɔːkɪŋ əˈbaʊt ɪt/', '<span>I</span><span pid="600" class="highlight highlight-i">was like</span><span>,</span><span>yeah</span><span>,</span><span>but</span><span>everyone</span><span>''s</span><span pid="601" class="highlight highlight-d">talking about</span><span>it</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 401, 914.62, 916.787, 'JIMMY KIMMEL: I have a weird true story to tell you.', '吉米·坎摩尔：我有一个离奇的真实故事要告诉你。', '/ˈdʒɪmi ˈkɪməl: aɪ hæv ə wɪrd truː stɔːri tuː tɛl juː/', '<span>JIMMY KIMMEL</span><span>:</span><span>I</span><span>have</span><span>a</span><span tid="50266" class="highlight highlight-a">weird</span><span>true</span><span>story</span><span pid="602" class="highlight highlight-d">to tell</span><span>you</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 402, 916.787, 923.5, 'Last night in my haze, as I was drifting in and out of sleep, I thought, what if Ant-Man just shrunk down', '昨晚在迷糊中，当我时睡时醒时，我想，如果蚁人缩小到微观尺寸，', '/læst naɪt ɪn maɪ heɪz, æz aɪ wʌz ˈdrɪftɪŋ ɪn ænd aʊt ʌv sliːp, aɪ θɔːt, wʌt ɪf ˈæntˌmæn dʒʌst ʃrʌŋk daʊn/', '<span>Last</span><span>night</span><span>in</span><span>my</span><span>haze,</span><span>as</span><span>I</span><span>was</span><span>drifting</span><span>in</span><span>and</span><span>out</span><span>of</span><span>sleep,</span><span>I</span><span>thought,</span><span>what</span><span>if</span><span>Ant-Man</span><span>just</span><span>shrunk</span><span>down</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 403, 923.5, 930.35, 'to a microscopic size and went into the veins of Thanos, and then messed up Thanos'' brain.', '进入灭霸的血管，然后搞乱灭霸的大脑。', '/tuː ə ˌmaɪkrəˈskɑːpɪk saɪz ænd wɛnt ˈɪntuː ðə veɪnz ʌv ˈθænɑːs, ænd ðɛn mɛst ʌp ˈθænɑːs breɪn/', '<span>to</span><span>a</span><span tid="50267" class="highlight highlight-a">microscopic</span><span>size</span><span>and</span><span pid="603" class="highlight highlight-d">went into</span><span>the</span><span tid="50268" class="highlight highlight-a">veins</span><span>of</span><span>Thanos</span><span>,</span><span>and</span><span>then</span><span pid="604" class="highlight highlight-d">messed up</span><span>Thanos</span><span>''</span><span>brain</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 404, 930.35, 937.87, 'And then this-- today I read that there is actually a theory that-- you know this one, Paul?', '然后——今天我看到实际上有一种理论——你知道这个吗，保罗？', '/ænd ðɛn ðɪs-- təˈdeɪ aɪ rɛd ðæt ðɛr ɪz ˈækʧuəli ə ˈθɪri-- juː noʊ ðɪs wʌn, pɔːl/', '<span>And</span><span>then</span><span>this</span><span>--</span><span>today</span><span>I</span><span tid="50269" class="highlight highlight-a">read</span><span>that</span><span>there</span><span>is</span><span tid="50270" class="highlight highlight-a">actually</span><span>a</span><span tid="50271" class="highlight highlight-a">theory</span><span>that</span><span>--</span><span>you</span><span>know</span><span>this</span><span>one</span><span>,</span><span>Paul</span><span>?</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 405, 937.87, 941.41, 'That Ant-Man will shrink down and go into Thanos'' butt.', '蚁人会缩小并进入灭霸的屁股。', '/ðæt ˈæntˌmæn wɪl ʃrɪŋk daʊn ænd goʊ ˈɪntuː ˈθænɑːs bʌt/', '<span>That</span><span tid="50272" class="highlight highlight-a">Ant-Man</span><span>will</span><span tid="50273" class="highlight highlight-a">shrink</span><span>down</span><span>and</span><span>go</span><span>into</span><span tid="50274" class="highlight highlight-a">Thanos</span><span>''</span><span tid="50275" class="highlight highlight-a">butt</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 406, 941.41, 942.31, 'Right?', '对吧？', '/raɪt/', '<span>Right</span><span>?</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 407, 942.31, 944.202, 'Yeah.', '是的。', '/jɛə/', '<span>Yeah</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 408, 944.202, 947.99, 'JIMMY KIMMEL: It seems less effective.', '这似乎没那么有效。', '/ɪt simz lɛs ɪˈfɛktɪv/', '<span>JIMMY KIMMEL:</span><span>It</span><span>seems</span><span>less</span><span tid="50276" class="highlight highlight-a">effective.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 409, 947.99, 950.352, 'Look, these lips are sealed.', '看，我的嘴很严。', '/lʊk, ðiːz lɪps ɑːr siːld/', '<span>Look,</span><span>these</span><span>lips</span><span>are</span><span tid="50277" class="highlight highlight-i">sealed.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 410, 950.352, 953.27, '[LAUGHING]', '[笑声]', '/ˈlæfɪŋ/', '<span>[LAUGHING]</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 411, 954.29, 955.37, 'Similar to your dream.', '和你的梦类似。', '/ˈsɪmələr tuː jɔːr driːm/', '<span>Similar</span><span>to</span><span>your</span><span>dream.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 412, 955.37, 956.31, 'One slight difference.', '有一点不同。', '/wʌn slaɪt ˈdɪfərəns/', '<span>One</span><span tid="50278" class="highlight highlight-a">slight</span><span>difference.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 413, 956.31, 959.84, '[LAUGHTER] Like how much Nyquil did you drink?', '[笑声] 你喝了多少奈奎尔？', '/laɪk haʊ mʌtʃ ˈnɪkwiːl dɪd juː drɪŋk/', '<span>[LAUGHTER]</span><span>Like</span><span>how</span><span>much</span><span tid="50279" class="highlight highlight-a">Nyquil</span><span>did</span><span>you</span><span>drink?</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 414, 959.84, 960.74, 'A lot.', '很多。', '/ə lɑːt/', '<span>A</span><span>lot.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 415, 960.74, 961.64, 'A lot.', '很多。', '/ə lɑːt/', '<span>A</span><span>lot.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 416, 961.64, 964.38, 'I was really losing my mind.', '我当时真的快疯了。', '/aɪ wʌz ˈrɪli ˈluzɪŋ maɪ maɪnd/', '<span>I</span><span>was</span><span>really</span><span>losing</span><span>my</span><span>mind.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 417, 964.38, 965.8, 'I am right now a little bit too.', '我现在也有点。', '/aɪ æm raɪt naʊ ə ˈlɪtəl bit tuː/', '<span>I</span><span>am</span><span>right</span><span>now</span><span>a</span><span>little</span><span>bit</span><span>too.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 418, 965.8, 966.7, 'OK.', '好的。', '/oʊ keɪ/', '<span>OK.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 419, 966.7, 971.272, 'So you guys have something special for our studio audience here tonight.', '所以你们今晚为我们的现场观众准备了特别的东西。', '/soʊ juː ɡaɪz hæv ˈsʌmθɪŋ ˈspeʃəl fɔːr ˈaʊər ˈstʌdi.oʊ ˈɔːdiəns hɪr təˈnaɪt/', '<span>So</span><span>you</span><span>guys</span><span>have</span><span>something</span><span>special</span><span>for</span><span>our</span><span>studio</span><span>audience</span><span>here</span><span>tonight.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 420, 971.272, 977.09, 'Who would like to make this-- Chris, why don''t you tell them what you have for them.', '谁愿意来——克里斯，你为什么不告诉他们你为他们准备了什么。', '/huː wʊd laɪk tuː meɪk ðɪs-- krɪs, waɪ doʊnt juː tɛl ðɛm wʌt juː hæv fɔːr ðɛm/', '<span>Who</span><span>would</span><span>like</span><span>to</span><span>make</span><span>this--</span><span>Chris,</span><span>why</span><span>don''t</span><span>you</span><span>tell</span><span>them</span><span>what</span><span>you</span><span>have</span><span>for</span><span>them.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 421, 977.09, 981.28, 'We''re going to give everybody here tonight tickets to Avengers at IMAX.', '我们将给今晚在场的每个人赠送《复仇者联盟》IMAX 版电影票。', '/wiːr ˈɡoʊɪŋ tuː ɡɪv ˈɛvribɑdi hɪr təˈnaɪt ˈtɪkɪts tuː əˈvɛndʒərz æt ˈaɪmæks/', '<span>We''re</span><span>going</span><span>to</span><span>give</span><span>everybody</span><span>here</span><span>tonight</span><span>tickets</span><span>to</span><span>Avengers</span><span>at</span><span>IMAX.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 422, 981.28, 982.18, 'Oh, my god.', '哦，我的天哪。', '/oʊ maɪ ɡɑd/', '<span>Oh,</span><span>my</span><span>god.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 423, 982.18, 985.168, '[APPLAUSE] JIMMY KIMMEL: So you guys get gifts.', '[掌声] 吉米·坎摩尔：所以你们得到了礼物。', '/soʊ juː ɡaɪz ɡɛt ɡɪfts/', '<span>[APPLAUSE]</span><span>JIMMY</span><span>KIMMEL:</span><span>So</span><span>you</span><span>guys</span><span>get</span><span>gifts.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 424, 989.152, 992.14, 'See that.', '看到了吧。', '/siː ðæt/', '<span>See</span><span>that</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 425, 992.14, 997.69, '[LAUGHING] Instead of-- the money I saved on your present.', '[笑] 而不是——我花在你礼物上的钱省下来的。', '/læfɪŋ ɪnˈstɛd əv-- ðə ˈmʌni aɪ seɪvd ɑn jər ˈprɛzənt/', '<span>[LAUGHING]</span><span pid="605" class="highlight highlight-c">Instead of</span><span>--</span><span>the</span><span>money</span><span>I</span><span tid="50280" class="highlight highlight-a">saved</span><span>on</span><span>your</span><span>present</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 426, 997.69, 999.85, 'Uh-huh.', '嗯哼。', '/ʌn hʌ/', '<span>Uh-huh</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 427, 999.85, 1005.4, 'So everyone in the audience, as if you weren''t going already, is going to see the Avengers in IMAX.', '所以，在场的每一位观众，好像你们本来不会去似的，都会去看IMAX版的《复仇者联盟》。', '/soʊ ˈɛvriˌwʌn ɪn ði ˈɔdiəns, æz ɪf ju wɜːrnt ˈgoʊɪŋ ɔːlˈrɛdi, ɪz ˈgoʊɪŋ tu siː ði əˈvɛndʒərz ɪn ˈaɪmæks/', '<span>So</span><span>everyone</span><span>in</span><span>the</span><span tid="50281" class="highlight highlight-a">audience</span><span>,</span><span pid="606" class="highlight highlight-i">as if</span><span>you</span><span>weren''t</span><span>going</span><span>already</span><span>,</span><span>is</span><span>going</span><span>to</span><span>see</span><span>the</span><span>Avengers</span><span>in</span><span>IMAX</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 428, 1005.4, 1006.47, 'Thanks guys.', '谢谢大家。', '/θæŋks gʌz/', '<span>Thanks</span><span>guys</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 429, 1006.47, 1008.58, 'Scarlett, Robert, Paul, and Chris.', '斯嘉丽、罗伯特、保罗和克里斯。', '/ˈskɑrlɪt, ˈrɑbərt, pɔːl, ænd krɪs/', '<span>Scarlett</span><span>,</span><span>Robert</span><span>,</span><span>Paul</span><span>,</span><span>and</span><span>Chris</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 430, 1008.58, 1013.6, 'The "Avengers End Game" opens in theaters, 3D and IMAX April 26.', '《复仇者联盟4：终局之战》将于4月26日以3D和IMAX形式在影院上映。', '/ði əˈvɛndʒərz ɛnd geɪm ˈoʊpənz ɪn ˈθɪətərz, θri di ænd ˈaɪmæks ˈeɪprəl ˈtwɛnti sɪks/', '<span>The</span><span>"Avengers End Game"</span><span tid="50282" class="highlight highlight-a">opens</span><span>in</span><span>theaters</span><span>,</span><span>3D</span><span>and</span><span>IMAX</span><span>April</span><span>26</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 431, 1013.6, 1015.66, 'We will be right back!', '我们马上回来！', '/wi wɪl bi raɪt bæk/', '<span>We</span><span>will</span><span>be</span><span>right</span><span>back</span><span>!</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 432, 1015.66, 1017.94, 'If you liked that video, click the Subscribe button.', '如果你喜欢那个视频，请点击订阅按钮。', '/ɪf juː laɪkt ðæt ˈvɪdioʊ, klɪk ðə səbˈskraɪb ˈbʌtən/', '<span>If</span><span>you</span><span tid="50283" class="highlight highlight-a">liked</span><span>that</span><span>video</span><span>,</span><span tid="50284" class="highlight highlight-a">click</span><span>the</span><span tid="50285" class="highlight highlight-a">Subscribe</span><span>button</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';
INSERT INTO subtitles (id, episode_id, index, start, "end", english, chinese, ipa, english_html)
SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM subtitles), e.id, 433, 1017.94, 1021.14, 'But only if you''re ready for commitment.', '但只有当你准备好承诺时才这样做。', '/bʌt ˈoʊnli ɪf jʊr ˈrɛdi fɔːr kəˈmɪtmənt/', '<span>But</span><span>only</span><span>if</span><span>you</span><span>''re</span><span tid="50286" class="highlight highlight-a">ready</span><span>for</span><span tid="50287" class="highlight highlight-a">commitment</span><span>.</span>'
FROM episodes e WHERE e.video_id = '2-5Q4-m4L9dvoac';

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

-- imported video_ids: i8tBrrjm1aoxSbc, 2-5Q4-m4L9dvoac
