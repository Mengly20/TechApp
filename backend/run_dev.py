"""
Development server runner - Uses SQLite and in-memory cache
No PostgreSQL or Redis required
"""
import os
import sys
from pathlib import Path

# Set environment variables for dev mode
os.environ["DATABASE_URL"] = "sqlite:///./edtech_scanner.db"
os.environ["REDIS_URL"] = "memory://"
os.environ["SECRET_KEY"] = "dev-secret-key-2024"

sys.path.insert(0, str(Path(__file__).parent))

print("=" * 60)
print("EdTech Scanner Backend - Development Mode")
print("=" * 60)
print("Using SQLite database: ./edtech_scanner.db")
print("Using in-memory cache (no Redis required)")
print("=" * 60)

# Insert sample data
from app.models.equipment import Equipment
from app.core.database import SessionLocal, Base, engine

# Create all tables
Base.metadata.create_all(bind=engine)

def init_sample_data():
    db = SessionLocal()
    try:
        # Check if data already exists
        count = db.query(Equipment).count()
        if count > 0:
            print(f"Database already has {count} equipment items")
            return
        
        print("Initializing sample equipment data...")
        sample_equipment = [
            Equipment(
                class_name="microscope",
                name_en="Compound Microscope",
                category="Microscopy",
                description_en="An optical instrument with multiple lenses for magnifying small objects",
                usage_en="Used to observe cells, microorganisms, and other tiny specimens in detail",
                safety_info_en="Handle with care, avoid touching lenses, use proper lighting to prevent eye strain",
                tags=["optical", "magnification", "biology"]
            ),
            Equipment(
                class_name="beaker",
                name_en="Laboratory Beaker",
                category="Glassware",
                description_en="A cylindrical container with a flat bottom used for mixing and heating liquids",
                usage_en="Used for holding, mixing, and heating liquids in laboratory experiments",
                safety_info_en="Use heat-resistant beakers for heating, handle hot glassware with tongs",
                tags=["glassware", "container", "chemistry"]
            ),
            Equipment(
                class_name="test-tube",
                name_en="Test Tube",
                category="Glassware",
                description_en="A thin glass tube closed at one end, used for holding small amounts of liquid",
                usage_en="Used for chemical reactions, heating small amounts of substances",
                safety_info_en="Always point away from people when heating, use test tube holders",
                tags=["glassware", "chemistry", "reactions"]
            ),
            Equipment(
                class_name="flask",
                name_en="Erlenmeyer Flask",
                category="Glassware",
                description_en="A conical flask with a narrow neck, ideal for mixing and heating",
                usage_en="Used for titrations, mixing solutions, and heating liquids",
                safety_info_en="Handle with care when hot, avoid thermal shock",
                tags=["glassware", "mixing", "chemistry"]
            ),
            Equipment(
                class_name="bunsen-burner",
                name_en="Bunsen Burner",
                category="Heating",
                description_en="A gas burner used for heating and sterilization",
                usage_en="Used to heat substances, sterilize equipment, and perform flame tests",
                safety_info_en="Keep flammable materials away, tie back long hair, wear safety goggles",
                tags=["heating", "flame", "safety"]
            )
        ]
        
        for eq in sample_equipment:
            db.add(eq)
        
        db.commit()
        print(f"✓ Added {len(sample_equipment)} equipment items to database")
        
    except Exception as e:
        print(f"Error initializing data: {e}")
    finally:
        db.close()

# Initialize data
init_sample_data()

# Run the server
if __name__ == "__main__":
    import uvicorn
    print("\nStarting server on http://localhost:8000")
    print("API Documentation: http://localhost:8000/docs")
    print("Press CTRL+C to stop\n")
    
    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
        log_level="info"
    )
