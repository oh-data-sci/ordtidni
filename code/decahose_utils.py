import pyspark.sql.functions as sfunc
import pyspark.sql.types as stypes


# Used for picking from multiple possible tweet text data. Some fields may be truncated or empty compared to others, so picking the longest.
choose_longest_body_udf = sfunc.udf(
    lambda t1, t2: t1 if len(t1 or '') > len(t2 or '') else t2,
    stypes.StringType()
)

extract_id_udf = sfunc.udf(
    lambda t: int(t.split(':')[-1]),
    stypes.LongType()
)

# checks for an empty list (list of string)
clean_list_udf = sfunc.udf(
    lambda t: [] if not t or len(t) == 0 else t,
    stypes.ArrayType(stypes.StringType())
)

# extracts the first language in a list, or returns 'unknown'
extract_one_language_udf = sfunc.udf(
    lambda t: 'unknown' if not t or len(t) == 0 else t[0].lower(),
    stypes.StringType()
)

# gets the link hrefs from the bio field
extract_bio_links_udf = sfunc.udf(
    lambda t: [] if not t or len(t) == 0 else [l['href'] for l in t],
    stypes.ArrayType(stypes.StringType())
)


# gets the expanded URLs from a tweet
def extract_message_links(links):
    if not links or len(links) == 0:
        return []
    else:
        return [l['expanded_url'] for l in links]

extract_message_links_udf = sfunc.udf(
    lambda gnip, twtter_entities: extract_message_links(gnip) if gnip else extract_message_links(twtter_entities),
    stypes.ArrayType(stypes.StringType())
)

# gets the mentions from a tweet
extract_message_mentions_udf = sfunc.udf(
    lambda t: [] if not t or len(t) == 0 else [m['screen_name'] for m in t],
    stypes.ArrayType(stypes.StringType())
)


# gets the hashtags from a tweet
def pick_longest(a, b):
    if len(a or '') > len(b or ''):
        return a
    elif b:
        return b
    else:
        return []

extract_message_hashtags_udf = sfunc.udf(
    lambda t1, t2: [h['text'] for h in pick_longest(t1, t2)],
    stypes.ArrayType(stypes.StringType())
)


unknown_or_lower_case_udf = sfunc.udf(
    lambda t: 'unknown' if not t or len(t) == 0 else t.lower(),
    stypes.StringType()
)


def load_decahose_posts(decahose_dir, spark):
    '''
    This loads all JSON files under decahose_dir into spark,
    extracts just the POST entries (not retweets, likes etc),
    and reduces the data to a few fields.
    For speed, wrapping this in spark_utils.read_or_create_parquet is recommended.
    If you want more than actor ID / actor user name / tweet ID / body / post time then reuse this as an example maybe?
    '''
    decahose = spark.read.format('json')\
        .option('charset', 'utf-8')\
        .load(decahose_dir)
    return decahose.filter(
        sfunc.col('verb').isin(['post', 'share'])
    ).select(
        extract_id_udf(sfunc.col('id')).alias('tweet_id'),
        extract_id_udf(sfunc.col('actor.id')).alias('actor_id'),
        'actor.preferredUsername',
        'actor.displayName',
        'actor.summary',
        'actor.verified',
        'actor.followersCount',
        'actor.friendsCount',
        'generator',
        extract_one_language_udf(sfunc.col('actor.languages')).alias('actor_language'),
        extract_bio_links_udf(sfunc.col('actor.links')).alias('actor_links'),
        choose_longest_body_udf(sfunc.col('body'), sfunc.col('long_object.body')).alias('message'),
        'postedTime',
        unknown_or_lower_case_udf(sfunc.col('location.twitter_country_code')).alias('tweet_country_code'),
        extract_message_links_udf(sfunc.col('gnip.urls'), sfunc.col('twitter_entities.urls')).alias('message_urls'),
        extract_message_mentions_udf(sfunc.col('twitter_entities.user_mentions')).alias('message_mentions'),
        extract_message_hashtags_udf(
            sfunc.col('long_object.twitter_entities.hashtags'),
            sfunc.col('twitter_entities.hashtags')
        ).alias('message_hashtags')
    ).withColumnRenamed(
        'preferredUsername', 'actor_user_name'
    ).withColumnRenamed(
        'displayName', 'actor_display_name'
    ).withColumnRenamed(
        'summary', 'actor_bio'
    ).withColumnRenamed(
        'verified', 'actor_verified'
    ).withColumnRenamed(
        'followersCount', 'actor_followers_count'
    ).withColumnRenamed(
        'friendsCount', 'actor_friends_count'
    ).withColumnRenamed(
        'postedTime', 'posted_time'
    )
