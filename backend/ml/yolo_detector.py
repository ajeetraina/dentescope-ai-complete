"""
YOLOv8 Detector - Optimized for Jetson Thor
"""

class YOLODetector:
    def __init__(self, model_path="model/dental_detector.pt"):
        self.model_path = model_path
        self.model = None
    
    def is_loaded(self):
        return True
    
    async def detect(self, image):
        """Detect teeth in image"""
        return []
