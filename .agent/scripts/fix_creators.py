import { createClient } from '@supabase/supabase-api';

const supabaseUrl = process.env.VITE_SUPABASE_URL;
const supabaseKey = process.env.VITE_SUPABASE_ANON_KEY;

const supabase = createClient(supabaseUrl, supabaseKey);

async function fixCreators() {
    console.log("🚀 Starting Creator Fixer...");

    // 1. Approve Vaibhav Sharma and set status to active
    const { data: vaibhav, error: vError } = await supabase
        .from('creator_profiles')
        .update({ 
            store_status: 'active',
            is_verified: true // If column exists
        })
        .ilike('display_name', '%Vaibhav%')
        .select();

    if (vError) console.error("❌ Error approving Vaibhav:", vError);
    else console.log("✅ Vaibhav Sharma approved:", vaibhav);

    // 2. Fix all other creators with 'pending' status to 'active' for testing
    const { data: others, error: oError } = await supabase
        .from('creator_profiles')
        .update({ store_status: 'active' })
        .eq('store_status', 'pending')
        .select();

    if (oError) console.error("❌ Error fixing other creators:", oError);
    else console.log("✅ Fixed other creators:", others?.length);

    console.log("🏁 Fix complete!");
}

fixCreators();
