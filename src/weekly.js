require('dotenv').config()
const fs = require('fs')
const path = require('path')
const { S3Client, PutObjectCommand } = require('@aws-sdk/client-s3')

const s3 = new S3Client({ region: process.env.AWS_REGION })

const uploadDaily = async () => {
  const filePath = path.join(__dirname, 'file', 'dump.sql.tar.gz')
  const fileName = `${new Date().toISOString().replace(/[:.]/g, '-')}.tar.gz`
  const key = `weekly/${fileName}`

  const command = new PutObjectCommand({
    Bucket: process.env.S3_BUCKET_NAME,
    Key: key,
    Body: fs.createReadStream(filePath),
    ContentType: 'application/gzip',
  })

  try {
    await s3.send(command)
    console.log(`✅ Daily backup uploaded: ${key}`)
  } catch (error) {
    console.error('❌ Upload error:', error)
  }
}

uploadDaily()
