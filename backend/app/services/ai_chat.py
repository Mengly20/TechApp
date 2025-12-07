from typing import Dict, List, Any
import os

class GeminiChat:
    """Google Gemini AI chat service for equipment assistance"""
    
    def __init__(self):
        self.api_key = os.getenv("GEMINI_API_KEY", "")
        self.model = None
        
        # Try to initialize Gemini
        if self.api_key:
            try:
                import google.generativeai as genai
                genai.configure(api_key=self.api_key)
                self.model = genai.GenerativeModel('gemini-pro')
                print("Gemini AI initialized successfully")
            except Exception as e:
                print(f"Could not initialize Gemini: {e}")
                print("Using mock AI responses")
    
    def generate_response(
        self,
        equipment_context: Dict[str, Any],
        user_message: str,
        conversation_history: List[Dict[str, str]] = None
    ) -> str:
        """Generate AI response using Gemini or fallback to mock"""
        
        if self.model and self.api_key:
            try:
                # Build context prompt
                context = self._build_context(equipment_context)
                
                # Build conversation
                conversation_text = context + "\n\n"
                if conversation_history:
                    for msg in conversation_history:
                        role = "User" if msg.get("role") == "user" else "Assistant"
                        conversation_text += f"{role}: {msg.get('content', '')}\n"
                
                conversation_text += f"User: {user_message}\nAssistant:"
                
                # Generate response
                response = self.model.generate_content(conversation_text)
                return response.text
                
            except Exception as e:
                print(f"Gemini error: {e}, using fallback")
        
        # Fallback to mock responses
        return self._generate_mock_response(equipment_context, user_message)
    
    def _build_context(self, equipment_context: Dict[str, Any]) -> str:
        """Build context prompt for Gemini"""
        context = f"""You are an expert science equipment assistant helping students learn about laboratory equipment.

Current Equipment: {equipment_context['equipment_name']}
Category: {equipment_context['category']}
Description: {equipment_context['description']}
Usage: {equipment_context['usage']}
"""
        if equipment_context.get('safety_info'):
            context += f"Safety Information: {equipment_context['safety_info']}\n"
        
        context += """
Your role is to:
1. Answer questions about this equipment clearly and concisely
2. Provide educational information suitable for students
3. Emphasize safety when relevant
4. Be encouraging and supportive
5. Keep responses under 150 words

Please answer the user's questions naturally and helpfully."""
        
        return context
    
    def _generate_mock_response(
        self,
        equipment_context: Dict[str, Any],
        user_message: str
    ) -> str:
        """Generate mock AI response when Gemini is not available"""
        message_lower = user_message.lower()
        equipment_name = equipment_context['equipment_name']
        
        # Pattern matching for common questions
        if any(word in message_lower for word in ['use', 'how', 'operate', 'work']):
            return f"To use a {equipment_name}, {equipment_context['usage'][:200]}... Would you like more specific step-by-step instructions?"
        
        elif any(word in message_lower for word in ['safety', 'danger', 'hazard', 'careful']):
            if equipment_context.get('safety_info'):
                return f"Safety is very important! {equipment_context['safety_info'][:200]}... Always follow proper laboratory safety protocols."
            return f"When using {equipment_name}, always wear appropriate safety equipment including goggles and gloves. Follow your laboratory's safety guidelines and never work unsupervised."
        
        elif any(word in message_lower for word in ['clean', 'maintain', 'care']):
            return f"To properly maintain your {equipment_name}: 1) Clean thoroughly after each use with appropriate cleaning solutions, 2) Store in a safe, dry place away from extreme temperatures, 3) Inspect regularly for damage or wear, 4) Handle with care to prevent breakage. Regular maintenance ensures accuracy and longevity."
        
        elif any(word in message_lower for word in ['what', 'describe', 'explain']):
            return f"The {equipment_name} is a {equipment_context['category']} equipment. {equipment_context['description'][:200]}... It's commonly used in {equipment_context['category'].lower()} experiments and research."
        
        elif any(word in message_lower for word in ['buy', 'cost', 'price', 'where']):
            return f"I can provide educational information about {equipment_name}, but I don't have current pricing information. You can find this equipment at scientific supply stores, educational suppliers, or online marketplaces that specialize in laboratory equipment."
        
        else:
            return f"That's an interesting question about {equipment_name}! {equipment_context['description'][:150]}... Could you please be more specific about what aspect you'd like to learn about? I can help with usage, safety, maintenance, or general information."
