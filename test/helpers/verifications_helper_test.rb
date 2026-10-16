require "test_helper"

class VerificationsHelperTest < ActionView::TestCase
    
  test "recent verification has no freshness warning" do
    verified_on = 1.month.ago.to_date

    assert_nil verification_freshness_label(verified_on)
  end

  test "verification older than six months has warning" do
    verified_on = 7.months.ago.to_date

    assert_match(
      /6か月以上/,
      verification_freshness_label(verified_on)
    )
  end

  test "verification older than twelve months has stronger warning" do
    verified_on = 13.months.ago.to_date

    assert_match(
      /1年以上/,
      verification_freshness_label(verified_on)
    )
  end
  
    
  
  
  test "detects explicit egg status conflict" do
    latest = Verification.new(
      egg_status: "egg_free",
      verified_on: Date.new(2026, 10, 1)
    )
  
    histories = [
      Verification.new(
        egg_status: "contains_egg",
        verified_on: Date.new(2026, 10, 1)
      )
    ]
  
    assert_equal :conflict,
                 verification_same_day_status(latest, histories)
  end
  
  test "detects uncertain egg status" do
    latest = Verification.new(
      egg_status: "egg_free",
      verified_on: Date.new(2026, 10, 1)
    )
  
    histories = [
      Verification.new(
        egg_status: "unknown",
        verified_on: Date.new(2026, 10, 1)
      )
    ]
  
    assert_equal :uncertain,
                 verification_same_day_status(latest, histories)
  end
  
  test "detects consistent egg status" do
    latest = Verification.new(
      egg_status: "egg_free",
      verified_on: Date.new(2026, 10, 1)
    )
  
    histories = [
      Verification.new(
        egg_status: "egg_free",
        verified_on: Date.new(2026, 10, 1)
      )
    ]
  
    assert_equal :consistent,
                 verification_same_day_status(latest, histories)
  end
  
  test "prioritizes explicit conflict over unknown" do
    latest = Verification.new(
      egg_status: "unknown",
      verified_on: Date.new(2026, 10, 1)
    )
  
    histories = [
      Verification.new(
        egg_status: "egg_free",
        verified_on: Date.new(2026, 10, 1)
      ),
      Verification.new(
        egg_status: "contains_egg",
        verified_on: Date.new(2026, 10, 1)
      )
    ]
  
    assert_equal :conflict,
                 verification_same_day_status(latest, histories)
  end
  
  test "ignores different verification dates" do
    latest = Verification.new(
      egg_status: "egg_free",
      verified_on: Date.new(2026, 10, 1)
    )
  
    histories = [
      Verification.new(
        egg_status: "contains_egg",
        verified_on: Date.new(2026, 9, 1)
      )
    ]
  
    assert_equal :consistent,
                 verification_same_day_status(latest, histories)
  end
  
  test "detects changed egg status across dates" do
    latest = Verification.new(
      egg_status: "contains_egg",
      verified_on: Date.new(2026, 10, 1)
    )
  
    histories = [
      Verification.new(
        egg_status: "egg_free",
        verified_on: Date.new(2026, 9, 1)
      )
    ]
  
    assert_equal :changed,
                 verification_history_status(latest, histories)
  end
  
  test "detects uncertain status across dates" do
    latest = Verification.new(
      egg_status: "egg_free",
      verified_on: Date.new(2026, 10, 1)
    )
  
    histories = [
      Verification.new(
        egg_status: "unknown",
        verified_on: Date.new(2026, 9, 1)
      )
    ]
  
    assert_equal :uncertain,
                 verification_history_status(latest, histories)
  end
  
  test "detects consistent status across dates" do
    latest = Verification.new(
      egg_status: "egg_free",
      verified_on: Date.new(2026, 10, 1)
    )
  
    histories = [
      Verification.new(
        egg_status: "egg_free",
        verified_on: Date.new(2026, 9, 1)
      )
    ]
  
    assert_equal :consistent,
                 verification_history_status(latest, histories)
  end
  
  test "returns consistent without previous history" do
    latest = Verification.new(
      egg_status: "egg_free",
      verified_on: Date.new(2026, 10, 1)
    )
  
    assert_equal :consistent,
                 verification_history_status(latest, [])
  end
  
  test "compares only the most recent previous verification" do
    latest = Verification.new(
      egg_status: "egg_free",
      verified_on: Date.new(2026, 10, 1)
    )
  
    histories = [
      Verification.new(
        egg_status: "egg_free",
        verified_on: Date.new(2026, 9, 1)
      ),
      Verification.new(
        egg_status: "contains_egg",
        verified_on: Date.new(2026, 5, 1)
      )
    ]
  
    assert_equal :consistent,
                 verification_history_status(latest, histories)
  end

  test "egg_status_badge renders label with status-specific class" do
    badge = egg_status_badge("egg_free")
    assert_includes badge, "卵不使用を確認"
    assert_includes badge, "egg-badge--egg_free"

    assert_includes egg_status_badge("contains_egg"), "egg-badge--contains_egg"
    assert_includes egg_status_badge("unknown"), "未確認"
  end

  test "egg_status_conflict_badge does not show a single egg status" do
    badge = egg_status_conflict_badge
    assert_includes badge, "egg-badge--conflict"
    assert_not_includes badge, "卵不使用"
  end
end
