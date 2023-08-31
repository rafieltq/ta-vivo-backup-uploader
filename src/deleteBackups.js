require('dotenv').config()
const fs = require('fs');
const { createClient } = require('@supabase/supabase-js')

const supabaseUrl = process.env.SUPABASE_URL
const supabaseAnonKey = process.env.SUPABASE_ANON_KEY
const supabaseBucket = process.env.SUPABASE_BUCKET

const supabase = createClient(supabaseUrl, supabaseAnonKey)

const deleteOldBackups = async () => {
    const { data, error } = await supabase.storage.from(supabaseBucket).list();
  
    if (error) {
      console.error('Error listing files:', error);
      return;
    }

    // count files in bucket
    console.log('🚀 ~ file: deleteBackups.js ~ line 20 ~ deleteOldBackups ~ files in bucket', data.length - 1)

    if (data.length -1 > 19) {
        const backupsToDelete = data.filter(file => {
            // Define your criteria for identifying old backups here
            // For example, you can compare the file name's date with a threshold
            const thresholdDate = new Date();
            const fileDate = new Date(file.name.split('.')[0]);
            return fileDate < thresholdDate;
          });
        
          console.log(backupsToDelete)
        
          for (const fileToDelete of backupsToDelete) {
            const { error: deleteError } = await supabase.storage
              .from(supabaseBucket)
              .remove([fileToDelete.name]);
        
            if (deleteError) {
              console.error('Error deleting file:', deleteError);
            } else {
              console.log('Deleted file:', fileToDelete.name);
            }
          }
    }

    console.log('🚀 ~ file: deleteBackups.js ~ line 47 ~ deleteOldBackups ~ Too few files for deleting', data.length - 1)

  };

  deleteOldBackups()
  