package com.rajkumartimalsina.backend.ticket.repository;

import com.rajkumartimalsina.backend.ticket.entity.TicketEntity;
import com.rajkumartimalsina.backend.ticket.enums.TicketCategory;
import com.rajkumartimalsina.backend.ticket.enums.TicketStatus;
import jakarta.persistence.criteria.JoinType;
import jakarta.persistence.criteria.Predicate;
import org.springframework.data.jpa.domain.Specification;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class TicketSpecification {

    public static Specification<TicketEntity> withFilters(
            TicketStatus status,
            TicketCategory category,
            UUID customerId,
            String search
    ) {
        return (root, query, cb) -> {
            // Eager fetch customer to avoid N+1 queries when fetching data (not count queries)
            if (Long.class != query.getResultType() && long.class != query.getResultType()) {
                root.fetch("customer", JoinType.INNER);
            }

            List<Predicate> predicates = new ArrayList<>();

            if (status != null) {
                predicates.add(cb.equal(root.get("status"), status));
            }

            if (category != null) {
                predicates.add(cb.equal(root.get("category"), category));
            }

            if (customerId != null) {
                predicates.add(cb.equal(root.get("customer").get("id"), customerId));
            }

            if (search != null && !search.isBlank()) {
                String pattern = "%" + search.trim().toLowerCase() + "%";
                Predicate subjectLike = cb.like(cb.lower(root.get("subject")), pattern);
                Predicate customerEmailLike = cb.like(cb.lower(root.get("customer").get("email")), pattern);
                Predicate customerNameLike = cb.like(cb.lower(root.get("customer").get("name")), pattern);
                predicates.add(cb.or(subjectLike, customerEmailLike, customerNameLike));
            }

            return cb.and(predicates.toArray(new Predicate[0]));
        };
    }
}
