# -*- coding: utf-8 -*-

require 'json'
require 'kyotocabinet'

class TwitterKCBase

  def initialize
    init_db_all
  end

  def close_all_db
    @dblist.map{ |db| close_db(db) }
  end

  def init_db_all
    @dblist = []
    @dblist << @stream_db = init_db('stream')
    @dblist << @user_db = init_db('user')
    @dblist << @userid_screenname_db = init_db('userid_screenname')
    @dblist << @screenname_userid_db = init_db('screenmae_userid')
    @dblist << @userid_tweetid_db = init_db('userid_tweetid')
  end

  def init_db(dbname)
    db = KyotoCabinet::DB::new
    unless db.open(dbname+'.kct', KyotoCabinet::DB::OWRITER | KyotoCabinet::DB::OCREATE)
      STDERR.printf("open error: %s\n", db.error)
    end
    return db
  end

  def close_db(db)
    unless db.close
      STDERR.printf("close error: %s\n", db.error)
    end
  end

end
