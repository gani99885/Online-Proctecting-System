from PIL import Image, ImageDraw, ImageFont
import os

W, H = 1800, 1100
img = Image.new('RGB', (W, H), 'white')
d = ImageDraw.Draw(img)

try:
    title_font = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf', 34)
    group_font = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf', 24)
    box_font = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf', 20)
    small_font = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf', 16)
except Exception:
    title_font = group_font = box_font = small_font = ImageFont.load_default()

# Colors
blue = (218, 232, 252)
blue_border = (108, 142, 191)
green = (213, 232, 212)
green_border = (130, 179, 102)
yellow = (255, 242, 204)
yellow_border = (214, 182, 86)
white = (255, 255, 255)
black = (40, 40, 40)
gray = (80, 80, 80)


def rounded_rect(xy, fill, outline, width=3, radius=22):
    d.rounded_rectangle(xy, radius=radius, fill=fill, outline=outline, width=width)


def centered_text(xy, text, font, fill=black, line_spacing=6):
    x1, y1, x2, y2 = xy
    lines = text.split('\n')
    heights = []
    widths = []
    for line in lines:
        bbox = d.textbbox((0, 0), line, font=font)
        widths.append(bbox[2]-bbox[0])
        heights.append(bbox[3]-bbox[1])
    total_h = sum(heights) + line_spacing*(len(lines)-1)
    y = y1 + ((y2-y1)-total_h)/2
    for line, tw, th in zip(lines, widths, heights):
        x = x1 + ((x2-x1)-tw)/2
        d.text((x, y), line, font=font, fill=fill)
        y += th + line_spacing


def label_group(xy, title, fill, outline):
    rounded_rect(xy, fill, outline, width=4, radius=28)
    x1, y1, x2, y2 = xy
    d.text((x1+25, y1+18), title, font=group_font, fill=black)


def box(xy, text, outline):
    rounded_rect(xy, white, outline, width=3, radius=18)
    centered_text(xy, text, box_font)


def arrow(start, end, label=None, label_offset=(0,0)):
    d.line([start, end], fill=gray, width=4)
    # arrow head
    import math
    angle = math.atan2(end[1]-start[1], end[0]-start[0])
    size = 16
    p1 = (end[0]-size*math.cos(angle-math.pi/6), end[1]-size*math.sin(angle-math.pi/6))
    p2 = (end[0]-size*math.cos(angle+math.pi/6), end[1]-size*math.sin(angle+math.pi/6))
    d.polygon([end, p1, p2], fill=gray)
    if label:
        lx = (start[0]+end[0])/2 + label_offset[0]
        ly = (start[1]+end[1])/2 + label_offset[1]
        bbox = d.textbbox((0,0), label, font=small_font)
        pad = 5
        d.rounded_rectangle((lx-5, ly-5, lx+(bbox[2]-bbox[0])+pad, ly+(bbox[3]-bbox[1])+pad), radius=6, fill=(255,255,255), outline=(220,220,220))
        d.text((lx, ly), label, font=small_font, fill=black)

# Title
centered_text((0, 25, W, 80), 'Online Proctoring System Architecture', title_font)

# Groups
client_xy = (60, 140, 470, 620)
backend_xy = (575, 140, 1125, 740)
data_xy = (1240, 140, 1740, 740)
label_group(client_xy, 'React Client', blue, blue_border)
label_group(backend_xy, 'Node.js Backend', green, green_border)
label_group(data_xy, 'Databases', yellow, yellow_border)

# Client boxes
student_xy = (105, 235, 425, 365)
proctor_xy = (105, 425, 425, 555)
box(student_xy, 'Student Browser\nExam UI\nCamera Capture\nAnswer Submission', blue_border)
box(proctor_xy, 'Proctor/Admin Browser\nLive Dashboard\nAlerts\nReports', blue_border)

# Backend boxes
rest_xy = (635, 225, 1065, 380)
ws_xy = (635, 430, 1065, 565)
worker_xy = (635, 610, 1065, 710)
box(rest_xy, 'Express REST API\nAuth + Exam + Answer APIs\nScore + Dispute APIs', green_border)
box(ws_xy, 'WebSocket Layer\nSocket.IO / WebRTC Signaling\nLive Alerts + Presence', green_border)
box(worker_xy, 'Frame Analysis Worker\nRule-based checks or ML placeholder\nCreates suspicious flags', green_border)

# Database boxes
pg_xy = (1295, 210, 1685, 360)
mongo_xy = (1295, 410, 1685, 545)
redis_xy = (1295, 595, 1685, 720)
box(pg_xy, 'PostgreSQL\nusers, exams, questions\nanswers, scores, disputes', yellow_border)
box(mongo_xy, 'MongoDB\nVideoSession\nFrameAnalysis\nFlexible proctoring metadata', yellow_border)
box(redis_xy, 'Redis / Memurai\nsessions, locks\nlive flags, pub/sub', yellow_border)

# Arrows client to backend
arrow((425, 275), (635, 285), 'REST requests', (-30,-40))
arrow((425, 500), (635, 500), 'Live dashboard', (-35,15))
arrow((425, 335), (635, 455), 'Live events', (-35,5))
arrow((425, 470), (635, 335), 'REST reports', (-35,-40))

# Backend to data
arrow((1065, 285), (1295, 285), 'SQL + ACID', (-25,-42))
arrow((1065, 340), (1295, 465), 'Session metadata', (-35,-15))
arrow((1065, 380), (1295, 650), 'Cache + locks', (-40,25))
arrow((1065, 500), (1295, 665), 'Pub/Sub', (-10,-15))
arrow((1065, 660), (1295, 480), 'Frame results', (-20,10))
arrow((1065, 700), (1295, 640), 'Alert publish', (0,10))

# WS to worker
arrow((850, 565), (850, 610), 'frame events', (20,-15))

# Footer: data responsibility
rounded_rect((160, 820, 1640, 1010), (248,248,248), (190,190,190), width=2, radius=18)
d.text((190, 845), 'Member 1 responsibility', font=group_font, fill=black)
footer = (
    '1. Architecture diagram: React client, Express REST API, WebSocket/WebRTC layer, PostgreSQL, MongoDB, Redis/Memurai.\n'
    '2. PostgreSQL schema: users, exams, questions, answers, scores, disputes, plus normalized question_options.\n'
    '3. MongoDB models: VideoSession and FrameAnalysis.\n'
    '4. Redis key pattern document: sessions, rate limits, exam state, submit locks, live proctoring flags, pub/sub channels.'
)
d.multiline_text((190, 890), footer, font=box_font, fill=black, spacing=8)

out = '/mnt/data/member1_proctoring_starter/architecture/architecture.png'
img.save(out, quality=95)
print(out)
