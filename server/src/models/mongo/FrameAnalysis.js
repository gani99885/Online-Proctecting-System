const mongoose = require('mongoose');

const frameAnalysisSchema = new mongoose.Schema(
  {
    videoSessionId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'VideoSession',
      required: true,
      index: true
    },

    // Denormalized PostgreSQL IDs for faster filtering in dashboard queries.
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

    frameNumber: {
      type: Number,
      required: true,
      min: 0
    },
    capturedAt: {
      type: Date,
      required: true,
      index: true
    },

    face: {
      faceCount: { type: Number, default: 0, min: 0 },
      mainFaceConfidence: { type: Number, default: null, min: 0, max: 1 },
      gazeDirection: {
        type: String,
        enum: ['center', 'left', 'right', 'up', 'down', 'unknown'],
        default: 'unknown'
      },
      lookingAway: { type: Boolean, default: false }
    },

    objectDetection: {
      phoneDetected: { type: Boolean, default: false },
      bookDetected: { type: Boolean, default: false },
      extraPersonDetected: { type: Boolean, default: false }
    },

    browserActivity: {
      tabSwitchDetected: { type: Boolean, default: false },
      copyPasteDetected: { type: Boolean, default: false },
      fullscreenExited: { type: Boolean, default: false }
    },

    audio: {
      voiceDetected: { type: Boolean, default: false },
      multipleVoicesDetected: { type: Boolean, default: false }
    },

    suspiciousScore: {
      type: Number,
      default: 0,
      min: 0,
      max: 100,
      index: true
    },

    flags: [
      {
        flagType: {
          type: String,
          enum: [
            'NO_FACE',
            'MULTIPLE_FACES',
            'LOOKING_AWAY',
            'PHONE_DETECTED',
            'BOOK_DETECTED',
            'TAB_SWITCH',
            'COPY_PASTE',
            'FULLSCREEN_EXIT',
            'VOICE_DETECTED',
            'MULTIPLE_VOICES'
          ],
          required: true
        },
        severity: {
          type: String,
          enum: ['low', 'medium', 'high'],
          required: true
        },
        message: {
          type: String,
          required: true
        }
      }
    ],

    snapshotUrl: {
      type: String,
      default: null
    },

    // Keeps raw analysis details flexible because AI/computer-vision output can change.
    rawModelOutput: {
      type: mongoose.Schema.Types.Mixed,
      default: {}
    }
  },
  {
    timestamps: true,
    collection: 'frame_analyses'
  }
);

frameAnalysisSchema.index({ videoSessionId: 1, capturedAt: 1 });
frameAnalysisSchema.index({ pgExamId: 1, pgStudentId: 1, capturedAt: 1 });
frameAnalysisSchema.index({ suspiciousScore: -1, capturedAt: -1 });
frameAnalysisSchema.index({ 'flags.flagType': 1 });

module.exports = mongoose.model('FrameAnalysis', frameAnalysisSchema);
