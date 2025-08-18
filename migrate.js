#!/usr/bin/env node

/**
 * MongoDB Migration Script for Medium Blog Platform
 * 
 * This script sets up the initial database structure and sample data
 * for the Medium Blog application.
 */

const { MongoClient, ObjectId } = require('mongodb');
const bcrypt = require('bcryptjs');

// Configuration
const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/medium-blog';
const DB_NAME = 'medium-blog';

// Migration flag collection to track completed migrations
const MIGRATIONS_COLLECTION = 'migrations';
const MIGRATION_VERSION = 'v1.0.0';

class MigrationRunner {
    constructor() {
        this.client = null;
        this.db = null;
    }

    async connect() {
        console.log('🔗 Connecting to MongoDB...');
        this.client = new MongoClient(MONGO_URI);
        await this.client.connect();
        this.db = this.client.db(DB_NAME);
        console.log('✅ Connected to MongoDB');
    }

    async disconnect() {
        if (this.client) {
            await this.client.close();
            console.log('🔌 Disconnected from MongoDB');
        }
    }

    async hasRunMigration(version) {
        const migration = await this.db.collection(MIGRATIONS_COLLECTION).findOne({ version });
        return migration !== null;
    }

    async markMigrationComplete(version) {
        await this.db.collection(MIGRATIONS_COLLECTION).insertOne({
            version,
            completedAt: new Date(),
            description: 'Initial database setup with sample data'
        });
    }

    async createIndexes() {
        console.log('📊 Creating database indexes...');
        
        // Users collection indexes
        await this.db.collection('users').createIndex({ username: 1 }, { unique: true });
        await this.db.collection('users').createIndex({ email: 1 }, { unique: true });
        
        // Posts collection indexes
        await this.db.collection('posts').createIndex({ authorId: 1 });
        await this.db.collection('posts').createIndex({ published: 1 });
        await this.db.collection('posts').createIndex({ createdAt: -1 });
        await this.db.collection('posts').createIndex({ publishedAt: -1 });
        await this.db.collection('posts').createIndex({ tags: 1 });
        
        // Text index for search functionality
        await this.db.collection('posts').createIndex(
            { title: 'text', content: 'text', tags: 'text' },
            { name: 'posts_search_index' }
        );
        
        console.log('✅ Database indexes created');
    }

