require('dotenv').config()
const { S3Client, ListObjectsV2Command, DeleteObjectCommand } = require('@aws-sdk/client-s3')

const s3 = new S3Client({ region: process.env.AWS_REGION })
const bucket = process.env.S3_BUCKET_NAME

const cleanDailyFolder = async () => {
  try {
    const { Contents } = await s3.send(
      new ListObjectsV2Command({ Bucket: bucket, Prefix: 'daily/' })
    )

    if (!Contents || Contents.length === 0) {
      console.log('🧺 No daily backups to delete.')
      return
    }

    for (const file of Contents) {
      await s3.send(new DeleteObjectCommand({ Bucket: bucket, Key: file.Key }))
      console.log(`🗑️ Deleted: ${file.Key}`)
    }

    console.log('🧹 Daily folder cleanup complete.')
  } catch (err) {
    console.error('❌ Cleanup error:', err)
  }
}

cleanDailyFolder()
