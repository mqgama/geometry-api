class CircleCollisionValidator < ActiveModel::Validator
  def validate(record)
    return unless record.frame_id.present?
    return unless record.center_x.present? && record.center_y.present? && record.diameter.present?

    validate_fits_in_frame(record)
    validate_no_collision_with_other_circles(record)
  end

  private

  def validate_fits_in_frame(record)
    frame = record.frame
    return unless frame

    if record.left < frame.left
      record.errors.add(:center_x, "Círculo se estende além do limite esquerdo do frame")
    end

    if record.right > frame.right
      record.errors.add(:center_x, "Círculo se estende além do limite direito do frame")
    end

    if record.top > frame.top
      record.errors.add(:center_y, "Círculo se estende além do limite superior do frame")
    end

    if record.bottom < frame.bottom
      record.errors.add(:center_y, "Círculo se estende além do limite inferior do frame")
    end
  end

  def validate_no_collision_with_other_circles(record)
    return unless record.frame_id.present?

    Circle.where(frame_id: record.frame_id).where.not(id: record.id).find_each do |other_circle|
      if circles_collide_or_touch?(record, other_circle)
        record.errors.add(:base, "Círculo não pode colidir ou encostar em outro círculo (ID: #{other_circle.id})")
      end
    end
  end

  def circles_collide_or_touch?(circle1, circle2)
    distance = Math.sqrt(
      (circle1.center_x - circle2.center_x)**2 +
      (circle1.center_y - circle2.center_y)**2
    )

    distance <= (circle1.radius + circle2.radius)
  end
end
