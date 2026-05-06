const mongoose = require('mongoose');

const videoSessionSchema = new mongoose.Schema(
  {
    // PostgreSQL IDs are stored as strings because MongoDB cannot enforce foreign keys to PostgreSQL.
    pgExamId: {
      type: String,
      required: true,
      index: true,
      trim: true
    },
    pgStudentId: {
      type: String,
      required: true,
      index: true,
      trim: true
    },
    pgProctorId: {
      type: String,
      default: null,
      trim: true
    },

    sessionKey: {
      type: String,
      required: true,
      unique: true,
      trim: true
    },

    status: {
      type: String,
      enum: ['created', 'waiting', 'live', 'ended', 'flagged', 'reviewed'],
      default: 'created',
      index: true
    },

    startedAt: {
      type: Date,
      default: null
    },
    endedAt: {
      type: Date,
      default: null
    },

    webrtcRoomId: {
      type: String,
      default: null,
      trim: true
    },
    socketRoom: {
      type: String,
      default: null,
      trim: true
    },

    device: {
      browser: { type: String, default: null },
      operatingSystem: { type: String, default: null },
      ipAddress: { type: String, default: null },
      userAgent: { type: String, default: null }
    },

    mediaPermissions: {
      camera: { type: Boolean, default: false },
      microphone: { type: Boolean, default: false },
      screenShare: { type: Boolean, default: false }
    },

    recording: {
      enabled: { type: Boolean, default: false },
      storageType: {
        type: String,
        enum: ['none', 'local', 'cloud'],
        default: 'none'
      },
      fileUrl: { type: String, default: null },
      durationSeconds: { type: Number, default: 0, min: 0 }
    },

    summary: {
      totalFramesAnalyzed: { type: Number, default: 0, min: 0 },
      suspiciousFrames: { type: Number, default: 0, min: 0 },
      highestSuspicionScore: { type: Number, default: 0, min: 0, max: 100 },
      alertCount: { type: Number, default: 0, min: 0 }
    },

    notes: {
      type: String,
      default: null
    }
  },
  {
    timestamps: true,
    collection: 'video_sessions'
  }
);

// Usually one active proctoring session per student per exam.
videoSessionSchema.index({ pgExamId: 1, pgStudentId: 1 }, { unique: true });
videoSessionSchema.index({ status: 1, createdAt: -1 });

module.exports = mongoose.model('VideoSession', videoSessionSchema);
