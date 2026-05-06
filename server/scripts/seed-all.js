/*
  Optional combined seed script for Member 1.

  What it does:
  1. Runs PostgreSQL schema file.
  2. Runs PostgreSQL seed file.
  3. Inserts MongoDB VideoSession and FrameAnalysis sample data.
  4. Creates a few Redis/Memurai temporary keys.

  Usage:
  1. Copy .env.example to .env and fill database passwords.
  2. npm install
  3. npm run seed
*/

require('dotenv').config();

const fs = require('fs');
const path = require('path');
const { Client } = require('pg');
const mongoose = require('mongoose');
const redis = require('redis');

const VideoSession = require('../src/models/mongo/VideoSession');
const FrameAnalysis = require('../src/models/mongo/FrameAnalysis');

const POSTGRES_CONFIG = {
  host: process.env.POSTGRES_HOST || 'localhost',
  port: Number(process.env.POSTGRES_PORT || 5432),
  database: process.env.POSTGRES_DB || 'proctoring_db',
  user: process.env.POSTGRES_USER || 'postgres',
  password: process.env.POSTGRES_PASSWORD || 'postgres'
};

const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/proctoring_db';
const REDIS_URL = process.env.REDIS_URL || 'redis://127.0.0.1:6379';

async function seedPostgres() {
  const client = new Client(POSTGRES_CONFIG);
  await client.connect();

  const schemaSql = fs.readFileSync(path.join(__dirname, '../postgres/01_schema.sql'), 'utf8');
  const seedSql = fs.readFileSync(path.join(__dirname, '../postgres/02_seed.sql'), 'utf8');

  await client.query(schemaSql);
  await client.query(seedSql);
  await client.end();

  console.log('[OK] PostgreSQL schema and sample data inserted');
}

async function seedMongo() {
  await mongoose.connect(MONGODB_URI);

  await FrameAnalysis.deleteMany({});
  await VideoSession.deleteMany({});

  const videoSession = await VideoSession.create({
    pgExamId: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    pgStudentId: '11111111-1111-1111-1111-111111111111',
    pgProctorId: '33333333-3333-3333-3333-333333333333',
    sessionKey: 'VS-DBMS-UNIT-TEST-001',
    status: 'live',
    startedAt: new Date('2026-05-10T04:30:00.000Z'),
    webrtcRoomId: 'room-dbms-unit-test-001',
    socketRoom: 'exam-aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    device: {
      browser: 'Chrome',
      operatingSystem: 'Windows 11',
      ipAddress: '127.0.0.1',
      userAgent: 'Sample user agent for testing'
    },
    mediaPermissions: {
      camera: true,
      microphone: true,
      screenShare: false
    },
    recording: {
      enabled: false,
      storageType: 'none',
      durationSeconds: 0
    },
    summary: {
      totalFramesAnalyzed: 2,
      suspiciousFrames: 1,
      highestSuspicionScore: 75,
      alertCount: 1
    },
    notes: 'Sample video session for DBMS project demo.'
  });

  await FrameAnalysis.insertMany([
    {
      videoSessionId: videoSession._id,
      pgExamId: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      pgStudentId: '11111111-1111-1111-1111-111111111111',
      frameNumber: 1,
      capturedAt: new Date('2026-05-10T04:35:00.000Z'),
      face: {
        faceCount: 1,
        mainFaceConfidence: 0.98,
        gazeDirection: 'center',
        lookingAway: false
      },
      objectDetection: {
        phoneDetected: false,
        bookDetected: false,
        extraPersonDetected: false
      },
      browserActivity: {
        tabSwitchDetected: false,
        copyPasteDetected: false,
        fullscreenExited: false
      },
      audio: {
        voiceDetected: false,
        multipleVoicesDetected: false
      },
      suspiciousScore: 5,
      flags: [],
      rawModelOutput: { model: 'rule-based-demo', version: '1.0' }
    },
    {
      videoSessionId: videoSession._id,
      pgExamId: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      pgStudentId: '11111111-1111-1111-1111-111111111111',
      frameNumber: 2,
      capturedAt: new Date('2026-05-10T04:40:00.000Z'),
      face: {
        faceCount: 1,
        mainFaceConfidence: 0.95,
        gazeDirection: 'left',
        lookingAway: true
      },
      objectDetection: {
        phoneDetected: true,
        bookDetected: false,
        extraPersonDetected: false
      },
      browserActivity: {
        tabSwitchDetected: false,
        copyPasteDetected: false,
        fullscreenExited: false
      },
      audio: {
        voiceDetected: false,
        multipleVoicesDetected: false
      },
      suspiciousScore: 75,
      flags: [
        {
          flagType: 'LOOKING_AWAY',
          severity: 'medium',
          message: 'Student looked away from screen.'
        },
        {
          flagType: 'PHONE_DETECTED',
          severity: 'high',
          message: 'Phone-like object detected in frame.'
        }
      ],
      rawModelOutput: { model: 'rule-based-demo', version: '1.0' }
    }
  ]);

  await mongoose.disconnect();
  console.log('[OK] MongoDB sample video session and frame analysis inserted');
}

async function seedRedis() {
  const client = redis.createClient({ url: REDIS_URL });
  await client.connect();

  const userId = '11111111-1111-1111-1111-111111111111';
  const examId = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
  const sampleSessionId = 'sample-video-session-id';

  await client.setEx(
    `auth:session:${userId}:token-abc`,
    7200,
    JSON.stringify({ role: 'student', email: 'aarav.student@example.com' })
  );

  await client.setEx(
    `exam:${examId}:student:${userId}:state`,
    5400,
    JSON.stringify({ status: 'in_progress', currentQuestion: 2, startedAt: '2026-05-10T04:30:00Z' })
  );

  await client.set(
    `lock:submit:${examId}:${userId}`,
    'locked',
    { NX: true, EX: 60 }
  );

  await client.setEx(
    `proctor:session:${sampleSessionId}:latest-frame`,
    600,
    JSON.stringify({ suspiciousScore: 75, flags: ['LOOKING_AWAY', 'PHONE_DETECTED'] })
  );

  await client.hIncrBy(`proctor:session:${sampleSessionId}:flag-count`, 'LOOKING_AWAY', 1);
  await client.hIncrBy(`proctor:session:${sampleSessionId}:flag-count`, 'PHONE_DETECTED', 1);
  await client.expire(`proctor:session:${sampleSessionId}:flag-count`, 90000);

  await client.sAdd(`proctor:exam:${examId}:connected-users`, userId);
  await client.expire(`proctor:exam:${examId}:connected-users`, 5400);

  await client.quit();
  console.log('[OK] Redis/Memurai sample keys inserted');
}

async function main() {
  try {
    await seedPostgres();
    await seedMongo();
    await seedRedis();
    console.log('[DONE] All sample data inserted successfully');
  } catch (error) {
    console.error('[ERROR] Seeding failed');
    console.error(error);
    process.exitCode = 1;
    try {
      await mongoose.disconnect();
    } catch (_) {
      // Ignore cleanup error.
    }
  }
}

main();
