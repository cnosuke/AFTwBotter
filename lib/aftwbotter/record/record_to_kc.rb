# -*- coding: utf-8 -*-
require 'json'
require 'kyotocabinet'

require './lib/aftwbotter/record/twitter_kc_base.rb'

class RecordToKC < TwitterKCBase

  def update(s)
    if s['text']
      set_stream_db(s, @stream_db)
      set_user_db(s, @user_db)
      set_userid_screenname_db(s, @userid_screenname_db)
      set_screenname_userid_db(s, @screenname_userid_db)
      set_userid_tweetid_db(s, @userid_tweetid_db)
    end
  end

  def set_userid_tweetid_db(s, db)
    uid = s['user'].fetch('id_str')
    sid = s['id_str']
    if db.get(uid)
      unless db.get(uid).split(',').include? sid
        db.store(uid, db.get(uid).to_s + ',' + sid.to_s)
      end
    else
      db.store(uid, sid)
    end
  end

  def set_userid_screenname_db(s, db)
    unless db.store(s['user'].fetch('id_str'), s['user'].fetch('screen_name'))
      STDERR.printf("set error: %s\n", db.error)
    end
  end

  def set_screenname_userid_db(s, db)
    unless db.store(s['user'].fetch('screen_name'), s['user'].fetch('id_str'))
      STDERR.printf("set error: %s\n", db.error)
    end
  end

  def set_user_db(s, db)
    unless db.store(s['user'].fetch('id_str'), s.to_json)
      STDERR.printf("set error: %s\n", db.error)
    end
  end

  def set_stream_db(s, db)
    unless db.get s['id_str']
      unless db.store(s['id_str'], s.to_json)
        STDERR.printf("set error: %s\n", db.error)
      end
    end
  end

end
