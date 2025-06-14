require('dotenv').config()
const fs = require('fs');
const { createClient } = require('@supabase/supabase-js')

const supabaseUrl = process.env.SUPABASE_URL
const supabaseAnonKey = process.env.SUPABASE_ANON_KEY
const supabaseBucket = process.env.SUPABASE_BUCKET

const supabase = createClient(supabaseUrl, supabaseAnonKey)

const uploadFile = async () => {
  // generate a file name with current date
  const fileName = `${new Date().toISOString()}.tar`
  const buf = fs.readFileSync(__dirname + '/file/dump.sql.tar.gz');

  const { data, error } = await supabase.storage
    .from(supabaseBucket)
    .upload(fileName, buf)

  // delete the file from the local directory
  fs.unlinkSync(__dirname + '/file/dump.sql.tar.gz')

  console.log('🚀 ~ file: index.js ~ line 13 ~ uploadFile ~ error', error)
  console.log('🚀 ~ file: index.js ~ line 15 ~ uploadFile ~ data', data)
}

uploadFile()
