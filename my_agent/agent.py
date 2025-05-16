from google.adk.agents import Agent
from google.adk.tools import google_search

root_agent = Agent(
    name="basic_agent",
    model="gemini-2.0-flash-exp",  # Use the appropriate model ID
    description="Basic agent to answer questions",
    instruction="You are a helpful assistant that provides accurate information.",
    tools=[google_search]
) 