    async createSampleData() {
        console.log('📝 Creating sample data...');
        
        // Check if data already exists
        const existingUsers = await this.db.collection('users').countDocuments();
        if (existingUsers > 0) {
            console.log('⚠️  Sample data already exists, skipping...');
            return;
        }

        // Create sample users
        const hashedPassword = await bcrypt.hash('demo123', 10);
        
        const sampleUsers = [
            {
                _id: new ObjectId(),
                username: 'john_doe',
                email: 'john@example.com',
                password: hashedPassword,
                firstName: 'John',
                lastName: 'Doe',
                bio: 'Tech enthusiast and blogger passionate about web development.',
                avatar: null,
                roles: ['USER'],
                createdAt: new Date(),
                updatedAt: new Date()
            },
            {
                _id: new ObjectId(),
                username: 'jane_smith',
                email: 'jane@example.com',
                password: hashedPassword,
                firstName: 'Jane',
                lastName: 'Smith',
                bio: 'UX designer sharing insights about design and user experience.',
                avatar: null,
                roles: ['USER'],
                createdAt: new Date(),
                updatedAt: new Date()
            }
        ];

        await this.db.collection('users').insertMany(sampleUsers);

        // Create sample posts
        const now = new Date();
        const samplePosts = [
            {
                _id: new ObjectId(),
                title: 'Welcome to Medium Blog Platform',
                content: `
                    <h2>Getting Started</h2>
                    <p>Welcome to our Medium-like blogging platform! This is a sample post to help you get started.</p>
                    
                    <h3>Features</h3>
                    <ul>
                        <li>Rich text editor with formatting options</li>
                        <li>User authentication and profiles</li>
                        <li>Post creation, editing, and publishing</li>
                        <li>Reading lists and bookmarks</li>
                        <li>Comments and interactions</li>
                    </ul>
                    
                    <p>Feel free to explore the platform and start writing your own posts!</p>
                `,
                excerpt: 'A welcome post introducing the features of our blogging platform.',
                authorId: sampleUsers[0]._id.toString(),
                authorName: sampleUsers[0].username,
                published: true,
                publishedAt: now,
                coverImage: null,
                tags: ['welcome', 'getting-started', 'platform'],
                likeCount: 5,
                readCount: 15,
                commentCount: 2,
                likedBy: [],
                comments: [
                    {
                        id: new ObjectId().toString(),
                        content: 'Great introduction! Looking forward to using this platform.',
                        authorId: sampleUsers[1]._id.toString(),
                        authorName: sampleUsers[1].username,
                        authorAvatar: null,
                        createdAt: new Date(now.getTime() + 3600000) // 1 hour later
                    },
                    {
                        id: new ObjectId().toString(),
                        content: 'The features look amazing. Thanks for building this!',
                        authorId: sampleUsers[1]._id.toString(),
                        authorName: sampleUsers[1].username,
                        authorAvatar: null,
                        createdAt: new Date(now.getTime() + 7200000) // 2 hours later
                    }
                ],
                createdAt: now,
                updatedAt: now
            },
            {
                _id: new ObjectId(),
                title: 'The Art of Technical Writing',
                content: `
                    <h2>Why Technical Writing Matters</h2>
                    <p>Technical writing is more than just documentation—it's about making complex ideas accessible to everyone.</p>
                    
                    <h3>Key Principles</h3>
                    <ol>
                        <li><strong>Clarity</strong>: Use simple, clear language</li>
                        <li><strong>Structure</strong>: Organize content logically</li>
                        <li><strong>Audience</strong>: Know who you're writing for</li>
                        <li><strong>Examples</strong>: Use concrete examples</li>
                    </ol>
                    
                    <blockquote>
                        "The best technical writing is invisible—it gets the job done without getting in the way."
                    </blockquote>
                    
                    <p>Whether you're writing API documentation, user guides, or blog posts like this one, these principles will help you communicate more effectively.</p>
                `,
                excerpt: 'Exploring the principles of effective technical writing and communication.',
                authorId: sampleUsers[1]._id.toString(),
                authorName: sampleUsers[1].username,
                published: true,
                publishedAt: new Date(now.getTime() + 86400000), // 1 day later
                coverImage: null,
                tags: ['writing', 'technical-writing', 'communication'],
                likeCount: 12,
                readCount: 28,
                commentCount: 1,
                likedBy: [sampleUsers[0]._id.toString()],
                comments: [
                    {
                        id: new ObjectId().toString(),
                        content: 'Excellent tips! I especially agree with the point about knowing your audience.',
                        authorId: sampleUsers[0]._id.toString(),
                        authorName: sampleUsers[0].username,
                        authorAvatar: null,
                        createdAt: new Date(now.getTime() + 90000000) // ~1 day + 1 hour later
                    }
                ],
                createdAt: new Date(now.getTime() + 86400000),
                updatedAt: new Date(now.getTime() + 86400000)
            },
            {
                _id: new ObjectId(),
                title: 'Draft Post: My Journey into Web Development',
                content: `
                    <h2>The Beginning</h2>
                    <p>This is a draft post about my journey into web development...</p>
                    
                    <p><em>This is still a work in progress. I plan to add more sections about:</em></p>
                    <ul>
                        <li>Learning resources</li>
                        <li>Challenges faced</li>
                        <li>Key milestones</li>
                        <li>Advice for beginners</li>
                    </ul>
                `,
                excerpt: 'A personal story about getting started in web development (draft).',
                authorId: sampleUsers[0]._id.toString(),
                authorName: sampleUsers[0].username,
                published: false,
                publishedAt: null,
                coverImage: null,
                tags: ['web-development', 'journey', 'learning'],
                likeCount: 0,
                readCount: 3,
                commentCount: 0,
                likedBy: [],
                comments: [],
                createdAt: new Date(now.getTime() + 172800000), // 2 days later
                updatedAt: new Date(now.getTime() + 172800000)
            }
        ];

        await this.db.collection('posts').insertMany(samplePosts);
        console.log('✅ Sample data created');
        console.log(`   - Created ${sampleUsers.length} sample users`);
        console.log(`   - Created ${samplePosts.length} sample posts (${samplePosts.filter(p => p.published).length} published, ${samplePosts.filter(p => !p.published).length} draft)`);
        console.log('');
        console.log('📝 Sample Login Credentials:');
        console.log('   Username: john_doe | Password: demo123');
        console.log('   Username: jane_smith | Password: demo123');
    }

    async run() {
        try {
            await this.connect();

            // Check if migration has already been run
            if (await this.hasRunMigration(MIGRATION_VERSION)) {
                console.log(`✅ Migration ${MIGRATION_VERSION} has already been completed`);
                return;
            }

            console.log(`🚀 Running migration ${MIGRATION_VERSION}...`);
            console.log('');

            // Run migration steps
            await this.createIndexes();
            await this.createSampleData();
            
            // Mark migration as complete
            await this.markMigrationComplete(MIGRATION_VERSION);

            console.log('');
            console.log(`🎉 Migration ${MIGRATION_VERSION} completed successfully!`);
            console.log('');

        } catch (error) {
            console.error('❌ Migration failed:', error);
            process.exit(1);
        } finally {
            await this.disconnect();
        }
    }
}

// Check if required dependencies are available
async function checkDependencies() {
    try {
        require('mongodb');
        require('bcryptjs');
    } catch (error) {
        console.error('❌ Missing dependencies. Please install them:');
        console.error('npm install mongodb bcryptjs');
        process.exit(1);
    }
}

// Main execution
async function main() {
    console.log('🗄️  Medium Blog Platform - Database Migration');
    console.log('=============================================');
    console.log('');

    await checkDependencies();
    
    const migrationRunner = new MigrationRunner();
    await migrationRunner.run();
}

// Run if called directly
if (require.main === module) {
    main().catch(console.error);
}

module.exports = MigrationRunner;
